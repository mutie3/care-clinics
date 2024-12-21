import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RatingPage extends StatefulWidget {
  final String appointmentId;
  final String doctorName;
  final String appointmentDate;
  final String appointmentTime;
  final String doctorId;
  const RatingPage({
    super.key,
    required this.appointmentId,
    required this.doctorName,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.doctorId,
  });

  @override
  RatingPageState createState() => RatingPageState();
}

class RatingPageState extends State<RatingPage> {
  double _rating = 0;
  bool _isSubmitting = false;

  Future<void> _submitRating() async {
    setState(() {
      _isSubmitting = true;
    });
    print("Doctor ID: ${widget.doctorId}");

    try {
      await FirebaseFirestore.instance.collection('ratings').add({
        'appointmentId': widget.appointmentId,
        'rating': _rating,
        'ratingSubmitted': true,
        'doctorId': widget.doctorId
      });
      await _calculateAndStoreDoctorRating(widget.doctorId);
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

  Future<void> _calculateAndStoreDoctorRating(String doctorId) async {
    try {
      // 1. جلب التقييمات الخاصة بالطبيب من مجموعة ratings
      QuerySnapshot ratingsSnapshot = await FirebaseFirestore.instance
          .collection('ratings')
          .where('doctorId', isEqualTo: doctorId)
          .get();

      // 2. حساب المتوسط
      num totalRating = 0;
      int ratingCount = 0;

      for (var doc in ratingsSnapshot.docs) {
        var ratingData = doc.data() as Map<String, dynamic>;
        if (ratingData['rating'] != null) {
          totalRating += ratingData['rating'];
          ratingCount++;
        }
      }

      if (ratingCount > 0) {
        double averageRating = totalRating / ratingCount;

        // 3. البحث عن العيادات التي تحتوي على الطبيب باستخدام doctorId
        QuerySnapshot clinicSnapshot = await FirebaseFirestore.instance
            .collection('clinics')
            .get(); // احصل على جميع العيادات

        bool doctorFoundInClinic = false;

        for (var clinicDoc in clinicSnapshot.docs) {
          // التحقق من وجود الطبيب في مجموعة 'doctors' داخل العيادة
          DocumentSnapshot doctorDoc = await clinicDoc.reference
              .collection('doctors')
              .doc(doctorId)
              .get();

          if (doctorDoc.exists) {
            // إذا تم العثور على الطبيب في العيادة، نقوم بتحديث التقييم
            await clinicDoc.reference
                .collection('doctors')
                .doc(doctorId)
                .update({
              'averageRating': averageRating,
            });

            doctorFoundInClinic = true;
            print('The average rating for doctor $doctorId is: $averageRating');
            break; // لا حاجة للبحث في العيادات الأخرى
          }
        }

        if (!doctorFoundInClinic) {
          print('No clinic found for doctor $doctorId');
        }
      } else {
        print('No ratings available for doctor $doctorId');
      }
    } catch (e) {
      print('Error calculating and storing doctor rating: $e');
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
