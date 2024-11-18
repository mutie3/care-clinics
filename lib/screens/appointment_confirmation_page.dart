import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/appointment_bloc.dart';

class UserAppointmentsPage extends StatelessWidget {
  final String patientName = "John Doe";

  const UserAppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        backgroundColor: Colors.blue,
      ),
      body: BlocProvider(
        create: (context) =>
            AppointmentBloc()..add(FetchAppointmentsByUserEvent(patientName)),
        child: BlocBuilder<AppointmentBloc, AppointmentState>(
          builder: (context, state) {
            if (state is AppointmentLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AppointmentLoaded) {
              final appointments = state.appointments;
              if (appointments.isEmpty) {
                return const Center(
                  child: Text(
                    'No appointments found.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                );
              }
              return ListView.builder(
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final appointment = appointments[index];
                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      leading: const Icon(Icons.event, color: Colors.green),
                      title: Text(
                        'Doctor: ${appointment.doctorName}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Date: ${appointment.appointmentDate.toLocal()}'
                        '\nTime: ${appointment.appointmentTime.toLocal()}',
                      ),
                    ),
                  );
                },
              );
            } else if (state is AppointmentFailure) {
              // Print the error to the console
              print('Error occurred: ${state.error}');

              // Show error message with retry button
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 50),
                    const SizedBox(height: 10),
                    Text(
                      'Error: ${state.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<AppointmentBloc>()
                            .add(FetchAppointmentsByUserEvent(patientName));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            } else {
              return const Center(child: Text('Start fetching appointments.'));
            }
          },
        ),
      ),
    );
  }
}
