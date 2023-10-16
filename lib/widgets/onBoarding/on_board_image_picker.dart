import 'dart:io';

import 'package:chat_app/widgets/image_source_selector.dart';
import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

class OnBoardingImagePicker extends StatelessWidget {
  const OnBoardingImagePicker({
    super.key,
    required this.pickedImageFile,
    required this.isUploading,
    required this.onSelectImageSource,
  });

  final File? pickedImageFile;
  final bool isUploading;
  final void Function(CustomImageSource) onSelectImageSource;

  @override
  Widget build(BuildContext context) {
    void pickImage() {
      if (isUploading) return;

      showModalBottomSheet(
        context: context,
        builder: (context) {
          return ImageSourceSelector(
            onSelectImageSource: onSelectImageSource,
          );
        },
      );
    }

    Widget imageHolder = DottedBorder(
      borderType: BorderType.Circle,
      dashPattern: const [7, 10],
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(250)),
        onTap: isUploading ? null : pickImage,
        child: SizedBox(
          width: 250,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
                color: Colors.grey.shade400,
              ),
              const SizedBox(
                height: 15,
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
    );

    if (pickedImageFile != null) {
      imageHolder = SizedBox(
        height: 250,
        width: 250,
        child: InkWell(
          onTap: isUploading ? null : pickImage,
          borderRadius: const BorderRadius.all(Radius.circular(250)),
          child: CircleAvatar(
            radius: 250,
            foregroundImage: FileImage(pickedImageFile!),
          ),
        ),
      );
    }

    return Container(
      height: 250,
      width: 250,
      margin: const EdgeInsets.only(bottom: 20),
      alignment: Alignment.center,
      child: imageHolder,
    );
  }
}
