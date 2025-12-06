import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../helpers/db_helper.dart';
import '../helpers/ui_helper.dart';
import '../model/fitness_entry.dart';
class EditEntryScreen extends StatefulWidget {
  final FitnessEntry entry;
  const EditEntryScreen({required this.entry, super.key});

  @override
  EditEntryScreenState createState() => EditEntryScreenState();
}

class EditEntryScreenState extends State<EditEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime selectedDate;
  late TextEditingController stepsController;
  late TextEditingController minutesController;
  late TextEditingController caloriesController;
  late TextEditingController notesController;
  late String type;
  final db = DBHelper();

  @override
  void initState() {
    super.initState();
    selectedDate = widget.entry.date;
    stepsController = TextEditingController(
      text: widget.entry.steps.toString(),
    );
    minutesController = TextEditingController(
      text: widget.entry.workoutMinutes.toString(),
    );
    caloriesController = TextEditingController(
      text: widget.entry.calories.toString(),
    );
    notesController = TextEditingController(text: widget.entry.notes);
    type = widget.entry.type;
  }

  Future<void> _pickDate(BuildContext context) async {
    final d = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (d != null) setState(() => selectedDate = d);
  }

  Future<void> _save(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    final updated = FitnessEntry(
      id: widget.entry.id,
      date: selectedDate,
      steps: int.tryParse(stepsController.text) ?? 0,
      workoutMinutes: int.tryParse(minutesController.text) ?? 0,
      calories: int.tryParse(caloriesController.text) ?? 0,
      type: type,
      notes: notesController.text,
    );

    await db.updateEntry(updated);

    if (context.mounted) context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Activity')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ListTile(
                title: UIHelper.appText('Date'),
                subtitle: UIHelper.appText(
                  DateFormat.yMMMd().format(selectedDate),
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _pickDate(context),
              ),
              8.heightBox,
              DropdownButtonFormField<String>(
                initialValue: type,
                items: ['Walk', 'Run', 'Gym', 'Cycling', 'Other']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => type = v ?? 'Walk'),
                decoration: InputDecoration(labelText: 'Activity Type'),
              ),
              8.heightBox,
              TextFormField(
                controller: stepsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Steps'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Enter steps or 0' : null,
              ),
              8.heightBox,
              TextFormField(
                controller: minutesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Workout Minutes'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Enter minutes or 0' : null,
              ),
              8.heightBox,
              TextFormField(
                controller: caloriesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Calories Burned'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Enter calories or 0' : null,
              ),

              8.heightBox,
              TextFormField(
                controller: notesController,
                decoration: InputDecoration(labelText: 'Notes (optional)'),
                maxLines: 2,
              ),
              16.heightBox,
              ElevatedButton.icon(
                onPressed: () => _save(context),
                icon: Icon(Icons.save),
                label: UIHelper.appText('Update Activity'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
