class User {
  final String? id;
  final String name;
  final String email;
  final int age;
  final double? height;
  final double? weight;
  final String? token;

  // 🔹 Goal Fields (Safe Defaults)
  final int stepGoal;
  final int waterGoal;
  final int calorieGoal;
  final double sleepGoal;

  // 🔹 Streak Field
  final int streak;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.age,
    this.height,
    this.weight,
    this.token,
    this.stepGoal = 10000,
    this.waterGoal = 3000,
    this.calorieGoal = 2500,
    this.sleepGoal = 8.0,
    this.streak = 0, // Default streak
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["_id"],
      name: json["name"] ?? "User",
      email: json["email"] ?? "",
      
      // 🛡️ Safe parsing
      age: (json["age"] is int) 
          ? json["age"] 
          : int.tryParse(json["age"]?.toString() ?? "0") ?? 0,

      height: (json["height"] is num) ? (json["height"] as num).toDouble() : null,
      weight: (json["weight"] is num) ? (json["weight"] as num).toDouble() : null,
      
      token: json["token"],

      // 🛡️ Safe parsing for Goals
      stepGoal: (json["stepGoal"] is int) 
          ? json["stepGoal"] 
          : int.tryParse(json["stepGoal"]?.toString() ?? "10000") ?? 10000,

      waterGoal: (json["waterGoal"] is int) 
          ? json["waterGoal"] 
          : int.tryParse(json["waterGoal"]?.toString() ?? "3000") ?? 3000,

      calorieGoal: (json["calorieGoal"] is int) 
          ? json["calorieGoal"] 
          : int.tryParse(json["calorieGoal"]?.toString() ?? "2500") ?? 2500,

      sleepGoal: (json["sleepGoal"] is num) 
          ? (json["sleepGoal"] as num).toDouble() 
          : double.tryParse(json["sleepGoal"]?.toString() ?? "8.0") ?? 8.0,

      // 🔹 Streak Parsing
      streak: (json["streak"] is int) 
          ? json["streak"] 
          : int.tryParse(json["streak"]?.toString() ?? "0") ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "email": email,
      "age": age,
      "height": height,
      "weight": weight,
      "token": token,
      "stepGoal": stepGoal,
      "waterGoal": waterGoal,
      "calorieGoal": calorieGoal,
      "sleepGoal": sleepGoal,
      "streak": streak,
    };
  }
}