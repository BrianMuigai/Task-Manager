import 'package:equatable/equatable.dart';

class Task extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime? startTime;
  final DateTime? dueDateTime;
  final bool completed;
  final String ownerId;
  final List<String> collaboratorIds;
  final DateTime? updatedAt;
  final String? calendarEventId;
  final int? priority; // e.g., 1 = High, 2 = Medium, 3 = Low
  final List<String>? tags;

  const Task({
    required this.id,
    required this.title,
    this.completed = false,
    required this.ownerId,
    this.collaboratorIds = const [],
    this.updatedAt,
    this.calendarEventId,
    required this.description,
    this.startTime,
    this.dueDateTime,
    this.priority,
    this.tags,
  });

  Task copyWith({
    String? id,
    String? title,
    DateTime? startTime,
    DateTime? dueDateTime,
    bool? completed,
    String? ownerId,
    List<String>? collaboratorIds,
    DateTime? updatedAt,
    String? description,
    String? calendarEventId,
    int? priority,
    List<String>? tags,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      dueDateTime: dueDateTime ?? this.dueDateTime,
      completed: completed ?? this.completed,
      ownerId: ownerId ?? this.ownerId,
      collaboratorIds: collaboratorIds ?? this.collaboratorIds,
      updatedAt: updatedAt ?? this.updatedAt,
      description: description ?? this.description,
      calendarEventId: calendarEventId ?? this.calendarEventId,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        startTime,
        dueDateTime,
        completed,
        ownerId,
        collaboratorIds,
        updatedAt,
        description,
        calendarEventId,
        priority,
        tags,
      ];
}
