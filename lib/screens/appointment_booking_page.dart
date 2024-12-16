import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:transparent_image/transparent_image.dart';

class AppointmentBookingPage extends StatefulWidget {
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
  _AppointmentBookingPageState createState() => _AppointmentBookingPageState();
}

class _AppointmentBookingPageState extends State<AppointmentBookingPage> {
  String? selectedDay;
  String? selectedTime;

  Future<List<String>> fetchWorkingDays(
      String clinicId, String doctorId) async {
    var doctorDoc = await FirebaseFirestore.instance
        .collection('clinics')
        .doc(clinicId)
        .collection('doctors')
        .doc(doctorId)
        .get();

    if (doctorDoc.exists) {
      Map<String, dynamic> doctorData = doctorDoc.data()!;
      List<String> workingDays = List<String>.from(doctorData['working_days']);
      return workingDays;
    } else {
      throw Exception('Doctor not found');
    }
  }

  // حجز الموعد في Firebase
  Future<void> bookAppointment() async {
    if (selectedDay != null && selectedTime != null) {
      try {
        // إرسال بيانات الموعد إلى Firebase
        await FirebaseFirestore.instance.collection('appointments').add({
          'doctorId': widget.doctorId,
          'clinicId': widget.clinicId,
          'doctorName': widget.doctorName,
          'patientName': 'Patient Name', // يجب استبداله باسم المريض
          'date': selectedDay,
          'time': selectedTime,
        });

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Appointment booked successfully!')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error booking appointment')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a day and time')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinic Information'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        // Adding scroll functionality
        child: Stack(
          children: [
            Positioned.fill(
              child: FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: widget.clinicImageUrl,
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Doctor's card
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: FadeInImage.memoryNetwork(
                              placeholder: kTransparentImage,
                              image: widget.doctorImageUrl,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.doctorName,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.doctorSpecialty,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${widget.experienceYears} years of experience',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Working Days:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  FutureBuilder<List<String>>(
                    future: fetchWorkingDays(widget.clinicId, widget.doctorId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('No working days available.',
                            style: TextStyle(color: Colors.white));
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: snapshot.data!
                            .map((day) => GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedDay = day;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0),
                                    child: Text(
                                      day,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: selectedDay == day
                                            ? Colors.blue
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                ))
                            .toList(),
                      );
                    },
                  ),
                  if (selectedDay != null) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Available Times:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // عرض الأوقات المتاحة (نصف ساعة)
                    for (var i = 9; i < 17; i++) ...[
                      for (var j = 0; j < 2; j++) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedTime = '${i}:${j == 0 ? "00" : "30"}';
                              });
                            },
                            child: Text(
                              '${i}:${j == 0 ? "00" : "30"}',
                              style: TextStyle(
                                fontSize: 14,
                                color: selectedTime ==
                                        '${i}:${j == 0 ? "00" : "30"}'
                                    ? Colors.blue
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ]
                    ],
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: bookAppointment,
                      child: const Text('Book Appointment'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
