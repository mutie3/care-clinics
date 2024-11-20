class Appointment {
  String? id; // Optional id
  final String patientName;
  final String doctorName;
  final bool status; // To indicate if the appointment is booked
  final DateTime appointmentDate;
  final DateTime appointmentTime;

  Appointment({
    this.id, // Optional id
    required this.patientName,
    required this.doctorName,
    this.status = false, // Default to false
    required this.appointmentDate,
    required this.appointmentTime,
  });

  // Convert Appointment to a Map
  Map<String, dynamic> toMap() {
    return {
      'patientName': patientName,
      'doctorName': doctorName,
      'status': status,
      'appointmentDate': appointmentDate
          .toIso8601String(), // تأكد من تحويل DateTime إلى String
      'appointmentTime': appointmentTime
          .toIso8601String(), // تأكد من تحويل DateTime إلى String
    };
  }

  // Create Appointment from a Map
  static Appointment fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'],
      patientName: map['patientName'],
      doctorName: map['doctorName'],
      status: map['status'] ?? false,
      appointmentDate: DateTime.parse(
          map['appointmentDate']), // تحويل من String إلى DateTime
      appointmentTime: DateTime.parse(
          map['appointmentTime']), // تحويل من String إلى DateTime
    );
  }
}
