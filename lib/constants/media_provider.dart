import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MediaProvider extends ChangeNotifier {
  XFile? image;
  Uint8List? bytes;
  bool isLoading = false;

  Future<void> setImage({ImageSource source = ImageSource.gallery}) async {
    isLoading = true;
    notifyListeners();

    try {
      final picker = ImagePicker();
      final raw = await picker.pickImage(source: source);

      if (raw != null) {
        image = raw;
        bytes = await raw
            .readAsBytes(); // Use readAsBytes (async) instead of readAsBytesSync
      } else {
        reset(); // Reset if no image is selected
      }
    } catch (e) {
      // Handle any errors
      reset();
      print("Error picking image: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    image = null;
    bytes = null;
    isLoading = false;
    notifyListeners();
  }
}
