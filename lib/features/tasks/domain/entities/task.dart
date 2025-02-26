import 'package:equatable/equatable.dart';

class Task extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime? dueDate;
  final bool completed;
  final String ownerId;
  final List<String> collaboratorIds;
  final DateTime? updatedAt;
  final String? calendarEventId;

  const Task(
      {required this.id,
      required this.title,
      this.dueDate,
      this.completed = false,
      required this.ownerId,
      this.collaboratorIds = const [],
      this.updatedAt,
      this.calendarEventId,
      required this.description});

  Task copyWith(
      {String? id,
      String? title,
      DateTime? dueDate,
      bool? completed,
      String? ownerId,
      List<String>? collaboratorIds,
      DateTime? updatedAt,
      String? description,
      String? calendarEventId}) {
    return Task(
        id: id ?? this.id,
        title: title ?? this.title,
        dueDate: dueDate ?? this.dueDate,
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
        dueDate,
        completed,
        ownerId,
        collaboratorIds,
        updatedAt,
        description,
        calendarEventId
      ];
}
