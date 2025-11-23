import 'package:flutter/material.dart';
import '../models/health_log.dart';
import '../services/health_service.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HealthService _healthService = HealthService();
  bool _isLoading = true;
  List<HealthLog> _logs = [];

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    fetchLogs();
  }

  Future<void> fetchLogs() async {
    setState(() => _isLoading = true);
    try {
      final logs = await _healthService.getLogs(
        start: _startDate ?? DateTime.now().subtract(const Duration(days: 7)),
        end: _endDate ?? DateTime.now(),
      );

      setState(() => _logs = logs);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to fetch logs: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 🔹 Delete Confirmation Logic
  Future<void> confirmDelete(String id) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Log"),
        content: const Text("Are you sure you want to delete this health log?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Cancel
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // Confirm
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await deleteLog(id);
    }
  }

  // 🔹 Call API to Delete
  Future<void> deleteLog(String id) async {
    setState(() => _isLoading = true);
    try {
      await _healthService.deleteLog(id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Log deleted successfully")),
        );
        // Refresh the list after deletion
        fetchLogs(); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete: $e")),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> pickStartDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
      fetchLogs();
    }
  }

  Future<void> pickEndDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
      fetchLogs();
    }
  }

  Widget buildLogCard(HealthLog log) {
    final dateStr = DateFormat('MMM dd, yyyy').format(log.date);
    
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Header Row: Date + Delete Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateStr,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 16,
                    color: Color(0xFF1E88E5),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: "Delete Log",
                  onPressed: () {
                    if (log.id != null) {
                      confirmDelete(log.id!);
                    }
                  },
                ),
              ],
            ),
            const Divider(), // Optional divider for looks
            const SizedBox(height: 4),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                if(log.water != null && log.water! > 0) Chip(label: Text("Water: ${log.water} ml")),
                if(log.steps != null && log.steps! > 0) Chip(label: Text("Steps: ${log.steps}")),
                if(log.caloriesIntake != null && log.caloriesIntake! > 0) Chip(label: Text("Intake: ${log.caloriesIntake} kcal")),
                if(log.caloriesBurned != null && log.caloriesBurned! > 0) Chip(label: Text("Burned: ${log.caloriesBurned} kcal")),
                if(log.sleepHours != null && log.sleepHours! > 0) Chip(label: Text("Sleep: ${log.sleepHours} hrs")),
                if(log.heartRate != null && log.heartRate! > 0) Chip(label: Text("Heart: ${log.heartRate} bpm")),
              ],
            )
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
            onRefresh: fetchLogs,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Date Pickers
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF42A5F5),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: pickStartDate,
                          child: Text(_startDate == null
                              ? "Start Date"
                              : DateFormat('yyyy-MM-dd').format(_startDate!)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF42A5F5),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: pickEndDate,
                          child: Text(_endDate == null
                              ? "End Date"
                              : DateFormat('yyyy-MM-dd').format(_endDate!)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Logs List
                  _logs.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              "No logs found for selected date range.",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _logs.length,
                          itemBuilder: (context, index) {
                            return buildLogCard(_logs[index]);
                          },
                        ),
                ],
              ),
            ),
          );
  }
}