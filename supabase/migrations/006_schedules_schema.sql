-- ====================================================================
-- FlowSpace Database Schema: 006_schedules_schema.sql
-- Multi-Dimensional Advanced Scheduling Engine (PostgreSQL 16+)
-- ====================================================================

-- 1. Ensure public.profiles table exists and is linked with auth/users
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email VARCHAR(255),
    display_name VARCHAR(100),
    avatar_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Sync any existing public.users to public.profiles if users table exists
DO $$
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'users') THEN
        INSERT INTO public.profiles (id, email, display_name, avatar_url, created_at, updated_at)
        SELECT id, email, display_name, avatar_url, created_at, updated_at
        FROM public.users
        ON CONFLICT (id) DO NOTHING;
    END IF;
END $$;

-- 2. Define schedule_mode enum
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'schedule_mode') THEN
        CREATE TYPE schedule_mode AS ENUM ('delay', 'bounded', 'recurrent', 'dependent');
    END IF;
END $$;

-- 3. Create public.schedules table
CREATE TABLE IF NOT EXISTS public.schedules (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    description TEXT,
    mode schedule_mode NOT NULL DEFAULT 'delay',
    
    -- Time Dimension Fields
    delay_offset INTERVAL,
    window_start TIMESTAMPTZ,
    window_end TIMESTAMPTZ,
    rrule TEXT,
    prerequisite_id UUID REFERENCES public.schedules(id) ON DELETE SET NULL,
    
    -- State Tracking
    status TEXT CHECK (status IN ('pending', 'active', 'completed', 'blocked')) DEFAULT 'pending',
    completed_at TIMESTAMPTZ,
    next_run_at TIMESTAMPTZ,
    
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::TEXT, now()) NOT NULL
);

-- 4. Enable Row Level Security (RLS) & Policies
ALTER TABLE public.schedules ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users manage own schedules." ON public.schedules;
CREATE POLICY "Users manage own schedules." 
    ON public.schedules 
    FOR ALL 
    USING (auth.uid() = user_id);

-- 5. Performance Indexes
CREATE INDEX IF NOT EXISTS idx_schedules_user_id ON public.schedules(user_id);
CREATE INDEX IF NOT EXISTS idx_schedules_status ON public.schedules(status);
CREATE INDEX IF NOT EXISTS idx_schedules_mode ON public.schedules(mode);
CREATE INDEX IF NOT EXISTS idx_schedules_next_run_at ON public.schedules(next_run_at) WHERE next_run_at IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_schedules_prerequisite_id ON public.schedules(prerequisite_id) WHERE prerequisite_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_schedules_window ON public.schedules(window_start, window_end) WHERE window_start IS NOT NULL;

-- 6. Trigger: Automatic Activation of Prerequisite/Dependent Tasks
-- When a schedule transitions to 'completed', any child schedule blocked on it is automatically unblocked ('active').
CREATE OR REPLACE FUNCTION trigger_unblock_dependent_schedules()
RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.status = 'completed' AND (OLD.status IS NULL OR OLD.status != 'completed')) THEN
        UPDATE public.schedules
        SET status = 'active'
        WHERE prerequisite_id = NEW.id
          AND status = 'blocked';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_unblock_dependents ON public.schedules;
CREATE TRIGGER trg_unblock_dependents
    AFTER UPDATE OF status ON public.schedules
    FOR EACH ROW
    EXECUTE FUNCTION trigger_unblock_dependent_schedules();