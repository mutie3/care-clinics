import 'package:care_clinic/constants/colors_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'login_page.dart';
import '../field_regestration/phone_field.dart';

class VerifyPhoneNumberPage extends StatefulWidget {
  const VerifyPhoneNumberPage({super.key});

  @override
  VerifyPhoneNumberPageState createState() => VerifyPhoneNumberPageState();
}

class VerifyPhoneNumberPageState extends State<VerifyPhoneNumberPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _verificationId;
  bool _isVerificationSent = false;
  bool _isOTPVerified = false;
  bool _isResending = false; // للتأكد من أننا في حالة إعادة إرسال الرمز

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Verification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (!_isVerificationSent) ...[
                PhoneField(controller: _phoneController), // حقل الرقم
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isResending
                      ? null
                      : () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            await _sendVerificationCode();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    backgroundColor: AppColors.primaryColor,
                  ),
                  child: Text(
                    _isResending ? 'Please wait...' : 'Send Verification Code',
                    style: const TextStyle(
                        fontSize: 18, color: AppColors.scaffoldBackgroundColor),
                  ),
                ),
              ],
              if (_isVerificationSent) ...[
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child:
                      Text('A verification code has been sent to your phone.'),
                ),
                const SizedBox(height: 20),
                PinCodeTextField(
                  appContext: context,
                  length: 6,
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {},
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.underline,
                    borderWidth: 2,
                    fieldHeight: 50,
                    fieldWidth: 40,
                    activeColor: AppColors.primaryColor,
                    inactiveColor: AppColors.textColor,
                    selectedColor: AppColors.primaryColor,
                    activeFillColor: Colors.white,
                    inactiveFillColor: Colors.white,
                    selectedFillColor: Colors.white,
                  ),
                  onCompleted: (value) {
                    _verifyOTP();
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isResending
                      ? null
                      : () async {
                          await _verifyOTP();
                        },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    backgroundColor: AppColors.primaryColor,
                  ),
                  child: const Text(
                    'Verify OTP',
                    style: TextStyle(
                        fontSize: 18, color: AppColors.scaffoldBackgroundColor),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isResending
                      ? null
                      : () async {
                          setState(() {
                            _isResending = true; // بدء إعادة الإرسال
                          });
                          await _sendVerificationCode(); // إعادة إرسال الرمز
                        },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    backgroundColor: AppColors.primaryColor,
                  ),
                  child: const Text(
                    'Resend Verification Code',
                    style: TextStyle(
                        fontSize: 18, color: AppColors.scaffoldBackgroundColor),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // إرسال رمز التحقق
  Future<void> _sendVerificationCode() async {
    try {
      String phoneNumber = _phoneController.text.trim();

      if (!phoneNumber.startsWith('+962')) {
        phoneNumber = '+962' + phoneNumber.replaceFirst(RegExp(r'^(07)'), '');
      }

      print(phoneNumber);

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Phone number automatically verified.')),
          );
        },
        verificationFailed: (FirebaseAuthException e) {
          print('Verification failed: ${e.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Verification failed: ${e.message}')),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _isVerificationSent = true;
            _isResending = false;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            _verificationId = verificationId;
          });
        },
      );
    } catch (e) {
      setState(() {
        _isResending = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // التحقق من OTP
  Future<void> _verifyOTP() async {
    try {
      final code = _otpController.text.trim();
      if (code.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter the OTP.')),
        );
        return;
      }

      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: code,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      setState(() {
        _isOTPVerified = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number verified successfully.')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
