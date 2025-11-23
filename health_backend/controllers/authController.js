const User = require("../models/User");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");

// REGISTER USER
exports.register = async (req, res) => {
  try {
    console.log("\n📍 REGISTER Request Received");
    console.log("➡ Request Body:", req.body);

    const { name, email, password, age, height, weight } = req.body;

    // Check existing user
    const existing = await User.findOne({ email });
    if (existing) {
      console.warn("⚠ User already exists:", email);
      return res.status(400).json({ message: "User already exists" });
    }

    // Hash password
    const hashed = await bcrypt.hash(password, 10);
    console.log("🔐 Password hashed successfully");

    // Create user
    const user = await User.create({
      name,
      email,
      password: hashed,
      age,
      height,
      weight
    });

    console.log("✅ User Created:", user._id);

    // Generate token
    const token = jwt.sign({ userId: user._id }, process.env.JWT_SECRET, {
      expiresIn: "7d",
    });

    console.log("🔑 JWT Created:", token);

    return res.status(201).json({
      message: "Registered successfully",
      token,
      user,
    });

  } catch (error) {
    console.error("\n❌ REGISTER ERROR:", error);
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};


// LOGIN USER
exports.login = async (req, res) => {
  try {
    console.log("\n📍 LOGIN Request Received");
    console.log("➡ Request Body:", req.body);

    const { email, password } = req.body;

    // Find user
    const user = await User.findOne({ email });
    if (!user) {
      console.warn("⚠ User not found:", email);
      return res.status(404).json({ message: "User not found" });
    }

    console.log("👤 User found:", user._id);

    // Check password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      console.warn("⚠ Invalid password attempt for:", email);
      return res.status(400).json({ message: "Invalid Credentials" });
    }

    console.log("🔐 Password matched");

    // Token
    const token = jwt.sign({ userId: user._id }, process.env.JWT_SECRET, {
      expiresIn: "7d",
    });

    console.log("🔑 JWT Created:", token);

    return res.status(200).json({
      message: "Login successful",
      token,
      user,
    });

  } catch (error) {
    console.error("\n❌ LOGIN ERROR:", error);
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};

// 🔹 UPDATE USER PROFILE / GOALS
exports.updateProfile = async (req, res) => {
  try {
    console.log(`\n📍 UPDATE PROFILE Request Received`);
    console.log(`👤 User ID: ${req.user._id}`);
    console.log("➡ Update Data:", req.body);

    const updatedUser = await User.findByIdAndUpdate(
      req.user._id,
      req.body, 
      { new: true } // Return the updated doc
    ).select("-password"); // Don't send back the password

    if (!updatedUser) {
       console.warn(`⚠ User not found for update: ${req.user._id}`);
       return res.status(404).json({ message: "User not found" });
    }

    console.log("✅ Profile Updated Successfully:", updatedUser._id);
    
    res.status(200).json(updatedUser);
  } catch (error) {
    console.error("\n❌ UPDATE PROFILE ERROR:", error);
    res.status(500).json({ message: "Update failed", error: error.message });
  }
};

// 🔹 GET USER PROFILE
exports.getProfile = async (req, res) => {
  try {
    const user = await User.findById(req.user._id).select("-password");
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }
    res.status(200).json(user);
  } catch (error) {
    console.error("❌ GET PROFILE ERROR:", error);
    res.status(500).json({ message: "Server Error" });
  }
};
