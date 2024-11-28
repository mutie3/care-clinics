part of 'appointment_bloc.dart';

sealed class AppointmentState extends Equatable {
  const AppointmentState();
  
  @override
  List<Object> get props => [];
}

final class AppointmentInitial extends AppointmentState {}
