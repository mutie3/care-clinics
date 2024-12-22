import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../widgets/custom_phone_field.dart';

class ChangePhonePage extends StatefulWidget {
  const ChangePhonePage({Key? key}) : super(key: key);

  @override
  _ChangePhonePageState createState() => _ChangePhonePageState();
}

class _ChangePhonePageState extends State<ChangePhonePage> {
  final TextEditingController _phoneController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;

  // جلب رقم الهاتف الحالي من Firestore
  Future<void> _getCurrentPhoneNumber() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        // جلب بيانات المستخدم من Firestore
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final phone = userDoc['phone'] ?? ''; // الحصول على رقم الهاتف
          _phoneController.text = phone; // تعيينه في المربع
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء جلب رقم الهاتف: $e')),
        );
      }
    }
  }

  // للتحقق من صحة الرقم
  String? _validatePhoneNumber(String value) {
    if (value.isEmpty) {
      return "245".tr; // "رقم الهاتف لا يمكن أن يكون فارغاً"
    }
    if (value.length < 9) {
      return "246".tr; // "رقم الهاتف يجب أن يحتوي على 10 أرقام"
    }
    return null;
  }

  Future<void> _updatePhoneNumber() async {
    if (_phoneController.text.isEmpty ||
        _validatePhoneNumber(_phoneController.text) != null) {
      // إظهار رسالة خطأ إذا كان الرقم غير صالح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("247".tr)), // "الرجاء إدخال رقم هاتف صالح"
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final user = _auth.currentUser;
      if (user != null) {
        // تحديث الرقم في Firestore
        await _firestore.collection('users').doc(user.uid).update({
          'phone': _phoneController.text,
        });

        // إظهار رسالة تأكيد
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("248".tr)), // "تم تحديث رقم الهاتف بنجاح"
        );

        Navigator.pop(context); // العودة إلى الصفحة السابقة
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('249'.tr + e.toString())), // "حدث خطأ: "
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentPhoneNumber(); // جلب رقم الهاتف عند بداية الصفحة
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '251'.tr, // Use the translation for title text here
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: Theme.of(context).brightness == Brightness.dark
                  ? [Colors.blueGrey, Colors.blueGrey.shade700]
                  : [Colors.blueAccent, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
        elevation: 5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),
              CustomPhoneField(
                controller: _phoneController,
              ),
              const SizedBox(height: 20),

              // Loading or Button Display
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        backgroundColor: Colors.blueAccent,
                      ),
                      onPressed: _updatePhoneNumber,
                      child: Text(
                        "252".tr, // "تحديث رقم الهاتف"
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
