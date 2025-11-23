class HealthLog {
  final String? id; // MongoDB _id
  final DateTime date;
  final int? water; // in liters or ml
  final int? steps;
  final int? caloriesIntake;
  final int? caloriesBurned;
  final double? sleepHours;
  final int? heartRate;

  HealthLog({
    this.id,
    required this.date,
    this.water,
    this.steps,
    this.caloriesIntake,
    this.caloriesBurned,
    this.sleepHours,
    this.heartRate,
  });

  factory HealthLog.fromJson(Map<String, dynamic> json) {
    return HealthLog(
      id: json['_id'],
      date: DateTime.parse(json['date']),
      water: json['water'],
      steps: json['steps'],
      caloriesIntake: json['caloriesIntake'],
      caloriesBurned: json['caloriesBurned'],
      sleepHours: (json['sleepHours'] != null) ? json['sleepHours'].toDouble() : null,
      heartRate: json['heartRate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (water != null) 'water': water,
      if (steps != null) 'steps': steps,
      if (caloriesIntake != null) 'caloriesIntake': caloriesIntake,
      if (caloriesBurned != null) 'caloriesBurned': caloriesBurned,
      if (sleepHours != null) 'sleepHours': sleepHours,
      if (heartRate != null) 'heartRate': heartRate,
      'date': date.toIso8601String(),
    };
  }
}
