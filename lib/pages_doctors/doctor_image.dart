import 'package:flutter/material.dart';

class DoctorImage extends StatelessWidget {
  final String imgPath;

  const DoctorImage({super.key, required this.imgPath});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.green, width: 4),
        ),
        child: ClipOval(
          child: Image.asset(
            imgPath,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
