import 'package:care_clinic/widgets/custom_text_fieled.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NameField extends StatelessWidget {
  final TextEditingController
      controllerFirstName; // إضافة المتغير للتحكم في الاسم الأول
  final TextEditingController
      controllerLastName; // إضافة المتغير للتحكم في الاسم الأخير

  const NameField({
    super.key,
    required this.controllerFirstName,
    required this.controllerLastName,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            controller: controllerFirstName, // تمرير المتحكم للاسم الأول
            text: '47'.tr,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: CustomTextField(
            controller: controllerLastName, // تمرير المتحكم للاسم الأخير
            text: '48'.tr,
          ),
        ),
      ],
    );
  }
}
