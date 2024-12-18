import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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

  /// Fetch appointments from Firestore
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
          String formattedDate = _formatDate(data['appointmentDate']);

          fetchedAppointments.add({
            'id': doc.id,
            'doctorName': doctorName,
            'date': formattedDate,
            'time': data['appointmentTime'] ?? 'N/A',
            'appointmentDate': data['appointmentDate'], // Store the raw date
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Appointment deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete appointment: $e')),
      );
    }
  }

  /// Check if the appointment is less than 8 hours away
  bool _isAppointmentTooClose(String appointmentDate) {
    DateTime appointmentDateTime = DateTime.parse(appointmentDate);
    DateTime currentDateTime = DateTime.now();

    // Calculate the difference between current time and appointment time
    Duration difference = appointmentDateTime.difference(currentDateTime);
    return difference.isNegative ||
        difference.inHours < 8; // Appointment is too close
  }

  /// Format date
  String _formatDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('yyyy-MM-dd').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Appointments'),
        backgroundColor: Colors.indigo,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 18),
                  ),
                )
              : appointments.isEmpty
                  ? const Center(
                      child: Text('No appointments found'),
                    )
                  : ListView.builder(
                      itemCount: appointments.length,
                      itemBuilder: (context, index) {
                        final appointment = appointments[index];

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.calendar_today,
                                color: Colors.indigo),
                            title: Text(
                              'Doctor: ${appointment['doctorName']}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle: Text(
                              'Date: ${appointment['date']}\nTime: ${appointment['time']}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteAppointment(
                                  appointment['id'],
                                  appointment['appointmentDate']),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
