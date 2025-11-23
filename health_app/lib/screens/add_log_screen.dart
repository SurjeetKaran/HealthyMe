import 'package:flutter/material.dart';
import '../services/health_service.dart';
import '../models/health_log.dart';

class AddLogScreen extends StatefulWidget {
  const AddLogScreen({super.key});

  @override
  State<AddLogScreen> createState() => _AddLogScreenState();
}

class _AddLogScreenState extends State<AddLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final HealthService _healthService = HealthService();

  final TextEditingController _waterController = TextEditingController();
  final TextEditingController _stepsController = TextEditingController();
  final TextEditingController _caloriesIntakeController = TextEditingController();
  final TextEditingController _caloriesBurnedController = TextEditingController();
  final TextEditingController _sleepController = TextEditingController();
  final TextEditingController _heartRateController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _waterController.dispose();
    _stepsController.dispose();
    _caloriesIntakeController.dispose();
    _caloriesBurnedController.dispose();
    _sleepController.dispose();
    _heartRateController.dispose();
    super.dispose();
  }

  Future<void> _addLog() async {
    // 🔹 FIX: Validation Logic
    // Instead of requiring all fields, we check if ALL are empty.
    bool isAllEmpty = _waterController.text.isEmpty &&
        _stepsController.text.isEmpty &&
        _caloriesIntakeController.text.isEmpty &&
        _caloriesBurnedController.text.isEmpty &&
        _sleepController.text.isEmpty &&
        _heartRateController.text.isEmpty;

    if (isAllEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter at least one value")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Safe parsing: Empty strings become 0 (or null if you prefer, but 0 is safer for math)
      final log = HealthLog(
        date: DateTime.now(),
        water: int.tryParse(_waterController.text.trim()) ?? 0,
        steps: int.tryParse(_stepsController.text.trim()) ?? 0,
        caloriesIntake: int.tryParse(_caloriesIntakeController.text.trim()) ?? 0,
        caloriesBurned: int.tryParse(_caloriesBurnedController.text.trim()) ?? 0,
        sleepHours: double.tryParse(_sleepController.text.trim()) ?? 0,
        heartRate: int.tryParse(_heartRateController.text.trim()) ?? 0,
      );

      await _healthService.addLog(log);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Health log added successfully!")),
        );
        Navigator.pop(context, true); // Return to Dashboard & Refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to add log: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildNumberField(TextEditingController controller, String label, String unit,
      {bool allowDecimal = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: allowDecimal
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      decoration: InputDecoration(
        labelText: "$label ($unit)",
        border: const OutlineInputBorder(),
      ),
      // 🔹 FIX: Removed 'validator' so fields are optional
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Health Log"),
        backgroundColor: const Color(0xFF42A5F5),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildNumberField(_waterController, "Water", "ml"),
              const SizedBox(height: 12),
              _buildNumberField(_stepsController, "Steps", "steps"),
              const SizedBox(height: 12),
              _buildNumberField(_caloriesIntakeController, "Calories Intake", "kcal"),
              const SizedBox(height: 12),
              _buildNumberField(_caloriesBurnedController, "Calories Burned", "kcal"),
              const SizedBox(height: 12),
              _buildNumberField(_sleepController, "Sleep", "hrs", allowDecimal: true),
              const SizedBox(height: 12),
              _buildNumberField(_heartRateController, "Heart Rate", "bpm"),
              const SizedBox(height: 20),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF42A5F5),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _addLog,
                        child: const Text("Add Log"),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}