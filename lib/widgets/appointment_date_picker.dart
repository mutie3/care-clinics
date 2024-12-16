import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentDatePicker extends StatefulWidget {
  final String doctorId;
  final String clinicId;

  const AppointmentDatePicker({
    Key? key,
    required this.doctorId,
    required this.clinicId,
    required Null Function(DateTime date, String time) onDateSelected,
  }) : super(key: key);

  @override
  State<AppointmentDatePicker> createState() => _AppointmentDatePickerState();
}

class _AppointmentDatePickerState extends State<AppointmentDatePicker> {
  List<String> workingDays = [];
  String? selectedDay;
  TimeOfDay? selectedTime;
  bool isLoading = true;
  List<TimeOfDay> bookedTimes = [];

  // خريطة لتحويل اختصارات الأيام إلى أسمائها الكاملة
  final Map<String, String> dayMapping = {
    "SUN": "Sunday",
    "MON": "Monday",
    "TUE": "Tuesday",
    "WED": "Wednesday",
    "THU": "Thursday",
    "FRI": "Friday",
    "SAT": "Saturday",
  };

  @override
  void initState() {
    super.initState();
    _fetchWorkingDays();
  }

  Future<void> _fetchWorkingDays() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('clinics')
          .doc(widget.clinicId)
          .collection('doctors')
          .doc(widget.doctorId)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        setState(() {
          workingDays = List<String>.from(data?['working_days'] ?? []);
          isLoading = false;
        });

        // بعد تحميل أيام العمل، نحقق من المواعيد المحجوزة
        _fetchBookedTimes();
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // دالة لجلب المواعيد المحجوزة
  Future<void> _fetchBookedTimes() async {
    try {
      final bookedSnapshot = await FirebaseFirestore.instance
          .collection('clinics')
          .doc(widget.clinicId)
          .collection('doctors')
          .doc(widget.doctorId)
          .collection('appointments')
          .where('day', isEqualTo: selectedDay)
          .get();

      List<TimeOfDay> bookedList = [];
      for (var doc in bookedSnapshot.docs) {
        var time = doc['time'].toDate();
        bookedList.add(TimeOfDay(hour: time.hour, minute: time.minute));
      }

      setState(() {
        bookedTimes = bookedList;
      });
    } catch (e) {
      print("Error fetching booked times: $e");
    }
  }

  // هذه الدالة تقوم بتوليد قائمة من المواعيد من الساعة 9 صباحاً إلى الساعة 5 مساءً مع نصف ساعة بين كل موعد.
  List<TimeOfDay> _generateTimeSlots() {
    List<TimeOfDay> slots = [];
    for (int hour = 9; hour < 18; hour++) {
      for (int minute = 0; minute < 60; minute += 30) {
        TimeOfDay timeSlot = TimeOfDay(hour: hour, minute: minute);
        // إزالة الوقت المحجوز من القائمة
        if (!bookedTimes.contains(timeSlot)) {
          slots.add(timeSlot);
        }
      }
    }
    return slots;
  }

  Future<void> _pickTime() async {
    // الحصول على المواعيد الممكنة
    List<TimeOfDay> timeSlots = _generateTimeSlots();

    // عرض قائمة المواعيد
    TimeOfDay? pickedTime = await showDialog<TimeOfDay>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select a time'),
          content: SingleChildScrollView(
            child: Column(
              children: timeSlots.map((time) {
                return ListTile(
                  title: Text(time.format(context)),
                  onTap: () {
                    Navigator.of(context).pop(time);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );

    // إذا تم اختيار الوقت
    if (pickedTime != null) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select a day:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: workingDays.map((shortDay) {
                  final fullDay = dayMapping[shortDay] ?? shortDay;
                  final isSelected = shortDay == selectedDay;

                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isSelected ? Colors.blue : Colors.grey[300],
                      foregroundColor: isSelected ? Colors.white : Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    onPressed: () {
                      setState(() {
                        selectedDay = shortDay;
                        selectedTime = null;
                        _fetchBookedTimes(); // تحديث المواعيد المحجوزة
                      });
                    },
                    child: Text(
                      fullDay,
                      style: const TextStyle(fontSize: 16),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              if (selectedDay != null) ...[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        selectedTime == null ? Colors.grey[300] : Colors.blue,
                    foregroundColor:
                        selectedTime == null ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  onPressed: _pickTime,
                  child: Text(
                    selectedTime != null
                        ? selectedTime!.format(context)
                        : 'Pick a time',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ],
          );
  }
}

class CustomTimePicker extends StatefulWidget {
  const CustomTimePicker({super.key});

  @override
  _CustomTimePickerState createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  TimeOfDay? selectedTime;

  // هذه الدالة تقوم بتوليد قائمة من المواعيد من الساعة 9 صباحاً إلى الساعة 5 مساءً مع نصف ساعة بين كل موعد.
  List<TimeOfDay> _generateTimeSlots() {
    List<TimeOfDay> slots = [];
    for (int hour = 9; hour < 18; hour++) {
      for (int minute = 0; minute < 60; minute += 30) {
        slots.add(TimeOfDay(hour: hour, minute: minute));
      }
    }
    return slots;
  }

  @override
  Widget build(BuildContext context) {
    List<TimeOfDay> timeSlots = _generateTimeSlots();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select a time:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<TimeOfDay>(
          decoration: const InputDecoration(
            labelText: 'Select a time',
            border: OutlineInputBorder(),
          ),
          value: selectedTime,
          items: timeSlots.map((TimeOfDay slot) {
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
        const SizedBox(height: 20),
        if (selectedTime != null)
          Text(
            'Selected Time: ${selectedTime!.format(context)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
      ],
    );
  }
}
