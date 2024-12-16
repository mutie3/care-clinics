import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:care_clinic/constants/theme_dark_mode.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/appointment_booking_page.dart';

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
    ]);
    setState(() {
      isLoading = false;
    });
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
                  'experience_years': doc.data()['experience'] ?? 0,
                })
            .toList();
      });
    } catch (e) {
      print('Error fetching doctors: $e');
    }
  }

  void _onDoctorSelected(int index) {
    final selectedDoctor = doctors[index];
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return AppointmentBookingPage(
            doctorId: selectedDoctor['id'],
            doctorName: selectedDoctor['name'],
            doctorSpecialty: selectedDoctor['specialty'],
            experienceYears: selectedDoctor['experience_years'],
            clinicId: widget.clinicId,
            doctorImageUrl: selectedDoctor['image_url'],
            clinicImageUrl: widget.imgPath,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
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
                                                      Row(
                                                        children: [
                                                          const Icon(
                                                            Icons.star,
                                                            color:
                                                                Colors.yellow,
                                                            size: 20,
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
                    ],
                  ),
                ),
        ));
      },
    );
  }
}
