import 'dart:io';
import 'package:care_clinic/constants/colors_page.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class UploadFile extends StatefulWidget {
  final Function(File)? onFilePicked; // باراميتر onFilePicked

  const UploadFile({this.onFilePicked, Key? key}) : super(key: key);

  @override
  _UploadFileState createState() => _UploadFileState();
}

class _UploadFileState extends State<UploadFile> {
  File? file;
  PlatformFile? platformFile;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primaryColor),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          file == null
              ? Center(
                  child: Text(
                    '132'.tr,
                    style: const TextStyle(
                      color: AppColors.textColor,
                      fontFamily: 'Tajawal',
                      fontSize: 18,
                    ),
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black54),
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.textColor.withOpacity(0.2),
                        ),
                        height: 50,
                        width: 50,
                        child: FaIcon(
                          platformFile!.extension == 'pdf'
                              ? FontAwesomeIcons.filePdf
                              : FontAwesomeIcons.fileWord,
                          size: 30,
                          color: platformFile!.extension == 'pdf'
                              ? Colors.red
                              : Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        platformFile!.name.split('.').first,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
          if (file == null)
            Positioned.fill(
              child: MaterialButton(
                onPressed: _pickFile,
                color: AppColors.scaffoldBackgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '58'.tr,
                  style: TextStyle(
                    color: AppColors.primaryColor.withOpacity(0.6),
                    fontFamily: 'Tajawal',
                  ),
                ),
              ),
            ),
          if (file != null)
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                onPressed: _deleteFile,
                icon: const FaIcon(
                  FontAwesomeIcons.trash,
                  size: 20,
                  color: Colors.black,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Function to pick a single PDF or Word file
  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      setState(() {
        file = File(result.paths.first!);
        platformFile = result.files.first;
      });
      _showCustomSnackBar('133'.tr);

      // استدعاء الدالة الممررة في onFilePicked
      widget.onFilePicked?.call(file!);
    } else {
      _showCustomSnackBar('134'.tr);
    }
  }

  void _deleteFile() {
    setState(() {
      file = null;
      platformFile = null;
    });
    _showCustomSnackBar('135'.tr);
  }

  void _showCustomSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.black.withOpacity(0.7),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
