part of 'appointment_bloc.dart';

abstract class AppointmentState extends Equatable {
  const AppointmentState();

  @override
  List<Object> get props => [];
}

class AppointmentInitial extends AppointmentState {}

class AppointmentLoading extends AppointmentState {}

class AppointmentLoaded extends AppointmentState {
  final List<Appointment> appointments;

  const AppointmentLoaded(this.appointments);

  @override
  List<Object> get props => [appointments];
}

class AppointmentSuccess extends AppointmentState {}

class AppointmentFailure extends AppointmentState {
  final String error;

  const AppointmentFailure(this.error);

  @override
  List<Object> get props => [error];
}
