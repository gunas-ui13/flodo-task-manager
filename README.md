# Flodo AI Task Manager

A full-stack, responsive Task Management application built for the Flodo AI engineering assessment. This project demonstrates clean architecture, asynchronous state management, and UX-focused feature implementation.

## 🚀 Track & Stretch Goal Selection
* **Track:** Track A (The Full-Stack Builder)
  * **Frontend:** Flutter & Dart
  * **Backend:** Python (FastAPI) & SQLite
* **Stretch Goal:** Debounced Autocomplete Search
  * Implemented a custom 300ms debounce timer on the search input to optimize performance. This ensures the UI updates smoothly and prevents spamming the filtering logic on every keystroke.

## ✨ Core Features
* **Complete CRUD functionality** with a seamless integration between the Flutter frontend and the RESTful Python API.
* **Simulated Network Delays:** A strict 2-second delay is implemented on all Create and Update operations. The UI handles this by disabling the submit button and displaying a clear loading indicator to prevent duplicate submissions.
* **Offline Draft Persistence:** If a user minimizes the app or navigates away while creating a task, their text is preserved locally using `SharedPreferences` and restored upon returning.
* **Dependency Logic ("Blocked By"):** Tasks that are blocked by an incomplete parent task are visually distinct (greyed out) and disabled in the UI to prevent premature interaction.
* **Interactive Filtering:** Users can filter tasks dynamically by their status (To-Do, In Progress, Done).

---

## 🛠️ Complete Setup & Execution Instructions

### Prerequisites
* **Python 3.8+** installed on your system.
* **Flutter SDK** installed and added to your system environment variables.

### 1. Backend Setup (Python/FastAPI)
The backend utilizes FastAPI for rapid, self-documenting endpoints and SQLAlchemy for SQLite database management.

1. Open a terminal and navigate to the backend directory:
   ```bash
   cd backend
Create and activate a Python virtual environment:

Bash
# Create the environment
python -m venv venv

# Activate on Windows:
.\venv\Scripts\activate
# (Note: For Mac/Linux, use: source venv/bin/activate)
Install the required dependencies:

Bash
pip install fastapi uvicorn sqlalchemy pydantic
Start the backend server:

Bash
uvicorn main:app --reload
Note: The server will run on http://127.0.0.1:8000. The SQLite database file (tasks.db) will automatically generate upon startup. You can view the auto-generated Swagger documentation at http://127.0.0.1:8000/docs.

2. Frontend Setup (Flutter)
The frontend is a cross-platform Flutter application utilizing standard Material 3 design principles.

Open a new terminal (leaving the backend server running) and navigate to the frontend directory:
cd frontend

Fetch the required Flutter packages (http and shared_preferences):
flutter pub get

Run the application (Testing on Chrome is recommended for the fastest compilation):
flutter run -d chrome
