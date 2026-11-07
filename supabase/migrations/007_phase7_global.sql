-- Phase 7: Advanced AI Intelligence, Global Education & Scalability
-- Classrooms, documents, career guidance, collaboration, curriculum, language learning

-- Virtual Classrooms table
CREATE TABLE classrooms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    teacher_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    invitation_code VARCHAR(20) UNIQUE NOT NULL,
    curriculum VARCHAR(100),
    grade_level VARCHAR(50),
    subject VARCHAR(100),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Classroom Members table
CREATE TABLE classroom_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    classroom_id UUID NOT NULL REFERENCES classrooms(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(20) DEFAULT 'student',
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(classroom_id, user_id)
);

-- Classroom Messages table
CREATE TABLE classroom_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    classroom_id UUID NOT NULL REFERENCES classrooms(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    message TEXT NOT NULL,
    message_type VARCHAR(20) DEFAULT 'text',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Classroom Activities table
CREATE TABLE classroom_activities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    classroom_id UUID NOT NULL REFERENCES classrooms(id) ON DELETE CASCADE,
    activity_type VARCHAR(50),
    title VARCHAR(255),
    description TEXT,
    scheduled_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Uploaded Documents table
CREATE TABLE uploaded_documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    file_url TEXT NOT NULL,
    file_type VARCHAR(50),
    file_size INTEGER,
    subject VARCHAR(100),
    topic VARCHAR(100),
    summary TEXT,
    extracted_text TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Document Questions table
CREATE TABLE document_questions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_id UUID NOT NULL REFERENCES uploaded_documents(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    question TEXT NOT NULL,
    answer TEXT,
    page_reference INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Study Groups table
CREATE TABLE study_groups (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    creator_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    invitation_code VARCHAR(20) UNIQUE NOT NULL,
    max_members INTEGER DEFAULT 10,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Study Group Members table
CREATE TABLE study_group_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    group_id UUID NOT NULL REFERENCES study_groups(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(20) DEFAULT 'member',
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(group_id, user_id)
);

-- Group Discussions table
CREATE TABLE group_discussions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    group_id UUID NOT NULL REFERENCES study_groups(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    topic VARCHAR(255),
    message TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User Curriculum table
CREATE TABLE user_curriculum (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    country VARCHAR(100),
    education_system VARCHAR(100),
    grade_level VARCHAR(50),
    curriculum_code VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id)
);

-- Career Guidance table
CREATE TABLE career_guidance (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    interests TEXT[],
    skills TEXT[],
    career_goals TEXT[],
    recommended_careers JSONB,
    recommended_subjects TEXT[],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Language Learning Progress table
CREATE TABLE language_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    language VARCHAR(20) NOT NULL,
    proficiency_level VARCHAR(20),
    vocabulary_learned INTEGER DEFAULT 0,
    lessons_completed INTEGER DEFAULT 0,
    practice_score INTEGER DEFAULT 0,
    last_practiced_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, language)
);

-- AI Learning Context table
CREATE TABLE ai_learning_context (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    context_type VARCHAR(50),
    context_data JSONB,
    last_updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Content Generation Studio table
CREATE TABLE generated_content (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content_type VARCHAR(50),
    title VARCHAR(255),
    content TEXT,
    parameters JSONB,
    is_approved BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_classrooms_teacher_id ON classrooms(teacher_id);
CREATE INDEX idx_classrooms_invitation_code ON classrooms(invitation_code);
CREATE INDEX idx_classroom_members_classroom_id ON classroom_members(classroom_id);
CREATE INDEX idx_classroom_members_user_id ON classroom_members(user_id);
CREATE INDEX idx_classroom_messages_classroom_id ON classroom_messages(classroom_id);
CREATE INDEX idx_uploaded_documents_user_id ON uploaded_documents(user_id);
CREATE INDEX idx_uploaded_documents_subject ON uploaded_documents(subject);
CREATE INDEX idx_document_questions_document_id ON document_questions(document_id);
CREATE INDEX idx_study_groups_creator_id ON study_groups(creator_id);
CREATE INDEX idx_study_group_members_group_id ON study_group_members(group_id);
CREATE INDEX idx_study_group_members_user_id ON study_group_members(user_id);
CREATE INDEX idx_group_discussions_group_id ON group_discussions(group_id);
CREATE INDEX idx_user_curriculum_user_id ON user_curriculum(user_id);
CREATE INDEX idx_career_guidance_user_id ON career_guidance(user_id);
CREATE INDEX idx_language_progress_user_id ON language_progress(user_id);
CREATE INDEX idx_ai_learning_context_user_id ON ai_learning_context(user_id);
CREATE INDEX idx_generated_content_user_id ON generated_content(user_id);

-- RLS
ALTER TABLE classrooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE classroom_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE classroom_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE classroom_activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE uploaded_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE document_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE study_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE study_group_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE group_discussions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_curriculum ENABLE ROW LEVEL SECURITY;
ALTER TABLE career_guidance ENABLE ROW LEVEL SECURITY;
ALTER TABLE language_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_learning_context ENABLE ROW LEVEL SECURITY;
ALTER TABLE generated_content ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view own classrooms as teacher"
    ON classrooms FOR SELECT USING (auth.uid() = teacher_id);
CREATE POLICY "Users can view classrooms they are member of"
    ON classrooms FOR SELECT USING (
    EXISTS (SELECT 1 FROM classroom_members WHERE classroom_members.classroom_id = classrooms.id AND classroom_members.user_id = auth.uid())
    );
CREATE POLICY "Teachers can create classrooms"
    ON classrooms FOR INSERT WITH CHECK (auth.uid() = teacher_id);
CREATE POLICY "Teachers can update own classrooms"
    ON classrooms FOR UPDATE USING (auth.uid() = teacher_id);

CREATE POLICY "Users can view own classroom membership"
    ON classroom_members FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own classroom membership"
    ON classroom_members FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view messages in own classrooms"
    ON classroom_messages FOR SELECT USING (
    EXISTS (SELECT 1 FROM classroom_members WHERE classroom_members.classroom_id = classroom_messages.classroom_id AND classroom_members.user_id = auth.uid())
    );
CREATE POLICY "Users can insert messages in own classrooms"
    ON classroom_messages FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM classroom_members WHERE classroom_members.classroom_id = classroom_messages.classroom_id AND classroom_members.user_id = auth.uid())
    );

CREATE POLICY "Users can view own documents"
    ON uploaded_documents FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own documents"
    ON uploaded_documents FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own documents"
    ON uploaded_documents FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own documents"
    ON uploaded_documents FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own document questions"
    ON document_questions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own document questions"
    ON document_questions FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own study groups"
    ON study_groups FOR SELECT USING (auth.uid() = creator_id OR EXISTS (SELECT 1 FROM study_group_members WHERE study_group_members.group_id = study_groups.id AND study_group_members.user_id = auth.uid()));
CREATE POLICY "Users can create study groups"
    ON study_groups FOR INSERT WITH CHECK (auth.uid() = creator_id);
CREATE POLICY "Users can update own study groups"
    ON study_groups FOR UPDATE USING (auth.uid() = creator_id);

CREATE POLICY "Users can view own study group membership"
    ON study_group_members FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own study group membership"
    ON study_group_members FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view discussions in own groups"
    ON group_discussions FOR SELECT USING (
    EXISTS (SELECT 1 FROM study_group_members WHERE study_group_members.group_id = group_discussions.group_id AND study_group_members.user_id = auth.uid())
    );
CREATE POLICY "Users can insert discussions in own groups"
    ON group_discussions FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM study_group_members WHERE study_group_members.group_id = group_discussions.group_id AND study_group_members.user_id = auth.uid())
    );

CREATE POLICY "Users can view own curriculum"
    ON user_curriculum FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own curriculum"
    ON user_curriculum FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own curriculum"
    ON user_curriculum FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own career guidance"
    ON career_guidance FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own career guidance"
    ON career_guidance FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own career guidance"
    ON career_guidance FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own language progress"
    ON language_progress FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own language progress"
    ON language_progress FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own language progress"
    ON language_progress FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own AI learning context"
    ON ai_learning_context FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own AI learning context"
    ON ai_learning_context FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own AI learning context"
    ON ai_learning_context FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own generated content"
    ON generated_content FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own generated content"
    ON generated_content FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own generated content"
    ON generated_content FOR UPDATE USING (auth.uid() = user_id);

-- Triggers
CREATE TRIGGER update_user_curriculum_updated_at BEFORE UPDATE ON user_curriculum
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_career_guidance_updated_at BEFORE UPDATE ON career_guidance
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_language_progress_updated_at BEFORE UPDATE ON language_progress
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
