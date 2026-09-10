# FlowSpace REST API Specification

This document defines the RESTful backend API specification for FlowSpace (FastAPI / Node.js compatible), corresponding to the mobile client contracts implemented in `lib/core/network/api_client.dart`.

---

## 1. Overview & Conventions

- **Base URL**: `https://api.flowspace.app/api/v1`
- **Content Type**: `application/json; charset=utf-8`
- **Authentication**: `Authorization: Bearer <access_token>` (JWT)
- **Date/Time Standard**: ISO 8601 UTC (`YYYY-MM-DDTHH:mm:ss.sssZ`)
- **Pagination**: Limit/Offset query parameters (`?limit=50&offset=0`)

### Standard Response Envelope
```json
{
  "success": true,
  "data": {},
  "meta": {
    "timestamp": "2026-09-09T18:00:00.000Z",
    "version": "1.0.0"
  }
}
```

### Standard Error Envelope
```json
{
  "success": false,
  "error": {
    "code": "RESOURCE_NOT_FOUND",
    "message": "Task with ID 'task-999' was not found.",
    "details": []
  }
}
```

---

## 2. Authentication Endpoints

### `POST /auth/register`
Register a new FlowSpace account.

**Request Body**:
```json
{
  "email": "kibret@example.com",
  "password": "SecurePassword123!",
  "display_name": "Kibret",
  "avatar_url": null
}
```

**Response (201 Created)**:
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "usr-uuid-1234",
      "email": "kibret@example.com",
      "display_name": "Kibret",
      "avatar_url": null,
      "created_at": "2026-09-09T18:00:00.000Z"
    },
    "tokens": {
      "access_token": "eyJhbGciOi...",
      "refresh_token": "def5020...",
      "expires_in": 3600
    }
  }
}
```

### `POST /auth/login`
Authenticate with email and password.

**Request Body**:
```json
{
  "email": "kibret@example.com",
  "password": "SecurePassword123!"
}
```

**Response (200 OK)**:
```json
{
  "success": true,
  "data": {
    "user": { "id": "usr-uuid-1234", "email": "kibret@example.com", "display_name": "Kibret" },
    "tokens": { "access_token": "eyJhbGciOi...", "refresh_token": "def5020...", "expires_in": 3600 }
  }
}
```

### `POST /auth/refresh`
Refresh an expired access token using a valid refresh token.

**Request Body**:
```json
{ "refresh_token": "def5020..." }
```

---

## 3. Workspaces Endpoints

### `GET /workspaces`
List workspaces accessible to the authenticated user.

### `POST /workspaces`
Create a new workspace.

**Request Body**:
```json
{
  "name": "Personal Workspace",
  "icon": "🚀",
  "color_hex": "#4F46E5"
}
```

---

## 4. Task Management Endpoints

### `GET /tasks`
Fetch tasks for the active workspace. Supports filters:
- `status`: `todo | in_progress | completed | cancelled`
- `priority`: `urgent | high | medium | low | none`
- `project_id`: UUID
- `category_id`: UUID
- `due_before`: ISO 8601 date
- `due_after`: ISO 8601 date

### `POST /tasks`
Create a new task.

**Request Body**:
```json
{
  "title": "Review Mobile Architecture PR",
  "description": "Examine state management and calendar overlap logic.",
  "status": "todo",
  "priority": "urgent",
  "due_date": "2026-09-10T17:00:00.000Z",
  "project_id": "proj-mobile-01",
  "category_id": "cat-eng",
  "subtasks": [
    { "title": "Check Riverpod notifiers", "is_completed": false },
    { "title": "Verify test suite execution", "is_completed": false }
  ]
}
```

### `PATCH /tasks/{id}`
Update task fields or toggle completion.

**Request Body**:
```json
{
  "status": "completed",
  "completed_at": "2026-09-09T18:15:00.000Z"
}
```

### `DELETE /tasks/{id}`
Delete a task and its associated subtasks.

---

## 5. Calendar Endpoints

### `GET /calendar/events`
Fetch calendar events within a datetime range.
- Query parameters: `start_time=2026-09-01T00:00:00Z&end_time=2026-09-30T23:59:59Z`

### `POST /calendar/events`
Schedule a new calendar event.

**Request Body**:
```json
{
  "title": "Engineering Sync",
  "description": "Weekly sprint sync with cross-platform core team.",
  "start_time": "2026-09-10T10:00:00.000Z",
  "end_time": "2026-09-10T11:00:00.000Z",
  "is_all_day": false,
  "location": "Google Meet",
  "color_hex": "#2563EB",
  "category_id": "cat-eng",
  "recurrence_rule": "FREQ=WEEKLY;BYDAY=TH"
}
```

### `PATCH /calendar/events/{id}`
Update an event's timeslot or recurrence parameters.

---

## 6. Notes & Block Editor Endpoints

### `GET /notes`
List root or nested notes/wikis in the workspace.
- Query parameter: `parent_id` (optional for hierarchical subpages)

### `GET /notes/{id}`
Fetch full note document including ordered editor blocks.

**Response (200 OK)**:
```json
{
  "success": true,
  "data": {
    "id": "note-arch-spec",
    "title": "Architecture Blueprint",
    "icon": "📐",
    "cover_url": null,
    "parent_id": null,
    "is_pinned": true,
    "is_archived": false,
    "blocks": [
      {
        "id": "blk-1",
        "type": "heading1",
        "content": "System Architecture Overview",
        "order": 0,
        "metadata": {}
      },
      {
        "id": "blk-2",
        "type": "paragraph",
        "content": "FlowSpace uses a feature-first Clean Architecture pattern.",
        "order": 1,
        "metadata": {}
      },
      {
        "id": "blk-3",
        "type": "todo",
        "content": "Deploy database migrations to production",
        "order": 2,
        "metadata": { "is_checked": false }
      }
    ],
    "updated_at": "2026-09-09T18:20:00.000Z"
  }
}
```

### `PUT /notes/{id}/blocks`
Batch replace or update ordered blocks for a note document.

**Request Body**:
```json
{
  "blocks": [
    { "id": "blk-1", "type": "heading1", "content": "Updated Heading", "order": 0 },
    { "id": "blk-4", "type": "callout", "content": "Critical notice", "order": 1, "metadata": { "icon": "⚠️" } }
  ]
}
```

---

## 7. Projects & Reminders Endpoints

### `GET /projects`
Retrieve all projects with computed task completion stats.

### `POST /projects`
Create a project with target deadlines, budget, and category.

### `GET /reminders`
Retrieve upcoming or past reminders.

### `POST /reminders/{id}/snooze`
Snooze a reminder by a duration preset (15 min, 1 hour, tomorrow morning).

**Request Body**:
```json
{
  "snooze_until": "2026-09-10T09:00:00.000Z"
}
```

---

## 8. Offline Outbox Batch Synchronization

### `POST /sync/batch`
Atomically applies a queue of offline client mutations and returns updated server timestamps and conflicting states.

**Request Body**:
```json
{
  "client_id": "device-pixel-8-pro",
  "actions": [
    {
      "action_id": "sync-act-101",
      "entity_type": "task",
      "action_type": "update",
      "entity_id": "task-001",
      "payload": {
        "status": "completed",
        "completed_at": "2026-09-09T18:25:00.000Z"
      },
      "timestamp": "2026-09-09T18:25:00.000Z"
    },
    {
      "action_id": "sync-act-102",
      "entity_type": "note_block",
      "action_type": "create",
      "entity_id": "blk-new-77",
      "payload": {
        "page_id": "note-arch-spec",
        "type": "paragraph",
        "content": "Drafted offline in subway.",
        "order": 3
      },
      "timestamp": "2026-09-09T18:26:30.000Z"
    }
  ]
}
```

**Response (200 OK)**:
```json
{
  "success": true,
  "data": {
    "processed_action_ids": ["sync-act-101", "sync-act-102"],
    "conflicts": [],
    "server_sync_time": "2026-09-09T18:27:00.000Z"
  }
}
```
