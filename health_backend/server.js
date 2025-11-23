const express = require("express");
const dotenv = require("dotenv");
const cors = require("cors");
const connectDB = require("./config/db");
const PORT = process.env.PORT || 5000;

dotenv.config();
const app = express();

// Middlewares
app.use(cors());
app.use(express.json());

// DB connection
connectDB();

// Routes
app.use("/api/auth", require("./routes/authRoutes"));
app.use("/api/health", require("./routes/healthRoutes"));

app.get("/", (req, res) => {
  res.send("Health Tracking API Running...");
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(`Server running on http://0.0.0.0:${PORT}`);
});
