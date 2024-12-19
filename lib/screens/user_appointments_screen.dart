import 'package:care_clinic/constants/colors_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
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

        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('appointments')
            .where('patientId', isEqualTo: uid)
            .get();

        List<Map<String, dynamic>> fetchedAppointments = [];

        for (var doc in querySnapshot.docs) {
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

  AppointmentStatus _getAppointmentStatus(DateTime appointmentDateTime) {
    if (appointmentDateTime.isBefore(DateTime.now())) {
      return AppointmentStatus.past;
    } else {
      return AppointmentStatus.upcoming;
    }
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

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Appointments',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryColor,
        centerTitle: true,
        elevation: 5, // إضافة تأثير ظل للـ AppBar
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
                  ? const Center(
                      child: Text(
                        'No appointments found',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          if (upcomingAppointments.isNotEmpty)
                            _buildAppointmentList(
                                upcomingAppointments, 'Upcoming Appointments'),
                          if (pastAppointments.isNotEmpty)
                            _buildAppointmentList(
                                pastAppointments, 'Past Appointments'),
                        ],
                      ),
                    ),
    );
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
                  color: Colors.black),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              DateTime appointmentDateTime =
                  DateTime.parse(appointment['appointmentDate']);
              bool isPastAppointment =
                  appointmentDateTime.isBefore(DateTime.now());

              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(15), // زاوية دائرية أكبر للبطاقات
                ),
                elevation: 3, // إضافة ظل للبطاقات لتمييزها
                child: ListTile(
                  contentPadding: const EdgeInsets.all(
                      15), // إضافة مسافة داخلية داخل الـ ListTile
                  leading: const Icon(
                    Icons.calendar_today,
                    color: AppColors.primaryColor,
                    size: 30,
                  ),
                  title: Text(
                    'Doctor: ${appointment['doctorName']}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black),
                  ),
                  subtitle: Text(
                    'Date: ${appointment['date']}\nTime: ${appointment['time']}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  trailing: isPastAppointment
                      ? IconButton(
                          icon:
                              const Icon(Icons.rate_review, color: Colors.blue),
                          onPressed: () {
                            // الانتقال إلى صفحة التقييم
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RatingPage(
                                  appointmentId: appointment['id'],
                                  doctorName: appointment['doctorName'],
                                  appointmentDate: appointment['date'],
                                  appointmentTime: appointment['time'],
                                ),
                              ),
                            );
                          },
                        )
                      : IconButton(
                          icon: const Icon(Icons.delete,
                              color: Colors.red, size: 28),
                          onPressed: () => _deleteAppointment(appointment['id'],
                              appointment['appointmentDate']),
                        ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAppointment(
      String appointmentId, String appointmentDate) async {
    try {
      if (_isAppointmentTooClose(appointmentDate)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Cannot delete appointment less than 8 hours away')),
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment deleted successfully')),
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
}
