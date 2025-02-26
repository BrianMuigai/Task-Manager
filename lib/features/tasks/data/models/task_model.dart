import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/task.dart';

class TaskModel extends Task {
  const TaskModel({
    required super.id,
    required super.title,
    required super.description,
    super.startTime,
    super.dueDateTime,
    super.completed,
    required super.ownerId,
    super.collaboratorIds,
    super.updatedAt,
    super.calendarEventId,
    super.priority,
    super.tags,
  });

  factory TaskModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      title: data['title'] ?? '',
      startTime: data['startTime'] != null
          ? (data['startTime'] as Timestamp).toDate()
          : null,
      dueDateTime: data['dueDateTime'] != null
          ? (data['dueDateTime'] as Timestamp).toDate()
          : null,
      completed: data['completed'] ?? false,
      ownerId: data['ownerId'] ?? '',
      collaboratorIds: data['collaboratorIds'] != null
          ? List<String>.from(data['collaboratorIds'])
          : [],
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      description: data['description'] ?? '',
      calendarEventId: data['calendarEventId'],
      priority: data['priority'],
      tags: data['tags'] != null ? List<String>.from(data['tags']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'startTime': startTime != null ? Timestamp.fromDate(startTime!) : null,
      'dueDateTime':
          dueDateTime != null ? Timestamp.fromDate(dueDateTime!) : null,
      'completed': completed,
      'ownerId': ownerId,
      'collaboratorIds': collaboratorIds,
      'updatedAt': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : FieldValue.serverTimestamp(),
      'calendarEventId': calendarEventId,
      'priority': priority,
      'tags': tags,
    };
  }
}
