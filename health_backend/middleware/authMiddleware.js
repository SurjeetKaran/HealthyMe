const jwt = require("jsonwebtoken");

module.exports = (req, res, next) => {
  const token = req.header("Authorization");
  if (!token) return res.status(401).json({ message: "Access Denied" });

  try {
    // 1. Clean the token
    const tokenString = token.replace("Bearer ", "");

    // 2. Verify the token
    const verified = jwt.verify(tokenString, process.env.JWT_SECRET);

    // 3. 🚨 CRITICAL FIX: Map 'userId' from token to 'req.user._id'
    req.user = verified; 
    req.user._id = verified.userId; // <--- This line fixes your "undefined" error

    next();
  } catch (err) {
    res.status(400).json({ message: "Invalid Token" });
  }
};