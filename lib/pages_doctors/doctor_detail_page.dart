import 'package:care_clinic/widgets/video.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:care_clinic/constants/colors_page.dart';
import 'package:care_clinic/constants/theme_dark_mode.dart';
import 'package:url_launcher/url_launcher.dart';
import 'date_picker_widget.dart';

class DoctorDetailPage extends StatefulWidget {
  final String clinicId;
  final String imgPath;
  final String doctorName;
  final String doctorSpeciality;
  final String rating;
  final double latitude;
  final double longitude;

  const DoctorDetailPage({
    super.key,
    required this.clinicId,
    required this.imgPath,
    required this.doctorName,
    required this.doctorSpeciality,
    required this.rating,
    required this.latitude,
    required this.longitude,
  });

  @override
  _DoctorDetailPageState createState() => _DoctorDetailPageState();
}

class _DoctorDetailPageState extends State<DoctorDetailPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  DateTime selectedDate = DateTime.now();
  int? selectedDoctorIndex;
  String? selectedTime;
  List<Map<String, dynamic>> doctors = [];
  bool isLoading = true;
  List<Map<String, dynamic>> appointments = [];
  String clinicPhoneNumber = '';
  String? patientFirstName;
  String? patientLastName;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  Future<void> _fetchInitialData() async {
    await Future.wait([
      _fetchClinicData(),
      _fetchDoctors(),
      _fetchUserData(),
    ]);
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchUserData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        String uid = currentUser.uid;
        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (userDoc.exists) {
          setState(() {
            patientFirstName = userDoc['firstName'] as String?;
            patientLastName = userDoc['lastName'] as String?;
          });
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _fetchClinicData() async {
    try {
      final clinicSnapshot = await FirebaseFirestore.instance
          .collection('clinics')
          .doc(widget.clinicId)
          .get();
      if (clinicSnapshot.exists) {
        setState(() {
          clinicPhoneNumber = clinicSnapshot.data()?['phone'] ?? '';
        });
      }
    } catch (e) {
      print('Error fetching clinic data: $e');
    }
  }

  Future<void> _fetchDoctors() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('clinics')
          .doc(widget.clinicId)
          .collection('doctors')
          .get();
      setState(() {
        doctors = querySnapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  'name': doc.data()['name'] ?? 'No Name',
                  'specialty': doc.data()['specialty'] ?? 'No Specialty',
                  'image_url': doc.data()['image_url'] ?? '',
                })
            .toList();
      });
    } catch (e) {
      print('Error fetching doctors: $e');
    }
  }

  Future<void> _fetchAppointments() async {
    if (selectedDoctorIndex == null) return;

    try {
      final doctorId = doctors[selectedDoctorIndex!]['id'];
      final querySnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .get();
      setState(() {
        appointments = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      print('Error fetching appointments: $e');
    }
  }

  void _onDoctorSelected(int index) {
    setState(() {
      selectedDoctorIndex = index;
      selectedTime = null;
      appointments = [];
    });
    _fetchAppointments();
    _controller.forward();
  }

  Future<void> _openMap() async {
    final Uri url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${widget.latitude},${widget.longitude}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not open the map.';
    }
  }

  Future<void> _makeCall(String phoneNumber) async {
    final Uri url = Uri.parse('tel:0$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not make the call.';
    }
  }

  bool isTimeSlotBooked(String time) {
    return appointments.any((appointment) =>
        appointment['time'] == time &&
        DateTime.parse(appointment['date']).isAtSameMomentAs(selectedDate));
  }

  void _makeAppointment() {
    if (selectedDoctorIndex == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a doctor, date, and time."),
        ),
      );
      return;
    }

    final selectedDoctor = doctors[selectedDoctorIndex!];
    final appointment = {
      'doctorName': selectedDoctor['name'],
      'doctorId': selectedDoctor['id'],
      'clinicId': widget.clinicId,
      'date': selectedDate.toIso8601String(),
      'time': selectedTime,
      'patientName':
          '${patientFirstName ?? 'Unknown'} ${patientLastName ?? ''}',
    };

    FirebaseFirestore.instance
        .collection('appointments')
        .add(appointment)
        .then((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => VideoPage()),
      );
    }).catchError((error) {
      print('Error making appointment: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to make appointment. Try again."),
        ),
      );
    });
  }

  Widget _buildDoctorCardContent(Map<String, dynamic> doctor) {
    final String? imageUrl = doctor['image_url'];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 25,
          backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
              ? NetworkImage(imageUrl)
              : const AssetImage('images/R.png') as ImageProvider,
        ),
        const SizedBox(height: 5),
        Text(
          doctor['name'],
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          doctor['specialty'],
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  List<String> _generateTimeSlots() {
    return List<String>.generate(8, (index) {
      final time = TimeOfDay(hour: 9 + index, minute: 0);
      return time.format(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            // title: Text(widget.doctorName,
            //     style: const TextStyle(
            //         color: Colors.white, fontWeight: FontWeight.bold)),
            centerTitle: true,
            backgroundColor: themeProvider.isDarkMode
                ? AppColors.textBox
                : AppColors.primaryColor,
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: (widget.imgPath.isNotEmpty)
                                  ? NetworkImage(widget.imgPath)
                                  : const AssetImage('images/R.png')
                                      as ImageProvider,
                            ),
                            const SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.doctorName,
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .start, // Align the buttons to the start
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: _openMap,
                                        icon: const Icon(Icons.location_on,
                                            size: 20),
                                        label: const Text(
                                          'موقع',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              themeProvider.isDarkMode
                                                  ? AppColors.textBox
                                                  : AppColors.primaryColor,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 15),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                30), // Rounded corners
                                          ),
                                          elevation:
                                              5, // Adds shadow for better depth
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      ElevatedButton.icon(
                                        onPressed: () =>
                                            _makeCall(clinicPhoneNumber),
                                        icon: const Icon(Icons.phone, size: 20),
                                        label: const Text(
                                          'اتصال',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              themeProvider.isDarkMode
                                                  ? AppColors.textBox
                                                  : AppColors.primaryColor,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 15),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                30), // Rounded corners
                                          ),
                                          elevation:
                                              5, // Adds shadow for better depth
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(color: Colors.black),
                      const SizedBox(height: 5),
                      const Align(
                        alignment: Alignment
                            .bottomLeft, // Aligns the text to the bottom left
                        child: Text(
                          'Doctors: ',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 20),
                      doctors.isNotEmpty
                          ? SizedBox(
                              height: 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: doctors.length,
                                itemBuilder: (context, index) {
                                  final doctor = doctors[index];
                                  bool isSelected =
                                      selectedDoctorIndex == index;

                                  return GestureDetector(
                                    onTap: () => _onDoctorSelected(index),
                                    child: Card(
                                      color: isSelected
                                          ? Colors.blueAccent.withOpacity(0.5)
                                          : Colors.white,
                                      child: _buildDoctorCardContent(doctor),
                                    ),
                                  );
                                },
                              ),
                            )
                          : const Text('No doctors available'),
                      const SizedBox(height: 20),
                      SizeTransition(
                        sizeFactor: _animation,
                        axisAlignment: -1.0,
                        child: Column(
                          children: [
                            DatePickerWidget(
                              selectedDate: selectedDate,
                              onSelectDate: (date) {
                                setState(() => selectedDate = date);
                                _fetchAppointments();
                              },
                            ),
                            const SizedBox(height: 20),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: _generateTimeSlots()
                                  .map(
                                    (time) => ElevatedButton(
                                      onPressed: isTimeSlotBooked(time)
                                          ? null
                                          : () {
                                              setState(
                                                  () => selectedTime = time);
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isTimeSlotBooked(time)
                                            ? Colors.red
                                            : (selectedTime == time
                                                ? Colors.green
                                                : null),
                                      ),
                                      child: Text(time),
                                    ),
                                  )
                                  .toList(),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _makeAppointment,
                              child: const Text("Make Appointment"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
