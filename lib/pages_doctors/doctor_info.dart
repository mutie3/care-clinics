import 'package:flutter/material.dart';

class DoctorInfo extends StatelessWidget {
  final String doctorName;
  final String doctorSpeciality;
  final String rating;

  const DoctorInfo({
    super.key,
    required this.doctorName,
    required this.doctorSpeciality,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                doctorName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 5),
                Text(
                  rating,
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          doctorSpeciality,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
