part of 'appointment_bloc.dart';

abstract class AppointmentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadAppointments extends AppointmentEvent {}

class AddAppointment extends AppointmentEvent {
  final Appointment appointment;

  AddAppointment(this.appointment);

  @override
  List<Object?> get props => [appointment];
}

class UpdateAppointment extends AppointmentEvent {
  final Appointment appointment;

  UpdateAppointment(this.appointment);

  @override
  List<Object?> get props => [appointment];
}

class DeleteAppointment extends AppointmentEvent {
  final String appointmentId;

  DeleteAppointment(this.appointmentId);

  @override
  List<Object?> get props => [appointmentId];
}
