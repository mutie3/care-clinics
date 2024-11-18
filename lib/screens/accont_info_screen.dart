import 'package:care_clinic/constants/colors_page.dart';
import 'package:care_clinic/constants/theme_dark_mode.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountInfoScreen extends StatefulWidget {
  const AccountInfoScreen({super.key});

  @override
  AccountInfoScreenState createState() => AccountInfoScreenState();
}

class AccountInfoScreenState extends State<AccountInfoScreen> {
  String gender = 'ذكر';
  bool isEditing = false;
  DateTime? birthDate; // متغير لتخزين تاريخ الميلاد

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
                    isEditing = !isEditing;
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
                    TextFormField(
                      initialValue: 'mutieaz@yahoo.com',
                      enabled: isEditing,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        labelText: 'البريد الإلكتروني',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: themeProvider.isDarkMode
                            ? AppColors.textBox
                            : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: 'Mutie Abu Zanat',
                      enabled: isEditing,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        labelText: 'الاسم الأول',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: themeProvider.isDarkMode
                            ? AppColors.textBox
                            : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: 'Zanat',
                      enabled: isEditing,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        labelText: 'الاسم الأخير',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: themeProvider.isDarkMode
                            ? AppColors.textBox
                            : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        if (isEditing) {
                          _selectBirthDate(context);
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
                          prefixIcon: const Icon(
                              Icons.calendar_today), // إضافة أيقونة التقويم
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
                // هنا يمكنك تنفيذ كود حذف الحساب
                Navigator.of(context).pop();
                print('حساب تم حذفه'); // يمكنك استبداله بكود الحذف الفعلي
              },
              child: const Text('حذف', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
