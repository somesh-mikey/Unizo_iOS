-- =====================================================
-- UNIZO REAL-TIME CHAT DATABASE SCHEMA
-- Run this in Supabase SQL Editor
-- =====================================================

-- 1. Create conversations table
CREATE TABLE IF NOT EXISTS conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    buyer_id UUID REFERENCES users(id) ON DELETE CASCADE,
    seller_id UUID REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(product_id, buyer_id)  -- One conversation per buyer-product pair
);

-- 2. Create messages table
CREATE TABLE IF NOT EXISTS messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
    sender_id UUID REFERENCES users(id) ON DELETE CASCADE,
    content TEXT,
    message_type TEXT DEFAULT 'text',  -- 'text' or 'image'
    image_url TEXT,
    read_at TIMESTAMPTZ,  -- NULL = unread, timestamp = when read
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_messages_conversation ON messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON messages(created_at);
CREATE INDEX IF NOT EXISTS idx_conversations_buyer ON conversations(buyer_id);
CREATE INDEX IF NOT EXISTS idx_conversations_seller ON conversations(seller_id);
CREATE INDEX IF NOT EXISTS idx_conversations_product ON conversations(product_id);

-- =====================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =====================================================

-- Enable RLS
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- 4. Conversations SELECT Policy
-- Users can only see conversations they're part of
CREATE POLICY "Users can view own conversations" ON conversations
    FOR SELECT USING (
        auth.uid() = buyer_id OR auth.uid() = seller_id
    );

-- 5. Conversations INSERT Policy
-- Users can create conversations where they are either buyer or seller
-- (buyer creates when initiating chat, system may need flexibility)
CREATE POLICY "Users can create conversations" ON conversations
    FOR INSERT WITH CHECK (
        auth.uid() = buyer_id OR auth.uid() = seller_id
    );

-- 6. Messages SELECT Policy
-- Users can only see messages in their conversations
CREATE POLICY "Users can view messages in own conversations" ON messages
    FOR SELECT USING (
        conversation_id IN (
            SELECT id FROM conversations
            WHERE buyer_id = auth.uid() OR seller_id = auth.uid()
        )
    );

-- 7. Messages INSERT Policy
-- Users can only send messages in their conversations
CREATE POLICY "Users can send messages in own conversations" ON messages
    FOR INSERT WITH CHECK (
        sender_id = auth.uid() AND
        conversation_id IN (
            SELECT id FROM conversations
            WHERE buyer_id = auth.uid() OR seller_id = auth.uid()
        )
    );

-- 8. Messages UPDATE Policy (for marking as read)
CREATE POLICY "Users can mark messages as read" ON messages
    FOR UPDATE USING (
        conversation_id IN (
            SELECT id FROM conversations
            WHERE buyer_id = auth.uid() OR seller_id = auth.uid()
        )
    );

-- =====================================================
-- ENABLE REALTIME
-- =====================================================

-- Enable realtime for messages table
ALTER PUBLICATION supabase_realtime ADD TABLE messages;

-- =====================================================
-- OPTIONAL: Trigger to update conversation last activity
-- (Run this if you want to track last message for sorting)
-- =====================================================

-- Add columns to conversations table (optional)
-- ALTER TABLE conversations ADD COLUMN IF NOT EXISTS last_message_at TIMESTAMPTZ;
-- ALTER TABLE conversations ADD COLUMN IF NOT EXISTS last_message TEXT;

-- CREATE OR REPLACE FUNCTION update_conversation_last_message()
-- RETURNS TRIGGER AS $$
-- BEGIN
--     UPDATE conversations
--     SET last_message = NEW.content,
--         last_message_at = NEW.created_at
--     WHERE id = NEW.conversation_id;
--     RETURN NEW;
-- END;
-- $$ LANGUAGE plpgsql;

-- CREATE TRIGGER on_new_message
-- AFTER INSERT ON messages
-- FOR EACH ROW
-- EXECUTE FUNCTION update_conversation_last_message();
