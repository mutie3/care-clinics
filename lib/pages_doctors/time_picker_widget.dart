// import 'package:care_clinic/constants/colors_page.dart';
// import 'package:care_clinic/constants/theme_dark_mode.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:provider/provider.dart';

// class TimePickerWidget extends StatelessWidget {
//   final TimeOfDay selectedTime;
//   final Function(TimeOfDay) onSelectTime;

//   const TimePickerWidget({
//     super.key,
//     required this.selectedTime,
//     required this.onSelectTime,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<ThemeProvider>(
//       builder: (context, themeProvider, child) {
//         return Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 '92'.tr,
//                 style: const TextStyle(
//                   color: Color(0xff363636),
//                   fontSize: 25,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               GestureDetector(
//                 onTap: () async {
//                   final TimeOfDay? picked = await showTimePicker(
//                     context: context,
//                     initialTime: selectedTime,
//                   );
//                   if (picked != null && picked != selectedTime) {
//                     onSelectTime(picked);
//                   }
//                 },
//                 child: Container(
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
//                   decoration: BoxDecoration(
//                     color: themeProvider.isDarkMode
//                         ? Colors.grey
//                         : AppColors.primaryColor,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         selectedTime.format(context),
//                         style: const TextStyle(
//                           fontSize: 18,
//                           color: Colors.black,
//                         ),
//                       ),
//                       const Icon(Icons.access_time, color: Colors.black),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
