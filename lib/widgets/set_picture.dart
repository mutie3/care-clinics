import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SetProfilePicture extends StatefulWidget {
  final Function(File) onImagePicked;
  const SetProfilePicture({required this.onImagePicked, super.key});

  @override
  State<SetProfilePicture> createState() => _SetProfilePictureState();
}

class _SetProfilePictureState extends State<SetProfilePicture> {
  String image = '';

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        image = pickedFile.path;
      });
      widget.onImagePicked(File(image));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => pickImage(ImageSource.gallery),
      child: CircleAvatar(
        radius: 60,
        backgroundImage: image.isEmpty
            ? const AssetImage('images/patient.png')
            : FileImage(File(image)) as ImageProvider,
      ),
    );
  }
}
