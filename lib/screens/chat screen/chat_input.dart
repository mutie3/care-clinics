import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants/colors_page.dart';

class ChatInput extends StatelessWidget {
  final TextEditingController messageController;
  final VoidCallback onSendMessage;
  final Function(Uint8List) onSendImage;

  const ChatInput({
    super.key,
    required this.messageController,
    required this.onSendMessage,
    required this.onSendImage,
  });

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();
      onSendImage(imageBytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: isDarkMode
            ? []
            : [BoxShadow(blurRadius: 6, color: Colors.grey.shade300)],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.image,
              color: isDarkMode ? Colors.tealAccent : AppColors.primaryColor,
            ),
            onPressed: _pickImage,
          ),
          Expanded(
            child: TextField(
              controller: messageController,
              maxLines: null, // Allow unlimited lines
              minLines: 1, // Start with 1 line
              decoration: InputDecoration(
                hintText: '97'.tr,
                hintStyle: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey.shade600,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : AppColors.textBox,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.send,
              color: isDarkMode ? Colors.tealAccent : AppColors.primaryColor,
            ),
            onPressed: onSendMessage,
          ),
        ],
      ),
    );
  }
}
