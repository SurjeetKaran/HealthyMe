const express = require("express");
const { register, login, updateProfile, getProfile } = require("../controllers/authController");
const auth = require("../middleware/authMiddleware"); 
const router = express.Router();

router.post("/register", register);
router.post("/login", login);
router.put("/update", auth, updateProfile); 
router.get("/profile", auth, getProfile);

module.exports = router;
