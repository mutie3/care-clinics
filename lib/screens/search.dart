import 'package:care_clinic/constants/colors_page.dart';
import 'package:care_clinic/constants/theme_dark_mode.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../pages_doctors/doctor_card.dart';
import '../pages_doctors/doctor_detail_page.dart';
import 'home_page.dart';

class Search extends StatefulWidget {
  const Search({super.key});

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

      final List<Map<String, dynamic>> allClinics =
          clinicsSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          "id": doc.id,
          "img": data['imageUrl'] ?? 'images/default_image.png',
          "name": data['name'] ?? 'No Name',
          "speciality": data['specialty'] ?? 'No Specialty',
          "rating": data['rating'] ?? '0',
          "location": data['location'] ?? 'No Location',
        };
      }).toList();

      setState(() {
        clinics = allClinics;
        filteredClinics = allClinics;
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
      preferredSize: Size.fromHeight(100),
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
              decoration: const InputDecoration(
                hintText: 'ابحث باسم العيادة أو التخصص...',
                hintStyle: TextStyle(color: Colors.white70),
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search, color: Colors.white70),
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
          appBar: _buildCurvedAppBar(
              context, themeProvider), // Using the PreferredSizeWidget here
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredClinics.isEmpty
                  ? const Center(
                      child: Text(
                        'لا توجد نتائج تطابق البحث',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
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
        );
      },
    );
  }
}
