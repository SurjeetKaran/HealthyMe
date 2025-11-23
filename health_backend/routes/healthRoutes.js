const express = require("express");
const {
  addLog,
  getTodayLogs,
  getLogs,
  getTodaySummary,
  deleteLog,
} = require("../controllers/healthController");
const auth = require("../middleware/authMiddleware");

const router = express.Router();

// 🔹 Add a new health log
router.post("/add", auth, addLog);

// 🔹 Get today's logs
router.get("/today", auth, getTodayLogs);

// 🔹 Get logs in a date range (optional query: startDate, endDate)
router.get("/", auth, getLogs);

// 🔹 Get today's summary
router.get("/summary", auth, getTodaySummary);

// 🔹 Delete a specific log by ID
router.delete("/:id", auth, deleteLog);

module.exports = router;

