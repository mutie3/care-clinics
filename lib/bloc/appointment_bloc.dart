import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../data/appointment.dart';
import '../data/appointment_repository.dart';

part 'appointment_event.dart';
part 'appointment_state.dart';

class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  final AppointmentRepository appointmentRepository;

  AppointmentBloc(this.appointmentRepository) : super(AppointmentInitial()) {
    on<LoadAppointments>(_onLoadAppointments);
    on<AddAppointment>(_onAddAppointment);
    on<UpdateAppointment>(_onUpdateAppointment);
    on<DeleteAppointment>(_onDeleteAppointment);
  }

  Future<void> _onLoadAppointments(
      LoadAppointments event, Emitter<AppointmentState> emit) async {
    emit(AppointmentLoading());
    try {
      final appointments = await appointmentRepository.getAppointments();
      emit(AppointmentLoaded(appointments));
    } catch (e) {
      emit(AppointmentError('Failed to load appointments: ${e.toString()}'));
    }
  }

  Future<void> _onAddAppointment(
      AddAppointment event, Emitter<AppointmentState> emit) async {
    emit(AppointmentLoading());
    try {
      await appointmentRepository.addAppointment(event.appointment);
      add(LoadAppointments());
    } catch (e) {
      emit(AppointmentError('Failed to add appointment: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateAppointment(
      UpdateAppointment event, Emitter<AppointmentState> emit) async {
    emit(AppointmentLoading());
    try {
      await appointmentRepository.updateAppointment(event.appointment);
      add(LoadAppointments());
    } catch (e) {
      emit(AppointmentError('Failed to update appointment: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteAppointment(
      DeleteAppointment event, Emitter<AppointmentState> emit) async {
    emit(AppointmentLoading());
    try {
      await appointmentRepository.deleteAppointment(event.appointmentId);
      add(LoadAppointments());
    } catch (e) {
      emit(AppointmentError('Failed to delete appointment: ${e.toString()}'));
    }
  }
}
