import 'package:cloud_firestore/cloud_firestore.dart';
import 'appointment.dart';

class AppointmentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// إضافة موعد جديد
  Future<void> addAppointment(Appointment appointment) async {
    try {
      if (appointment.id.isEmpty || appointment.userId.isEmpty) {
        throw Exception('Invalid appointment data: ID or User ID is empty');
      }
      await _firestore
          .collection('appointments')
          .doc(appointment.id)
          .set(appointment.toMap());
    } catch (e) {
      rethrow;
    }
  }

  /// تحديث موعد
  Future<void> updateAppointment(Appointment appointment) async {
    try {
      final doc =
          await _firestore.collection('appointments').doc(appointment.id).get();

      if (!doc.exists) {
        throw Exception('Appointment with ID ${appointment.id} does not exist');
      }

      await _firestore
          .collection('appointments')
          .doc(appointment.id)
          .update(appointment.toMap());
    } catch (e) {
      rethrow;
    }
  }

  /// حذف موعد
  Future<void> deleteAppointment(String id) async {
    try {
      final doc = await _firestore.collection('appointments').doc(id).get();

      if (!doc.exists) {
        throw Exception('Appointment with ID $id does not exist');
      }

      await _firestore.collection('appointments').doc(id).delete();
    } catch (e) {
      rethrow;
    }
  }

  /// جلب جميع المواعيد
  Future<List<Appointment>> getAppointments() async {
    try {
      final querySnapshot = await _firestore.collection('appointments').get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('No appointments found');
      }

      return querySnapshot.docs
          .map((doc) => Appointment.fromMap(doc.data()))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// جلب مواعيد مستخدم معين
  Future<List<Appointment>> getUserAppointments(String userId) async {
    try {
      if (userId.isEmpty) {
        throw Exception('User ID cannot be empty');
      }

      final querySnapshot = await _firestore
          .collection('appointments')
          .where('userId', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('No appointments found for user ID $userId');
      }

      return querySnapshot.docs
          .map((doc) => Appointment.fromMap(doc.data()))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// إضافة موعد باستخدام المعاملات
  Future<void> addAppointmentWithTransaction(Appointment appointment) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final docRef =
            _firestore.collection('appointments').doc(appointment.id);

        final docSnapshot = await transaction.get(docRef);

        if (docSnapshot.exists) {
          throw Exception(
              'Appointment with ID ${appointment.id} already exists');
        }

        transaction.set(docRef, appointment.toMap());
      });
    } catch (e) {
      rethrow;
    }
  }
}
