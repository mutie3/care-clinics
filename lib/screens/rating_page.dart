import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RatingPage extends StatefulWidget {
  final String doctorId;

  const RatingPage({super.key, required this.doctorId});

  @override
  RatingPageState createState() => RatingPageState();
}

class RatingPageState extends State<RatingPage> {
  double _rating = 3.0;
  final TextEditingController _commentController = TextEditingController();

  Future<void> submitRating() async {
    String userId = 'user123';

    try {
      await FirebaseFirestore.instance.collection('ratings').add({
        'userId': userId,
        'doctorId': widget.doctorId,
        'rating': _rating,
        'comment': _commentController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rating submitted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting rating: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rate Doctor")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // واجهة تقييم النجوم
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 40,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
              itemBuilder: (context, index) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 20),
            // حقل التعليق
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: "Add a comment",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            // زر إرسال التقييم
            ElevatedButton(
              onPressed: submitRating,
              child: const Text("Submit Rating"),
            ),
          ],
        ),
      ),
    );
  }
}
