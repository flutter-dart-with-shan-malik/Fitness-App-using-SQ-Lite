import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../model/fitness_entry.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'fitness.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE entries(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT,
            steps INTEGER,
            workoutMinutes INTEGER,
            calories INTEGER,
            type TEXT,
            notes TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertEntry(FitnessEntry entry) async {
    final db = await database;
    return await db.insert('entries', entry.toMap());
  }

  Future<int> updateEntry(FitnessEntry entry) async {
    final db = await database;
    return await db.update(
      'entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteEntry(int id) async {
    final db = await database;
    return await db.delete('entries', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<FitnessEntry>> getAllEntries() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'entries',
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => FitnessEntry.fromMap(maps[i]));
  }

  Future<List<FitnessEntry>> getEntriesForDate(DateTime date) async {
    final db = await database;
    String start = DateTime(date.year, date.month, date.day).toIso8601String();
    String end = DateTime(
      date.year,
      date.month,
      date.day,
      23,
      59,
      59,
    ).toIso8601String();
    final List<Map<String, dynamic>> maps = await db.query(
      'entries',
      where: 'date >= ? AND date <= ?',
      whereArgs: [start, end],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => FitnessEntry.fromMap(maps[i]));
  }

  Future<Map<String, int>> getSummaryForDate(DateTime date) async {
    final entries = await getEntriesForDate(date);
    int steps = 0;
    int minutes = 0;
    int calories = 0;
    for (var e in entries) {
      steps += e.steps;
      minutes += e.workoutMinutes;
      calories += e.calories;
    }
    return {'steps': steps, 'minutes': minutes, 'calories': calories};
  }

  Future<List<Map<String, dynamic>>> getLast7DaysSummary() async {
    final db = await database;
    DateTime today = DateTime.now();
    List<Map<String, dynamic>> weekly = [];
    for (int i = 0; i < 7; i++) {
      DateTime day = DateTime(
        today.year,
        today.month,
        today.day,
      ).subtract(Duration(days: i));
      String start = day.toIso8601String();
      String end = DateTime(
        day.year,
        day.month,
        day.day,
        23,
        59,
        59,
      ).toIso8601String();

      final res = await db.rawQuery(
        '''
        SELECT
          date(substr(date,1,10)) as day,
          SUM(steps) as steps,
          SUM(workoutMinutes) as minutes,
          SUM(calories) as calories
        FROM entries
        WHERE date >= ? AND date <= ?
        GROUP BY day
      ''',
        [start, end],
      );

      if (res.isNotEmpty) {
        weekly.add(res.first);
      } else {
        weekly.add({
          'day': DateFormat('yyyy-MM-dd').format(day),
          'steps': 0,
          'minutes': 0,
          'calories': 0,
        });
      }
    }
    return weekly.reversed.toList(); // oldest -> newest
  }
}
