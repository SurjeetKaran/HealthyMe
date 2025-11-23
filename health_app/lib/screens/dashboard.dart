import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart'; 
import '../services/health_service.dart';
import '../services/auth_service.dart';
import 'add_log_screen.dart';
import 'history_screen.dart';
import 'login_screen.dart';
import 'set_goals_screen.dart'; 

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final HealthService _healthService = HealthService();
  final AuthService _authService = AuthService(); // 🔹 Needed for streak
  
  int _streak = 0; // 🔹 Local state for streak

  // 🔹 Define the 3 Screens (Today, History, Goals)
  late final List<Widget> _screens;
  
  final List<String> _titles = [
    "Today's Progress", 
    "Health History",
    "Set Daily Goals" 
  ];

  @override
  void initState() {
    super.initState();
    _screens = [
      TodaySummaryTab(healthService: _healthService), // Tab 0
      const HistoryScreen(),                          // Tab 1
      const SetGoalsScreen(),                         // Tab 2: New Goal Screen
    ];

    // 🔹 Fetch Streak Data on Load
    _fetchStreak();
  }

  // 🔹 Fetch User Profile to get Streak
  Future<void> _fetchStreak() async {
    try {
      final user = await _authService.getUserProfile();
      if (user != null && mounted) {
        setState(() {
          _streak = user.streak;
        });
      }
    } catch (e) {
      debugPrint("❌ Failed to fetch streak: $e");
    }
  }

  void onTabTapped(int index) {
    setState(() => _currentIndex = index);
    // Refresh streak if user returns to Today tab (in case they added a log elsewhere)
    if (index == 0) _fetchStreak(); 
  }

  Future<void> _handleLogout() async {
    debugPrint("👋 Dashboard: User logging out...");
    final AuthService authService = AuthService();
    await authService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF42A5F5),
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Text(_titles[_currentIndex]),
            const Spacer(),
            // 🔹 Streak Badge (Only show on Today Tab)
            if (_currentIndex == 0) ...[
              const Icon(Icons.local_fire_department, color: Colors.orangeAccent),
              const SizedBox(width: 4),
              Text(
                "$_streak", 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(width: 10),
            ]
          ],
        ), 
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF42A5F5),
        unselectedItemColor: Colors.grey,
        onTap: onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Today"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: "Goals"), // 🔹 New Tab
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 🔹 UPDATED TODAY TAB (With Progress Rings)
// ---------------------------------------------------------------------------

class TodaySummaryTab extends StatefulWidget {
  final HealthService healthService;
  const TodaySummaryTab({super.key, required this.healthService});

  @override
  State<TodaySummaryTab> createState() => _TodaySummaryTabState();
}

class _TodaySummaryTabState extends State<TodaySummaryTab> {
  final AuthService _authService = AuthService(); // 🔹 Needed to fetch profile
  bool _isLoading = true;
  
  // Data Storage
  Map<String, dynamic>? todaySummary;
  
  // 🔹 Variables to store goals (Default values just in case)
  int stepGoal = 10000;
  int waterGoal = 3000;
  int calorieGoal = 2500;
  double sleepGoal = 8.0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => _isLoading = true);
    try {
      // 1. Fetch Health Logs Summary
      final summary = await widget.healthService.getTodaySummary();
      
      // 2. 🔹 Fetch User Profile (Updated Goals)
      final user = await _authService.getUserProfile();

      if (mounted) {
        setState(() {
          todaySummary = summary;
          // 🔹 Update local variables with data from backend
          if (user != null) {
            stepGoal = user.stepGoal;
            waterGoal = user.waterGoal;
            calorieGoal = user.calorieGoal;
            sleepGoal = user.sleepGoal;
          }
        });
      }
    } catch (e) {
      debugPrint("Error fetching data: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget buildProgressCard({
    required String title, 
    required int current, 
    required int goal, 
    required IconData icon, 
    required Color color
  }) {
    // Calculate percentage (0.0 to 1.0)
    double percent = (goal == 0) ? 0 : (current / goal);
    if (percent > 1.0) percent = 1.0; // Cap at 100%

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 🔹 Circular Progress Indicator
            CircularPercentIndicator(
              radius: 35.0,
              lineWidth: 6.0,
              percent: percent,
              center: Icon(icon, color: color, size: 24),
              progressColor: color,
              backgroundColor: color.withOpacity(0.1),
              circularStrokeCap: CircularStrokeCap.round,
            ),
            const SizedBox(width: 20),
            // 🔹 Text Data
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(
                    "$current / $goal", 
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  // 🔹 Percentage Text
                  Text(
                    "${(percent * 100).toStringAsFixed(0)}% Done",
                    style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: fetchData,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 🔹 Header Stats using Progress Rings
                buildProgressCard(
                  title: "Steps",
                  current: todaySummary?['steps'] ?? 0,
                  goal: stepGoal,
                  icon: Icons.directions_walk,
                  color: Colors.green,
                ),
                buildProgressCard(
                  title: "Water (ml)",
                  current: todaySummary?['water'] ?? 0,
                  goal: waterGoal,
                  icon: Icons.local_drink,
                  color: Colors.blue,
                ),
                buildProgressCard(
                  title: "Calories (kcal)",
                  current: todaySummary?['caloriesIntake'] ?? 0,
                  goal: calorieGoal,
                  icon: Icons.fastfood,
                  color: Colors.orange,
                ),
                buildProgressCard(
                  title: "Sleep (hrs)",
                  current: (todaySummary?['sleepHours'] ?? 0).toInt(),
                  goal: sleepGoal.toInt(),
                  icon: Icons.bedtime,
                  color: Colors.indigo,
                ),
                
                // Heart Rate (No goal, just display)
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.pink.withOpacity(0.1),
                      child: const Icon(Icons.favorite, color: Colors.pink),
                    ),
                    title: const Text("Heart Rate", style: TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Text(
                      "${todaySummary?['heartRate'] ?? 0} bpm", 
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                
                // 🔹 Add Log Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddLogScreen()),
                      ).then((_) => fetchData());
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Add Health Log"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF42A5F5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}