import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late Future<List<DocumentSnapshot>> _notificationsFuture;

  Future<String?> _getPatientId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        return user.uid; // UID المستخدم المسجل حاليًا
      }
    } catch (e) {
      print('Error fetching patient ID: $e');
    }
    return null;
  }

  Future<List<DocumentSnapshot>> _fetchNotifications() async {
    final patientId = await _getPatientId();
    if (patientId == null) {
      throw Exception('User not logged in');
    }

    final querySnapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('patientId', isEqualTo: patientId)
        .get();

    final notifications = querySnapshot.docs;

    // ترتيب الإشعارات بناءً على createdAt
    notifications.sort((a, b) {
      final dateA = (a['createdAt'] as Timestamp).toDate();
      final dateB = (b['createdAt'] as Timestamp).toDate();
      return dateB.compareTo(dateA); // ترتيب تنازلي
    });

    return notifications;
  }

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _fetchNotifications();
  }

  Future<void> _deleteNotification(String notificationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف الإشعار بنجاح')),
      );

      // تحديث قائمة الإشعارات بعد الحذف
      setState(() {
        _notificationsFuture = _fetchNotifications();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء حذف الإشعار')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _notificationsFuture = _fetchNotifications();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'حدث خطأ أثناء تحميل الإشعارات.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد إشعارات.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final notifications = snapshot.data!;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final message = notification['message'] as String;
              final date = (notification['date'] as Timestamp).toDate();
              final notificationId = notification.id;
              final formattedDate = DateFormat('yyyy-MM-dd').format(date);
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: const Icon(Icons.notifications, color: Colors.blue),
                  title: Text(
                    message,
                    style: const TextStyle(fontSize: 16),
                  ),
                  subtitle: Text(
                    ' تاريخ الموعد المحذوف: ${formattedDate.toString()}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('تأكيد الحذف'),
                        content: const Text('هل تريد حذف هذا الإشعار؟'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('إلغاء'),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await _deleteNotification(notificationId);
                            },
                            child: const Text('حذف'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
