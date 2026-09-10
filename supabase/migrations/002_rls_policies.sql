-- ====================================================================
-- FlowSpace Database Schema: 002_rls_policies.sql
-- Row-Level Security (RLS) Policies for Multi-Tenant Isolation
-- ====================================================================

-- 1. Helper function to check if current auth user has access to a workspace
CREATE OR REPLACE FUNCTION public.user_has_workspace_access(ws_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.workspace_members
        WHERE workspace_id = ws_id
        AND user_id = auth.uid()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Enable RLS on ALL tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workspaces ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workspace_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.task_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subtasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.calendars ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.calendar_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reminders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.editor_blocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attachments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sync_outbox_audit ENABLE ROW LEVEL SECURITY;

-- ----------------------------------------------------
-- USERS POLICIES
-- ----------------------------------------------------
CREATE POLICY users_select_self ON public.users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY users_update_self ON public.users
    FOR UPDATE USING (auth.uid() = id);

-- ----------------------------------------------------
-- WORKSPACES POLICIES
-- ----------------------------------------------------
CREATE POLICY workspaces_select ON public.workspaces
    FOR SELECT USING (public.user_has_workspace_access(id) OR owner_id = auth.uid());

CREATE POLICY workspaces_insert ON public.workspaces
    FOR INSERT WITH CHECK (owner_id = auth.uid());

CREATE POLICY workspaces_update ON public.workspaces
    FOR UPDATE USING (owner_id = auth.uid());

CREATE POLICY workspaces_delete ON public.workspaces
    FOR DELETE USING (owner_id = auth.uid());

-- ----------------------------------------------------
-- WORKSPACE MEMBERS POLICIES
-- ----------------------------------------------------
CREATE POLICY workspace_members_select ON public.workspace_members
    FOR SELECT USING (
        user_id = auth.uid() OR
        public.user_has_workspace_access(workspace_id)
    );

CREATE POLICY workspace_members_insert ON public.workspace_members
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.workspaces
            WHERE id = workspace_id AND owner_id = auth.uid()
        )
    );

-- ----------------------------------------------------
-- CATEGORIES & TAGS POLICIES
-- ----------------------------------------------------
CREATE POLICY categories_all ON public.categories
    FOR ALL USING (public.user_has_workspace_access(workspace_id));

CREATE POLICY tags_all ON public.tags
    FOR ALL USING (public.user_has_workspace_access(workspace_id));

-- ----------------------------------------------------
-- PROJECTS POLICIES
-- ----------------------------------------------------
CREATE POLICY projects_all ON public.projects
    FOR ALL USING (public.user_has_workspace_access(workspace_id));

-- ----------------------------------------------------
-- TASKS & SUBTASKS POLICIES
-- ----------------------------------------------------
CREATE POLICY tasks_all ON public.tasks
    FOR ALL USING (public.user_has_workspace_access(workspace_id));

CREATE POLICY task_tags_all ON public.task_tags
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.tasks
            WHERE tasks.id = task_tags.task_id
            AND public.user_has_workspace_access(tasks.workspace_id)
        )
    );

CREATE POLICY subtasks_all ON public.subtasks
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.tasks
            WHERE tasks.id = subtasks.task_id
            AND public.user_has_workspace_access(tasks.workspace_id)
        )
    );

-- ----------------------------------------------------
-- CALENDAR POLICIES
-- ----------------------------------------------------
CREATE POLICY calendars_all ON public.calendars
    FOR ALL USING (public.user_has_workspace_access(workspace_id));

CREATE POLICY calendar_events_all ON public.calendar_events
    FOR ALL USING (public.user_has_workspace_access(workspace_id));

-- ----------------------------------------------------
-- REMINDERS POLICIES
-- ----------------------------------------------------
CREATE POLICY reminders_all ON public.reminders
    FOR ALL USING (public.user_has_workspace_access(workspace_id));

-- ----------------------------------------------------
-- NOTES & EDITOR BLOCKS POLICIES
-- ----------------------------------------------------
CREATE POLICY notes_all ON public.notes
    FOR ALL USING (public.user_has_workspace_access(workspace_id));

CREATE POLICY editor_blocks_all ON public.editor_blocks
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.notes
            WHERE notes.id = editor_blocks.note_id
            AND public.user_has_workspace_access(notes.workspace_id)
        )
    );

-- ----------------------------------------------------
-- NOTIFICATIONS & ATTACHMENTS POLICIES
-- ----------------------------------------------------
CREATE POLICY notifications_all ON public.notifications
    FOR ALL USING (auth.uid() = user_id);

CREATE POLICY attachments_all ON public.attachments
    FOR ALL USING (public.user_has_workspace_access(workspace_id));

CREATE POLICY sync_outbox_audit_all ON public.sync_outbox_audit
    FOR ALL USING (auth.uid() = user_id);
