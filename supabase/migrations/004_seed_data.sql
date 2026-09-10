-- ====================================================================
-- FlowSpace Database Schema: 004_seed_data.sql
-- Seed Initial Demo Data (Kibret Workspace)
-- ====================================================================

DO $$
DECLARE
    v_user_id UUID := '11111111-1111-1111-1111-111111111111';
    v_ws_id UUID := '22222222-2222-2222-2222-222222222222';
    v_cat_work UUID := '33333333-3333-3333-3333-333333333331';
    v_cat_personal UUID := '33333333-3333-3333-3333-333333333332';
    v_proj_id UUID := '44444444-4444-4444-4444-444444444444';
    v_cal_id UUID := '55555555-5555-5555-5555-555555555555';
    v_task_id UUID := '66666666-6666-6666-6666-666666666666';
    v_note_id UUID := '77777777-7777-7777-7777-777777777777';
BEGIN
    -- 1. Insert Demo User
    INSERT INTO public.users (id, email, display_name, password_hash)
    VALUES (v_user_id, 'kibret@flowspace.app', 'Kibret', '$2b$12$eX.SampleHashedPasswordPlaceholder')
    ON CONFLICT (id) DO NOTHING;

    -- 2. Insert Demo Workspace
    INSERT INTO public.workspaces (id, owner_id, name, icon, color_hex)
    VALUES (v_ws_id, v_user_id, 'Kibret''s Workspace', '🚀', '#4F46E5')
    ON CONFLICT (id) DO NOTHING;

    -- 3. Workspace Membership
    INSERT INTO public.workspace_members (workspace_id, user_id, role)
    VALUES (v_ws_id, v_user_id, 'owner')
    ON CONFLICT (workspace_id, user_id) DO NOTHING;

    -- 4. Categories
    INSERT INTO public.categories (id, workspace_id, name, color_hex, icon)
    VALUES 
        (v_cat_work, v_ws_id, 'Engineering', '#2563EB', 'code'),
        (v_cat_personal, v_ws_id, 'Productivity', '#059669', 'sparkles')
    ON CONFLICT (id) DO NOTHING;

    -- 5. Primary Calendar
    INSERT INTO public.calendars (id, workspace_id, name, color_hex)
    VALUES (v_cal_id, v_ws_id, 'Sprint Planning Calendar', '#4F46E5')
    ON CONFLICT (id) DO NOTHING;

    -- 6. Project
    INSERT INTO public.projects (id, workspace_id, category_id, name, description, icon, color_hex, status)
    VALUES (v_proj_id, v_ws_id, v_cat_work, 'FlowSpace Mobile Architecture', 'Deploy cross-platform Flutter client and FastAPI backend with Supabase.', '📱', '#4F46E5', 'active')
    ON CONFLICT (id) DO NOTHING;

    -- 7. Task & Subtasks
    INSERT INTO public.tasks (id, workspace_id, project_id, category_id, title, description, status, priority, due_date)
    VALUES (v_task_id, v_ws_id, v_proj_id, v_cat_work, 'Configure Supabase & Render Deployment', 'Setup GitHub Actions CI/CD pipelines, RLS policies, and Docker image.', 'in_progress', 'urgent', NOW() + INTERVAL '1 day')
    ON CONFLICT (id) DO NOTHING;

    INSERT INTO public.subtasks (task_id, title, is_completed, subtask_order)
    VALUES 
        (v_task_id, 'Write SQL migrations and RLS policies', TRUE, 0),
        (v_task_id, 'Configure Render web service blueprint', TRUE, 1),
        (v_task_id, 'Verify Flutter web static deployment on Vercel', FALSE, 2)
    ON CONFLICT DO NOTHING;

    -- 8. Calendar Event
    INSERT INTO public.calendar_events (workspace_id, calendar_id, category_id, title, description, start_time, end_time, location, color_hex)
    VALUES (v_ws_id, v_cal_id, v_cat_work, 'Architecture & Deployment Review', 'Review Supabase PostgreSQL schema, FastAPI backend, and Flutter client.', NOW() + INTERVAL '2 hours', NOW() + INTERVAL '3 hours', 'Google Meet', '#2563EB')
    ON CONFLICT DO NOTHING;

    -- 9. Reminder
    INSERT INTO public.reminders (workspace_id, title, notes, remind_at)
    VALUES (v_ws_id, 'Verify GitHub Actions CI Pass', 'Ensure flutter analyze, test, and backend test workflows run green.', NOW() + INTERVAL '4 hours')
    ON CONFLICT DO NOTHING;

    -- 10. Note & Notion-Style Blocks
    INSERT INTO public.notes (id, workspace_id, title, icon, is_pinned)
    VALUES (v_note_id, v_ws_id, 'FlowSpace Cloud Architecture Spec', '⚡', TRUE)
    ON CONFLICT (id) DO NOTHING;

    INSERT INTO public.editor_blocks (note_id, block_type, content, block_order, metadata)
    VALUES
        (v_note_id, 'heading1', 'Cloud Infrastructure & Free-Tier Strategy', 0, '{}'::jsonb),
        (v_note_id, 'paragraph', 'FlowSpace combines a Flutter mobile/web client with a containerized FastAPI backend deployed on Render, backed by Supabase PostgreSQL.', 1, '{}'::jsonb),
        (v_note_id, 'todo', 'Deploy migrations to Supabase', 2, '{"is_checked": true}'::jsonb),
        (v_note_id, 'todo', 'Push code to GitHub and trigger CI/CD', 3, '{"is_checked": false}'::jsonb)
    ON CONFLICT DO NOTHING;
END $$;
