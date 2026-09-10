# Contributing to FlowSpace

Thank you for your interest in contributing to FlowSpace! This guide details local setup, architecture standards, and our pull request lifecycle.

---

## 1. Project Overview & Tech Stack

- **Client**: Flutter 3.47+ (Dart 3.13+), Riverpod 3.x, GoRouter, Dio, Flutter Secure Storage.
- **Backend**: Python 3.11+, FastAPI, Uvicorn, SQLAlchemy, PostgreSQL.
- **Persistence & Cloud**: Supabase (PostgreSQL 16, Auth, Storage, Row-Level Security).
- **CI/CD**: GitHub Actions.
- **Hosting**: Render (API) and Vercel (Web SPA).

---

## 2. Local Development Setup

### 2.1 Flutter Mobile/Web Setup
```bash
# Clone the repository
git clone https://github.com/your-username/flowspace.git
cd flowspace

# Create local environment config from template
cp .env.example .env

# Install Flutter dependencies
flutter pub get

# Run static analysis
flutter analyze

# Run test suite
flutter test

# Run application on Chrome or connected device
flutter run -d chrome
```

### 2.2 FastAPI Backend Setup
```bash
# Navigate to backend directory
cd backend

# Create virtual environment
python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run pytest suite
pytest -v tests/

# Launch development server
uvicorn app.main:app --reload --port 8000
```

Verify backend health at `http://localhost:8000/health` and open interactive docs at `http://localhost:8000/docs`.

---

## 3. Engineering Guidelines

1. **Clean Architecture**: Never access network or database layers directly from UI widgets. Follow `UI -> Provider/Notifier -> Repository -> Network/Database`.
2. **Secrets Hygiene**: NEVER commit `.env`, private keys, or API secrets. Always check `.gitignore`.
3. **Zero Analyzer Warnings**: Ensure `flutter analyze` runs with **0 issues found** before pushing.
4. **Offline First**: All user-facing writes must update local state optimistically and enqueue a `SyncQueueItem`.

---

## 4. Submitting Pull Requests

1. Fork the repo and create a feature branch (`git checkout -b feature/amazing-feature`).
2. Verify all tests pass (`flutter test`, `pytest tests/`).
3. Commit with concise messages (`git commit -m "feat(calendar): implement collision clustering"`).
4. Push and open a Pull Request against the `main` branch.
