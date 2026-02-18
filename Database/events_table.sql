-- =====================================================
-- UNIZO EVENTS TABLE SCHEMA
-- Run this in Supabase SQL Editor
-- =====================================================

-- 1. Create events table
CREATE TABLE IF NOT EXISTS events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organizer_id UUID REFERENCES users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    venue TEXT NOT NULL,
    event_date DATE NOT NULL,
    event_time TEXT NOT NULL,
    price NUMERIC(10,2) DEFAULT 0,
    is_free BOOLEAN DEFAULT false,
    image_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_events_date ON events(event_date);
CREATE INDEX IF NOT EXISTS idx_events_organizer ON events(organizer_id);
CREATE INDEX IF NOT EXISTS idx_events_active ON events(is_active);

-- =====================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =====================================================

-- Enable RLS
ALTER TABLE events ENABLE ROW LEVEL SECURITY;

-- 3. SELECT Policy — anyone can read active events
CREATE POLICY "Anyone can view active events" ON events
    FOR SELECT USING (is_active = true);

-- 4. INSERT Policy — authenticated users can create events
CREATE POLICY "Users can create events" ON events
    FOR INSERT WITH CHECK (
        auth.uid() = organizer_id
    );

-- 5. UPDATE Policy — organizers can update their own events
CREATE POLICY "Organizers can update own events" ON events
    FOR UPDATE USING (
        auth.uid() = organizer_id
    );

-- 6. DELETE Policy — organizers can delete their own events
CREATE POLICY "Organizers can delete own events" ON events
    FOR DELETE USING (
        auth.uid() = organizer_id
    );

-- =====================================================
-- OPTIONAL: Enable Realtime
-- =====================================================
-- ALTER PUBLICATION supabase_realtime ADD TABLE events;
