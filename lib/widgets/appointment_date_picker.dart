import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentDatePicker extends StatefulWidget {
  final String doctorId; // ID الطبيب المستخدم لاسترجاع البيانات
  final String clinicId; // ID العيادة

  const AppointmentDatePicker(
      {super.key, required this.doctorId, required this.clinicId});

  @override
  State<AppointmentDatePicker> createState() => _AppointmentDatePickerState();
}

class _AppointmentDatePickerState extends State<AppointmentDatePicker> {
  List<String> workingDays = []; // أيام دوام الطبيب
  String? selectedDay; // اليوم المختار
  TimeOfDay? selectedTime; // الوقت المختار
  bool isLoading = true; // للتحقق إذا كانت البيانات تُحمّل

  @override
  void initState() {
    super.initState();
    _fetchWorkingDays();
  }

  // استرجاع أيام دوام الطبيب من Firebase
  Future<void> _fetchWorkingDays() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('clinics') // مجموعة العيادات
          .doc(widget.clinicId) // معرّف العيادة
          .collection('doctors') // مجموعة الأطباء داخل العيادة
          .doc(widget.doctorId) // معرّف الطبيب
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        print('Fetched doctor data: $data'); // طباعة البيانات للتحقق
        setState(() {
          workingDays = List<String>.from(data?['working_days'] ?? []);
          isLoading = false;
        });
      } else {
        print('Doctor not found');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching working days: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // إنشاء قائمة الأوقات المتاحة (كل نصف ساعة)
  List<TimeOfDay> _generateTimeSlots() {
    List<TimeOfDay> slots = [];
    for (int hour = 9; hour < 18; hour++) {
      // ساعات العمل: من 9 صباحًا إلى 6 مساءً
      for (int minute = 0; minute < 60; minute += 30) {
        slots.add(TimeOfDay(hour: hour, minute: minute));
      }
    }
    return slots;
  }

  @override
  Widget build(BuildContext context) {
    final timeSlots = _generateTimeSlots();

    return isLoading
        ? const Center(child: CircularProgressIndicator()) // تحميل البيانات
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // اختيار اليوم
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select a day',
                  border: OutlineInputBorder(),
                ),
                value: selectedDay,
                items: workingDays.map((day) {
                  return DropdownMenuItem<String>(
                    value: day,
                    child: Text(day),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDay = value;
                    selectedTime = null; // إعادة تعيين الوقت عند تغيير اليوم
                  });
                },
              ),
              const SizedBox(height: 20),

              // اختيار الوقت
              if (selectedDay != null) ...[
                const Text(
                  'Select a time:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<TimeOfDay>(
                  decoration: const InputDecoration(
                    labelText: 'Select a time',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedTime,
                  items: timeSlots.map((slot) {
                    return DropdownMenuItem<TimeOfDay>(
                      value: slot,
                      child: Text(slot.format(context)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedTime = value;
                    });
                  },
                ),
              ],
              const SizedBox(height: 20),

              // عرض النتيجة المختارة
              if (selectedDay != null && selectedTime != null) ...[
                Text(
                  'Selected Day: $selectedDay',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Selected Time: ${selectedTime!.format(context)}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ],
          );
  }
}
