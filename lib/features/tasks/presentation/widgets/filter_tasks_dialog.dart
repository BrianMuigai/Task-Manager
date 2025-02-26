import 'package:flutter/material.dart';
import 'package:task/core/l10n/app_localization.dart';

class FilterTasksDialog extends StatefulWidget {
  const FilterTasksDialog({super.key});

  @override
  State<FilterTasksDialog> createState() => _FilterTasksDialogState();
}

class _FilterTasksDialogState extends State<FilterTasksDialog> {
  final TextEditingController _nameController = TextEditingController();
  DateTime? _selectedDate;
  final TextEditingController _priorityController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: Row(
        children: [
          Text(AppLocalizations.getString(context, 'filterTasks')),
          const Spacer(),
          IconButton(
            onPressed: () {
              Navigator.of(context).pop(null);
            },
            icon: Icon(Icons.cancel),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                  labelText:
                      AppLocalizations.getString(context, 'nameContains')),
            ),
            SizedBox(height: 8),
            ListTile(
              title: Text(_selectedDate == null
                  ? AppLocalizations.getString(context, 'selectDate')
                  : "${AppLocalizations.getString(context, 'date')}: ${_selectedDate!.toLocal().toString().split(' ')[0]}"),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  setState(() {
                    _selectedDate = date;
                  });
                }
              },
            ),
            SizedBox(height: 8),
            TextField(
              controller: _priorityController,
              decoration: InputDecoration(
                  labelText:
                      AppLocalizations.getString(context, 'priorityNumber')),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 8),
            TextField(
              controller: _tagsController,
              decoration: InputDecoration(
                  labelText: AppLocalizations.getString(
                      context, 'tagsCommaSeparated')),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            final filterData = {
              "name": _nameController.text,
              "date": _selectedDate,
              "priority": int.tryParse(_priorityController.text),
              "tags": _tagsController.text
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList(),
            };
            Navigator.of(context).pop(filterData);
          },
          child: Text(AppLocalizations.getString(context, 'apply')),
        )
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priorityController.dispose();
    _tagsController.dispose();
    super.dispose();
  }
}
