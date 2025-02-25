import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task/features/auth/domain/entities/user.dart';
import 'package:task/features/tasks/presentation/bloc/tasks_bloc.dart';

class SearchCollaboratorsWidget extends StatefulWidget {
  final String
      currentUserId; // To filter out the current user from search results
  final Function(AppUser) onUserSelected; // Callback when a user is chosen

  const SearchCollaboratorsWidget({
    super.key,
    required this.currentUserId,
    required this.onUserSelected,
  });

  @override
  State<SearchCollaboratorsWidget> createState() =>
      _SearchCollaboratorsWidgetState();
}

class _SearchCollaboratorsWidgetState extends State<SearchCollaboratorsWidget> {
  final _searchController = TextEditingController();

  void _onSearchChanged(String query) {
    // Dispatch event to TasksBloc to perform the search.
    context.read<TasksBloc>().add(
          SearchCollaboratorsEvent(
            query: query,
            currentUserId: widget.currentUserId,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: "Search Collaborators",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: _onSearchChanged,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: BlocBuilder<TasksBloc, TasksState>(
              builder: (context, state) {
                if (state is CollaboratorsSearchLoading) {
                  return Center(child: CircularProgressIndicator.adaptive());
                } else if (state is CollaboratorsSearchLoaded) {
                  final results = state.results;
                  if (results.isEmpty) {
                    return Center(
                      child: Text(
                        "No results found.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final user = results[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: user.photoUrl.isNotEmpty
                              ? NetworkImage(user.photoUrl)
                              : null,
                          child:
                              user.photoUrl.isEmpty ? Icon(Icons.person) : null,
                        ),
                        title: Text(user.displayName),
                        subtitle: Text(user.email),
                        onTap: () => widget.onUserSelected(user),
                      );
                    },
                  );
                } else if (state is CollaboratorsSearchError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                } else {
                  // When no search has been performed yet.
                  return Container();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
