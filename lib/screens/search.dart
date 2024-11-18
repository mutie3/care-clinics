import 'package:care_clinic/constants/colors_page.dart';
import 'package:care_clinic/constants/theme_dark_mode.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../pages_doctors/doctor_card.dart';
import '../pages_doctors/doctor_detail_page.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> filteredClinics = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    searchController.addListener(_filterClinics);
    _fetchClinicsData();
  }

  Future<void> _fetchClinicsData() async {
    setState(() {
      isLoading = true;
    });

    try {
      QuerySnapshot<Map<String, dynamic>> clinicsSnapshot =
      await FirebaseFirestore.instance.collection('clinics').get();

      List<Map<String, dynamic>> allClinics = clinicsSnapshot.docs.map((doc) {
        return {
          "id": doc.id,
          "img": doc.data()['imageUrl'] ?? 'images/default_image.png',
          "name": doc.data()['name'] ?? 'No Name',
          "speciality": doc.data()['specialty'] ?? 'No Specialty',
          "rating": doc.data()['rating'] ?? '0',
          "location": doc.data()['location'] ?? 'No Location',
          "latitude": doc.data()['latitude'] ?? 0.0,
          "longitude": doc.data()['longitude'] ?? 0.0,
        };
      }).toList();

      if (mounted) {

        setState(() {
          filteredClinics = allClinics;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching clinics data: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }


  Future<List<Map<String, dynamic>>> _fetchDoctors(String clinicId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> doctorsSnapshot =
      await FirebaseFirestore.instance
          .collection('clinics')
          .doc(clinicId)
          .collection('doctors')
          .get();

      return doctorsSnapshot.docs.map((doc) {
        return {
          "img": doc.data()['imageUrl'] ?? 'images/default_image.png',
          "name": doc.data()['name'] ?? 'No Name',
          "specialty": doc.data()['specialty'] ?? 'No Specialty',
        };
      }).toList();
    } catch (e) {
      print("Error fetching doctors data: $e");
      return [];
    }
  }


  void _filterClinics() {
    final query = searchController.text.toLowerCase();

    if (mounted) {

      setState(() {
        filteredClinics = filteredClinics.where((clinic) {
          final name = clinic["name"]!.toLowerCase();
          final speciality = clinic["speciality"]!.toLowerCase();
          return name.contains(query) || speciality.contains(query);
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return Scaffold(
        body: Column(
          children: [
            ClipPath(
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
                          ? AppColors.textBox
                          : AppColors.primaryColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  title: TextField(
                    controller: searchController,
                    onChanged: (value) {
                      _filterClinics();
                    },
                    decoration: InputDecoration(
                      hintText: '......ابحث باسم العيادة',
                      hintStyle: TextStyle(color: Colors.white),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search, color: Colors.white),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
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
                    clinic["speciality"] ?? "No Specialty",
                    rating: clinic["rating"] ?? "0",
                    onTap: () async {

                      List<Map<String, dynamic>> doctors =
                      await _fetchDoctors(clinic["id"]);

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
            ),
          ],
        ),
      );
    });
  }
}


class AppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 20);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 20);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
