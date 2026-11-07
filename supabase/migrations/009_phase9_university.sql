-- Phase 9: Digital University & Intelligent Education
-- Universities, courses, LMS, AI professors, research, certificates

-- University Institutions table
CREATE TABLE university_institutions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    logo_url TEXT,
    website_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Academic Departments table
CREATE TABLE academic_departments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    institution_id UUID REFERENCES university_institutions(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    head_id UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Academic Programs table
CREATE TABLE academic_programs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    institution_id UUID REFERENCES university_institutions(id) ON DELETE CASCADE,
    department_id UUID REFERENCES academic_departments(id) ON DELETE SET NULL,
    name VARCHAR(255) NOT NULL,
    program_type VARCHAR(50),
    duration_years INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- University Courses table
CREATE TABLE university_courses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    institution_id UUID REFERENCES university_institutions(id) ON DELETE CASCADE,
    department_id UUID REFERENCES academic_departments(id) ON DELETE SET NULL,
    teacher_id UUID REFERENCES users(id),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    subject VARCHAR(100),
    education_level VARCHAR(50),
    duration_weeks INTEGER,
    is_published BOOLEAN DEFAULT false,
    is_free BOOLEAN DEFAULT true,
    price DECIMAL(10,2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Course Modules table
CREATE TABLE course_modules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    course_id UUID NOT NULL REFERENCES university_courses(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    order_index INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Course Lessons table
CREATE TABLE course_lessons (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    module_id UUID NOT NULL REFERENCES course_modules(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    content TEXT,
    video_url TEXT,
    reading_materials TEXT,
    order_index INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Course Enrollments table
CREATE TABLE course_enrollments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    course_id UUID NOT NULL REFERENCES university_courses(id) ON DELETE CASCADE,
    enrolled_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    progress_percentage INTEGER DEFAULT 0,
    UNIQUE(user_id, course_id)
);

-- Course Progress table
CREATE TABLE course_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    enrollment_id UUID NOT NULL REFERENCES course_enrollments(id) ON DELETE CASCADE,
    lesson_id UUID NOT NULL REFERENCES course_lessons(id) ON DELETE CASCADE,
    is_completed BOOLEAN DEFAULT false,
    completed_at TIMESTAMP WITH TIME ZONE,
    UNIQUE(enrollment_id, lesson_id)
);

-- Digital Certificates table
CREATE TABLE digital_certificates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    course_id UUID REFERENCES university_courses(id) ON DELETE SET NULL,
    certificate_type VARCHAR(50),
    certificate_number VARCHAR(100) UNIQUE NOT NULL,
    issue_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    verification_code VARCHAR(100) UNIQUE NOT NULL,
    is_revoked BOOLEAN DEFAULT false,
    revoked_at TIMESTAMP WITH TIME ZONE,
    revoked_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Research Projects table
CREATE TABLE research_projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(50) DEFAULT 'planning',
    subject VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_university_courses_institution ON university_courses(institution_id);
CREATE INDEX idx_university_courses_teacher ON university_courses(teacher_id);
CREATE INDEX idx_course_enrollments_user ON course_enrollments(user_id);
CREATE INDEX idx_course_enrollments_course ON course_enrollments(course_id);
CREATE INDEX idx_digital_certificates_user ON digital_certificates(user_id);
CREATE INDEX idx_digital_certificates_number ON digital_certificates(certificate_number);
CREATE INDEX idx_research_projects_user ON research_projects(user_id);

-- RLS policies omitted for brevity - should follow same pattern as previous migrations
