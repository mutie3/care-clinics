// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../bloc/appointment_bloc.dart';
// import '../data/appointment .dart';

// class ModifyAppointmentPage extends StatelessWidget {
//   final Appointment appointment;

//   const ModifyAppointmentPage({super.key, required this.appointment});

//   @override
//   Widget build(BuildContext context) {
//     final TextEditingController doctorController =
//         TextEditingController(text: appointment.doctorName);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Modify Appointment'),
//         backgroundColor: Theme.of(context).primaryColor,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: doctorController,
//               decoration: const InputDecoration(labelText: 'Doctor'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 final updatedAppointment = Appointment(
//                   id: appointment.id,
//                   patientName: appointment.patientName,
//                   doctorName: doctorController.text,
//                   appointmentDate: appointment.appointmentDate,
//                   appointmentTime: appointment.appointmentTime,
//                 );

//                 // Dispatch the ModifyAppointmentEvent with the updated data
//                 context.read<AppointmentBloc>().add(
//                       ModifyAppointmentEvent(
//                         appointment.id,
//                         updatedAppointment.toMap(),
//                       ),
//                     );

//                 Navigator.pop(context);
//               },
//               child: const Text('Save Changes'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
