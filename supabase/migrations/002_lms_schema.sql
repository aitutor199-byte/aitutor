-- Phase 2: Learning Management System Schema
-- This migration adds tables for subjects, chapters, lessons, quizzes, examinations, bookmarks, and progress tracking

-- Subjects table
CREATE TABLE subjects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    icon VARCHAR(50),
    color VARCHAR(20),
    order_index INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Chapters table
CREATE TABLE chapters (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    order_index INTEGER DEFAULT 0,
    education_level VARCHAR(100),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(subject_id, title, education_level)
);

-- Lessons table
CREATE TABLE lessons (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    chapter_id UUID NOT NULL REFERENCES chapters(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    learning_objectives TEXT[],
    definitions JSONB,
    examples JSONB,
    formulas JSONB,
    image_urls TEXT[],
    order_index INTEGER DEFAULT 0,
    language VARCHAR(10) DEFAULT 'en',
    is_published BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(chapter_id, title, language)
);

-- Lesson Progress table
CREATE TABLE lesson_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    lesson_id UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    is_completed BOOLEAN DEFAULT false,
    completion_percentage INTEGER DEFAULT 0 CHECK (completion_percentage >= 0 AND completion_percentage <= 100),
    time_spent_minutes INTEGER DEFAULT 0,
    last_accessed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, lesson_id)
);

-- Quizzes table
CREATE TABLE quizzes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lesson_id UUID REFERENCES lessons(id) ON DELETE SET NULL,
    chapter_id UUID REFERENCES chapters(id) ON DELETE SET NULL,
    subject_id UUID REFERENCES subjects(id) ON DELETE SET NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    question_type VARCHAR(50) NOT NULL CHECK (question_type IN ('multiple_choice', 'true_false', 'fill_blank', 'short_answer')),
    difficulty VARCHAR(20) CHECK (difficulty IN ('easy', 'medium', 'hard')),
    time_limit_minutes INTEGER,
    passing_score INTEGER DEFAULT 60,
    total_marks INTEGER DEFAULT 100,
    is_ai_generated BOOLEAN DEFAULT false,
    is_published BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Quiz Questions table
CREATE TABLE quiz_questions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    quiz_id UUID NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
    question_text TEXT NOT NULL,
    question_type VARCHAR(50) NOT NULL CHECK (question_type IN ('multiple_choice', 'true_false', 'fill_blank', 'short_answer')),
    options JSONB,
    correct_answer TEXT NOT NULL,
    explanation TEXT,
    marks INTEGER DEFAULT 1,
    order_index INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Quiz Attempts table
CREATE TABLE quiz_attempts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    quiz_id UUID NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    submitted_at TIMESTAMP WITH TIME ZONE,
    total_marks INTEGER NOT NULL,
    obtained_marks INTEGER DEFAULT 0,
    percentage DECIMAL(5,2) DEFAULT 0,
    is_passed BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Quiz Answers table
CREATE TABLE quiz_answers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    attempt_id UUID NOT NULL REFERENCES quiz_attempts(id) ON DELETE CASCADE,
    question_id UUID NOT NULL REFERENCES quiz_questions(id) ON DELETE CASCADE,
    user_answer TEXT,
    is_correct BOOLEAN DEFAULT false,
    marks_obtained INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Examinations table
CREATE TABLE examinations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    education_level VARCHAR(100),
    duration_minutes INTEGER NOT NULL,
    total_marks INTEGER NOT NULL,
    passing_score INTEGER DEFAULT 60,
    is_published BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Examination Questions table (reuse quiz_questions or create separate)
CREATE TABLE examination_questions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    examination_id UUID NOT NULL REFERENCES examinations(id) ON DELETE CASCADE,
    question_text TEXT NOT NULL,
    question_type VARCHAR(50) NOT NULL CHECK (question_type IN ('multiple_choice', 'true_false', 'fill_blank', 'short_answer')),
    options JSONB,
    correct_answer TEXT NOT NULL,
    explanation TEXT,
    marks INTEGER DEFAULT 1,
    order_index INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Examination Attempts table
CREATE TABLE examination_attempts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    examination_id UUID NOT NULL REFERENCES examinations(id) ON DELETE CASCADE,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    submitted_at TIMESTAMP WITH TIME ZONE,
    total_marks INTEGER NOT NULL,
    obtained_marks INTEGER DEFAULT 0,
    percentage DECIMAL(5,2) DEFAULT 0,
    is_passed BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Examination Answers table
CREATE TABLE examination_answers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    attempt_id UUID NOT NULL REFERENCES examination_attempts(id) ON DELETE CASCADE,
    question_id UUID NOT NULL REFERENCES examination_questions(id) ON DELETE CASCADE,
    user_answer TEXT,
    is_correct BOOLEAN DEFAULT false,
    marks_obtained INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Bookmarks table
CREATE TABLE bookmarks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    lesson_id UUID REFERENCES lessons(id) ON DELETE CASCADE,
    question_id UUID REFERENCES quiz_questions(id) ON DELETE CASCADE,
    explanation_id UUID,
    title VARCHAR(200),
    note TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Saved Explanations table
CREATE TABLE saved_explanations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    subject VARCHAR(100),
    lesson_id UUID REFERENCES lessons(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Update learning_progress table to be more detailed
ALTER TABLE learning_progress RENAME COLUMN learning_progress TO overall_progress;
ALTER TABLE learning_progress ADD COLUMN lessons_completed_count INTEGER DEFAULT 0;
ALTER TABLE learning_progress ADD COLUMN quizzes_attempted INTEGER DEFAULT 0;
ALTER TABLE learning_progress ADD COLUMN average_quiz_score DECIMAL(5,2) DEFAULT 0;
ALTER TABLE learning_progress ADD COLUMN total_study_time_minutes INTEGER DEFAULT 0;
ALTER TABLE learning_progress ADD COLUMN last_study_date TIMESTAMP WITH TIME ZONE;

-- Create indexes for better performance
CREATE INDEX idx_chapters_subject_id ON chapters(subject_id);
CREATE INDEX idx_lessons_chapter_id ON lessons(chapter_id);
CREATE INDEX idx_lesson_progress_user_id ON lesson_progress(user_id);
CREATE INDEX idx_lesson_progress_lesson_id ON lesson_progress(lesson_id);
CREATE INDEX idx_quizzes_lesson_id ON quizzes(lesson_id);
CREATE INDEX idx_quizzes_chapter_id ON quizzes(chapter_id);
CREATE INDEX idx_quizzes_subject_id ON quizzes(subject_id);
CREATE INDEX idx_quiz_questions_quiz_id ON quiz_questions(quiz_id);
CREATE INDEX idx_quiz_attempts_user_id ON quiz_attempts(user_id);
CREATE INDEX idx_quiz_attempts_quiz_id ON quiz_attempts(quiz_id);
CREATE INDEX idx_quiz_answers_attempt_id ON quiz_answers(attempt_id);
CREATE INDEX idx_examinations_subject_id ON examinations(subject_id);
CREATE INDEX idx_examination_questions_examination_id ON examination_questions(examination_id);
CREATE INDEX idx_examination_attempts_user_id ON examination_attempts(user_id);
CREATE INDEX idx_examination_attempts_examination_id ON examination_attempts(examination_id);
CREATE INDEX idx_examination_answers_attempt_id ON examination_answers(attempt_id);
CREATE INDEX idx_bookmarks_user_id ON bookmarks(user_id);
CREATE INDEX idx_bookmarks_lesson_id ON bookmarks(lesson_id);
CREATE INDEX idx_saved_explanations_user_id ON saved_explanations(user_id);

-- Enable Row Level Security for new tables
ALTER TABLE subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE chapters ENABLE ROW LEVEL SECURITY;
ALTER TABLE lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE lesson_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE quizzes ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_answers ENABLE ROW LEVEL SECURITY;
ALTER TABLE examinations ENABLE ROW LEVEL SECURITY;
ALTER TABLE examination_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE examination_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE examination_answers ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookmarks ENABLE ROW LEVEL SECURITY;
ALTER TABLE saved_explanations ENABLE ROW LEVEL SECURITY;

-- RLS Policies for subjects (public read, admin write)
CREATE POLICY "Public can view active subjects"
    ON subjects FOR SELECT
    USING (is_active = true);

CREATE POLICY "Authenticated can view all subjects"
    ON subjects FOR SELECT
    USING (auth.role() = 'authenticated');

-- RLS Policies for chapters (public read, admin write)
CREATE POLICY "Public can view active chapters"
    ON chapters FOR SELECT
    USING (is_active = true);

CREATE POLICY "Authenticated can view all chapters"
    ON chapters FOR SELECT
    USING (auth.role() = 'authenticated');

-- RLS Policies for lessons (public read published, admin write)
CREATE POLICY "Public can view published lessons"
    ON lessons FOR SELECT
    USING (is_published = true);

CREATE POLICY "Authenticated can view all lessons"
    ON lessons FOR SELECT
    USING (auth.role() = 'authenticated');

-- RLS Policies for lesson_progress (user-specific)
CREATE POLICY "Users can view own lesson progress"
    ON lesson_progress FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own lesson progress"
    ON lesson_progress FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own lesson progress"
    ON lesson_progress FOR UPDATE
    USING (auth.uid() = user_id);

-- RLS Policies for quizzes (public read published, admin write)
CREATE POLICY "Public can view published quizzes"
    ON quizzes FOR SELECT
    USING (is_published = true);

CREATE POLICY "Authenticated can view all quizzes"
    ON quizzes FOR SELECT
    USING (auth.role() = 'authenticated');

-- RLS Policies for quiz_questions (public read if quiz published, admin write)
CREATE POLICY "Public can view questions for published quizzes"
    ON quiz_questions FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM quizzes
            WHERE quizzes.id = quiz_questions.quiz_id
            AND quizzes.is_published = true
        )
    );

CREATE POLICY "Authenticated can view all quiz questions"
    ON quiz_questions FOR SELECT
    USING (auth.role() = 'authenticated');

-- RLS Policies for quiz_attempts (user-specific)
CREATE POLICY "Users can view own quiz attempts"
    ON quiz_attempts FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own quiz attempts"
    ON quiz_attempts FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- RLS Policies for quiz_answers (user-specific via attempt)
CREATE POLICY "Users can view own quiz answers"
    ON quiz_answers FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM quiz_attempts
            WHERE quiz_attempts.id = quiz_answers.attempt_id
            AND quiz_attempts.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert own quiz answers"
    ON quiz_answers FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM quiz_attempts
            WHERE quiz_attempts.id = quiz_answers.attempt_id
            AND quiz_attempts.user_id = auth.uid()
        )
    );

-- RLS Policies for examinations (public read published, admin write)
CREATE POLICY "Public can view published examinations"
    ON examinations FOR SELECT
    USING (is_published = true);

CREATE POLICY "Authenticated can view all examinations"
    ON examinations FOR SELECT
    USING (auth.role() = 'authenticated');

-- RLS Policies for examination_questions (public read if exam published, admin write)
CREATE POLICY "Public can view questions for published examinations"
    ON examination_questions FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM examinations
            WHERE examinations.id = examination_questions.examination_id
            AND examinations.is_published = true
        )
    );

CREATE POLICY "Authenticated can view all examination questions"
    ON examination_questions FOR SELECT
    USING (auth.role() = 'authenticated');

-- RLS Policies for examination_attempts (user-specific)
CREATE POLICY "Users can view own examination attempts"
    ON examination_attempts FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own examination attempts"
    ON examination_attempts FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- RLS Policies for examination_answers (user-specific via attempt)
CREATE POLICY "Users can view own examination answers"
    ON examination_answers FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM examination_attempts
            WHERE examination_attempts.id = examination_answers.attempt_id
            AND examination_attempts.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert own examination answers"
    ON examination_answers FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM examination_attempts
            WHERE examination_attempts.id = examination_answers.attempt_id
            AND examination_attempts.user_id = auth.uid()
        )
    );

-- RLS Policies for bookmarks (user-specific)
CREATE POLICY "Users can view own bookmarks"
    ON bookmarks FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own bookmarks"
    ON bookmarks FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own bookmarks"
    ON bookmarks FOR DELETE
    USING (auth.uid() = user_id);

-- RLS Policies for saved_explanations (user-specific)
CREATE POLICY "Users can view own saved explanations"
    ON saved_explanations FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own saved explanations"
    ON saved_explanations FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own saved explanations"
    ON saved_explanations FOR DELETE
    USING (auth.uid() = user_id);

-- Triggers to auto-update updated_at for new tables
CREATE TRIGGER update_subjects_updated_at BEFORE UPDATE ON subjects
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_chapters_updated_at BEFORE UPDATE ON chapters
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_lessons_updated_at BEFORE UPDATE ON lessons
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_lesson_progress_updated_at BEFORE UPDATE ON lesson_progress
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_quizzes_updated_at BEFORE UPDATE ON quizzes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_examinations_updated_at BEFORE UPDATE ON examinations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
