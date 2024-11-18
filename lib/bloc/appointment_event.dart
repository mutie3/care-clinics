part of 'appointment_bloc.dart';

abstract class AppointmentEvent extends Equatable {
  const AppointmentEvent();

  @override
  List<Object> get props => [];
}

class BookAppointmentEvent extends AppointmentEvent {
  final Appointment appointment;

  const BookAppointmentEvent(this.appointment);

  @override
  List<Object> get props => [appointment];
}

class FetchAppointmentsByUserEvent extends AppointmentEvent {
  final String patientName;

  const FetchAppointmentsByUserEvent(this.patientName);

  @override
  List<Object> get props => [patientName];
}

class ModifyAppointmentEvent extends AppointmentEvent {
  final String appointmentId;
  final Map<String, dynamic> updatedData;

  const ModifyAppointmentEvent(this.appointmentId, this.updatedData);

  @override
  List<Object> get props => [appointmentId, updatedData];
}

class DeleteAppointmentEvent extends AppointmentEvent {
  final String appointmentId;

  const DeleteAppointmentEvent(this.appointmentId);

  @override
  List<Object> get props => [appointmentId];
}
