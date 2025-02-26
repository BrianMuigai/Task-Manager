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
  });

  Task copyWith(
      {String? id,
      String? title,
      DateTime? startTime,
      DateTime? dueDateTime,
      bool? completed,
      String? ownerId,
      List<String>? collaboratorIds,
      DateTime? updatedAt,
      String? description,
      String? calendarEventId}) {
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
        calendarEventId: calendarEventId ?? this.calendarEventId);
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
        calendarEventId
      ];
}
