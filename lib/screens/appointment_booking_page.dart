import 'package:flutter/material.dart';

class AppointmentBookingPage extends StatelessWidget {
  final String doctorName;
  final String doctorSpecialty;
  final int experienceYears;
  final String clinicImageUrl;
  final String doctorImageUrl;
  final String clinicId;
  final String doctorId;

  const AppointmentBookingPage({
    super.key,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.experienceYears,
    required this.clinicImageUrl,
    required this.doctorImageUrl,
    required this.clinicId,
    required this.doctorId,
  });

  @override
  Widget build(BuildContext context) {
    // استخدم هذه المتغيرات لعرض معلومات الطبيب
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text(doctorName),
            Text(doctorSpecialty),
            Text(experienceYears.toString()),
            Image.network(doctorImageUrl),
          ],
        ),
      ),
    );
  }
}
