# FlowSpace Free-Tier Cloud Deployment Guide

A step-by-step, beginner-friendly guide to deploying FlowSpace across free-tier cloud infrastructure:
- **Database & Auth & Storage**: Supabase (Free tier)
- **REST API Backend**: Render (Free web service tier)
- **Web Frontend**: Vercel (Free static hosting)
- **Continuous Integration**: GitHub Actions (Free tier minutes)

---

## 1. Prerequisites & Accounts

Before beginning, create free accounts on:
1. **[GitHub](https://github.com/)** — Code hosting & CI/CD automation
2. **[Supabase](https://supabase.com/)** — Managed PostgreSQL, Auth, and Object Storage
3. **[Render](https://render.com/)** — Containerized FastAPI web service
4. **[Vercel](https://vercel.com/)** — Static hosting for Flutter Web

---

## 2. Step 1: Push Project to GitHub

Initialize the Git repository and push your code:

```bash
# In the project root (e:\Developer\Cross Platform\Notion):
git init -b main

# Stage all project files (secrets are already excluded by .gitignore)
git add .

# Create initial commit
git commit -m "feat: initial commit with Flutter client, FastAPI backend, and Supabase migrations"

# Link your remote repository and push
git remote add origin https://github.com/<YOUR_GITHUB_USERNAME>/flowspace.git
git push -u origin main
```

---

## 3. Step 2: Supabase Setup (Database, Auth, Storage)

### 3.1 Create Project
1. Log in to [Supabase](https://supabase.com/) and click **New project**.
2. Name the project `flowspace`, set a strong database password, and choose your preferred cloud region.
3. Once provisioned, navigate to **Project Settings** > **API**:
   - Copy **Project URL** (e.g., `https://xyzcompany.supabase.co`)
   - Copy **Project API Keys** > `anon` / `public` (for Flutter client)
   - Copy **Project API Keys** > `service_role` (for FastAPI backend ONLY — keep secret!)
4. Navigate to **Project Settings** > **Database**:
   - Under **Connection string**, select **URI** and **Mode: Session** or **Transaction Pooler** (Port `6543` or `5432`). Copy this string as your `DATABASE_URL`.

### 3.2 Execute SQL Migrations
In the Supabase Dashboard, open the **SQL Editor** and run the migration files in order:
1. Open [`supabase/migrations/001_initial_schema.sql`](supabase/migrations/001_initial_schema.sql) -> Paste & Click **Run**.
2. Open [`supabase/migrations/002_rls_policies.sql`](supabase/migrations/002_rls_policies.sql) -> Paste & Click **Run**.
3. Open [`supabase/migrations/003_indexes.sql`](supabase/migrations/003_indexes.sql) -> Paste & Click **Run**.
4. Open [`supabase/migrations/004_seed_data.sql`](supabase/migrations/004_seed_data.sql) -> Paste & Click **Run**.
5. Open [`supabase/migrations/005_storage_buckets.sql`](supabase/migrations/005_storage_buckets.sql) -> Paste & Click **Run**.

### 3.3 Verify Storage Buckets
Navigate to **Storage** in the Supabase Dashboard. Confirm the four buckets appear:
- `user-avatars` (Public read)
- `note-images` (Private)
- `attachments` (Private)
- `project-files` (Private)

---

## 4. Step 3: Render Deployment (FastAPI Backend)

### 4.1 Deploy with Blueprint (`render.yaml`)
1. Log in to [Render](https://render.com/) and click **New +** > **Blueprint**.
2. Connect your GitHub repository `flowspace`.
3. Render detects `render.yaml` automatically.
4. Fill in the required environment variables prompted by the dashboard:
   - `DATABASE_URL`: Your Supabase connection pooler URI.
   - `SUPABASE_URL`: Your Supabase Project URL (`https://xyz.supabase.co`).
   - `SUPABASE_SERVICE_ROLE_KEY`: Your Supabase `service_role` secret key.
   - `JWT_SECRET`: Click generate or provide a 32+ character random string.
   - `CORS_ORIGINS`: Add your Vercel URL and localhost: `http://localhost:3000,http://localhost:8080,https://flowspace.vercel.app`.
5. Click **Apply**.

### 4.2 Verify Backend Health
Once Render completes building:
1. Open the assigned URL: `https://flowspace-api.onrender.com/health`
2. You will receive:
   ```json
   {
     "status": "ok",
     "service": "flowspace-api"
   }
   ```
3. Interactive API documentation is available at `https://flowspace-api.onrender.com/docs`.

---

## 5. Step 4: Vercel Deployment (Flutter Web)

### 5.1 Configure Vercel Project
1. Log in to [Vercel](https://vercel.com/) and click **Add New...** > **Project**.
2. Import your GitHub repository `flowspace`.
3. Under **Build and Output Settings**:
   - **Framework Preset**: Other
   - **Build Command**:
     ```bash
     flutter build web --release --dart-define=API_BASE_URL=https://flowspace-api.onrender.com/api/v1 --dart-define=SUPABASE_URL=https://xyz.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY --dart-define=ENVIRONMENT=production
     ```
   - **Output Directory**: `build/web`
4. The included [`vercel.json`](vercel.json) automatically directs all SPA routes to `/index.html` preventing 404 errors on page reload.
5. Click **Deploy**.

---

## 6. Step 5: Configure GitHub Secrets for CI/CD

In your GitHub repository, navigate to **Settings** > **Secrets and variables** > **Actions** and add:

| Secret Name | Value Description | Where Used |
| :--- | :--- | :--- |
| `API_BASE_URL` | `https://flowspace-api.onrender.com/api/v1` | Flutter Web Build in CI |
| `SUPABASE_URL` | `https://your-project.supabase.co` | Flutter Client & Backend CI |
| `SUPABASE_ANON_KEY` | Supabase Public `anon` Key | Flutter Web Build in CI |
| `DATABASE_URL` | Supabase Database URI | Backend CI Tests |
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase `service_role` Key | Backend CI Tests |
| `JWT_SECRET` | 32-character random string | Backend CI Tests |

---

## 7. Step 6: Mobile Build Instructions (Android & iOS)

### 7.1 Android APK & App Bundle
- **Debug APK** (Generated automatically by GitHub Actions):
  ```bash
  flutter build apk --debug
  # Output: build/app/outputs/flutter-apk/app-debug.apk
  ```
- **Release AAB (Google Play)**:
  1. Generate an upload keystore:
     ```bash
     keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
     ```
  2. Create `android/key.properties` (ignored by git).
  3. Build app bundle:
     ```bash
     flutter build appbundle --release
     ```

### 7.2 iOS (TestFlight / App Store)
1. Open the iOS project in Xcode on macOS:
   ```bash
   open ios/Runner.xcworkspace
   ```
2. In **Signing & Capabilities**, select your Apple Developer Team.
3. Build the archive:
   ```bash
   flutter build ipa --release
   ```
*Note: iOS App Store distribution requires an active Apple Developer Program account.*

---

## 8. Production Verification Checklist

- [ ] `GET /health` returns `200 OK` on Render.
- [ ] Swagger docs at `/docs` render all endpoint routes.
- [ ] Supabase SQL tables and RLS policies are active.
- [ ] Vercel static site loads Flutter Web and route transitions work without 404s.
- [ ] GitHub Actions workflows (`flutter.yml` and `backend.yml`) execute green on push.
- [ ] Offline test: Toggle airplane mode in client, create a task, re-enable network, and observe sync outbox flush.
