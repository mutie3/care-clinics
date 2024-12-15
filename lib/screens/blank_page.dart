import 'package:flutter/material.dart';

class BlankPage extends StatelessWidget {
  const BlankPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'This is a blank page', // يمكنك ترك هذه الصفحة فارغة
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
