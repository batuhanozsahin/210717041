import 'package:engv1/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationList extends StatefulWidget {
  const NotificationList({Key? key}) : super(key: key);

  @override
  _NotificationListState createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  final notificationStream =
      FirebaseFirestore.instance.collection("teacher").snapshots();
  final Api _api = Api();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: notificationStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Connection Error"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          
          if (docs.isEmpty) {
            return const Center(child: Text("There are no notifications"));
          }

          return ListView.builder(
            shrinkWrap: true,
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final notification = docs[index];
              final String header = notification['header'];
              final DateTime date = notification['date'].toDate();

              return ListTile(
                title: Text(header),
                subtitle: Text(_api.convertDateTimeDisplay('${DateUtils.dateOnly(date)}')),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_forever),
                  onPressed: () => _deleteNotification(notification.id),
                ),
                onTap: () => _showNotificationDialog(context, notification),
              );
            },
          );
        },
      ),
    );
  }

  // Function to delete a notification
  void _deleteNotification(String documentId) async {
    try {
      await _api.delete(documentId, 'teacher');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to delete notification")),
      );
    }
  }

  // Function to show the notification dialog
  void _showNotificationDialog(BuildContext context, QueryDocumentSnapshot notification) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _api.notification(context, notification.id, notification);
      },
    );
  }
}
