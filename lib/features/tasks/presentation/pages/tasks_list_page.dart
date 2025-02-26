import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task/features/settings/presentation/pages/settings_page.dart';
import 'package:task/features/tasks/domain/entities/task.dart';
import 'package:task/features/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:task/features/tasks/presentation/pages/add_edit_task_page.dart';
import 'package:task/features/tasks/presentation/widgets/empty_task_widget.dart';

class TasksListPage extends StatefulWidget {
  const TasksListPage({super.key});

  @override
  State<TasksListPage> createState() => _TasksListPageState();
}

class _TasksListPageState extends State<TasksListPage> {
  String searchQuery = "";
  final double _itemHeight = 80.0;

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
              hintText: "Search Tasks...",
              leading: Icon(Icons.search,
                  color: Theme.of(context)
                          .inputDecorationTheme
                          .labelStyle
                          ?.color ??
                      Colors.white70),
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
                  if (state is TasksLoaded) {
                    if (state.tasks.isEmpty) {
                      return EmptyTasksWidget();
                    }
                    final filteredTasks = state.tasks
                        .where((task) => task.title
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase()))
                        .toList();
                    return SingleChildScrollView(
                      child: SizedBox(
                        height: filteredTasks.length * _itemHeight,
                        child: Stack(
                          children: filteredTasks.asMap().entries.map((entry) {
                            int index = entry.key;
                            Task task = entry.value;
                            return AnimatedPositioned(
                              key: ValueKey(task.id),
                              duration: Duration(milliseconds: 800),
                              curve: Curves.easeInOut,
                              top: index * _itemHeight,
                              left: 0,
                              right: 0,
                              height: _itemHeight,
                              child: Card(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
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
                                      : Text("No due date"),
                                  trailing: Checkbox(
                                    value: task.completed,
                                    onChanged: (value) {
                                      final updatedTask = task.copyWith(
                                          completed: value ?? false);
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
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  } else if (state is TasksError) {
                    return Center(child: Text(state.message));
                  }
                  return Center(child: CircularProgressIndicator());
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
