import 'package:care_clinic/constants/colors_page.dart';
import 'package:care_clinic/constants/theme_dark_mode.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart';
import '../pages_doctors/doctor_card.dart';
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

  // لتحويل الإحداثيات إلى اسم الموقع
  Future<String> _getLocationName(double latitude, double longitude) async {
    try {
      // استخدام مكتبة geocoding لتحويل الإحداثيات إلى اسم
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        print("Location Name: ${placemarks[0].locality}"); // سجل اسم المدينة
        return placemarks[0].locality ??
            'Unknown Location'; // يمكنك استخدام خصائص أخرى مثل locality أو administrativeArea
      }
    } catch (e) {
      print('Error getting location name: $e');
    }
    return 'Unknown Location';
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

        // التأكد إذا كانت قيمة 'location' مخزنة كنص بصيغة "Lat: x, Lng: y"
        if (clinicData['location'] != null &&
            clinicData['location'] is String) {
          final locationString = clinicData['location'] as String;

          // استخدام تعبير عادي لاستخراج إحداثيات Lat و Lng
          final latLngMatch = RegExp(r'Lat:\s*([\d.-]+),\s*Lng:\s*([\d.-]+)')
              .firstMatch(locationString);

          if (latLngMatch != null) {
            latitude = double.parse(latLngMatch.group(1) ?? '0.0');
            longitude = double.parse(latLngMatch.group(2) ?? '0.0');
          }
        }

        // الحصول على اسم الموقع من الإحداثيات
        String locationName = await _getLocationName(latitude, longitude);

        if (widget.selectedSpecialty.isEmpty) {
          allClinics.add({
            "id": clinicId,
            "name": clinicData['name'] ?? 'No Name',
            "location": locationName, // عرض اسم الموقع بدلاً من الإحداثيات
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
              "location": locationName, // عرض اسم الموقع بدلاً من الإحداثيات
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
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context); // العودة عند الضغط على زر الرجوع في الهاتف
        return false; // منع الإغلاق المباشر
      },
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return Scaffold(
            body: Column(
              children: [
                const SizedBox(
                    height: 40), // المسافة بين الـ AppBar والـ search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    height: 60, // تأكد أن الارتفاع مناسب
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
                          borderRadius: BorderRadius.circular(30),
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

                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredClinics.isEmpty
                          ? const Center(
                              child: Text(
                                'لا توجد عيادات تتطابق مع هذا البحث',
                                style:
                                    TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                            )
                          : GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 0.7,
                              ),
                              itemCount: filteredClinics.length,
                              itemBuilder: (context, index) {
                                final clinic = filteredClinics[index];
                                return Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 5,
                                  child: InkWell(
                                    onTap: () async {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DoctorDetailPage(
                                            clinicId: clinic["id"],
                                            imgPath: clinic["img"],
                                            doctorName: clinic["name"],
                                            doctorSpeciality:
                                                clinic["location"],
                                            rating: clinic["rating"],
                                            latitude: clinic["latitude"],
                                            longitude: clinic["longitude"],
                                          ),
                                        ),
                                      );
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                  top: Radius.circular(15)),
                                          child: Image.network(
                                            clinic["img"],
                                            width: double.infinity,
                                            height: 120,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            clinic["name"] ?? "No Name",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: Text(
                                            clinic["location"] ?? "No Location",
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0, vertical: 4),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                clinic["rating"] ?? "2.3",
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
