import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../pages_doctors/date_picker_widget.dart';

class UserAppointmentsPage extends StatefulWidget {
  const UserAppointmentsPage({super.key});

  @override
  _UserAppointmentsPageState createState() => _UserAppointmentsPageState();
}

class _UserAppointmentsPageState extends State<UserAppointmentsPage> {
  String? patientName;
  List<Map<String, dynamic>> appointments = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPatientName();
  }

  Future<void> _fetchPatientName() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        String uid = currentUser.uid;
        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();

        if (userDoc.exists) {
          setState(() {
            patientName =
                '${userDoc['firstName'] ?? 'N/A'} ${userDoc['lastName'] ?? 'N/A'}';
          });
          _fetchAppointments();
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching patient name: $e';
      });
    }
  }

  Future<void> _fetchAppointments() async {
    if (patientName == null) return;

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('patientName', isEqualTo: patientName)
          .get();

      setState(() {
        appointments = querySnapshot.docs
            .map((doc) => {
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id, // Add document ID for editing and deletion
                })
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching appointments: $e';
      });
    }
  }

  Future<void> _deleteAppointment(String appointmentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId)
          .delete();

      setState(() {
        appointments
            .removeWhere((appointment) => appointment['id'] == appointmentId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('50'.tr)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete appointment: $e')),
      );
    }
  }

  bool _isAppointmentCompleted(String date, String time) {
    try {
      DateTime appointmentDate =
          DateFormat('dd-MM-yyyy hh:mm').parse('$date $time');
      return DateTime.now().isAfter(appointmentDate);
    } catch (e) {
      return false;
    }
  }

  void _editAppointment(Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (context) {
        DateTime selectedDate = DateTime.now(); // Default to today
        String selectedTime =
            _generateTimeSlots(context).first; // Default to first slot

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('181'.tr),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DatePickerWidget(
                      selectedDate: selectedDate,
                      onSelectDate: (newDate) {
                        setState(() {
                          selectedDate = newDate;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '92'.tr,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButton<String>(
                      value: selectedTime,
                      items: _generateTimeSlots(context).map((timeSlot) {
                        return DropdownMenuItem(
                          value: timeSlot,
                          child: Text(timeSlot),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedTime = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('117'.tr),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      String formattedDate =
                          DateFormat('dd-MM-yyyy').format(selectedDate);

                      await FirebaseFirestore.instance
                          .collection('appointments')
                          .doc(appointment['id'])
                          .update({
                        'date': formattedDate,
                        'time': selectedTime,
                      });

                      setState(() {
                        appointment['date'] = formattedDate;
                        appointment['time'] = selectedTime;
                      });

                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('182'.tr)),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Failed to update appointment: $e')),
                      );
                    }
                  },
                  child: Text('55'.tr),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<String> _generateTimeSlots(BuildContext context) {
    return List<String>.generate(8, (index) {
      final time = TimeOfDay(hour: 9 + index, minute: 0);
      return time.format(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('183'.tr),
        backgroundColor: Colors.indigo,
        elevation: 5,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 80),
                      const SizedBox(height: 15),
                      Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _fetchAppointments,
                        icon: const Icon(Icons.refresh),
                        label: Text('184'.tr),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : appointments.isEmpty
                  ? Center(
                      child: Text(
                        '185'.tr,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: appointments.length,
                      itemBuilder: (context, index) {
                        final appointment = appointments[index];
                        String formattedDate = '';
                        if (appointment['date'] != null) {
                          // Parse and format the date
                          try {
                            DateTime parsedDate =
                                DateTime.parse(appointment['date']);
                            formattedDate =
                                DateFormat('dd-MM-yyyy').format(parsedDate);
                          } catch (e) {
                            formattedDate =
                                appointment['date']; // Fallback to raw value
                          }
                        }

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 4,
                          child: ListTile(
                            leading:
                                const Icon(Icons.person, color: Colors.indigo),
                            title: Text(
                              'Doctor: ${appointment['doctorName']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              'Date: $formattedDate\n'
                              'Time: ${appointment['time']}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () =>
                                      _editAppointment(appointment),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () =>
                                      _deleteAppointment(appointment['id']),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
