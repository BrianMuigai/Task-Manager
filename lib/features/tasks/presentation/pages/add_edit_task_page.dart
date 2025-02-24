import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:task/features/tasks/domain/entities/task.dart';
import 'package:task/features/tasks/presentation/bloc/tasks_bloc.dart';

class AddEditTaskPage extends StatefulWidget {
  final Task? task;

  const AddEditTaskPage({super.key, this.task});

  @override
  State<AddEditTaskPage> createState() => _AddEditTaskPageState();
}

class _AddEditTaskPageState extends State<AddEditTaskPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _collaboratorsController;
  DateTime? _dueDate;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _dueDate = widget.task?.dueDate;
    _completed = widget.task?.completed ?? false;
    // Initialize collaborator field with comma-separated values if task exists.
    _collaboratorsController = TextEditingController(
        text:
            widget.task != null ? widget.task!.collaboratorIds.join(", ") : "");
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

  // Parse collaborator IDs from the text field.
  List<String> _parseCollaborators(String input) {
    return input
        .split(',')
        .map((collab) => collab.trim())
        .where((collab) => collab.isNotEmpty)
        .toList();
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

      // Parse collaborators from the input.
      final collaborators = _parseCollaborators(_collaboratorsController.text);

      // If editing, use the existing id; otherwise, generate one.
      final String id = widget.task?.id ?? UniqueKey().toString();
      final Task newTask = Task(
        id: id,
        title: _titleController.text,
        dueDate: _dueDate,
        completed: _completed,
        ownerId: ownerId,
        collaboratorIds: collaborators,
        updatedAt: DateTime.now(),
      );
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
    _collaboratorsController.dispose();
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
              TextFormField(
                controller: _collaboratorsController,
                decoration: InputDecoration(
                  labelText: "Collaborators (comma-separated IDs/emails)",
                  border: OutlineInputBorder(),
                ),
                // No strict validation; can be optional.
              ),
              SizedBox(height: 20),
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
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: _saveTask,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    "Save Task",
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
