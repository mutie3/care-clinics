import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RatingPage extends StatefulWidget {
  final String appointmentId; // معرف الموعد
  final String doctorName; // اسم الطبيب
  final String appointmentDate; // تاريخ الموعد
  final String appointmentTime; // وقت الموعد

  const RatingPage({
    Key? key,
    required this.appointmentId,
    required this.doctorName,
    required this.appointmentDate,
    required this.appointmentTime,
  }) : super(key: key);

  @override
  _RatingPageState createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  double _rating = 0; // التقييم الافتراضي
  bool _isSubmitting = false; // حالة الزر

  // دالة لحفظ التقييم في Firebase
  Future<void> _submitRating() async {
    setState(() {
      _isSubmitting = true; // تغيير حالة الزر إلى "إرسال"
    });

    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(widget.appointmentId)
          .update({
        'rating': _rating, // حفظ التقييم في Firestore
        'ratingSubmitted': true, // تحديد ما إذا كان التقييم قد تم تقديمه
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rating submitted successfully!')),
      );
      Navigator.pop(context); // العودة إلى الصفحة السابقة بعد التقديم
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit rating: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false; // إعادة حالة الزر بعد الإرسال
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate Your Appointment'),
        backgroundColor: Colors.blueAccent, // تغيير اللون إلى الأزرق الفاتح
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عنوان الطبيب وتفاصيل الموعد
            Text(
              'Doctor: ${widget.doctorName}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Appointment Date: ${widget.appointmentDate} at ${widget.appointmentTime}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // إشعار حول سرية التقييم
            const Text(
              'Your feedback is anonymous and helps us improve the service. We appreciate your honesty!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 20),

            // تعليمات التقييم
            const Text(
              'Please rate your appointment:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),

            // إضافة شريط النجوم
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 40,
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating; // تحديث التقييم
                });
              },
            ),
            const SizedBox(height: 30),

            // زر إرسال التقييم
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitRating,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent, // اللون الأزرق للفأرة
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isSubmitting
                  ? const CircularProgressIndicator()
                  : const Text(
                      'Submit Rating',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
