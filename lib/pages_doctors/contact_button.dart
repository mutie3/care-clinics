import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactButton extends StatelessWidget {
  final String doctorPhoneNumber;

  const ContactButton({super.key, required this.doctorPhoneNumber});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SizedBox(
              width: 20,
            ),
            Text(
              '89'.tr,
              style: const TextStyle(
                color: Color(0xff363636),
                fontSize: 25,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                if (doctorPhoneNumber.isNotEmpty) {
                  final Uri whatsappUrl = Uri.parse(
                      "https://wa.me/$doctorPhoneNumber?text=هل ممكن أن احصل على استفسار");
                  launchUrl(whatsappUrl);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('90'.tr)),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Image.asset(
                  'images/whatsapp_icon.png',
                  width: 50,
                  height: 50,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (doctorPhoneNumber.isNotEmpty) {
                  launch('tel:$doctorPhoneNumber');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('90'.tr)),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Image.asset(
                  'images/call_icon.png',
                  width: 50,
                  height: 50,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
