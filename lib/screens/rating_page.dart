import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RatingPage extends StatefulWidget {
  final String doctorId; // معرّف الطبيب الذي سيتم تقييمه

  RatingPage({required this.doctorId});

  @override
  _RatingPageState createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  double _rating = 3.0;
  TextEditingController _commentController = TextEditingController();

  // دالة لإرسال التقييم
  Future<void> submitRating() async {
    String userId =
        'user123'; // هنا قم بجلب معرّف المستخدم من Firebase أو SharedPreferences

    try {
      await FirebaseFirestore.instance.collection('ratings').add({
        'userId': userId,
        'doctorId': widget.doctorId,
        'rating': _rating,
        'comment': _commentController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rating submitted successfully!')),
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
      appBar: AppBar(title: Text("Rate Doctor")),
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
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
              itemBuilder: (context, index) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
            ),
            SizedBox(height: 20),
            // حقل التعليق
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: "Add a comment",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            // زر إرسال التقييم
            ElevatedButton(
              onPressed: submitRating,
              child: Text("Submit Rating"),
            ),
          ],
        ),
      ),
    );
  }
}
