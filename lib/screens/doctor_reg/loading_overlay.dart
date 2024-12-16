import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final String message;

  const LoadingOverlay({Key? key, this.message = "Loading..."})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withOpacity(0.5),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Color(0xFF1E88E5)),
            const SizedBox(height: 20),
            Text(
              message,
              style: const TextStyle(color: Color(0xFF1E88E5), fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
