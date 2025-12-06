import 'package:flutter/material.dart';
import '../global/config.dart';

class AddEntryScreen extends StatefulWidget {
  final FitnessEntry? initial;
  const AddEntryScreen({this.initial, super.key});

  @override
  AddEntryScreenState createState() => AddEntryScreenState();
}

class AddEntryScreenState extends State<AddEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime selectedDate = DateTime.now();
  TextEditingController stepsController = TextEditingController(text: '0');
  TextEditingController minutesController = TextEditingController(text: '0');
  TextEditingController caloriesController = TextEditingController(text: '0');
  TextEditingController notesController = TextEditingController();
  String type = 'Walk';

  final db = DBHelper();

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      final e = widget.initial!;
      selectedDate = e.date;
      stepsController.text = e.steps.toString();
      minutesController.text = e.workoutMinutes.toString();
      caloriesController.text = e.calories.toString();
      notesController.text = e.notes;
      type = e.type;
    }
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
    final entry = FitnessEntry(
      date: selectedDate,
      steps: int.tryParse(stepsController.text) ?? 0,
      workoutMinutes: int.tryParse(minutesController.text) ?? 0,
      calories: int.tryParse(caloriesController.text) ?? 0,
      type: type,
      notes: notesController.text,
    );

    await db.insertEntry(entry);
    if (context.mounted) {
      return Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        backgroundColor: const Color.fromARGB(255, 14, 80, 134),
        title: UIHelper.appText(
          'Add Activity',
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
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
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: UIHelper.appText(t),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => type = v ?? 'Walk'),
                decoration: InputDecoration(
                  labelStyle: GoogleFonts.montserrat(),
                  labelText: 'Activity Type',
                ),
              ),

              8.heightBox,
              TextFormField(
                controller: stepsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelStyle: GoogleFonts.montserrat(),
                  labelText: 'Steps',
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Enter steps or 0' : null,
              ),
              8.heightBox,
              TextFormField(
                controller: minutesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelStyle: GoogleFonts.montserrat(),
                  labelText: 'Workout Minutes',
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Enter minutes or 0' : null,
              ),

              8.heightBox,
              TextFormField(
                controller: caloriesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelStyle: GoogleFonts.montserrat(),
                  labelText: 'Calories Burned',
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Enter calories or 0' : null,
              ),

              8.heightBox,
              TextFormField(
                controller: notesController,
                decoration: InputDecoration(
                  labelStyle: GoogleFonts.montserrat(),
                  labelText: 'Notes (optional)',
                ),
                maxLines: 2,
              ),

              16.heightBox,
              ElevatedButton.icon(
                onPressed: () => _save(context),
                icon: Icon(Icons.save),
                label: UIHelper.appText('Save Activity'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
