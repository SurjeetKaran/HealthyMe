const mongoose = require("mongoose");

const healthLogSchema = new mongoose.Schema({
  userId: mongoose.Schema.Types.ObjectId,
  date: { type: Date, default: Date.now },
  water: Number,
  steps: Number,
  caloriesIntake: Number,
  caloriesBurned: Number,
  sleepHours: Number,
  heartRate: Number,
});

module.exports = mongoose.model("HealthLog", healthLogSchema);
