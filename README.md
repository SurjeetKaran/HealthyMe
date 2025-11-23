# HealthyMe - Full Stack Health Tracker App

**HealthyMe** is a comprehensive health tracking application designed to help users monitor their daily wellness activities.  
It features a mobile frontend built with **Flutter** and a robust RESTful backend built with **Node.js, Express, and MongoDB**.

The app allows users to track vital metrics like water intake, steps, calories, and sleep, while staying motivated with daily goals and streak counters.

---

## 🚀 Features

### 📱 Mobile App (Flutter)
- **Authentication:** Secure Login & Registration using JWT.
- **Dashboard:**
  - **Visual Progress:** Circular progress rings for Steps, Water, Calories, and Sleep.
  - **Streak Counter:** Gamified daily logging streak with a visual badge (🔥).
  - **Heart Rate:** Quick view of the latest heart rate log.
- **Logging:** Add daily health logs easily. Supports partial updates (e.g., logging only water).
- **History:** View past health logs filtered by custom date ranges.
- **Goal Setting:** Customize daily targets for steps, hydration, calories, and sleep.
- **UI/UX:** Modern interface with custom splash screen, gradient backgrounds, and intuitive navigation.

### 🖥️ Backend (Node.js)
- **REST API:** Structured endpoints for Authentication and Health Data management.
- **Database:** MongoDB via Mongoose for data persistence.
- **Security:**
  - Password hashing using bcrypt.
  - Protected routes using JSON Web Token (JWT) middleware.
- **Smart Logic:**
  - Automatic streak calculation based on log dates.
  - Daily summary aggregation for the dashboard.

---

## 📂 Project Structure

```

HealthyMe/
├── health_app/          # Flutter Mobile Application (Frontend)
│   ├── lib/
│   │   ├── models/      # Data models (User, HealthLog)
│   │   ├── screens/     # UI Screens (Login, Dashboard, History, etc.)
│   │   ├── services/    # API integration (Auth, Health)
│   │   └── utils/       # Constants and helpers
│   └── pubspec.yaml     # Dependencies
│
└── health_backend/      # Node.js Server (Backend)
├── config/          # Database configuration
├── controllers/     # Business logic (Auth, Health)
├── middleware/      # Auth verification
├── models/          # Mongoose Schemas
├── routes/          # API Routes definition
└── server.js        # Entry point

````

---

## 🛠️ Tech Stack

- **Frontend:** Flutter, Dart  
- **Backend:** Node.js, Express.js  
- **Database:** MongoDB  

**Flutter Dependencies:**
- `http` – For API requests.  
- `shared_preferences` – For storing auth tokens locally.  
- `percent_indicator` – For dashboard progress rings.  
- `intl` – For date formatting.  

---

## 🔧 Installation & Setup

### 1️⃣ Backend Setup
1. Navigate to the backend folder:
   ```bash
   cd health_backend
````

2. Install dependencies:

   ```bash
   npm install
   ```
3. Create a `.env` file in the backend root:

   ```env
   PORT=5000
   MONGO_URI=your_mongodb_connection_string_here
   JWT_SECRET=your_secret_key_here
   ```
4. Start the server:

   ```bash
   node server.js
   ```

Server will run at: `http://0.0.0.0:5000`

### 2️⃣ Frontend Setup

1. Navigate to the frontend folder:

   ```bash
   cd health_app
   ```
2. Install Flutter dependencies:

   ```bash
   flutter pub get
   ```
3. Configure the API URL:

   * Open `lib/utils/constants.dart`.
   * Set `BASE_URL` to your machine's IP (e.g., `http://192.168.1.5:5000/api`).
   * For Android Emulator, use: `http://10.0.2.2:5000/api`.
4. Run the app:

   ```bash
   flutter run
   ```

---

## 🤝 Contributing

This is a personal project for learning Full Stack development with Flutter and Node.js.
Feel free to **fork it**, experiment, and improve the project!



