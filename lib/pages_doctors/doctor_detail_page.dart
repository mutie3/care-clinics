import 'package:care_clinic/widgets/video.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:care_clinic/constants/colors_page.dart';
import 'package:care_clinic/constants/theme_dark_mode.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/rotating_dropdown.dart';
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
  int? selectedDoctorIndex;
  List<Map<String, dynamic>> doctors = [];
  bool isLoading = true;
  String clinicPhoneNumber = '';
  String? userId;
  List<String> workingDays = [];
  String? selectedDay; // تعريف المتغير الذي سيخزن اليوم المحدد
  String? selectedTime;

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
    await Future.wait([_fetchClinicData(), _fetchDoctors(), _fetchUserData()]);
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchWorkingDays(String doctorId) async {
    try {
      final doctorSnapshot = await FirebaseFirestore.instance
          .collection('clinics')
          .doc(widget.clinicId)
          .collection('doctors')
          .doc(doctorId)
          .get();
      if (doctorSnapshot.exists) {
        setState(() {
          workingDays =
              List<String>.from(doctorSnapshot.data()?['working_days'] ?? []);
        });
      }
    } catch (e) {
      print('Error fetching working days: $e');
    }
  }

  Future<void> _fetchUserData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid;
      userId = uid;
    }
  }

  Future<void> _makeAppointment(int? selectedDoctorIndex) async {
    try {
      // الحصول على مرجع لـ Firestore
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('appointments').add({
        'clinicId': widget.clinicId, // ID العيادة
        'doctorId': doctors[selectedDoctorIndex!]['id'], // ID الطبيب
        'patientId': userId, // اسم المريض
        'appointmentDate': selectedDay, // تاريخ الموعد
        'appointmentTime': selectedTime, // وقت الموعد
        'createdAt': FieldValue.serverTimestamp(), // تاريخ الإنشاء
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => VideoPage()),
      );
      // إذا كانت العملية ناجحة
      print("Appointment successfully created!");
    } catch (e) {
      // التعامل مع الأخطاء في حال فشل العملية
      print("Error making appointment: $e");
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

  void _onDoctorSelected(int index) {
    setState(() {
      selectedDoctorIndex = index;
    });
    _fetchWorkingDays(doctors[index]['id']);
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

  List<String> generateTimeSlots() {
    List<String> timeSlots = [];
    DateTime startTime = DateTime(2024, 12, 18, 9, 0); // 9 AM
    DateTime endTime = DateTime(2024, 12, 18, 17, 0); // 5 PM

    while (startTime.isBefore(endTime)) {
      String formattedTime =
          "${startTime.hour}:${startTime.minute == 0 ? '00' : '30'}";
      timeSlots.add(formattedTime);
      startTime = startTime.add(Duration(minutes: 30));
    }

    return timeSlots;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
            body: WillPopScope(
          onWillPop: () async {
            Navigator.pop(context);
            return true;
          },
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: FadeInImage.memoryNetwork(
                              placeholder: kTransparentImage,
                              image: widget.imgPath.isNotEmpty
                                  ? widget.imgPath
                                  : 'https://via.placeholder.com/150',
                              height: 250,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned.fill(
                            child: Container(
                              color: Colors.black54,
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            left: 10,
                            right: 10,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.doctorName,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Rank: ${widget.rating}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: _openMap,
                                      icon: const Icon(Icons.location_on,
                                          size: 20),
                                      label: const Text(
                                        'Location',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: themeProvider
                                                .isDarkMode
                                            ? Colors.blueGrey.withOpacity(0.7)
                                            : Colors.blue.withOpacity(0.8),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        elevation: 4,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    ElevatedButton.icon(
                                      onPressed: () =>
                                          _makeCall(clinicPhoneNumber),
                                      icon: const Icon(Icons.phone, size: 20),
                                      label: const Text(
                                        'Call',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            themeProvider.isDarkMode
                                                ? Colors.greenAccent
                                                    .withOpacity(0.7)
                                                : Colors.green.withOpacity(0.8),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        elevation: 4,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        'Select a Doctor: ',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),
                    doctors.isNotEmpty
                        ? SizedBox(
                            height: 180,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: doctors.length,
                              itemBuilder: (context, index) {
                                final doctor = doctors[index];
                                bool isSelected = selectedDoctorIndex == index;

                                return GestureDetector(
                                  onTap: () {
                                    _onDoctorSelected(index);
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    transform: isSelected
                                        ? (Matrix4.identity()..scale(1.1))
                                        : (Matrix4.identity()..scale(0.9)),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Card(
                                        elevation: isSelected ? 10 : 5,
                                        color: isSelected
                                            ? Colors.blueAccent.withOpacity(0.5)
                                            : Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Stack(
                                          children: [
                                            FadeInImage.memoryNetwork(
                                              placeholder: kTransparentImage,
                                              image: doctor['image_url'] ?? '',
                                              height: 150,
                                              width: 120,
                                              fit: BoxFit.cover,
                                            ),
                                            Positioned(
                                              bottom: 10,
                                              left: 10,
                                              right: 10,
                                              child: Container(
                                                color: Colors.black54,
                                                padding:
                                                    const EdgeInsets.all(5),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    LayoutBuilder(
                                                      builder: (context,
                                                          constraints) {
                                                        return SingleChildScrollView(
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          child: Text(
                                                            doctor['name'],
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                    Text(
                                                      doctor['specialty'],
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Colors.white70,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        : const Center(
                            child: Text('No doctors available at the moment'),
                          ),
                    const SizedBox(height: 30),
                    if (selectedDoctorIndex != null)
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return SizeTransition(
                            sizeFactor: _animation,
                            axisAlignment: -1.0,
                            child: Column(
                              children: [
                                const Text(
                                  'Available Days:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                if (workingDays.isEmpty)
                                  const Text('No working days available'),
                                // استخدام Row لعرض الأيام بجانب بعضهم
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: workingDays
                                      .map(
                                        (day) => GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              // تعيين اليوم المختار
                                              selectedDay = day;
                                            });
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                      horizontal: 4),
                                              decoration: BoxDecoration(
                                                color: selectedDay == day
                                                    ? Colors.blueAccent
                                                        .withOpacity(0.7)
                                                    : Colors.grey
                                                        .withOpacity(0.3),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                day,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: selectedDay == day
                                                      ? Colors.white
                                                      : Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                                SizedBox(
                                  width: 250, // حدد العرض المناسب
                                  height: 200, // حدد الارتفاع المناسب
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                        vertical:
                                            10.0), // تحديد الـ padding حول الـ widget
                                    child: RotatingDropdown(
                                      selectedValue:
                                          selectedTime ?? 'Select Time',
                                      items:
                                          generateTimeSlots(), // تمرير قائمة المواعيد
                                      onChanged: (selectedTime) {
                                        setState(() {
                                          this.selectedTime = selectedTime;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: selectedDay != null &&
                                          selectedTime != null
                                      ? () {
                                          _makeAppointment(selectedDoctorIndex);
                                        }
                                      : null, // تعطيل الزر إذا لم يتم تحديد اليوم أو الوقت
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14, horizontal: 20),
                                    backgroundColor: Colors.blueAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Book Appointment',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                )),
        ));
      },
    );
  }
}
