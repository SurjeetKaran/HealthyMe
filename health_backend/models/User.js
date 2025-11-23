const mongoose = require("mongoose");

const userSchema = new mongoose.Schema({
  name: String,
  email: { type: String, unique: true },
  password: String,
  age: Number,
  height: Number,
  weight: Number,
  stepGoal: { type: Number, default: 10000 },
  waterGoal: { type: Number, default: 3000 },
  calorieGoal: { type: Number, default: 2500 },
  sleepGoal: { type: Number, default: 8 },

   // 🔹 NEW: Streak Tracking
  streak: { type: Number, default: 0 },
  lastLogDate: { type: Date, default: null } 
});

module.exports = mongoose.model("User", userSchema);
