import 'package:care_clinic/constants/colors_page.dart';
import 'package:care_clinic/constants/theme_dark_mode.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'rating_page.dart';

enum AppointmentStatus { past, upcoming }

class UserAppointmentsPage extends StatefulWidget {
  const UserAppointmentsPage({super.key});

  @override
  State<UserAppointmentsPage> createState() => _UserAppointmentsPageState();
}

class _UserAppointmentsPageState extends State<UserAppointmentsPage> {
  List<Map<String, dynamic>> appointments = [];
  bool isLoading = true;
  String? errorMessage;
  String? doctorId;
  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        String uid = currentUser.uid;

        // جلب المواعيد من مجموعة appointments
        QuerySnapshot upcomingSnapshot = await FirebaseFirestore.instance
            .collection('appointments')
            .where('patientId', isEqualTo: uid)
            .get();

        // جلب المواعيد من مجموعة appointmentsisdone
        QuerySnapshot pastSnapshot = await FirebaseFirestore.instance
            .collection('appointmentsisdone')
            .where('patientId', isEqualTo: uid)
            .get();

        List<Map<String, dynamic>> fetchedAppointments = [];

        // معالجة المواعيد القادمة
        for (var doc in upcomingSnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          String doctorName = await _fetchDoctorName(data['doctorId']);
          DateTime? appointmentDateTime =
              convertToDate(data['appointmentDate']);

          String formattedDate = appointmentDateTime != null
              ? DateFormat('yyyy-MM-dd').format(appointmentDateTime)
              : 'Invalid Date';

          fetchedAppointments.add({
            'id': doc.id,
            'doctorName': doctorName,
            'date': formattedDate,
            'time': data['appointmentTime'] ?? 'N/A',
            'appointmentDate': appointmentDateTime?.toIso8601String() ?? 'N/A',
            'appointmentTime': data['appointmentTime'],
            'status': AppointmentStatus.upcoming,
          });
        }

        // معالجة المواعيد المنتهية
        for (var doc in pastSnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          String doctorName = await _fetchDoctorName(data['doctorId']);
          String doctorId = data['doctorId'];
          DateTime movedToDoneAt =
              (data['movedToDoneAt'] as Timestamp).toDate();

          String formattedDate = DateFormat('yyyy-MM-dd').format(movedToDoneAt);

          fetchedAppointments.add({
            'id': doc.id,
            'doctorName': doctorName,
            'doctorId': doctorId,
            'date': formattedDate,
            'time': data['appointmentTime'] ?? 'N/A',
            'appointmentDate': movedToDoneAt.toIso8601String(),
            'appointmentTime': data['appointmentTime'],
            'status': AppointmentStatus.past,
          });
        }

        setState(() {
          appointments = fetchedAppointments;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching appointments: $e';
      });
    }
  }

  /// Fetch doctor name
  Future<String> _fetchDoctorName(String doctorId) async {
    try {
      QuerySnapshot clinicsSnapshot =
          await FirebaseFirestore.instance.collection('clinics').get();

      for (var clinicDoc in clinicsSnapshot.docs) {
        QuerySnapshot doctorsSnapshot = await clinicDoc.reference
            .collection('doctors')
            .where(FieldPath.documentId, isEqualTo: doctorId)
            .get();

        if (doctorsSnapshot.docs.isNotEmpty) {
          return doctorsSnapshot.docs.first['name'] ?? 'Unknown Doctor';
        }
      }
    } catch (e) {
      print('Error fetching doctor name: $e');
    }
    return 'Unknown Doctor';
  }

  DateTime? convertToDate(String dayString) {
    final Map<String, int> dayMap = {
      "SUN": DateTime.sunday,
      "MON": DateTime.monday,
      "TUE": DateTime.tuesday,
      "WED": DateTime.wednesday,
      "THU": DateTime.thursday,
      "FRI": DateTime.friday,
      "SAT": DateTime.saturday,
    };

    if (!dayMap.containsKey(dayString.toUpperCase())) {
      print("Invalid day string: $dayString");
      return null;
    }

    DateTime now = DateTime.now();
    int currentWeekday = now.weekday;

    int targetWeekday = dayMap[dayString.toUpperCase()]!;

    int daysToAdd = (targetWeekday - currentWeekday) % 7;
    if (daysToAdd < 0) {
      daysToAdd += 7;
    }

    return now.add(Duration(days: daysToAdd));
  }

  // دالة _getAppointmentStatus
  AppointmentStatus _getAppointmentStatus(DateTime appointmentDateTime) {
    if (appointmentDateTime.isBefore(DateTime.now())) {
      return AppointmentStatus.past;
    } else {
      return AppointmentStatus.upcoming;
    }
  }

  Future<void> _moveAppointmentToDone(
      String appointmentId, Map<String, dynamic> appointmentData) async {
    try {
      // إضافة الموعد إلى مجموعة appointmentsisdone
      await FirebaseFirestore.instance.collection('appointmentsisdone').add({
        ...appointmentData,
        'movedToDoneAt': FieldValue.serverTimestamp(), // إضافة تاريخ ووقت النقل
      });

      // حذف الموعد من مجموعة appointments
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId)
          .delete();

      // إزالة الموعد من الواجهة
      setState(() {
        appointments
            .removeWhere((appointment) => appointment['id'] == appointmentId);
      });

      // إظهار رسالة تأكيد للمستخدم
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Appointment has been moved to "Done" successfully.')),
      );
    } catch (e) {
      print('Error moving appointment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to move appointment: $e')),
      );
    }
  }

  Future<void> _deleteAppointment(
      String appointmentId, String appointmentDate) async {
    try {
      DateTime appointmentDateTime = DateTime.parse(appointmentDate);

      // إذا كانت الموعد قد انتهى، نقله إلى appointmentsisdone بدلاً من حذفه
      if (appointmentDateTime.isBefore(DateTime.now())) {
        var appointmentData = appointments
            .firstWhere((appointment) => appointment['id'] == appointmentId);
        await _moveAppointmentToDone(appointmentId, appointmentData);
      } else {
        // إذا كانت الموعد لم ينتهي بعد، نقوم فقط بحذفه
        if (_isAppointmentTooClose(appointmentDate)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('290'.tr)),
          );
          return;
        }

        await FirebaseFirestore.instance
            .collection('appointments')
            .doc(appointmentId)
            .delete();

        setState(() {
          appointments
              .removeWhere((appointment) => appointment['id'] == appointmentId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('180'.tr)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete appointment: $e')),
        );
      }
    }
  }

  bool _isAppointmentTooClose(String appointmentDate) {
    DateTime appointmentDateTime = DateTime.parse(appointmentDate);
    DateTime currentDateTime = DateTime.now();

    Duration difference = appointmentDateTime.difference(currentDateTime);
    return difference.isNegative || difference.inHours < 8;
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> pastAppointments = appointments
        .where((appointment) =>
            _getAppointmentStatus(
                DateTime.parse(appointment['appointmentDate'])) ==
            AppointmentStatus.past)
        .toList();

    List<Map<String, dynamic>> upcomingAppointments = appointments
        .where((appointment) =>
            _getAppointmentStatus(
                DateTime.parse(appointment['appointmentDate'])) ==
            AppointmentStatus.upcoming)
        .toList();
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            '291'.tr,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors
              .primaryColor, // You can customize this color or make it dynamic
          centerTitle: true,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  themeProvider.isDarkMode
                      ? Colors.black.withOpacity(0.8)
                      : AppColors.primaryColor.withOpacity(0.8),
                  themeProvider.isDarkMode
                      ? Colors.black.withOpacity(1.0)
                      : AppColors.primaryColor.withOpacity(1.0),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          elevation: 5,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? Center(
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(
                          color: Colors.red,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                : appointments.isEmpty
                    ? Center(
                        child: Text(
                          '185'.tr,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            if (upcomingAppointments.isNotEmpty)
                              _buildAppointmentList(
                                upcomingAppointments,
                                '292'.tr,
                              ),
                            if (pastAppointments.isNotEmpty)
                              _buildAppointmentList(pastAppointments, '293'.tr),
                          ],
                        ),
                      ),
      );
    });
  }

  Widget _buildAppointmentList(
      List<Map<String, dynamic>> appointments, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              final String doctorName = appointment['doctorName'] ?? 'Unknown';
              final String appointmentDate =
                  appointment['appointmentDate'] ?? '';
              final String time = appointment['time'] ?? 'N/A';
              final String date = appointment['date'] ?? 'N/A';
              final String id = appointment['id'] ?? '';

              DateTime appointmentDateTime =
                  DateTime.tryParse(appointmentDate) ?? DateTime.now();
              bool isPastAppointment =
                  appointmentDateTime.isBefore(DateTime.now());

              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 3,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  leading: const Icon(
                    Icons.calendar_today,
                    color: AppColors.primaryColor,
                    size: 30,
                  ),
                  title: Text(
                    'Doctor: $doctorName',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    'Date: $date\nTime: $time',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  trailing: isPastAppointment
                      ? IconButton(
                          tooltip: '294'.tr,
                          icon:
                              const Icon(Icons.rate_review, color: Colors.blue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RatingPage(
                                  appointmentId: id,
                                  appointmentDate: date,
                                  appointmentTime: time,
                                  doctorName: doctorName,
                                  doctorId: appointment['doctorId'].toString(),
                                ),
                              ),
                            );
                          },
                        )
                      : IconButton(
                          tooltip: '295'.tr,
                          icon: const Icon(Icons.delete,
                              color: Colors.red, size: 28),
                          onPressed: () => _confirmDelete(
                            appointmentId: id,
                            appointmentDate: appointmentDate,
                          ),
                        ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

// Method for delete confirmation
  void _confirmDelete(
      {required String appointmentId, required String appointmentDate}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('115'.tr),
          content: Text(
              'Are you sure you want to delete the appointment on $appointmentDate?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('117'.tr),
            ),
            TextButton(
              onPressed: () {
                _deleteAppointment(appointmentId, appointmentDate);
                Navigator.pop(context);
              },
              child: Text('78'.tr),
            ),
          ],
        );
      },
    );
  }
}
