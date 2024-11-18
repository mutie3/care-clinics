import 'dart:typed_data';
import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final bool isUser;
  final dynamic message;
  const MessageBubble({super.key, required this.isUser, required this.message});

  @override
  Widget build(BuildContext context) {
    if (message['type'] == 'text') {
      return Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isUser ? Colors.cyan : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message['data'] ?? '',
            style: TextStyle(color: isUser ? Colors.white : Colors.black),
          ),
        ),
      );
    } else if (message['type'] == 'image' && message['data'] is Uint8List) {
      return Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Column(
            children: [
              Image.memory(
                message['data'],
                height: 200,
                fit: BoxFit.cover,
              ),
              if (message['sender'] == 'ai' && message['data'] != null)
                Text('AI Response: ${message['data']}'),
            ],
          ),
        ),
      );
    }
    return Container();
  }
}
