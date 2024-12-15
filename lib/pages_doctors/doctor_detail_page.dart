import 'package:care_clinic/widgets/video.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:care_clinic/constants/colors_page.dart';
import 'package:care_clinic/constants/theme_dark_mode.dart';
import 'package:transparent_image/transparent_image.dart';
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
    return List<String>.generate(20, (index) {
      final startTime = DateTime(selectedDate.year, selectedDate.month,
          selectedDate.day, 9, 0); // يبدأ من الساعة 9 صباحًا
      final timeSlot = startTime.add(Duration(minutes: 30 * index));
      return "${timeSlot.hour.toString().padLeft(2, '0')}:${timeSlot.minute.toString().padLeft(2, '0')}";
    });
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
                                    : 'https://via.placeholder.com/150', // صورة افتراضية
                                height: 250, // ارتفاع الصورة
                                width: double.infinity,
                                fit: BoxFit.cover, // ملائمة الصورة داخل الإطار
                              ),
                            ),
                            // المساحة الشفافة التي تغطي الصورة بالكامل
                            Positioned.fill(
                              child: Container(
                                color: Colors.black54, // خلفية شفافة داكنة
                              ),
                            ),
                            // عرض المعلومات والأزرار داخل الصورة ولكن في الأسفل
                            Positioned(
                              bottom: 10, // تحديد المسافة من الأسفل
                              left: 10,
                              right: 10,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.doctorName, // اسم العيادة
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white, // اللون الأبيض للنص
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    'Rank: ${widget.rating}', // التقييم
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          Colors.white70, // اللون الأبيض الفاتح
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  // عرض الأزرار الخاصة بالموقع والاتصال
                                  Row(
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: _openMap, // لفتح الموقع
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
                                        onPressed: () => _makeCall(
                                            clinicPhoneNumber), // الاتصال
                                        icon: const Icon(Icons.phone, size: 20),
                                        label: const Text(
                                          'Call',
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: themeProvider
                                                  .isDarkMode
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
                              height: 180, // يمكنك تعديل الارتفاع حسب الحاجة
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: doctors.length,
                                itemBuilder: (context, index) {
                                  final doctor = doctors[index];
                                  bool isSelected = selectedDoctorIndex ==
                                      index; // تحقق إذا كان هذا الطبيب هو المحدد

                                  return GestureDetector(
                                    onTap: () {
                                      _onDoctorSelected(
                                          index); // تعيين الطبيب المحدد
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                          milliseconds: 300), // مدة الانتقال
                                      curve: Curves
                                          .easeInOut, // نوع تأثير الانتقال
                                      transform: isSelected
                                          ? (Matrix4.identity()
                                            ..scale(
                                                1.1)) // تكبير الحجم للطبيب المحدد
                                          : (Matrix4.identity()
                                            ..scale(
                                                0.9)), // الحجم الطبيعي للطبيب غير المحدد
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Card(
                                          elevation: isSelected
                                              ? 10
                                              : 5, // إضافة ظل أقوى للطبيب المحدد
                                          color: isSelected
                                              ? Colors.blueAccent.withOpacity(
                                                  0.5) // تغيير اللون للطبيب المحدد
                                              : Colors
                                                  .white, // اللون الطبيعي للطبيب غير المحدد
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                12), // جعل الحواف مدورة
                                          ),
                                          child: Stack(
                                            children: [
                                              FadeInImage.memoryNetwork(
                                                placeholder: kTransparentImage,
                                                image:
                                                    doctor['image_url'] ?? '',
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
                                                        CrossAxisAlignment
                                                            .start,
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
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                      const SizedBox(height: 5),
                                                      LayoutBuilder(
                                                        builder: (context,
                                                            constraints) {
                                                          return SingleChildScrollView(
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            child: Text(
                                                              doctor[
                                                                  'specialty'],
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ), // مسافة بين النص والتقييم
                                                      // Row لإظهار التقييم
                                                      Row(
                                                        children: [
                                                          const Icon(
                                                            Icons
                                                                .star, // أيقونة النجمة
                                                            color: Colors
                                                                .yellow, // اللون الذهبي للنجمة
                                                            size:
                                                                20, // حجم الأيقونة
                                                          ),
                                                          const SizedBox(
                                                              width:
                                                                  5), // فاصل بين الأيقونة والنص
                                                          Text(
                                                            '${doctor['rating'] ?? "0.0"}', // التقييم (افتراضي 0.0 إذا لم يكن موجوداً)
                                                            style:
                                                                const TextStyle(
                                                              color: Colors
                                                                  .white70, // اللون الفاتح للنص
                                                              fontSize:
                                                                  12, // حجم النص
                                                            ),
                                                          ),
                                                        ],
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
                            SizedBox(
                              width: 200, // تحديد العرض ليكون أقل
                              child: DropdownButtonFormField<String>(
                                value: selectedTime, // الوقت المختار
                                hint: const Text("Select Time",
                                    style: TextStyle(color: Colors.white)),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16), // تحديد شكل النص
                                decoration: InputDecoration(
                                  filled: true, // تعبئة الخلفية
                                  fillColor:
                                      Colors.blue, // اللون الأزرق للخلفية
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        10), // شكل الحواف المدورة
                                    borderSide: BorderSide.none, // إزالة الحدود
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14), // تحديد الهوامش الداخلية
                                ),
                                items: _generateTimeSlots().map((String time) {
                                  return DropdownMenuItem<String>(
                                    value: time,
                                    child: Text(
                                      time,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          color: AppColors.textColor),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newTime) {
                                  setState(() {
                                    selectedTime =
                                        newTime; // تعيين الوقت الجديد المختار
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _makeAppointment,
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor:
                                    Colors.blue, // اللون عند التفاعل (أبيض)
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 32), // تباعد داخلي أكبر
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      30), // جعل الزر ذو حواف مدورة بشكل عصري
                                ),
                                elevation: 8, // إضافة ظل لإعطاء تأثير عميق
                                shadowColor: Colors.blueAccent, // لون الظل
                                textStyle: const TextStyle(
                                  fontSize: 18, // تكبير النص ليبدو أكثر وضوحًا
                                  fontWeight: FontWeight.bold, // جعل النص عريض
                                ),
                              ),
                              child: const Text("Make Appointment"),
                            ),
                            const SizedBox(
                              height: 5,
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
        ));
      },
    );
  }
}
