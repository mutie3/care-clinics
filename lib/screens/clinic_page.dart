import 'dart:io';
import 'package:care_clinic/screens/drug_info_page.dart';
import 'package:care_clinic/screens/setting_screen.dart';
import 'package:care_clinic/widgets/appointments_doc.dart';
import 'package:care_clinic/widgets/custom_text_fieled.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

import '../constants/theme_dark_mode.dart';
import '../widgets/custom_location_picker.dart';
import 'doctor_reg/doctor_info.dart';

class ClinicPage extends StatefulWidget {
  const ClinicPage({super.key});

  @override
  ClinicPageState createState() => ClinicPageState();
}

class ClinicPageState extends State<ClinicPage> {
  bool isEditingClinic = false;
  Map<String, dynamic> clinicData = {
    'name': '',
    'phone': '',
    'location': '',
    'imageUrl': ''
  };

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController specialtyController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController doctorNameController = TextEditingController();
  ValueNotifier<List<bool>> daysSelected =
      ValueNotifier<List<bool>>(List<bool>.filled(7, false));

  File? _imageFile;
  String clinicId = '';
  bool isDoctorEditing = false;
  Map<String, dynamic>? selectedDoctor;

  @override
  void initState() {
    super.initState();
    fetchClinicData();
  }

  Future<void> fetchClinicData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      clinicId = user.uid;
      var doc = await FirebaseFirestore.instance
          .collection('clinics')
          .doc(clinicId)
          .get();
      if (doc.exists) {
        setState(() {
          clinicData = doc.data()!;
          nameController.text = clinicData['name'];
          phoneController.text = clinicData['phone'];
          locationController.text = clinicData['location'];
        });
      }
    }
  }

  Future<void> saveClinicData() async {
    try {
      await FirebaseFirestore.instance
          .collection('clinics')
          .doc(clinicId)
          .update({
        'name': nameController.text,
        'phone': phoneController.text,
        'location': locationController.text,
      });
      setState(() {
        isEditingClinic = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('273'.tr)),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving clinic data: $e');
      }
    }
  }

  Future<void> saveDoctorData(String doctorId) async {
    try {
      List<String> selectedDays = [];
      var days = [
        "102".tr,
        "103".tr,
        "104".tr,
        "105".tr,
        "106".tr,
        "107".tr,
        "108".tr
      ];
      for (int i = 0; i < daysSelected.value.length; i++) {
        if (daysSelected.value[i]) {
          selectedDays.add(days[i]);
        }
      }

      await FirebaseFirestore.instance
          .collection('clinics')
          .doc(clinicId)
          .collection('doctors')
          .doc(doctorId)
          .update({
        'specialty': specialtyController.text,
        'name': doctorNameController.text,
        'working_days': selectedDays,
        'experience': int.tryParse(experienceController.text) ?? 0,
      });
      if (mounted) {
        Navigator.pop(context);
        setState(() {
          isDoctorEditing = false;
          selectedDoctor = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('274'.tr)),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving doctor data: $e');
      }
    }
  }

  Stream<QuerySnapshot> getDoctors() {
    return FirebaseFirestore.instance
        .collection('clinics')
        .doc(clinicId)
        .collection('doctors')
        .snapshots();
  }

  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void showDoctorDetails(Map<String, dynamic> doctor, String doctorId) {
    doctorNameController.text = doctor['name'] ?? '';
    experienceController.text = doctor['experience']?.toString() ?? '';
    specialtyController.text = doctor['specialty'] ?? '';
    daysSelected.value = List<bool>.generate(
      7,
      (index) =>
          doctor['working_days']?.contains([
            "102".tr,
            "103".tr,
            "104".tr,
            "105".tr,
            "106".tr,
            "107".tr,
            "108".tr
          ][index]) ??
          false,
    );

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
            Center(
              child: GestureDetector(
                onTap: () {},
                child: Card(
                  color: Colors.white,
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: NetworkImage(doctor['image_url'] ??
                              'https://www.theclinics.us//150'),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            showDoctorEditInfo(doctorId);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E88E5),
                          ),
                          child: Text(
                            '275'.tr,
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            showDoctorWorkingDays(doctorId);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E88E5),
                          ),
                          child: Text(
                            '276'.tr,
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DoctorAppointmentsPage(
                                  doctorId: doctorId,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E88E5),
                          ),
                          child: Text(
                            '277'.tr,
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showDoctorEditInfo(String doctorId) {
    showDialog(
      context: context,
      builder: (context) => GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
            Center(
              child: GestureDetector(
                onTap: () {},
                child: Card(
                  color: Colors.white,
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 10),
                        TextField(
                          controller: doctorNameController,
                          decoration: InputDecoration(
                            labelText: '74'.tr,
                            labelStyle: const TextStyle(color: Colors.black),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: experienceController,
                          decoration: InputDecoration(
                            labelText: '278'.tr,
                            labelStyle: const TextStyle(color: Colors.black),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            saveDoctorData(doctorId);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E88E5),
                          ),
                          child: Text(
                            '279'.tr,
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            _showDeleteConfirmationDialog(doctorId);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: Text(
                            '280'.tr,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showDoctorWorkingDays(String doctorId) {
    showDialog(
      context: context,
      builder: (context) => GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
            Center(
              child: GestureDetector(
                onTap: () {},
                child: Card(
                  color: Colors.white,
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '276'.tr,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 10),
                        ValueListenableBuilder<List<bool>>(
                          valueListenable: daysSelected,
                          builder: (context, selectedDays, child) {
                            return Wrap(
                              spacing: 10,
                              children: List<Widget>.generate(7, (index) {
                                final day = [
                                  "102".tr,
                                  "103".tr,
                                  "104".tr,
                                  "105".tr,
                                  "106".tr,
                                  "107".tr,
                                  "108".tr
                                ][index];
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Checkbox(
                                      value: selectedDays[index],
                                      onChanged: (bool? value) {
                                        setState(() {
                                          daysSelected.value[index] =
                                              value ?? false;
                                          daysSelected.value = List<bool>.from(
                                              daysSelected.value);
                                        });
                                      },
                                    ),
                                    Text(day),
                                  ],
                                );
                              }),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            // حفظ التعديلات
                            saveDoctorData(doctorId);

                            // التحقق من الأيام التي تم تعديلها
                            checkAndDeleteAppointments(
                                doctorId, daysSelected.value);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E88E5),
                          ),
                          child: Text(
                            '279'.tr,
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> checkAndDeleteAppointments(
      String doctorId, List<bool> selectedDays) async {
    try {
      // العثور على جميع المواعيد التي تخص الطبيب
      final snapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .get();

      // قائمة لتخزين المواعيد التي تحتاج إلى الحذف
      List<String> appointmentsToDelete = [];

      final doctorWorkingDays = [
        "102".tr,
        "103".tr,
        "104".tr,
        "105".tr,
        "106".tr,
        "107".tr,
        "108".tr
      ];

      for (var doc in snapshot.docs) {
        // جلب يوم الموعد كقيمة نصية
        final appointmentDay = doc['appointmentDate'] as String;

        // إذا كان الموعد يتعارض مع يوم تم إلغاؤه
        if (!selectedDays[doctorWorkingDays.indexOf(appointmentDay)]) {
          appointmentsToDelete.add(doc.id); // إضافة المعرف إلى قائمة الحذف
        }
      }

      // حذف المواعيد التي تم تحديدها
      for (var appointmentId in appointmentsToDelete) {
        await FirebaseFirestore.instance
            .collection('appointments')
            .doc(appointmentId)
            .delete();

        // إرسال إشعار للمريض بأنه تم حذف موعده
        final patientId = snapshot.docs
            .firstWhere((doc) => doc.id == appointmentId)['patientId'];
        await FirebaseFirestore.instance.collection('notifications').add({
          'patientId': patientId,
          'message': '281'.tr,
          'createdAt': FieldValue.serverTimestamp(),
          'date': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error checking and deleting appointments: $e');
    }
  }

  void _showDeleteConfirmationDialog(String doctorId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('115'.tr),
          content: Text('282'.tr),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('117'.tr),
            ),
            TextButton(
              onPressed: () {
                deleteDoctor(doctorId);
                Navigator.of(context).pop();
              },
              child: Text('78'.tr),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteDoctor(String doctorId) async {
    try {
      await FirebaseFirestore.instance
          .collection('clinics')
          .doc(clinicId)
          .collection('doctors')
          .doc(doctorId)
          .delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('283'.tr)),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting doctor: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.isDarkMode;
    return Scaffold(
      appBar: AppBar(
        title: Text('284'.tr),
        backgroundColor: Colors.blue,
        actions: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(
                        isClinic: true,
                      ), // تأكد من وجود صفحة SettingScreen
                    ),
                  );
                },
              ),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ClincInfo(clinicId: clinicId)));
        },
        child: const Icon(Icons.add),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: pickImage,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : NetworkImage(clinicData['imageUrl'] ??
                                  'images/861547d6b20eedd16ab36dc108f44254.jpg')
                              as ImageProvider,
                      child: _imageFile == null
                          ? const Icon(Icons.camera_alt, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    clinicData['name'] ?? '57'.tr,
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ],
              ),
            ),
            ExpansionTile(
              title: Text('285'.tr),
              leading: const Icon(Icons.edit),
              children: [
                buildEditableField('57'.tr, nameController),
                buildPhoneField(),
                ListTile(
                  title: Text('76'.tr),
                  subtitle: IgnorePointer(
                    ignoring:
                        !isEditingClinic, // تعطيل التفاعل إذا لم يكن في وضع التعديل
                    child: Opacity(
                      opacity: isEditingClinic
                          ? 1.0
                          : 0.5, // تقليل شفافية العنصر إذا لم يكن في وضع التعديل
                      child: CustomLocationPicker(
                        controller: locationController,
                      ),
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(isEditingClinic ? Icons.save : Icons.edit),
                  title: Text(isEditingClinic ? '55'.tr : '79'.tr),
                  onTap: () {
                    setState(() {
                      isEditingClinic = !isEditingClinic;
                    });
                    if (!isEditingClinic) {
                      saveClinicData();
                    }
                  },
                ),
              ],
            ),
            _buildInfoCard(Icons.medication_outlined, '202'.tr, '',
                isDarkMode: isDarkMode, onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const DrugInfoSearchPage()),
              );
            }),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getDoctors(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('286'.tr));
          }

          var doctors = snapshot.data!.docs;

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              var doctor = doctors[index].data() as Map<String, dynamic>;
              String doctorId = doctors[index].id;

              return GestureDetector(
                onTap: () => showDoctorDetails(doctor, doctorId),
                child: Card(
                  color: Colors.white,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(doctor['image_url'] ??
                            'https://www.theclinics.us/'),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        doctor['name'] ?? '74'.tr,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        doctor['specialty'] ?? '75'.tr,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value,
      {VoidCallback? onTap, required bool isDarkMode}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDarkMode ? Colors.grey[800] : Colors.white,
      child: ListTile(
        leading:
            Icon(icon, color: isDarkMode ? Colors.blueAccent : Colors.blue),
        title: Text(title,
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            if (onTap != null)
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  Widget buildPhoneField() {
    return ListTile(
      title: CustomTextField(
        text: '41'.tr,
        controller: phoneController,
        keyboardType: TextInputType.number,
        enabled: isEditingClinic,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '287'.tr;
          }
          if (value.length != 10) {
            return '246'.tr;
          }
          return null;
        },
        onChanged: (value) {
          // معالجة أي تغييرات في النص إذا لزم الأمر
        },
        icon: const Icon(Icons.phone), // أيقونة الهاتف
      ),
    );
  }

// استدعاء الوظيفة لتسجيل الخروج

  Widget buildEditableField(String label, TextEditingController controller) {
    return ListTile(
      title: CustomTextField(
        text: label,
        controller: controller,
        enabled: isEditingClinic,
        onChanged: (value) {
          // معالجة النص إذا لزم الأمر
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label مطلوب';
          }
          return null;
        },
        icon: const Icon(Icons
            .medical_information), // أيقونة للتوضيح (يمكنك تغييرها حسب الحاجة)
      ),
    );
  }
}
