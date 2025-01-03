import 'package:care_clinic/constants/colors_page.dart';
import 'package:care_clinic/constants/theme_dark_mode.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart'; // لاستخدام Consumer لمتابعة الوضع المظلم

class CustomLocationPicker extends StatefulWidget {
  final TextEditingController controller;

  const CustomLocationPicker({super.key, required this.controller});

  @override
  CustomLocationPickerState createState() => CustomLocationPickerState();
}

class CustomLocationPickerState extends State<CustomLocationPicker> {
  // ignore: unused_field
  LatLng? _pickedLocation;

  Future<bool> _handleLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('198'.tr);
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('199'.tr);
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () async {
                final LatLng? result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LocationMap(
                      onLocationSelected: (LatLng location) {
                        setState(() {
                          _pickedLocation = location;
                          widget.controller.text =
                              'Lat: ${location.latitude}, Lng: ${location.longitude}';
                        });
                      },
                    ),
                  ),
                );

                if (result != null) {
                  setState(() {
                    _pickedLocation = result;
                    widget.controller.text =
                        'Lat: ${result.latitude}, Lng: ${result.longitude}';
                  });
                }
              },
              child: Container(
                width: double.infinity, // لجعل العرض بعرض الشاشة
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: themeProvider.isDarkMode
                        ? Colors.grey.shade600 // حدود داكنة في الوضع المظلم
                        : AppColors.primaryColor, // حدود ملونة في الوضع الفاتح
                  ),
                  borderRadius: BorderRadius.circular(20),
                  color: themeProvider.isDarkMode
                      ? Colors.grey.shade800 // خلفية داكنة في الوضع المظلم
                      : Colors.white, // خلفية فاتحة في الوضع العادي
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: themeProvider.isDarkMode
                          ? Colors.white
                          : AppColors.primaryColor, // أيقونة باللون المناسب
                    ),
                    const SizedBox(width: 8), // مساحة بين الأيقونة والنص
                    Expanded(
                      child: Text(
                        widget.controller.text.isNotEmpty
                            ? widget.controller.text
                            : '59'.tr,
                        style: TextStyle(
                          color: themeProvider.isDarkMode
                              ? Colors.white // نص أبيض في الوضع المظلم
                              : AppColors.textColor, // نص أسود في الوضع الفاتح
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class LocationMap extends StatefulWidget {
  final Function(LatLng) onLocationSelected;

  const LocationMap({Key? key, required this.onLocationSelected})
      : super(key: key);

  @override
  _LocationMapState createState() => _LocationMapState();
}

class _LocationMapState extends State<LocationMap> {
  late GoogleMapController _mapController;
  final LatLng _currentLocation =
      const LatLng(31.963158, 35.930359); // موقع افتراضي في عمان
  late LatLng _markerLocation; // استخدم late هنا

  @override
  void initState() {
    super.initState();
    _markerLocation = _currentLocation; // تعيين موقع الدبوس الافتراضي
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('130'.tr),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              _moveCameraToUserLocation();
            },
            initialCameraPosition: CameraPosition(
              target: _currentLocation, // البدء من عمان
              zoom: 14,
            ),
            onCameraMove: (CameraPosition position) {
              setState(() {
                _markerLocation =
                    position.target; // تحديث موقع الدبوس مع حركة الكاميرا
              });
            },
            markers: {
              Marker(
                markerId: MarkerId('200'.tr),
                position: _markerLocation,
                infoWindow: InfoWindow(title: '201'.tr),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed), // دبوس أحمر لموقع مختار
              ),
            },
            zoomControlsEnabled: false, // إخفاء أزرار التكبير والتصغير
          );
        },
      ),
      floatingActionButton: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return FloatingActionButton.extended(
            onPressed: () {
              widget.onLocationSelected(_markerLocation); // تمرير الموقع المحدد
              Navigator.pop(context);
            },
            label: Text('131'.tr),
            icon: const Icon(Icons.check),
            backgroundColor: themeProvider.isDarkMode
                ? AppColors.primaryColor
                : AppColors.primaryColor, // الخلفية حسب الوضع المظلم
          );
        },
      ),
    );
  }

  void _moveCameraToUserLocation() {
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _currentLocation,
          zoom: 14,
        ),
      ),
    );
  }
}
