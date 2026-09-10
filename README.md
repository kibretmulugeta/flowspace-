# FlowSpace ⚡

> **A Production-Ready Full-Stack Cross-Platform Scheduling & Productivity Workspace**  
> Flutter Client • FastAPI Backend • Supabase PostgreSQL (RLS & Storage) • Render & Vercel Deployment • GitHub Actions CI/CD

---

## 🌟 Overview

**FlowSpace** merges the power and flexibility of **Notion**, **Google Calendar**, and **Todoist** into a unified, calm, and lightning-fast workspace.

- **Unified Hub**: Manage your daily tasks, block-based wiki documents, multi-view calendar, milestone-driven projects, and recurring reminders in one place.
- **Offline-First**: 100% operational without network connectivity. Local mutations are queued in an offline sync outbox and atomically synchronized with the backend once online.
- **Notion-Style Block Editor**: Document canvas supporting slash commands (`/heading`, `/todo`, `/callout`, etc.), markdown shortcuts (`# `, `- [ ] `), block reordering, and nested subpages.
- **Multi-View Calendar**: Seamlessly switch between Day, Week (hourly timeline with concurrent overlapping event collision clustering), Month (with event badges), and Agenda feeds.
- **Full-Stack Cloud Architecture**: Backed by a containerized **FastAPI** REST API on **Render**, **Supabase** PostgreSQL 16+ with Row-Level Security, **Vercel** static web hosting, and **GitHub Actions** CI/CD.

---

## 🏛️ Target Architecture

```
Flutter Client (Mobile / Tablet / Web)
        │
        │ HTTPS REST API (Dio + Secure Storage + Outbox)
        ▼
FastAPI Backend (Uvicorn ASGI / Render Free Tier)
        │
        ▼
Supabase Managed PostgreSQL 16+
        ├── Row Level Security (RLS) & Multi-Tenant Isolation
        ├── Supabase Auth (JWT & OAuth)
        └── Supabase Storage (Avatars, Notes, Attachments)

GitHub & CI/CD
        └── GitHub Actions
             ├── Flutter: analyze, test, web build, android APK
             └── Backend: pytest, Docker container verification
```

---

## 🚀 Feature Highlights

### 1. Home Productivity Dashboard
- Time-aware dynamic greeting (`"Good morning / afternoon / evening, Kibret"`).
- Real-time productivity metrics: task completion percentage ring, focus time estimation, upcoming deadlines.
- Quick action action bar: `+ Task`, `+ Event`, `+ Reminder`, `+ Note`.
- Timeline feed of today's schedule and next scheduled milestones.

### 2. Task & Subtask Execution
- Five workflow tabs: **Inbox**, **Today**, **Upcoming**, **Completed**, and **All**.
- Priorities: Urgent (P1 / Red), High (P2 / Orange), Medium (P3 / Blue), Low (P4 / Neutral), and None.
- Interactive subtask checklists with live completion progress tracking.
- Swipe gestures: Swipe right to complete, swipe left to delete.
- Multi-selection mode: Long-press any task to trigger bulk completion or bulk deletion.

### 3. Notion-Style Notes & Wiki Canvas
- Block-based editor with 14 supported block types:
  - Paragraph, Headings (H1, H2, H3), Bulleted list, Numbered list, To-Do checkbox, Quote, Code snippet, Divider, Callout, and Subpages.
- Slash command palette: Type `/` to open the command palette.
- Inline Markdown shortcuts: `# `, `## `, `### `, `[] `, `- `, `1. `, `> `.
- Nested subpage hierarchy: Workspaces -> Projects -> Pages -> Subpages.

### 4. Advanced Calendar System
- Four synchronized calendar views:
  - **Month View**: Date grid with event badges and preview.
  - **Week View**: Horizontal 7-day strip + 24-hour vertical timeline with dynamic multi-column overlap clustering.
  - **Day View**: High-resolution hourly timeline with active current-time indicator.
  - **Agenda View**: Chronological continuous feed grouped by day.

### 5. Offline-First Synchronization
- Local mutations captured instantly in the `SyncQueueItem` outbox.
- Batch synchronization via `POST /api/v1/sync/batch`.
- Conflict resolution with version timestamps and client idempotency.

---

## 🛠️ Tech Stack & Directory Structure

| Layer | Technologies |
| :--- | :--- |
| **Mobile & Web Client** | Flutter 3.47+, Dart 3.13+, Riverpod 3, GoRouter, Dio, Flutter Secure Storage |
| **Backend REST API** | Python 3.11+, FastAPI, Uvicorn, SQLAlchemy, Pydantic v2 |
| **Database & Auth** | Supabase (PostgreSQL 16+, Row-Level Security, Supabase Auth & Storage) |
| **Cloud Hosting** | Render (FastAPI Web Service) & Vercel (Flutter Web SPA) |
| **DevOps & CI/CD** | GitHub Actions, Docker, Render Blueprints (`render.yaml`) |

```
flowspace/
├── lib/
│   ├── core/
│   │   ├── config/app_config.dart          # Environment configuration (Dev, Staging, Prod)
│   │   ├── network/dio_client.dart         # Production Dio HTTP client with interceptors
│   │   ├── network/sync_queue_manager.dart # Offline outbox synchronization manager
│   │   ├── storage/secure_storage_service.dart # Secure token storage
│   │   ├── theme/                          # Material 3 Light & Dark themes
│   │   └── widgets/adaptive_scaffold.dart  # Mobile bottom bar vs. Tablet navigation rail
│   └── features/                           # Feature-first domain, data, and presentation modules
├── backend/
│   ├── app/
│   │   ├── main.py                         # FastAPI app & unauthenticated /health probe
│   │   ├── core/config.py                  # Pydantic Settings & environment parsing
│   │   ├── core/security.py                # JWT tokens & bcrypt password hashing
│   │   ├── db/models.py                    # SQLAlchemy ORM models
│   │   ├── api/                            # REST routers (auth, tasks, calendar, notes, etc.)
│   │   └── services/                       # Business logic services
│   ├── tests/                              # Pytest test suite
│   ├── Dockerfile                          # Multi-stage container image
│   └── requirements.txt
├── supabase/
│   └── migrations/                         # SQL schemas, RLS policies, indexes, seed data, storage
├── .github/
│   └── workflows/                          # flutter.yml & backend.yml CI/CD pipelines
├── render.yaml                             # Render infrastructure-as-code blueprint
├── vercel.json                             # Vercel Flutter Web SPA rewrite rules
├── DEPLOYMENT.md                           # Step-by-step deployment guide
└── LICENSE                                 # MIT License
```

---

## 💻 Local Development Setup

### Flutter Client
```bash
# 1. Install dependencies
flutter pub get

# 2. Run static analysis (0 warnings)
flutter analyze

# 3. Run automated test suite
flutter test

# 4. Run on Chrome or connected device
flutter run -d chrome
```

### FastAPI Backend
```bash
# 1. Navigate to backend directory
cd backend

# 2. Setup virtual environment
python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate

# 3. Install dependencies
pip install -r requirements.txt

# 4. Run automated test suite
pytest -v tests/

# 5. Launch development server
uvicorn app.main:app --reload --port 8000
```

Verify backend health at `http://localhost:8000/health` and open interactive Swagger docs at `http://localhost:8000/docs`.

---

## ☁️ Deployment Guide

For complete, step-by-step free-tier deployment instructions across Supabase, Render, Vercel, and GitHub Actions, read **[DEPLOYMENT.md](DEPLOYMENT.md)**.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
