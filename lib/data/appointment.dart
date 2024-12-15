class Appointment {
  final String id; // معرف الموعد
  final String userId; // معرف المستخدم
  final DateTime date; // تاريخ الموعد
  final String time; // وقت الموعد
  final String status; // حالة الموعد (pending, completed, cancelled, etc.)
  final String service; // نوع الخدمة
  final String? notes; // ملاحظات إضافية
  final String? staffId; // معرف الموظف (إذا وجد)
  final String? cancellationReason; // سبب الإلغاء (إن وجد)
  final DateTime createdAt; // وقت إنشاء الموعد
  final DateTime updatedAt; // وقت آخر تعديل

  Appointment({
    required this.id,
    required this.userId,
    required this.date,
    required this.time,
    required this.status,
    required this.service,
    this.notes,
    this.staffId,
    this.cancellationReason,
    required this.createdAt,
    required this.updatedAt,
  });

  /// تحويل كائن Appointment إلى خريطة (Map) لتخزينها في Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'time': time,
      'status': status,
      'service': service,
      'notes': notes,
      'staffId': staffId,
      'cancellationReason': cancellationReason,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// تحويل خريطة (Map) إلى كائن Appointment عند جلب البيانات من Firestore
  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'],
      userId: map['userId'],
      date: DateTime.parse(map['date']),
      time: map['time'],
      status: map['status'],
      service: map['service'],
      notes: map['notes'],
      staffId: map['staffId'],
      cancellationReason: map['cancellationReason'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}
