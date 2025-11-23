const HealthLog = require("../models/HealthLog");
const User = require("../models/User"); 

// 🔹 Add a new health log & Update Streak
exports.addLog = async (req, res) => {
  try {
    console.log(`[ADD LOG] User: ${req.user._id}, Data:`, req.body);

    // 1. Create the Log
    const log = await HealthLog.create({
      ...req.body,
      userId: req.user._id,
    });

    // 2. Calculate Streak Logic
    const user = await User.findById(req.user._id);
    const today = new Date();
    today.setHours(0, 0, 0, 0); // Normalize to midnight

    let lastDate = user.lastLogDate ? new Date(user.lastLogDate) : null;
    if (lastDate) lastDate.setHours(0, 0, 0, 0);

    // Logic:
    // If last log was TODAY -> No change
    // If last log was YESTERDAY -> Streak + 1
    // If last log was OLDER -> Streak = 1 (Reset)
    
    if (!lastDate) {
      // First ever log
      user.streak = 1;
      user.lastLogDate = new Date();
    } else if (lastDate.getTime() === today.getTime()) {
      // Already logged today, do nothing to streak
    } else {
      const oneDay = 24 * 60 * 60 * 1000;
      const diff = today.getTime() - lastDate.getTime();

      if (diff <= oneDay + 1000) { // Tolerance for slight offsets
        // Consecutive day
        user.streak += 1;
      } else {
        // Missed a day (or more)
        user.streak = 1;
      }
      user.lastLogDate = new Date();
    }

    await user.save();

    console.log(`[ADD LOG SUCCESS] Streak: ${user.streak}`);
    return res.status(201).json({ message: "Log added", log, streak: user.streak });
  } catch (err) {
    console.error(`[ADD LOG ERROR] User: ${req.user._id}`, err);
    return res.status(500).json({ message: "Error saving log" });
  }
};

// 🔹 Get today's logs
exports.getTodayLogs = async (req, res) => {
  try {
    const startOfDay = new Date();
    startOfDay.setHours(0, 0, 0, 0);
    const endOfDay = new Date();
    endOfDay.setHours(23, 59, 59, 999);

    console.log(`[GET TODAY LOGS] User: ${req.user._id}`);

    const logs = await HealthLog.find({
      userId: req.user._id,
      date: { $gte: startOfDay, $lte: endOfDay },
    });

    console.log(`[GET TODAY LOGS SUCCESS] Found ${logs.length} logs`);
    return res.status(200).json(logs);
  } catch (err) {
    console.error(`[GET TODAY LOGS ERROR] User: ${req.user._id}`, err);
    return res.status(500).json({ message: "Could not fetch logs" });
  }
};

// 🔹 Get logs in a date range
exports.getLogs = async (req, res) => {
  try {
    const { startDate, endDate } = req.query;
    console.log(`[GET LOGS] User: ${req.user._id}, Start: ${startDate}, End: ${endDate}`);

    const query = { userId: req.user._id };
    if (startDate && endDate) {
      query.date = { $gte: new Date(startDate), $lte: new Date(endDate) };
    }

    const logs = await HealthLog.find(query).sort({ date: -1 });
    console.log(`[GET LOGS SUCCESS] Found ${logs.length} logs`);
    res.status(200).json(logs);
  } catch (err) {
    console.error(`[GET LOGS ERROR] User: ${req.user._id}`, err);
    res.status(500).json({ message: "Could not fetch logs" });
  }
};

// 🔹 Get summary of today's health metrics
exports.getTodaySummary = async (req, res) => {
  try {
    const startOfDay = new Date();
    startOfDay.setHours(0, 0, 0, 0);
    const endOfDay = new Date();
    endOfDay.setHours(23, 59, 59, 999);

    console.log(`[GET TODAY SUMMARY] User: ${req.user._id}`);

    const logs = await HealthLog.find({
      userId: req.user._id,
      date: { $gte: startOfDay, $lte: endOfDay },
    });

    const summary = logs.reduce(
      (acc, log) => {
        acc.water += log.water || 0;
        acc.steps += log.steps || 0;
        acc.caloriesIntake += log.caloriesIntake || 0;
        acc.caloriesBurned += log.caloriesBurned || 0;
        acc.sleepHours += log.sleepHours || 0;
        acc.heartRate = log.heartRate || acc.heartRate;
        return acc;
      },
      { water: 0, steps: 0, caloriesIntake: 0, caloriesBurned: 0, sleepHours: 0, heartRate: 0 }
    );

    console.log(`[GET TODAY SUMMARY SUCCESS]`, summary);
    res.status(200).json(summary);
  } catch (err) {
    console.error(`[GET TODAY SUMMARY ERROR] User: ${req.user._id}`, err);
    res.status(500).json({ message: "Could not fetch summary" });
  }
};

// 🔹 Delete a log
exports.deleteLog = async (req, res) => {
  try {
    console.log(`[DELETE LOG] User: ${req.user._id}, Log ID: ${req.params.id}`);

    await HealthLog.findOneAndDelete({ _id: req.params.id, userId: req.user._id });

    console.log(`[DELETE LOG SUCCESS] Log ID: ${req.params.id}`);
    res.status(200).json({ message: "Log deleted" });
  } catch (err) {
    console.error(`[DELETE LOG ERROR] User: ${req.user._id}, Log ID: ${req.params.id}`, err);
    res.status(500).json({ message: "Could not delete log" });
  }
};
