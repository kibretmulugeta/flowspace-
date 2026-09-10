-- ====================================================================
-- FlowSpace Database Schema: 005_storage_buckets.sql
-- Supabase Storage Buckets & Access Policies
-- ====================================================================

-- 1. Create Storage Buckets (if not exists)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES 
    ('user-avatars', 'user-avatars', TRUE, 5242880, ARRAY['image/png', 'image/jpeg', 'image/webp', 'image/gif']),
    ('note-images', 'note-images', FALSE, 10485760, ARRAY['image/png', 'image/jpeg', 'image/webp', 'image/gif', 'image/svg+xml']),
    ('attachments', 'attachments', FALSE, 26214400, NULL),
    ('project-files', 'project-files', FALSE, 52428800, NULL)
ON CONFLICT (id) DO UPDATE SET 
    public = EXCLUDED.public,
    file_size_limit = EXCLUDED.file_size_limit;

-- 2. Enable RLS on storage objects
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- ----------------------------------------------------
-- AVATARS POLICIES (Public read, authenticated write)
-- ----------------------------------------------------
CREATE POLICY "Avatars are publicly viewable"
ON storage.objects FOR SELECT
USING (bucket_id = 'user-avatars');

CREATE POLICY "Users can upload their own avatar"
ON storage.objects FOR INSERT
WITH CHECK (
    bucket_id = 'user-avatars' 
    AND auth.role() = 'authenticated'
);

CREATE POLICY "Users can update their own avatar"
ON storage.objects FOR UPDATE
USING (
    bucket_id = 'user-avatars' 
    AND auth.uid()::text = (storage.foldername(name))[1]
);

-- ----------------------------------------------------
-- NOTE IMAGES POLICIES (Authenticated workspace members)
-- ----------------------------------------------------
CREATE POLICY "Authenticated users can view note images"
ON storage.objects FOR SELECT
USING (
    bucket_id = 'note-images' 
    AND auth.role() = 'authenticated'
);

CREATE POLICY "Authenticated users can upload note images"
ON storage.objects FOR INSERT
WITH CHECK (
    bucket_id = 'note-images' 
    AND auth.role() = 'authenticated'
);

-- ----------------------------------------------------
-- ATTACHMENTS & PROJECT FILES POLICIES
-- ----------------------------------------------------
CREATE POLICY "Authenticated users can access attachments"
ON storage.objects FOR SELECT
USING (
    bucket_id IN ('attachments', 'project-files')
    AND auth.role() = 'authenticated'
);

CREATE POLICY "Authenticated users can upload attachments"
ON storage.objects FOR INSERT
WITH CHECK (
    bucket_id IN ('attachments', 'project-files')
    AND auth.role() = 'authenticated'
);
