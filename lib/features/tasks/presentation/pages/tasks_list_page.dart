import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task/core/l10n/app_localization.dart';
import 'package:task/features/settings/presentation/pages/settings_page.dart';
import 'package:task/features/tasks/domain/entities/task.dart';
import 'package:task/features/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:task/features/tasks/presentation/pages/add_edit_task_page.dart';
import 'package:task/features/tasks/presentation/widgets/empty_task_widget.dart';
import 'package:task/features/tasks/presentation/widgets/filter_tasks_dialog.dart';

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
        title: Text(AppLocalizations.getString(context, 'appName')),
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
      body: BlocListener<TasksBloc, TasksState>(
        listener: (context, state) {
          if (state is CalendarSyncSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(AppLocalizations.getString(
                      context, 'taskAddedToCalendar'))),
            );
          } else if (state is CalendarSyncFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  backgroundColor: Colors.redAccent,
                  content: Text(AppLocalizations.getString(
                      context, 'coultNotAddToCalendar'))),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SearchBar(
                hintText: AppLocalizations.getString(context, 'searchTask'),
                leading: Icon(Icons.search,
                    color: Theme.of(context)
                            .inputDecorationTheme
                            .labelStyle
                            ?.color ??
                        Colors.white70),
                trailing: [
                  IconButton(
                    icon: Icon(Icons.filter_alt),
                    onPressed: () async {
                      final filterData = await showDialog<Map<String, dynamic>>(
                        context: context,
                        builder: (context) => FilterTasksDialog(),
                      );
                      if (filterData != null) {
                        // ignore: use_build_context_synchronously
                        context.read<TasksBloc>().add(FilterTasksEvent(
                              name: filterData["name"],
                              date: filterData["date"],
                              priority: filterData["priority"],
                              tags: filterData["tags"],
                            ));
                      }
                    },
                  ),
                ],
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
                            children:
                                filteredTasks.asMap().entries.map((entry) {
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
                                    subtitle: task.dueDateTime != null
                                        ? Text(
                                            "${AppLocalizations.getString(context, 'due')}: ${task.dueDateTime!.toLocal().toString().split(' ')[0]}")
                                        : Text(AppLocalizations.getString(
                                            context, 'noDueDate')),
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
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: AppLocalizations.getString(context, 'addTask'),
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
