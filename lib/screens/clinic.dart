import 'package:care_clinic/constants/theme_dark_mode.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart';
import 'package:transparent_image/transparent_image.dart';
import '../pages_doctors/doctor_detail_page.dart';

class Clinics extends StatefulWidget {
  final String selectedSpecialty;
  final bool isGustLogin;

  const Clinics({
    super.key,
    required this.selectedSpecialty,
    required this.isGustLogin,
  });

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

  Future<String> _getLocationName(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        return placemarks[0].locality ?? '158'.tr;
      }
    } catch (e) {
      return '157'.tr;
    }
    return '157'.tr;
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

        if (clinicData['location'] != null &&
            clinicData['location'] is String) {
          final locationString = clinicData['location'] as String;
          final latLngMatch = RegExp(r'Lat:\s*([\d.-]+),\s*Lng:\s*([\d.-]+)')
              .firstMatch(locationString);

          if (latLngMatch != null) {
            latitude = double.parse(latLngMatch.group(1) ?? '0.0');
            longitude = double.parse(latLngMatch.group(2) ?? '0.0');
          }
        }

        String locationName = await _getLocationName(latitude, longitude);

        if (widget.selectedSpecialty.isEmpty) {
          allClinics.add({
            "id": clinicId,
            "name": clinicData['name'] ?? 'No Name',
            "location": locationName,
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
              "location": locationName,
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
          appBar: AppBar(
            title: Text(
              '159'.tr,
              style: TextStyle(
                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            backgroundColor:
                themeProvider.isDarkMode ? Colors.grey[900] : Colors.white,
            elevation: 0,
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: '123'.tr,
                    hintStyle: TextStyle(
                      color: themeProvider.isDarkMode
                          ? Colors.grey[400]
                          : Colors.grey[600],
                    ),
                    filled: true,
                    fillColor: themeProvider.isDarkMode
                        ? Colors.grey[800]
                        : Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: themeProvider.isDarkMode
                          ? Colors.grey[400]
                          : Colors.grey[600],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: filteredClinics.isEmpty
                            ? clinics.length
                            : filteredClinics.length,
                        itemBuilder: (context, index) {
                          final clinic = filteredClinics.isEmpty
                              ? clinics[index]
                              : filteredClinics[index];
                          return ClinicCard(
                            clinic: clinic,
                            onSelectClinic: (selectedClinic) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DoctorDetailPage(
                                    clinicId: selectedClinic["id"],
                                    imgPath: selectedClinic["img"],
                                    doctorName: selectedClinic["name"],
                                    doctorSpeciality:
                                        selectedClinic["location"],
                                    rating: selectedClinic["rating"],
                                    latitude: selectedClinic["latitude"],
                                    longitude: selectedClinic["longitude"],
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

class ClinicCard extends StatelessWidget {
  final Map<String, dynamic> clinic;
  final void Function(Map<String, dynamic> clinic) onSelectClinic;

  const ClinicCard({
    super.key,
    required this.clinic,
    required this.onSelectClinic,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.hardEdge,
      elevation: 2,
      child: InkWell(
        onTap: () => onSelectClinic(clinic),
        child: Column(
          children: [
            Stack(
              children: [
                FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  image: clinic["img"],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 250,
                  imageErrorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.broken_image,
                    size: 70,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 44,
                    ),
                    color: Colors.black54,
                    child: Text(
                      clinic["name"],
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    clinic["location"],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Baseline(
                        baseline: 18.0, // القيمة تحدد ارتفاع خط النص
                        baselineType: TextBaseline.alphabetic,
                        child: Text(
                          clinic["rating"],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Baseline(
                        baseline: 18.0, // نفس الخط الأساسي للتنسيق
                        baselineType: TextBaseline.alphabetic,
                        child: Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 20,
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
    );
  }
}
