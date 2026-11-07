-- Phase 2: Admin Content Management Foundation
-- This migration adds tables for admin role and content management

-- Add is_admin column to users table
ALTER TABLE users ADD COLUMN is_admin BOOLEAN DEFAULT false;

-- Admin Audit Log table
CREATE TABLE admin_audit_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    admin_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    action VARCHAR(50) NOT NULL,
    table_name VARCHAR(100) NOT NULL,
    record_id UUID,
    old_data JSONB,
    new_data JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Content Approval table
CREATE TABLE content_approval (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    content_type VARCHAR(50) NOT NULL,
    content_id UUID NOT NULL,
    submitted_by UUID REFERENCES users(id) ON DELETE SET NULL,
    approved_by UUID REFERENCES users(id) ON DELETE SET NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('pending', 'approved', 'rejected')),
    rejection_reason TEXT,
    submitted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    reviewed_at TIMESTAMP WITH TIME ZONE
);

-- Create indexes
CREATE INDEX idx_admin_audit_log_admin_id ON admin_audit_log(admin_id);
CREATE INDEX idx_admin_audit_log_created_at ON admin_audit_log(created_at DESC);
CREATE INDEX idx_content_approval_content ON content_approval(content_type, content_id);
CREATE INDEX idx_content_approval_status ON content_approval(status);

-- Enable RLS
ALTER TABLE admin_audit_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE content_approval ENABLE ROW LEVEL SECURITY;

-- RLS Policies for admin_audit_log
CREATE POLICY "Admins can view audit logs"
    ON admin_audit_log FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE users.id = admin_audit_log.admin_id
            AND users.is_admin = true
        )
    );

CREATE POLICY "Admins can insert audit logs"
    ON admin_audit_log FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM users
            WHERE users.id = admin_audit_log.admin_id
            AND users.is_admin = true
        )
    );

-- RLS Policies for content_approval
CREATE POLICY "Admins can view all approvals"
    ON content_approval FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE users.id = auth.uid()
            AND users.is_admin = true
        )
    );

CREATE POLICY "Users can view own submissions"
    ON content_approval FOR SELECT
    USING (submitted_by = auth.uid());

CREATE POLICY "Admins can update approvals"
    ON content_approval FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE users.id = auth.uid()
            AND users.is_admin = true
        )
    );

-- RLS Policy for users table to allow viewing is_admin
CREATE POLICY "Users can view own is_admin status"
    ON users FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Admins can view all users"
    ON users FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE users.id = auth.uid()
            AND users.is_admin = true
        )
    );
