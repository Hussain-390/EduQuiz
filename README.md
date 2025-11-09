# 🧠 EduQuiz - Simple Quiz App (Flutter)

A **lightweight and offline Flutter quiz application** where users can create quizzes, attempt them, and view analytics — all without any external packages or databases.

---

## 📋 Overview

This app is a **self-contained quiz system** built using Flutter’s `Material` library.  
It allows two types of users:

- 🎨 **Creators** — Can create, edit, and manage quizzes.  
- 🧍 **Participants** — Can take available quizzes and view their results.

All data is stored **in-memory** (no backend or local storage), making it ideal for:
- Learning Flutter concepts (navigation, state management, dialogs)
- Offline demo projects
- Quick prototypes

---

## 🚀 Features

### 👩‍💻 Creator Mode
- Create multiple quizzes
- Add, edit, and delete questions
- Define 4 options per question
- Set the correct answer
- View quiz analytics:
  - Total attempts
  - Average score
  - Best score
  - Per-question accuracy graph

### 🧑‍🎓 Participant Mode
- Attempt quizzes question by question
- See immediate feedback (right/wrong)
- Get a result summary at the end
- View score and percentage

### 📊 Analytics
- Shows attempts history
- Displays average and best scores
- Visualizes per-question accuracy using progress bars

---

## 🧩 App Structure

```
lib/
├── main.dart
│
├── Models
│   ├── Question          # Represents a single question with 4 options
│   ├── Quiz              # Holds quiz title and list of questions
│   └── AttemptResult     # Stores quiz attempt data (score, accuracy, date)
│
├── AppState              # In-memory data store for quizzes and results
│
├── SimpleQuizApp         # Main app shell
│
├── RoleSelector          # Entry screen (choose Creator or Participant)
│
├── CreatorHome           # Dashboard for creating & managing quizzes
│   ├── QuizEditor        # Screen to add/edit a quiz
│   └── _QuestionDialog   # Dialog to create/edit questions
│
├── AttempterHome         # Lists available quizzes to attempt
│   └── TakeQuizPage      # Quiz-taking interface
│
├── ResultPage            # Displays final score after quiz completion
└── AnalyticsPage         # Shows performance metrics and history
```

---

## ⚙️ How It Works

### Data Flow:
- All data is stored in a single `AppState` instance.
- Quizzes and attempt results live **only in memory** (not saved to file or database).
- When you restart the app, data resets.

### UI Flow:
```
RoleSelector
 ├── Creator → CreatorHome → QuizEditor → Analytics
 └── Participant → AttempterHome → TakeQuizPage → ResultPage
```

---

## 🖥️ How to Run

### 1️⃣ Install Flutter
If not already installed, follow:  
👉 [Flutter Installation Guide](https://docs.flutter.dev/get-started/install)

### 2️⃣ Clone the project
```bash
git clone https://github.com/Hussain-390/EduQuiz.git
cd EduQuiz
```

### 3️⃣ Run the app
```bash
flutter run
```

✅ That’s it! The app will launch on your emulator or connected device.

---

## 🧠 Key Flutter Concepts Used

| Concept | Description |
|----------|--------------|
| `StatefulWidget` | Used for dynamic UIs like quiz progression and creation |
| `Navigator` | For page transitions between roles, quizzes, and analytics |
| `ListView` | To display quizzes and questions lists |
| `Dialogs` | For adding and editing quiz questions |
| `Material Design 3` | Clean and modern UI styling |
| `In-memory State` | Simulates backend storage using a singleton-like `AppState` |

---

## 🧩 Future Enhancements

- 💾 Save data locally using `shared_preferences` or `hive`
- ☁️ Sync quizzes with Firebase for multi-user access
- 🎨 Add themes and better animations
- 📱 Add timer-based quizzes and leaderboards

---

## 📸 Screens (Conceptual)

| Screen | Description |
|--------|--------------|
| **Role Selector** | Choose Creator or Participant |
| **Creator Dashboard** | Manage quizzes and view analytics |
| **Quiz Editor** | Create or modify quiz questions |
| **Quiz Attempt** | Take a quiz question-by-question |
| **Result Page** | Display quiz result summary |
| **Analytics Page** | Show insights and per-question accuracy |

---

## 🧑‍💻 Author

**Developed by:** *Mohammad Hussain SHaik*  
**Language:** Dart  
**Framework:** Flutter  

---

## ⭐ Support

If you like this project, give it a ⭐ on GitHub!  
Contributions and improvements are always welcome.
