-- Phase 5: Complete Learning Ecosystem
-- Gamification, flashcards, materials, notifications, achievements, leaderboard

-- Achievements table
CREATE TABLE achievements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    icon VARCHAR(100),
    category VARCHAR(100),
    xp_reward INTEGER DEFAULT 0,
    requirement_type VARCHAR(100),
    requirement_value INTEGER,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Student Achievements table
CREATE TABLE student_achievements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    achievement_id UUID NOT NULL REFERENCES achievements(id) ON DELETE CASCADE,
    unlocked_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, achievement_id)
);

-- XP Transactions table
CREATE TABLE xp_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    amount INTEGER NOT NULL,
    source VARCHAR(100),
    description TEXT,
    related_id UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Leaderboard Entries table
CREATE TABLE leaderboard_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    total_xp INTEGER DEFAULT 0,
    weekly_xp INTEGER DEFAULT 0,
    monthly_xp INTEGER DEFAULT 0,
    is_visible BOOLEAN DEFAULT true,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id)
);

-- Learning Materials table
CREATE TABLE learning_materials (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    content TEXT,
    material_type VARCHAR(100),
    subject VARCHAR(100),
    topic VARCHAR(100),
    is_ai_generated BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Flashcards table
CREATE TABLE flashcards (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    front TEXT NOT NULL,
    back TEXT NOT NULL,
    subject VARCHAR(100),
    topic VARCHAR(100),
    difficulty VARCHAR(20) DEFAULT 'medium',
    next_review_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Flashcard Progress table
CREATE TABLE flashcard_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    flashcard_id UUID NOT NULL REFERENCES flashcards(id) ON DELETE CASCADE,
    review_count INTEGER DEFAULT 0,
    correct_count INTEGER DEFAULT 0,
    last_reviewed_at TIMESTAMP WITH TIME ZONE,
    UNIQUE(user_id, flashcard_id)
);

-- Notifications table
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    message TEXT,
    type VARCHAR(100),
    is_read BOOLEAN DEFAULT false,
    action_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Announcements table
CREATE TABLE announcements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    content TEXT,
    priority VARCHAR(20) DEFAULT 'normal',
    is_active BOOLEAN DEFAULT true,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE
);

-- Notification Preferences table
CREATE TABLE notification_preferences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    study_reminders BOOLEAN DEFAULT true,
    quiz_notifications BOOLEAN DEFAULT true,
    achievement_notifications BOOLEAN DEFAULT true,
    announcement_notifications BOOLEAN DEFAULT true,
    UNIQUE(user_id)
);

-- Indexes
CREATE INDEX idx_student_achievements_user_id ON student_achievements(user_id);
CREATE INDEX idx_student_achievements_achievement_id ON student_achievements(achievement_id);
CREATE INDEX idx_xp_transactions_user_id ON xp_transactions(user_id);
CREATE INDEX idx_xp_transactions_created_at ON xp_transactions(created_at);
CREATE INDEX idx_leaderboard_entries_total_xp ON leaderboard_entries(total_xp DESC);
CREATE INDEX idx_leaderboard_entries_weekly_xp ON leaderboard_entries(weekly_xp DESC);
CREATE INDEX idx_learning_materials_user_id ON learning_materials(user_id);
CREATE INDEX idx_learning_materials_subject ON learning_materials(subject);
CREATE INDEX idx_flashcards_user_id ON flashcards(user_id);
CREATE INDEX idx_flashcards_next_review ON flashcards(next_review_date);
CREATE INDEX idx_flashcard_progress_user_id ON flashcard_progress(user_id);
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_announcements_is_active ON announcements(is_active);

-- RLS
ALTER TABLE achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE student_achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE xp_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE leaderboard_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE learning_materials ENABLE ROW LEVEL SECURITY;
ALTER TABLE flashcards ENABLE ROW LEVEL SECURITY;
ALTER TABLE flashcard_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE announcements ENABLE ROW LEVEL SECURITY;
ALTER TABLE notification_preferences ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "All users can view active achievements"
    ON achievements FOR SELECT USING (is_active = true);

CREATE POLICY "Users can view own achievements"
    ON student_achievements FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own achievements"
    ON student_achievements FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own XP transactions"
    ON xp_transactions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own XP transactions"
    ON xp_transactions FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own leaderboard entry"
    ON leaderboard_entries FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own leaderboard entry"
    ON leaderboard_entries FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own leaderboard entry"
    ON leaderboard_entries FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can view visible leaderboard entries"
    ON leaderboard_entries FOR SELECT USING (is_visible = true);

CREATE POLICY "Users can view own learning materials"
    ON learning_materials FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own learning materials"
    ON learning_materials FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own learning materials"
    ON learning_materials FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own learning materials"
    ON learning_materials FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own flashcards"
    ON flashcards FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own flashcards"
    ON flashcards FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own flashcards"
    ON flashcards FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own flashcards"
    ON flashcards FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own flashcard progress"
    ON flashcard_progress FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own flashcard progress"
    ON flashcard_progress FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own flashcard progress"
    ON flashcard_progress FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own notifications"
    ON notifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own notifications"
    ON notifications FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own notifications"
    ON notifications FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "All users can view active announcements"
    ON announcements FOR SELECT USING (is_active = true);

CREATE POLICY "Users can view own notification preferences"
    ON notification_preferences FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own notification preferences"
    ON notification_preferences FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own notification preferences"
    ON notification_preferences FOR UPDATE USING (auth.uid() = user_id);

-- Triggers
CREATE TRIGGER update_learning_materials_updated_at BEFORE UPDATE ON learning_materials
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_leaderboard_entries_updated_at BEFORE UPDATE ON leaderboard_entries
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert default achievements
INSERT INTO achievements (title, description, icon, category, xp_reward, requirement_type, requirement_value) VALUES
('First Quiz Completed', 'Complete your first quiz', 'quiz', 'milestone', 50, 'quizzes_completed', 1),
('7-Day Learning Streak', 'Maintain a 7-day learning streak', 'fire', 'streak', 100, 'streak_days', 7),
('Mathematics Master', 'Complete 10 Mathematics lessons', 'calculate', 'subject', 150, 'lessons_in_subject', 10),
('Science Explorer', 'Complete 10 Science lessons', 'science', 'subject', 150, 'lessons_in_subject', 10),
('100 Questions Solved', 'Answer 100 questions correctly', 'check_circle', 'milestone', 200, 'questions_solved', 100),
('Perfect Score', 'Get 100% on a quiz', 'star', 'performance', 100, 'perfect_quiz', 1),
('Consistent Learner', 'Study for 7 consecutive days', 'trending_up', 'streak', 75, 'consecutive_days', 7),
('Flashcard Expert', 'Review 50 flashcards', 'style', 'flashcards', 100, 'flashcards_reviewed', 50);
