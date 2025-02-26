import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task/features/auth/domain/entities/user.dart';
import 'package:task/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:task/features/tasks/domain/entities/task.dart';
import 'package:task/features/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:task/features/tasks/presentation/widgets/live_user_status_widget.dart';
import 'package:task/features/tasks/presentation/widgets/search_collaborators_widget.dart';

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
  DateTime? _dueDate;
  bool _completed = false;
  List<String> _collaboratorIds = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.task?.description ?? '');
    _dueDate = widget.task?.dueDate;
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

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
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
        // Fallback or error handling if needed.
        ownerId = "unknown";
      }

      // If editing, use the existing id; otherwise, generate one.
      final String id = widget.task?.id ?? UniqueKey().toString();
      final Task newTask = Task(
          id: id,
          title: _titleController.text,
          dueDate: _dueDate,
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
        title: Text(widget.task != null ? "Edit Task" : "New Task"),
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
                  labelText: "Task Title",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? "Please enter a task title"
                    : null,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: "Task Description",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 20),
              // Due date field.
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_dueDate != null
                    ? "Due Date: ${_dueDate!.toLocal().toString().split(' ')[0]}"
                    : "Set Due Date"),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDueDate(context),
              ),
              SizedBox(height: 20),
              // Collaborators field.
              Text(
                "Collaborators:",
                style: TextStyle(fontWeight: FontWeight.bold),
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
              TextButton.icon(
                onPressed: _showCollaboratorSearch,
                icon: Icon(Icons.search),
                label: Text("Add Collaborator"),
              ),
              SizedBox(height: 10),
              // Completed toggle.
              SwitchListTile(
                title: Text("Mark as Completed"),
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
                    widget.task != null ? "Update Task" : "Save Task",
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
