import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:flutter/material.dart';

class ImageSourceSelector extends StatelessWidget {
  final void Function(CustomImageSource source) onSelectImageSource;
  const ImageSourceSelector({super.key, required this.onSelectImageSource});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30, left: 10, right: 10, bottom: 20),
      child: SizedBox(
        width: double.infinity,
        height: 150,
        child: Column(
          children: [
            Text(
              'Pick a source',
              style:
                  Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 17),
            ),
            const SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    IconButton.filledTonal(
                      onPressed: () =>
                          onSelectImageSource(CustomImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      style: IconButton.styleFrom(
                        iconSize: 50,
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const Text('Camera'),
                  ],
                ),
                const SizedBox(
                  width: 20,
                ),
                Column(
                  children: [
                    IconButton.filledTonal(
                      onPressed: () =>
                          onSelectImageSource(CustomImageSource.gallery),
                      icon: const Icon(Icons.photo),
                      style: IconButton.styleFrom(
                        iconSize: 50,
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const Text('Gallery'),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
