import 'dart:io';
import 'package:chat_app/utils/custom_timedout_exception.dart';
import 'package:chat_app/widgets/onBoarding/on_board_image_picker.dart';
import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({
    super.key,
    this.user,
    required this.onFinishOnBoarding,
  });
  final User? user;
  final Future<void> Function(User?, String?, String) onFinishOnBoarding;

  @override
  State<StatefulWidget> createState() {
    return _OnBoardingScreenState();
  }
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  bool _isLoading = false;
  File? _pickedImageFile;
  late CustomImageSource imageSource;
  final TextEditingController _nameController = TextEditingController();
  String? errorMsg;

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

  Future<TaskSnapshot> putFile(Reference storageRef) async {
    return storageRef
        .putFile(_pickedImageFile!)
        .timeout(const Duration(seconds: 30), onTimeout: () {
      throw CustomTimedOutException('File Upload request timed out');
    });
  }

  Future<String?> _uploadImage() async {
    String? imageUrl;
    try {
      final user = widget.user;
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child('${user!.uid}.jpg');
      await putFile(storageRef);
      imageUrl = await storageRef.getDownloadURL();
    } catch (e) {
      print("Error here $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Something went wrong when trying to upload your photo, but you can set it later once logged in',
            ),
            duration: Duration(seconds: 10),
          ),
        );
      }
    }
    return imageUrl;
  }

  bool isNameValid(String name) {
    if (name.trim().isEmpty) {
      setState(() {
        errorMsg = 'Name is requied';
      });
      return false;
    }

    if (name.trim().length < 3) {
      setState(() {
        errorMsg = 'Name should be atleast 3 characters long';
      });
      return false;
    }

    return true;
  }

  void _submitHandler() async {
    final name = _nameController.text;

    if (!isNameValid(name)) return;

    setState(() {
      errorMsg = null;
      _isLoading = true;
    });

    String? imgUrl;
    if (_pickedImageFile != null) {
      imgUrl = await _uploadImage();
    }

    await widget.onFinishOnBoarding(widget.user, imgUrl, _nameController.text);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Setup your profile"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 20, bottom: 25),
              width: double.infinity,
              child: OnBoardingImagePicker(
                pickedImageFile: _pickedImageFile,
                isUploading: _isLoading,
                onSelectImageSource: onSelectImageSource,
              ),
            ),
            TextField(
              decoration: InputDecoration(
                label: const Text('Name'),
                errorText: errorMsg,
              ),
              controller: _nameController,
              enabled: !_isLoading,
            ),
            Container(
              margin: const EdgeInsets.only(top: 30),
              child: _isLoading
                  ? const SizedBox(
                      height: 25,
                      width: 25,
                      child: CircularProgressIndicator(),
                    )
                  : ElevatedButton.icon(
                      onPressed: _isLoading ? null : _submitHandler,
                      icon: const Icon(Icons.check),
                      label: const Text('Done'),
                    ),
            )
          ],
        ),
      ),
    );
  }
}
