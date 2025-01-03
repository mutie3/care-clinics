import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      throw Exception('260'.tr);
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
        SnackBar(content: Text('254'.tr)),
      );

      // تحديث قائمة الإشعارات بعد الحذف
      setState(() {
        _notificationsFuture = _fetchNotifications();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('255'.tr)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('28'.tr),
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
            return Center(
              child: Text(
                '256'.tr,
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                '257'.tr,
                style: const TextStyle(fontSize: 18, color: Colors.grey),
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
                    ' 259 ${formattedDate.toString()}'.tr,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('115'.tr),
                        content: Text('258'.tr),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('117'.tr),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await _deleteNotification(notificationId);
                            },
                            child: Text('78'.tr),
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
