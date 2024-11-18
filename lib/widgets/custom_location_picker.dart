import 'package:care_clinic/constants/colors_page.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class CustomLocationPicker extends StatefulWidget {
  final TextEditingController controller;

  const CustomLocationPicker({Key? key, required this.controller})
      : super(key: key);

  @override
  _CustomLocationPickerState createState() => _CustomLocationPickerState();
}

class _CustomLocationPickerState extends State<CustomLocationPicker> {
  LatLng? _pickedLocation;

  Future<void> _getCurrentLocation() async {
    try {
      bool hasPermission = await _handleLocationPermission();
      if (!hasPermission) return;

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _pickedLocation = LatLng(position.latitude, position.longitude);
        widget.controller.text =
            'Lat: ${position.latitude}, Lng: ${position.longitude}';
      });
      print("Current location obtained: $_pickedLocation");
    } catch (e) {
      print("Error getting current location: $e");
    }
  }

  Future<bool> _handleLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Location permissions are denied.");
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print("Location permissions are permanently denied.");
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
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
              border: Border.all(color: AppColors.primaryColor),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on,
                    color: AppColors.primaryColor), // إضافة أيقونة الموقع
                const SizedBox(width: 8), // مساحة بين الأيقونة والنص
                Expanded(
                  child: Text(
                    widget.controller.text.isNotEmpty
                        ? widget.controller.text
                        : 'Tap to select location',
                    style: const TextStyle(
                        color: AppColors.textColor, fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
  LatLng _currentLocation =
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
        title: const Text('Select Location'),
      ),
      body: GoogleMap(
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
            markerId: const MarkerId('selectedLocation'),
            position: _markerLocation,
            infoWindow: const InfoWindow(title: 'Selected Location'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed), // دبوس أحمر لموقع مختار
          ),
        },
        zoomControlsEnabled: false, // إخفاء أزرار التكبير والتصغير
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          widget.onLocationSelected(_markerLocation); // تمرير الموقع المحدد
          Navigator.pop(context);
        },
        label: const Text('Confirm Location'),
        icon: const Icon(Icons.check),
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
