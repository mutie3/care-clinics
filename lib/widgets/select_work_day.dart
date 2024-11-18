import 'package:care_clinic/constants/colors_page.dart';
import 'package:flutter/material.dart';

class selectWorkDays extends StatefulWidget {
  const selectWorkDays({super.key});

  @override
  State<selectWorkDays> createState() => _selectWorkDaysState();
}

class _selectWorkDaysState extends State<selectWorkDays> {
  List<String> days = const ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
  Set<int> selectedWorkDays = {};

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List<Widget>.generate(
        days.length,
        (index) {
          return Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  if (selectedWorkDays.contains(index)) {
                    selectedWorkDays.remove(index);
                  } else {
                    selectedWorkDays.add(index);
                  }
                });
              },
              child: Container(
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primaryColor),
                  color: selectedWorkDays.contains(index)
                      ? AppColors.primaryColor
                      : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    days[index],
                    style: TextStyle(
                      fontSize: 18,
                      color: selectedWorkDays.contains(index)
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
