import 'package:care_clinic/constants/colors_page.dart';
import 'package:care_clinic/constants/theme_dark_mode.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../pages_doctors/doctor_card.dart';
import '../pages_doctors/doctor_detail_page.dart';

class Clinics extends StatefulWidget {
  final String selectedSpecialty;
  final bool isGustLogin; // إضافة isGustLogin هنا

  const Clinics({super.key, required this.selectedSpecialty, required this.isGustLogin}); // إضافة isGustLogin للكونستركتر

  @override
  ClinicsState createState() => ClinicsState();
}

class ClinicsState extends State<Clinics> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> filteredClinics = [];
  List<Map<String, dynamic>> clinics = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    searchController.addListener(_filterClinics);
    _fetchClinicsData();
  }

  Future<void> _fetchClinicsData() async {
    try {
      QuerySnapshot<Map<String, dynamic>> clinicsSnapshot =
      await FirebaseFirestore.instance.collection('clinics').get();

      List<Map<String, dynamic>> allClinics = [];

      for (var clinicDoc in clinicsSnapshot.docs) {
        var clinicData = clinicDoc.data();
        String clinicId = clinicDoc.id;

        double latitude = 0.0;
        double longitude = 0.0;

        if (clinicData['location'] != null && clinicData['location'] is String) {
          final locationString = clinicData['location'] as String;
          final latLngMatch = RegExp(r'Lat:\s*([\d.-]+),\s*Lng:\s*([\d.-]+)')
              .firstMatch(locationString);

          if (latLngMatch != null) {
            latitude = double.parse(latLngMatch.group(1) ?? '0.0');
            longitude = double.parse(latLngMatch.group(2) ?? '0.0');
          }
        }

        if (widget.selectedSpecialty.isEmpty) {
          // إضافة جميع العيادات بدون تصفية
          allClinics.add({
            "id": clinicId,
            "name": clinicData['name'] ?? 'No Name',
            "location": clinicData['location'] ?? 'No Location',
            "img": clinicData['imageUrl'] ?? '',
            "rating": clinicData['rating']?.toString() ?? '0',
            "latitude": latitude,
            "longitude": longitude,
          });
        } else {
          QuerySnapshot<Map<String, dynamic>> doctorsSnapshot =
          await FirebaseFirestore.instance
              .collection('clinics')
              .doc(clinicId)
              .collection('doctors')
              .where("specialty", isEqualTo: widget.selectedSpecialty)
              .get();

          if (doctorsSnapshot.docs.isNotEmpty) {
            allClinics.add({
              "id": clinicId,
              "name": clinicData['name'] ?? 'No Name',
              "location": clinicData['location'] ?? 'No Location',
              "img": clinicData['imageUrl'] ?? '',
              "rating": clinicData['rating']?.toString() ?? '0',
              "latitude": latitude,
              "longitude": longitude,
            });
          }
        }
      }

      setState(() {
        clinics = allClinics;
        filteredClinics = clinics;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching clinics data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterClinics() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredClinics = clinics.where((clinic) {
        return clinic["name"]!.toLowerCase().contains(query) ||
            clinic["location"]!.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          body: Column(
            children: [
              const SizedBox(height: 20),
              SizedBox(
                height: 80,
                width: 370,
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        width: 50,
                        child: TextField(
                          controller: searchController,
                          onChanged: (value) {
                            _filterClinics();
                          },
                          decoration: InputDecoration(
                            hintText: 'ابحث عن عيادة...',
                            hintStyle: const TextStyle(color: Colors.white),
                            filled: true,
                            fillColor: themeProvider.isDarkMode
                                ? AppColors.textBox
                                : AppColors.primaryColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon:
                            const Icon(Icons.search, color: Colors.white),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredClinics.isEmpty
                    ? const Center(
                    child: Text('لا توجد عيادات تتطابق مع هذا البحث'))
                    : GridView.builder(
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: filteredClinics.length,
                  itemBuilder: (context, index) {
                    final clinic = filteredClinics[index];
                    return DoctorCard(
                      imgPath: clinic["img"],
                      doctorName: clinic["name"] ?? "No Name",
                      doctorSpeciality:
                      clinic["location"] ?? "No Location",
                      rating: clinic["rating"] ?? "0",
                      onTap: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DoctorDetailPage(
                              clinicId: clinic["id"],
                              imgPath: clinic["img"],
                              doctorName: clinic["name"],
                              doctorSpeciality: clinic["location"],
                              rating: clinic["rating"],
                              latitude: clinic["latitude"],
                              longitude: clinic["longitude"],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
