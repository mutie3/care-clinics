import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/appointment.dart';
part 'appointment_event.dart';
part 'appointment_state.dart';

class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  AppointmentBloc() : super(AppointmentInitial()) {
    // Handling appointment booking
    on<BookAppointmentEvent>((event, emit) async {
      emit(AppointmentLoading());
      try {
        await FirebaseFirestore.instance
            .collection('appointments')
            .add(event.appointment.toMap());
        emit(AppointmentSuccess());
      } catch (e) {
        emit(AppointmentFailure(e.toString()));
      }
    });
    on<FetchAppointmentsByUserEvent>((event, emit) async {
      emit(AppointmentLoading());
      try {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('appointments')
            .where('patientName', isEqualTo: event.patientName)
            .get();

        List<Appointment> appointments = querySnapshot.docs
            .map((doc) => Appointment.fromMap({
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id,
                }))
            .toList();

        emit(AppointmentLoaded(appointments));
      } catch (e) {
        emit(AppointmentFailure(e.toString()));
      }
    });

    // Handling appointment modification
    on<ModifyAppointmentEvent>((event, emit) async {
      emit(AppointmentLoading());
      try {
        await FirebaseFirestore.instance
            .collection('appointments')
            .doc(event.appointmentId)
            .update(event.updatedData);
        emit(AppointmentSuccess());
      } catch (e) {
        emit(AppointmentFailure(e.toString()));
      }
    });

    // Handle appointment deletion
    on<DeleteAppointmentEvent>((event, emit) async {
      emit(AppointmentLoading());
      try {
        await FirebaseFirestore.instance
            .collection('appointments')
            .doc(event.appointmentId)
            .delete();
        emit(AppointmentSuccess());
      } catch (e) {
        emit(AppointmentFailure(e.toString()));
      }
    });
  }
}
