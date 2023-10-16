import 'dart:io';
import 'package:chat_app/widgets/image_source_selector.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum CustomImageSource {
  camera,
  gallery,
}

class UserImagePicker extends StatefulWidget {
  final User? user;
  final Future<void> Function(String) onFinishOnBoarding;
  final void Function(bool) setLoading;
  const UserImagePicker({
    super.key,
    this.user,
    required this.onFinishOnBoarding,
    required this.setLoading,
  });

  @override
  State<UserImagePicker> createState() {
    return _UserImagePickerState();
  }
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImageFile;

  bool _isUploading = false;

  void _uploadImage() async {
    setState(() {
      _isUploading = true;
    });
    widget.setLoading(true);
    final user = widget.user;
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('user_images')
        .child('${user!.uid}.jpg');

    await storageRef.putFile(_pickedImageFile!);

    final imageUrl = await storageRef.getDownloadURL();

    await widget.onFinishOnBoarding(imageUrl);

    if (context.mounted) {
      setState(() {
        _isUploading = false;
      });
      widget.setLoading(false);
    }
  }

  void onSelectImageSource(CustomImageSource source) async {
    imageSource = source;

    Navigator.pop(context);
    if (imageSource == CustomImageSource.camera) {
      final pickedImage = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 250,
        maxHeight: 250,
      );

      if (pickedImage == null) return;

      setState(() {
        _pickedImageFile = File(pickedImage.path);
      });
    }
  }

  late CustomImageSource imageSource;

  void _pickImage() {
    if (_isUploading) return;

    showModalBottomSheet(
        context: context,
        builder: (context) {
          return ImageSourceSelector(
            onSelectImageSource: onSelectImageSource,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stackContents = [];

    if (_pickedImageFile != null) {
      stackContents.add(CircleAvatar(
        radius: 40,
        foregroundImage: FileImage(_pickedImageFile!),
      ));
    }

    if (_pickedImageFile != null && _isUploading) {
      stackContents.add(
        Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(222, 158, 158, 158),
            borderRadius: BorderRadius.circular(400),
          ),
          alignment: Alignment.center,
          child: const SizedBox(
            height: 25,
            width: 25,
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return _pickedImageFile == null
        ? Container(
            width: 250,
            height: 250,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: DottedBorder(
              borderType: BorderType.Circle,
              radius: const Radius.circular(10),
              dashPattern: const [7, 10],
              strokeWidth: 1,
              child: InkWell(
                borderRadius: BorderRadius.circular(800),
                onTap: _pickImage,
                child: Container(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Pick your profile photo',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        : Column(
            children: [
              SizedBox(
                width: 250,
                height: 250,
                child: InkWell(
                  onTap: _pickImage,
                  borderRadius: BorderRadius.circular(400),
                  child: Stack(
                    alignment: Alignment.center,
                    fit: StackFit.expand,
                    children: stackContents,
                  ),
                ),
              ),
              Visibility(
                visible: !_isUploading,
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: TextButton.icon(
                    onPressed: _uploadImage,
                    icon: const Icon(Icons.done),
                    label: const Text("Continue"),
                  ),
                ),
              ),
            ],
          );
  }
}
