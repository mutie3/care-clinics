import 'dart:io';
import 'package:care_clinic/widgets/appointments_doc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';

import 'doctor_reg/doctor_info.dart';

class BlankPage extends StatefulWidget {
  const BlankPage({super.key});

  @override
  BlankPageState createState() => BlankPageState();
}

class BlankPageState extends State<BlankPage> {
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
          const SnackBar(content: Text('تم حفظ التعديلات بنجاح!')),
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
      const days = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
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
          const SnackBar(content: Text('تم حفظ التعديلات للطبيب بنجاح!')),
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
    specialtyController.text = doctor['specialty'] ?? '';
    experienceController.text = doctor['experience']?.toString() ?? '';
    daysSelected.value = List<bool>.generate(
        7,
        (index) =>
            doctor['working_days']?.contains(
                ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"][index]) ??
            false);

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
                        TextField(
                          controller: doctorNameController,
                          decoration:
                              const InputDecoration(labelText: 'اسم الطبيب'),
                        ),
                        TextField(
                          controller: experienceController,
                          decoration:
                              const InputDecoration(labelText: 'الخبرة'),
                        ),
                        const SizedBox(height: 10),
                        ValueListenableBuilder<List<bool>>(
                          valueListenable: daysSelected,
                          builder: (context, selectedDays, child) {
                            return Wrap(
                              spacing: 10,
                              children: List<Widget>.generate(7, (index) {
                                final day = [
                                  "SUN",
                                  "MON",
                                  "TUE",
                                  "WED",
                                  "THU",
                                  "FRI",
                                  "SAT"
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DoctorAppointmentsPage(
                                  doctorId: doctorId,
                                ),
                              ),
                            );
                          },
                          child: const Text('عرض المرضى'),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            saveDoctorData(doctorId);
                          },
                          child: const Text('حفظ التعديلات'),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            _showDeleteConfirmationDialog(doctorId);
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          child: const Text('حذف الطبيب'),
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

  void _showDeleteConfirmationDialog(String doctorId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: const Text('هل أنت متأكد أنك تريد حذف هذا الطبيب؟'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                deleteDoctor(doctorId);
                Navigator.of(context).pop();
              },
              child: const Text('حذف'),
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
          const SnackBar(content: Text('تم حذف الطبيب بنجاح!')),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinic Dashboard'),
        backgroundColor: Colors.blue,
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
                    clinicData['name'] ?? 'اسم العيادة',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ],
              ),
            ),
            buildEditableField('اسم العيادة', nameController),
            buildPhoneField(),
            ListTile(
              title: const Text('الموقع'),
              subtitle: TextField(
                controller: locationController,
                enabled: isEditingClinic,
                decoration: const InputDecoration(
                  hintText: 'موقع العيادة',
                ),
              ),
            ),
            ListTile(
              leading: Icon(isEditingClinic ? Icons.save : Icons.edit),
              title: Text(isEditingClinic ? 'حفظ' : 'تعديل'),
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
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getDoctors(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('حدث خطأ أثناء تحميل البيانات.'));
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
                        doctor['name'] ?? 'اسم الطبيب',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        doctor['specialty'] ?? 'التخصص',
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

  Widget buildPhoneField() {
    return ListTile(
      title: TextField(
        controller: phoneController,
        enabled: isEditingClinic,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ],
        decoration: const InputDecoration(labelText: 'رقم الهاتف'),
      ),
    );
  }

  Widget buildEditableField(String label, TextEditingController controller) {
    return ListTile(
      title: TextField(
        controller: controller,
        enabled: isEditingClinic,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
