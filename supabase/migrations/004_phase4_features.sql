-- Phase 4: Advanced AI Learning Features
-- Image questions, handwriting, study plans, analytics, voice sessions

-- Image Questions table
CREATE TABLE image_questions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    conversation_id UUID REFERENCES conversations(id) ON DELETE SET NULL,
    image_url TEXT NOT NULL,
    extracted_text TEXT,
    question_text TEXT,
    answer_text TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Handwriting Results table
CREATE TABLE handwriting_results (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    recognized_text TEXT,
    confidence_score DECIMAL(5,2),
    is_processed BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Study Plans table
CREATE TABLE study_plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    education_level VARCHAR(100),
    subjects TEXT[],
    daily_study_minutes INTEGER,
    weekly_study_hours INTEGER,
    learning_goals TEXT[],
    start_date DATE,
    end_date DATE,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Study Plan Tasks table
CREATE TABLE study_plan_tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    study_plan_id UUID NOT NULL REFERENCES study_plans(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    subject VARCHAR(100),
    lesson_id UUID REFERENCES lessons(id) ON DELETE SET NULL,
    scheduled_date DATE,
    scheduled_time TIME,
    duration_minutes INTEGER,
    is_completed BOOLEAN DEFAULT false,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Learning Analytics table
CREATE TABLE learning_analytics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    questions_asked INTEGER DEFAULT 0,
    lessons_completed INTEGER DEFAULT 0,
    quizzes_attempted INTEGER DEFAULT 0,
    study_time_minutes INTEGER DEFAULT 0,
    subjects_studied TEXT[],
    weak_topics TEXT[],
    strong_topics TEXT[],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, date)
);

-- Voice Sessions table
CREATE TABLE voice_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    conversation_id UUID REFERENCES conversations(id) ON DELETE SET NULL,
    transcript TEXT,
    audio_url TEXT,
    duration_seconds INTEGER,
    language VARCHAR(10),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_image_questions_user_id ON image_questions(user_id);
CREATE INDEX idx_image_questions_conversation_id ON image_questions(conversation_id);
CREATE INDEX idx_handwriting_results_user_id ON handwriting_results(user_id);
CREATE INDEX idx_study_plans_user_id ON study_plans(user_id);
CREATE INDEX idx_study_plan_tasks_plan_id ON study_plan_tasks(study_plan_id);
CREATE INDEX idx_learning_analytics_user_id ON learning_analytics(user_id);
CREATE INDEX idx_learning_analytics_date ON learning_analytics(date);
CREATE INDEX idx_voice_sessions_user_id ON voice_sessions(user_id);

-- RLS
ALTER TABLE image_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE handwriting_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE study_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE study_plan_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE learning_analytics ENABLE ROW LEVEL SECURITY;
ALTER TABLE voice_sessions ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view own image questions"
    ON image_questions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own image questions"
    ON image_questions FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own handwriting results"
    ON handwriting_results FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own handwriting results"
    ON handwriting_results FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own study plans"
    ON study_plans FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own study plans"
    ON study_plans FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own study plans"
    ON study_plans FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own study tasks"
    ON study_plan_tasks FOR SELECT USING (
    EXISTS (SELECT 1 FROM study_plans WHERE study_plans.id = study_plan_tasks.study_plan_id AND study_plans.user_id = auth.uid())
    );
CREATE POLICY "Users can insert own study tasks"
    ON study_plan_tasks FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM study_plans WHERE study_plans.id = study_plan_tasks.study_plan_id AND study_plans.user_id = auth.uid())
    );
CREATE POLICY "Users can update own study tasks"
    ON study_plan_tasks FOR UPDATE USING (
    EXISTS (SELECT 1 FROM study_plans WHERE study_plans.id = study_plan_tasks.study_plan_id AND study_plans.user_id = auth.uid())
    );

CREATE POLICY "Users can view own analytics"
    ON learning_analytics FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own analytics"
    ON learning_analytics FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own analytics"
    ON learning_analytics FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own voice sessions"
    ON voice_sessions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own voice sessions"
    ON voice_sessions FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Triggers
CREATE TRIGGER update_study_plans_updated_at BEFORE UPDATE ON study_plans
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_learning_analytics_updated_at BEFORE UPDATE ON learning_analytics
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
