import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../helpers/db_helper.dart';
import '../helpers/ui_helper.dart';
import '../model/fitness_entry.dart';
import 'edit_entry.dart';
class EntryDetailScreen extends StatefulWidget {
  final FitnessEntry entry;
  const EntryDetailScreen({required this.entry, super.key});

  @override
  EntryDetailScreenState createState() => EntryDetailScreenState();
}

class EntryDetailScreenState extends State<EntryDetailScreen> {
  final db = DBHelper();

  Future<void> _delete(BuildContext context) async {
    if (widget.entry.id != null) {
      await db.deleteEntry(widget.entry.id!);
    }
    if (context.mounted) {
      return Navigator.pop(context, true);
    }
  }

  Future<void> _edit(BuildContext context) async {
    await context.push(EditEntryScreen(entry: widget.entry));
    if (context.mounted) {
      context.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    return Scaffold(
      appBar: AppBar(title: UIHelper.appText('Entry Details')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UIHelper.appText(
              DateFormat.yMMMMd().format(e.date),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),

            8.heightBox,
            UIHelper.appText('Type: ${e.type}'),
            UIHelper.appText('Steps: ${e.steps}'),
            UIHelper.appText('Workout Minutes: ${e.workoutMinutes}'),
            UIHelper.appText('Calories: ${e.calories}'),
            12.heightBox,
            UIHelper.appText('Notes:', fontWeight: FontWeight.bold),
            UIHelper.appText(e.notes.isEmpty ? 'No notes' : e.notes),
            Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _edit(context),
                    icon: Icon(Icons.edit),
                    label: UIHelper.appText('Edit'),
                  ),
                ),

                12.widthBox,
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _delete(context),
                    icon: Icon(Icons.delete),
                    label: UIHelper.appText('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
