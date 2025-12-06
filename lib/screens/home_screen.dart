import '../global/config.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final db = DBHelper();
  Map<String, int> todaySummary = {'steps': 0, 'minutes': 0, 'calories': 0};
  List<Map<String, dynamic>> weekly = [];
  List<FitnessEntry> recentEntries = [];

  final int stepsGoal = 10000;
  final int minutesGoal = 30;
  final int caloriesGoal = 500;

  @override
  void initState() {
    super.initState();
    _refreshAll();
  }

  Future<void> _refreshAll() async {
    final summary = await db.getSummaryForDate(DateTime.now());
    final wk = await db.getLast7DaysSummary();
    final all = await db.getAllEntries();
    setState(() {
      todaySummary = summary;
      weekly = wk;
      recentEntries = all;
    });
  }

  void _openAddEntry(BuildContext context) async {
    bool? saved = await context.push(AddEntryScreen());
    if (saved == true) _refreshAll();
  }

  void _openEntryDetail(FitnessEntry entry, BuildContext context) async {
    bool? changed = await context.push(EntryDetailScreen(entry: entry));
    if (changed == true) _refreshAll();
  }

  Widget _buildSummaryCard(String title, int value, int goal) {
    double progress = goal == 0 ? 0 : (value / goal).clamp(0.0, 1.0);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UIHelper.appText(title, fontWeight: FontWeight.bold),
            8.heightBox,
            UIHelper.appText(value.toString(), fontSize: 20),
            8.heightBox,
            LinearProgressIndicator(value: progress),
            6.heightBox,
            UIHelper.appText('${(progress * 100).toStringAsFixed(0)}% of goal'),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart() {
    // Simple textual/linear bar chart using Containers
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UIHelper.appText('Weekly Summary', fontWeight: FontWeight.bold),
            10.heightBox,
            Column(
              children: weekly.map((day) {
                final label = DateFormat(
                  'E',
                ).format(DateTime.parse(day['day']));
                final steps = day['steps'] ?? 0;
                // scale width by goal
                double pct = stepsGoal == 0
                    ? 0
                    : (steps / stepsGoal).clamp(0.0, 1.0);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    children: [
                      SizedBox(width: 40, child: UIHelper.appText(label)),
                      Expanded(
                        child: Stack(
                          children: [
                            Container(height: 20, color: Colors.grey[200]),
                            FractionallySizedBox(
                              widthFactor: pct,
                              child: Container(
                                height: 20,
                                color: Colors.green[300],
                              ),
                            ),
                          ],
                        ),
                      ),

                      8.widthBox,
                      SizedBox(
                        width: 60,
                        child: UIHelper.appText(steps.toString()),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentList(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UIHelper.appText('Recent Entries', fontWeight: FontWeight.bold),
            8.heightBox,
            ...recentEntries.take(5).map((e) {
              return ListTile(
                title: UIHelper.appText('${e.type} - ${e.steps} steps'),
                subtitle: UIHelper.appText(
                  '${DateFormat.yMMMd().format(e.date)} • ${e.workoutMinutes} min • ${e.calories} kcal',
                ),
                onTap: () => _openEntryDetail(e, context),
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 14, 80, 134),
        title: UIHelper.appText(
          'Fitness Tracker',
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshAll,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAll,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UIHelper.appText(
                'Today',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              8.heightBox,
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Steps',
                      todaySummary['steps'] ?? 0,
                      stepsGoal,
                    ),
                  ),

                  8.widthBox,
                  Expanded(
                    child: _buildSummaryCard(
                      'Workout (min)',
                      todaySummary['minutes'] ?? 0,
                      minutesGoal,
                    ),
                  ),
                ],
              ),
              8.heightBox,
              _buildSummaryCard(
                'Calories',
                todaySummary['calories'] ?? 0,
                caloriesGoal,
              ),
              12.heightBox,
              _buildWeeklyChart(),
              12.heightBox,
              _buildRecentList(context),
              80.heightBox,
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 14, 80, 134),
        onPressed: () => _openAddEntry(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
