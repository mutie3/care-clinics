import 'package:flutter/material.dart';
import 'message_bubble.dart';

class MessageList extends StatelessWidget {
  final List<Map<String, dynamic>> messages;

  const MessageList({super.key, required this.messages});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return MessageBubble(
          isUser: message['sender'] == 'user',
          message: message,
        );
      },
    );
  }
}
