import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'dashboard.dart'; // 🔹 Needed for navigation

class SetGoalsScreen extends StatefulWidget {
  const SetGoalsScreen({super.key});

  @override
  State<SetGoalsScreen> createState() => _SetGoalsScreenState();
}

class _SetGoalsScreenState extends State<SetGoalsScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  // Controllers (Default values)
  final TextEditingController _stepController = TextEditingController(text: "10000");
  final TextEditingController _waterController = TextEditingController(text: "3000");
  final TextEditingController _calorieController = TextEditingController(text: "2500");
  final TextEditingController _sleepController = TextEditingController(text: "8.0");

  @override
  void initState() {
    super.initState();
    _loadCurrentGoals();
  }

  // 🔹 Optional: Pre-fill fields with existing user data
  Future<void> _loadCurrentGoals() async {
    try {
      final user = await _authService.getUserProfile();
      if (user != null && mounted) {
        setState(() {
          _stepController.text = user.stepGoal.toString();
          _waterController.text = user.waterGoal.toString();
          _calorieController.text = user.calorieGoal.toString();
          _sleepController.text = user.sleepGoal.toString();
        });
      }
    } catch (e) {
      // Silent fail is okay here; defaults will show
    }
  }

  @override
  void dispose() {
    _stepController.dispose();
    _waterController.dispose();
    _calorieController.dispose();
    _sleepController.dispose();
    super.dispose();
  }

  Future<void> _saveGoals() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final Map<String, dynamic> goalData = {
        "stepGoal": int.tryParse(_stepController.text) ?? 10000,
        "waterGoal": int.tryParse(_waterController.text) ?? 3000,
        "calorieGoal": int.tryParse(_calorieController.text) ?? 2500,
        "sleepGoal": double.tryParse(_sleepController.text) ?? 8.0,
      };

      // 1. Update Backend
      await _authService.updateUserGoals(goalData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Goals updated successfully!")),
        );

        // 2. Navigate to Dashboard (Forces a refresh of the data)
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
          (route) => false, 
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update goals: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildGoalField(
      TextEditingController controller, String label, String unit, IconData icon,
      {bool isDecimal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
        decoration: InputDecoration(
          labelText: "$label ($unit)",
          prefixIcon: Icon(icon, color: const Color(0xFF42A5F5)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return "Please enter a value";
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
         width: double.infinity,
         padding: const EdgeInsets.all(20),
         child: SingleChildScrollView(
           child: Form(
             key: _formKey,
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 const Text(
                   "Personalize Your Targets",
                   style: TextStyle(
                     fontSize: 22, 
                     fontWeight: FontWeight.bold, 
                     color: Color(0xFF1E88E5)
                   ),
                 ),
                 const SizedBox(height: 8),
                 const Text(
                   "Adjust your daily health goals below:",
                   style: TextStyle(color: Colors.grey, fontSize: 16),
                 ),
                 const SizedBox(height: 24),

                 _buildGoalField(_stepController, "Daily Steps", "steps", Icons.directions_walk),
                 _buildGoalField(_waterController, "Water Intake", "ml", Icons.local_drink),
                 _buildGoalField(_calorieController, "Calorie Limit", "kcal", Icons.fastfood),
                 _buildGoalField(_sleepController, "Sleep Goal", "hrs", Icons.bedtime, isDecimal: true),

                 const SizedBox(height: 20),
                 
                 SizedBox(
                   width: double.infinity,
                   height: 50,
                   child: _isLoading 
                     ? const Center(child: CircularProgressIndicator())
                     : ElevatedButton.icon(
                         style: ElevatedButton.styleFrom(
                           backgroundColor: const Color(0xFF42A5F5),
                           foregroundColor: Colors.white,
                           shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(12),
                           ),
                         ),
                         onPressed: _saveGoals,
                         icon: const Icon(Icons.save),
                         label: const Text("Save Goals & Refresh", style: TextStyle(fontSize: 18)),
                       ),
                 ),
               ],
             ),
           ),
         ),
      ),
    );
  }
}