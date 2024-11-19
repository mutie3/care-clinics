import 'package:care_clinic/constants/colors_page.dart';
import 'package:care_clinic/constants/theme_dark_mode.dart';
import 'package:care_clinic/widgets/custom_text_fieled.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountInfoScreen extends StatefulWidget {
  const AccountInfoScreen({super.key});

  @override
  AccountInfoScreenState createState() => AccountInfoScreenState();
}

class AccountInfoScreenState extends State<AccountInfoScreen> {
  String gender = 'ذكر';
  bool isEditing = false; // التحكم في إمكانية التعديل
  DateTime? birthDate;

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('معلومات الحساب', style: TextStyle(fontSize: 20)),
            backgroundColor: themeProvider.isDarkMode
                ? AppColors.textBox
                : AppColors.primaryColor,
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(
                  isEditing ? Icons.save : Icons.edit,
                  color: themeProvider.isDarkMode
                      ? Colors.grey
                      : AppColors.scaffoldBackgroundColor,
                ),
                onPressed: () {
                  setState(() {
                    isEditing = !isEditing; // التبديل بين حالتي التعديل
                  });
                },
              ),
            ],
          ),
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                color:
                    themeProvider.isDarkMode ? Colors.grey[900] : Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      text: 'البريد الإلكتروني',
                      controller:
                          TextEditingController(text: 'mutieaz@yahoo.com'),
                      icon: const Icon(Icons.email),
                      onChanged: (value) {},
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال البريد الإلكتروني';
                        }
                        return null;
                      },
                      obscureText: false,
                      enabled: isEditing, // السماح بالتعديل بناءً على الحالة
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      text: 'الاسم الأول',
                      controller:
                          TextEditingController(text: 'Mutie Abu Zanat'),
                      icon: const Icon(Icons.person),
                      onChanged: (value) {},
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال الاسم الأول';
                        }
                        return null;
                      },
                      obscureText: false,
                      enabled: isEditing, // السماح بالتعديل بناءً على الحالة
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      text: 'الاسم الأخير',
                      controller: TextEditingController(text: 'Zanat'),
                      icon: const Icon(Icons.person_outline),
                      onChanged: (value) {},
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال الاسم الأخير';
                        }
                        return null;
                      },
                      obscureText: false,
                      enabled: isEditing, // السماح بالتعديل بناءً على الحالة
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        if (isEditing) {
                          _selectBirthDate(
                              context); // السماح بتغيير تاريخ الميلاد عند التعديل
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'تاريخ الميلاد (اختياري)',
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: themeProvider.isDarkMode
                              ? AppColors.textBox
                              : Colors.white,
                          prefixIcon: const Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          birthDate == null
                              ? 'اختر تاريخ الميلاد'
                              : '${birthDate!.day}/${birthDate!.month}/${birthDate!.year}',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: birthDate == null
                                ? Colors.grey
                                : AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('الجنس', style: TextStyle(fontSize: 16)),
                    Row(
                      children: [
                        Radio<String>(
                          value: 'ذكر',
                          groupValue: gender,
                          onChanged: (value) {
                            if (isEditing) {
                              setState(() {
                                gender = value!;
                              });
                            }
                          },
                        ),
                        const Text('ذكر'),
                        Radio<String>(
                          value: 'أنثى',
                          groupValue: gender,
                          onChanged: (value) {
                            if (isEditing) {
                              setState(() {
                                gender = value!;
                              });
                            }
                          },
                        ),
                        const Text('أنثى'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 48, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        onPressed: () {
                          _confirmDeleteAccount();
                        },
                        child: const Text('احذف حسابي',
                            style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: birthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppColors.primaryColor,
            hintColor: AppColors.primaryColor,
            colorScheme:
                const ColorScheme.light(primary: AppColors.primaryColor),
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != birthDate) {
      setState(() {
        birthDate = picked;
      });
    }
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تأكيد الحذف',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text(
            'هل أنت متأكد أنك تريد حذف حسابك؟',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('إلغاء',
                  style: TextStyle(color: AppColors.textColor)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                print('حساب تم حذفه');
              },
              child: const Text('حذف', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
