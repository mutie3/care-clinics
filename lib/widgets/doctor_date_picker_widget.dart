import 'package:flutter/material.dart';

class DoctorDatePickerWidget extends StatefulWidget {
  final String doctorName;
  final List<int> workingDays; // 0 = Sunday, 1 = Monday, ..., 6 = Saturday
  final ValueChanged<DateTime> onDateSelected;

  const DoctorDatePickerWidget({
    super.key,
    required this.doctorName,
    required this.workingDays,
    required this.onDateSelected,
  });

  @override
  _DoctorDatePickerWidgetState createState() => _DoctorDatePickerWidgetState();
}

class _DoctorDatePickerWidgetState extends State<DoctorDatePickerWidget> {
  DateTime _selectedDate = DateTime.now();

  // دالة لاختيار تاريخ
  Future<void> _selectDate(BuildContext context) async {
    DateTime today = DateTime.now();
    DateTime firstAvailableDate =
        today.isBefore(DateTime(today.year, today.month, today.day, 0, 0, 0))
            ? today
            : DateTime(today.year, today.month, today.day); // اليوم الحالي

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: firstAvailableDate,
      firstDate: firstAvailableDate, // لا يمكن اختيار التواريخ السابقة
      lastDate: DateTime(today.year + 1, today.month,
          today.day), // تحديد الحد الأقصى لتاريخ الحجز (عام كامل مثلاً)
      selectableDayPredicate: (DateTime date) {
        // تحقق من أن اليوم في أيام الدوام المسموحة للطبيب
        int dayOfWeek = date.weekday - 1; // 0 = الأحد، 6 = السبت
        return widget.workingDays.contains(dayOfWeek);
      },
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
      widget.onDateSelected(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Select Date for Dr. ${widget.doctorName}',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            Text(
              "${_selectedDate.toLocal()}".split(' ')[0], // عرض التاريخ المحدد
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const Icon(
              Icons.calendar_today,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
