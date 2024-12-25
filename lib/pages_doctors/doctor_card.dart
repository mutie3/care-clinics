import 'package:care_clinic/constants/theme_dark_mode.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DoctorCard extends StatelessWidget {
  final String imgPath;
  final String doctorName;
  final String doctorSpeciality;
  final VoidCallback onTap;

  const DoctorCard({
    super.key,
    required this.imgPath,
    required this.doctorName,
    required this.doctorSpeciality,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return GestureDetector(
          onTap: onTap,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            elevation: 6.0,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[800]
                : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // صورة العيادة باستخدام NetworkImage
                  Container(
                    height: 100,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: Image.network(
                        imgPath,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.broken_image,
                              size: 50, color: Colors.grey);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 40.0),

                  // اسم العيادة
                  Text(
                    doctorName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
