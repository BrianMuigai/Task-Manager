import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task/core/app_dialogs.dart';
import 'package:task/core/l10n/app_localization.dart';
import 'package:task/features/auth/domain/entities/user.dart';
import 'package:task/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:task/features/tasks/domain/entities/task.dart';
import 'package:task/features/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:task/features/tasks/presentation/widgets/live_user_status_widget.dart';
import 'package:task/features/tasks/presentation/widgets/search_collaborators_widget.dart';
import 'package:intl/intl.dart';

class AddEditTaskPage extends StatefulWidget {
  final Task? task;

  const AddEditTaskPage({super.key, this.task});

  @override
  State<AddEditTaskPage> createState() => _AddEditTaskPageState();
}

class _AddEditTaskPageState extends State<AddEditTaskPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late AppUser currentUser;
  DateTime? _startTime;
  DateTime? _dueDateTime;
  bool _completed = false;
  List<String> _collaboratorIds = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.task?.description ?? '');
    _startTime = widget.task?.startTime;
    _dueDateTime = widget.task?.dueDateTime;
    _completed = widget.task?.completed ?? false;
    _collaboratorIds = widget.task?.collaboratorIds ?? [];
    currentUser = (context.read<AuthBloc>().state as Authenticated).user;
    if (widget.task != null) {
      FirebaseFirestore.instance
          .collection('tasks')
          .doc(widget.task?.id ?? 'newTaskId')
          .update({
        'editingUsers.${currentUser.uid}': currentUser.displayName,
      });
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    // Pick the date first.
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (!mounted || pickedDate == null) return;
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime != null
          ? TimeOfDay.fromDateTime(_startTime!)
          : TimeOfDay.now(),
    );
    if (picked != null) {
      final now = DateTime(pickedDate.year, pickedDate.month, pickedDate.day,
          picked.hour, picked.minute);
      final newStart =
          DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
      setState(() {
        _startTime = newStart;
      });
    }
  }

  Future<void> _selectDueDateTime(BuildContext context) async {
    // Pick the date first.
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (!mounted || pickedDate == null) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _dueDateTime != null
          ? TimeOfDay.fromDateTime(_dueDateTime!)
          : TimeOfDay.now(),
    );
    if (pickedTime != null) {
      final newDue = DateTime(pickedDate.year, pickedDate.month, pickedDate.day,
          pickedTime.hour, pickedTime.minute);
      setState(() {
        _dueDateTime = newDue;
      });
    }
  }

  void _addCollaborator(AppUser user) {
    if (!_collaboratorIds.contains(user.uid)) {
      setState(() {
        _collaboratorIds.add(user.uid);
      });
    }
    Navigator.pop(context); // Close the modal sheet
  }

  void _showCollaboratorSearch() {
    // Get current user id from AuthBloc
    String currentUserId = "";
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      currentUserId = authState.user.uid;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SearchCollaboratorsWidget(
          currentUserId: currentUserId,
          onUserSelected: _addCollaborator,
        );
      },
    );
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      // Retrieve the authenticated user from AuthBloc.
      String ownerId = "";
      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated) {
        ownerId = authState.user.uid;
      } else {
        return;
      }

      if (_startTime != null && _dueDateTime != null) {
        if (_startTime!.isAfter(_dueDateTime!)) {
          showErrorDialog(
              context, AppLocalizations.getString(context, 'taskTimeError'));
          return;
        }
      }

      // If editing, use the existing id; otherwise, generate one.
      final String id = widget.task?.id ?? UniqueKey().toString();
      final Task newTask = Task(
          id: id,
          title: _titleController.text,
          startTime: _startTime,
          dueDateTime: _dueDateTime,
          completed: _completed,
          ownerId: ownerId,
          collaboratorIds: _collaboratorIds,
          updatedAt: DateTime.now(),
          description: _descriptionController.text);
      if (widget.task != null) {
        context.read<TasksBloc>().add(UpdateTaskEvent(newTask));
      } else {
        context.read<TasksBloc>().add(AddTaskEvent(newTask));
      }
      Navigator.pop(context);
    }
  }

  Future<void> _deleteTask() async {
    if (widget.task != null) {
      context.read<TasksBloc>().add(DeleteTaskEvent(widget.task!.id));
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    if (widget.task != null) {
      FirebaseFirestore.instance
          .collection('tasks')
          .doc(widget.task?.id ?? 'newTaskId')
          .update({
        'editingUsers.${currentUser.uid}': FieldValue.delete(),
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task != null
            ? AppLocalizations.getString(context, 'editTask')
            : AppLocalizations.getString(context, 'newTask')),
        actions: widget.task != null
            ? [
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: _deleteTask,
                )
              ]
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Task title field.
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.getString(context, 'taskTitle'),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? AppLocalizations.getString(context, 'enterTaskTitle')
                    : null,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.getString(context, 'taskDescr'),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 20),
              // Start Time
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_startTime != null
                    ? "${AppLocalizations.getString(context, 'startTime')}: ${DateFormat("hh:mm a").format(_startTime!)}"
                    : "${AppLocalizations.getString(context, 'setStartTime')}"),
                trailing: Icon(Icons.access_time),
                onTap: () => _selectStartTime(context),
              ),
              // Due Date & Time
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_dueDateTime != null
                    ? "${AppLocalizations.getString(context, 'dueDate')}: ${DateFormat("MMM d, yyyy hh:mm a").format(_dueDateTime!)}"
                    : "${AppLocalizations.getString(context, 'setDueDateTime')}"),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDueDateTime(context),
              ),
              SizedBox(height: 20),
              Divider(),
              // Collaborators field.
              Row(
                children: [
                  Text(
                    "${AppLocalizations.getString(context, 'collaborators')}:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _showCollaboratorSearch,
                    icon: Icon(Icons.search),
                    label: Text(AppLocalizations.getString(
                        context, 'addCollaborators')),
                  ),
                ],
              ),

              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _collaboratorIds
                    .map((id) => Chip(
                          label: Text(id),
                          onDeleted: () {
                            setState(() {
                              _collaboratorIds.remove(id);
                            });
                          },
                        ))
                    .toList(),
              ),

              SizedBox(height: 10),
              // Completed toggle.
              SwitchListTile(
                title:
                    Text(AppLocalizations.getString(context, 'markCompleted')),
                value: _completed,
                onChanged: (bool value) {
                  setState(() {
                    _completed = value;
                  });
                },
              ),

              if (widget.task != null) ...[
                const SizedBox(height: 10),
                LiveUserStatusWidget(
                    taskId: widget.task!.id, currentUserId: currentUser.uid),
              ],
              SizedBox(height: 50),
              ElevatedButton(
                onPressed: _saveTask,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    widget.task != null
                        ? AppLocalizations.getString(context, 'updateTask')
                        : AppLocalizations.getString(context, 'saveTask'),
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
