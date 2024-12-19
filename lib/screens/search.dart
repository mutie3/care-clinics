import 'package:care_clinic/constants/colors_page.dart';
import 'package:care_clinic/constants/theme_dark_mode.dart';
import 'package:care_clinic/screens/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../pages_doctors/doctor_card.dart';
import '../pages_doctors/doctor_detail_page.dart';

class Search extends StatefulWidget {
  const Search({super.key, this.selectedSpecialty = ''});

  final String selectedSpecialty;

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> clinics = [];
  List<Map<String, dynamic>> filteredClinics = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchClinicsData();
    searchController.addListener(_filterClinics);
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

        // Simulate location name fetch
        String locationName = await _getLocationName(latitude, longitude);

        if (widget.selectedSpecialty.isEmpty) {
          allClinics.add({
            "id": clinicId,
            "name": clinicData['name'] ?? 'No Name',
            "speciality": clinicData['speciality'] ?? 'No Specialty',
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

  Future<String> _getLocationName(double latitude, double longitude) async {
    // Replace with your geocoding logic
    return "Location ($latitude, $longitude)";
  }

  void _filterClinics() {
    final query = searchController.text.toLowerCase();

    setState(() {
      filteredClinics = clinics.where((clinic) {
        final name = clinic["name"]?.toLowerCase() ?? '';
        final speciality = clinic["speciality"]?.toLowerCase() ?? '';
        return name.contains(query) || speciality.contains(query);
      }).toList();
    });
  }

  PreferredSizeWidget _buildCurvedAppBar(
      BuildContext context, ThemeProvider themeProvider) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100),
      child: ClipPath(
        clipper: AppBarClipper(),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                themeProvider.isDarkMode
                    ? AppColors.textBox
                    : AppColors.primaryColor,
                themeProvider.isDarkMode
                    ? AppColors.textBox.withOpacity(0.7)
                    : AppColors.primaryColor.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: themeProvider.isDarkMode
                    ? Colors.black.withOpacity(0.5)
                    : Colors.blue.withOpacity(0.3),
                offset: const Offset(0, 10),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: AppBar(
            title: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: '177'.tr,
                hintStyle: const TextStyle(color: Colors.white70),
                border: InputBorder.none,
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            elevation: 0.0,
            backgroundColor: Colors.transparent,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: _buildCurvedAppBar(context, themeProvider),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredClinics.isEmpty
                  ? Center(
                      child: Text(
                        '124'.tr,
                        style:
                            const TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: filteredClinics.length,
                      itemBuilder: (context, index) {
                        final clinic = filteredClinics[index];
                        return DoctorCard(
                          imgPath: clinic["img"],
                          doctorName: clinic["name"] ?? "No Name",
                          doctorSpeciality:
                              clinic["speciality"] ?? "No Specialty",
                          rating: clinic["rating"] ?? "0",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DoctorDetailPage(
                                  clinicId: clinic["id"],
                                  imgPath: clinic["img"],
                                  doctorName: clinic["name"],
                                  doctorSpeciality: clinic["speciality"],
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
        );
      },
    );
  }
}
