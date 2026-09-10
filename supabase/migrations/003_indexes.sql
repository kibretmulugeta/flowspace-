-- ====================================================================
-- FlowSpace Database Schema: 003_indexes.sql
-- High-Performance Composite & Full-Text Search Indexes
-- ====================================================================

-- 1. Workspace Partitioning & Lookups
CREATE INDEX IF NOT EXISTS idx_workspace_members_user ON public.workspace_members(user_id);
CREATE INDEX IF NOT EXISTS idx_workspace_members_ws_user ON public.workspace_members(workspace_id, user_id);

-- 2. Tasks & Subtasks
CREATE INDEX IF NOT EXISTS idx_tasks_workspace_status_due ON public.tasks(workspace_id, status, due_date);
CREATE INDEX IF NOT EXISTS idx_tasks_project ON public.tasks(project_id);
CREATE INDEX IF NOT EXISTS idx_tasks_category ON public.tasks(category_id);
CREATE INDEX IF NOT EXISTS idx_subtasks_task_order ON public.subtasks(task_id, subtask_order ASC);

-- 3. Calendar Events
CREATE INDEX IF NOT EXISTS idx_events_ws_time ON public.calendar_events(workspace_id, start_time, end_time);
CREATE INDEX IF NOT EXISTS idx_events_calendar ON public.calendar_events(calendar_id);
CREATE INDEX IF NOT EXISTS idx_events_category ON public.calendar_events(category_id);

-- 4. Notes & Editor Blocks
CREATE INDEX IF NOT EXISTS idx_notes_ws_parent ON public.notes(workspace_id, parent_id);
CREATE INDEX IF NOT EXISTS idx_notes_pinned ON public.notes(workspace_id, is_pinned) WHERE is_pinned = TRUE;
CREATE INDEX IF NOT EXISTS idx_blocks_note_order ON public.editor_blocks(note_id, block_order ASC);

-- 5. Reminders
CREATE INDEX IF NOT EXISTS idx_reminders_ws_active ON public.reminders(workspace_id, remind_at) WHERE is_completed = FALSE;

-- 6. Attachments & Notifications
CREATE INDEX IF NOT EXISTS idx_attachments_target ON public.attachments(target_type, target_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user_read ON public.notifications(user_id, is_read, created_at DESC);

-- 7. Trigram Full-Text Search Indexes (pg_trgm)
CREATE INDEX IF NOT EXISTS idx_tasks_title_trgm ON public.tasks USING gin (title gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_notes_title_trgm ON public.notes USING gin (title gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_blocks_content_trgm ON public.editor_blocks USING gin (content gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_events_title_trgm ON public.calendar_events USING gin (title gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_projects_name_trgm ON public.projects USING gin (name gin_trgm_ops);
