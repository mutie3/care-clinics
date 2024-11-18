import 'package:care_clinic/constants/colors_page.dart';
import 'package:care_clinic/constants/theme_dark_mode.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DatePickerWidget extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onSelectDate;

  const DatePickerWidget({
    super.key,
    required this.selectedDate,
    required this.onSelectDate,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Date',
                style: TextStyle(
                  color: Color(0xff363636),
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null && picked != selectedDate) {
                    onSelectDate(picked);
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode
                        ? Colors.grey
                        : AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('EEE, MMM d, yyyy').format(selectedDate),
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      const Icon(Icons.calendar_today, color: Colors.black),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
