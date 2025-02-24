import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task/features/settings/presentation/pages/settings_page.dart';
import 'package:task/features/tasks/domain/entities/task.dart';
import 'package:task/features/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:task/features/tasks/presentation/pages/add_edit_task_page.dart';

class TasksListPage extends StatefulWidget {
  const TasksListPage({super.key});

  @override
  State<TasksListPage> createState() => _TasksListPageState();
}

class _TasksListPageState extends State<TasksListPage> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Task Manager (Bloc)"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              context.read<TasksBloc>().add(LoadTasksEvent());
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SearchBar(
              onChanged: (query) {
                setState(() {
                  searchQuery = query;
                });
              },
            ),
            const SizedBox(height: 8),
            Expanded(
              child: BlocBuilder<TasksBloc, TasksState>(
                builder: (context, state) {
                  if (state is TasksLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state is TasksLoaded) {
                    final filteredTasks = state.tasks
                        .where((task) => task.title
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase()))
                        .toList();
                    return ListView.builder(
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        final Task task = filteredTasks[index];
                        return Card(
                          margin:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          elevation: 2,
                          child: ListTile(
                            title: Text(
                              task.title,
                              style: TextStyle(
                                decoration: task.completed
                                    ? TextDecoration.lineThrough
                                    : null,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: task.dueDate != null
                                ? Text(
                                    "Due: ${task.dueDate!.toLocal().toString().split(' ')[0]}")
                                : null,
                            trailing: Checkbox(
                              value: task.completed,
                              onChanged: (value) {
                                final updatedTask =
                                    task.copyWith(completed: value ?? false);
                                context
                                    .read<TasksBloc>()
                                    .add(UpdateTaskEvent(updatedTask));
                              },
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddEditTaskPage(task: task),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  } else if (state is TasksError) {
                    return Center(child: Text(state.message));
                  } else {
                    return Center(child: Text("Unknown state"));
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Task',
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEditTaskPage()),
          );
        },
      ),
    );
  }
}
