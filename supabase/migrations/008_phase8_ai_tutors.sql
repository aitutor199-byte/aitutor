-- Phase 8: AI Tutor 2.0 - Autonomous AI Teachers
-- AI teaching agents, video generation, visual learning, simulations

-- AI Teaching Agents table
CREATE TABLE ai_teaching_agents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    specialization VARCHAR(50) NOT NULL,
    description TEXT,
    capabilities JSONB,
    system_prompt TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Agent Conversations table
CREATE TABLE agent_conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    agent_id UUID NOT NULL REFERENCES ai_teaching_agents(id) ON DELETE CASCADE,
    context_data JSONB,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ended_at TIMESTAMP WITH TIME ZONE
);

-- Agent Messages table
CREATE TABLE agent_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID NOT NULL REFERENCES agent_conversations(id) ON DELETE CASCADE,
    sender_type VARCHAR(20) NOT NULL,
    message TEXT NOT NULL,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Educational Videos table
CREATE TABLE educational_videos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    subject VARCHAR(100),
    topic VARCHAR(100),
    video_url TEXT,
    thumbnail_url TEXT,
    duration_seconds INTEGER,
    transcript TEXT,
    is_ai_generated BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Visual Learning Resources table
CREATE TABLE visual_learning_resources (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    resource_type VARCHAR(50),
    title VARCHAR(255),
    subject VARCHAR(100),
    content_url TEXT,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Simulations table
CREATE TABLE simulations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    simulation_type VARCHAR(50),
    title VARCHAR(255),
    subject VARCHAR(100),
    parameters JSONB,
    results JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_ai_teaching_agents_specialization ON ai_teaching_agents(specialization);
CREATE INDEX idx_agent_conversations_user_id ON agent_conversations(user_id);
CREATE INDEX idx_agent_conversations_agent_id ON agent_conversations(agent_id);
CREATE INDEX idx_agent_messages_conversation_id ON agent_messages(conversation_id);
CREATE INDEX idx_educational_videos_user_id ON educational_videos(user_id);
CREATE INDEX idx_educational_videos_subject ON educational_videos(subject);
CREATE INDEX idx_visual_learning_resources_user_id ON visual_learning_resources(user_id);
CREATE INDEX idx_simulations_user_id ON simulations(user_id);

-- RLS
ALTER TABLE ai_teaching_agents ENABLE ROW LEVEL SECURITY;
ALTER TABLE agent_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE agent_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE educational_videos ENABLE ROW LEVEL SECURITY;
ALTER TABLE visual_learning_resources ENABLE ROW LEVEL SECURITY;
ALTER TABLE simulations ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "All users can view active agents"
    ON ai_teaching_agents FOR SELECT USING (is_active = true);

CREATE POLICY "Users can view own agent conversations"
    ON agent_conversations FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own agent conversations"
    ON agent_conversations FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view messages in own conversations"
    ON agent_messages FOR SELECT USING (
    EXISTS (SELECT 1 FROM agent_conversations WHERE agent_conversations.id = agent_messages.conversation_id AND agent_conversations.user_id = auth.uid())
    );
CREATE POLICY "Users can insert messages in own conversations"
    ON agent_messages FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM agent_conversations WHERE agent_conversations.id = agent_messages.conversation_id AND agent_conversations.user_id = auth.uid())
    );

CREATE POLICY "Users can view own educational videos"
    ON educational_videos FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own educational videos"
    ON educational_videos FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own visual resources"
    ON visual_learning_resources FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own visual resources"
    ON visual_learning_resources FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own simulations"
    ON simulations FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own simulations"
    ON simulations FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Insert default AI teaching agents
INSERT INTO ai_teaching_agents (name, specialization, description, capabilities, system_prompt) VALUES
('Math AI Teacher', 'mathematics', 'Specialized mathematics teaching agent', '["algebra", "geometry", "calculus", "statistics", "step-by-step solutions", "practice problems"]'::jsonb, 'You are a mathematics teacher. Explain problems step by step. Show your work clearly. Identify mistakes and provide alternative methods.'),
('Science AI Teacher', 'science', 'Physics, chemistry, and biology expert', '["physics", "chemistry", "biology", "experiments", "diagrams", "scientific concepts"]'::jsonb, 'You are a science teacher. Explain scientific concepts clearly. Use examples from everyday life. Explain diagrams and formulas.'),
('English AI Teacher', 'english', 'English language and literature specialist', '["grammar", "vocabulary", "writing", "speaking", "essays", "pronunciation"]'::jsonb, 'You are an English teacher. Help with grammar, vocabulary, and writing. Provide pronunciation guidance. Evaluate essays constructively.'),
('Programming AI Teacher', 'programming', 'Computer science and programming expert', '["programming fundamentals", "code explanation", "debugging", "algorithms", "data structures", "coding challenges"]'::jsonb, 'You are a programming teacher. Explain code clearly. Help debug problems. Teach algorithms and data structures. Provide coding challenges.'),
('General AI Teacher', 'general', 'General academic subjects and homework help', '["general subjects", "homework help", "study strategies", "exam preparation", "research assistance"]'::jsonb, 'You are a general education teacher. Help with various academic subjects. Provide study strategies. Assist with exam preparation.');
