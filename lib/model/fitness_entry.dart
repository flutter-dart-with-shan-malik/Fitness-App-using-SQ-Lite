class FitnessEntry {
  int? id;
  DateTime date;
  int steps;
  int workoutMinutes;
  int calories;
  String type; // e.g., "Run", "Gym", "Walk", "Cycling"
  String notes;

  FitnessEntry({
    this.id,
    required this.date,
    required this.steps,
    required this.workoutMinutes,
    required this.calories,
    required this.type,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'steps': steps,
      'workoutMinutes': workoutMinutes,
      'calories': calories,
      'type': type,
      'notes': notes,
    };
  }

  static FitnessEntry fromMap(Map<String, dynamic> map) {
    return FitnessEntry(
      id: map['id'] as int?,
      date: DateTime.parse(map['date']),
      steps: map['steps'],
      workoutMinutes: map['workoutMinutes'],
      calories: map['calories'],
      type: map['type'],
      notes: map['notes'] ?? '',
    );
  }
}
