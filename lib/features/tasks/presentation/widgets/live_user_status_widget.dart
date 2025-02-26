import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task/core/l10n/app_localization.dart';

class LiveUserStatusWidget extends StatelessWidget {
  final String taskId;
  final String currentUserId; // Current user's UID

  const LiveUserStatusWidget({
    super.key,
    required this.taskId,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final taskDocStream =
        FirebaseFirestore.instance.collection('tasks').doc(taskId).snapshots();

    return StreamBuilder<DocumentSnapshot>(
      stream: taskDocStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Container();
        final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
        final editingUsers =
            Map<String, dynamic>.from(data['editingUsers'] ?? {});
        // Remove current user if present
        editingUsers.remove(currentUserId);
        if (editingUsers.isEmpty) return Container();
        final users = editingUsers.values.cast<String>().toList();
        return Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            users.length == 1
                ? "${users.first} ${AppLocalizations.getString(context, 'isEditingThisTask')}"
                : "${users.join(', ')} ${AppLocalizations.getString(context, 'areEditingThisTask')}",
            style: TextStyle(color: Colors.blue[900]),
          ),
        );
      },
    );
  }
}
