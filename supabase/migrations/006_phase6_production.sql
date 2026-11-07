-- Phase 6: Production Deployment & Commercial Features
-- Subscriptions, payments, referrals, support, usage tracking

-- Subscription Plans table
CREATE TABLE subscription_plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price_monthly DECIMAL(10,2),
    price_yearly DECIMAL(10,2),
    currency VARCHAR(3) DEFAULT 'USD',
    features JSONB,
    ai_daily_limit INTEGER,
    ai_monthly_limit INTEGER,
    image_limit INTEGER,
    voice_limit INTEGER,
    materials_limit INTEGER,
    is_active BOOLEAN DEFAULT true,
    stripe_price_id_monthly VARCHAR(255),
    stripe_price_id_yearly VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User Subscriptions table
CREATE TABLE user_subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    plan_id UUID NOT NULL REFERENCES subscription_plans(id),
    status VARCHAR(50) DEFAULT 'active',
    start_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    end_date TIMESTAMP WITH TIME ZONE,
    cancelled_at TIMESTAMP WITH TIME ZONE,
    auto_renew BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Payments table
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    subscription_id UUID REFERENCES user_subscriptions(id) ON DELETE SET NULL,
    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    status VARCHAR(50) DEFAULT 'pending',
    payment_method VARCHAR(50),
    transaction_id VARCHAR(255),
    payment_gateway VARCHAR(50),
    receipt_url TEXT,
    refunded_at TIMESTAMP WITH TIME ZONE,
    refund_amount DECIMAL(10,2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- AI Usage Tracking table
CREATE TABLE ai_usage (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    usage_type VARCHAR(50),
    tokens_used INTEGER DEFAULT 0,
    requests_count INTEGER DEFAULT 0,
    date DATE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, date, usage_type)
);

-- Referrals table
CREATE TABLE referrals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    referrer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    referral_code VARCHAR(50) UNIQUE NOT NULL,
    total_referrals INTEGER DEFAULT 0,
    successful_referrals INTEGER DEFAULT 0,
    total_rewards DECIMAL(10,2) DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Referral Relationships table
CREATE TABLE referral_relationships (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    referrer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    referred_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    referral_code VARCHAR(50) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    reward_claimed BOOLEAN DEFAULT false,
    reward_amount DECIMAL(10,2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(referred_id)
);

-- Support Tickets table
CREATE TABLE support_tickets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    subject VARCHAR(255) NOT NULL,
    category VARCHAR(100),
    description TEXT,
    status VARCHAR(50) DEFAULT 'open',
    priority VARCHAR(20) DEFAULT 'normal',
    assigned_to UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Support Messages table
CREATE TABLE support_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ticket_id UUID NOT NULL REFERENCES support_tickets(id) ON DELETE CASCADE,
    sender_id UUID REFERENCES users(id) ON DELETE SET NULL,
    is_admin BOOLEAN DEFAULT false,
    message TEXT NOT NULL,
    attachment_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- App Settings table
CREATE TABLE app_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    theme VARCHAR(20) DEFAULT 'light',
    language VARCHAR(10) DEFAULT 'en',
    notification_study_reminders BOOLEAN DEFAULT true,
    notification_quiz_notifications BOOLEAN DEFAULT true,
    notification_achievement_notifications BOOLEAN DEFAULT true,
    notification_announcement_notifications BOOLEAN DEFAULT true,
    privacy_leaderboard_visible BOOLEAN DEFAULT true,
    data_download_requested BOOLEAN DEFAULT false,
    account_deletion_requested BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id)
);

-- Indexes
CREATE INDEX idx_user_subscriptions_user_id ON user_subscriptions(user_id);
CREATE INDEX idx_user_subscriptions_status ON user_subscriptions(status);
CREATE INDEX idx_payments_user_id ON payments(user_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_ai_usage_user_id ON ai_usage(user_id);
CREATE INDEX idx_ai_usage_date ON ai_usage(date);
CREATE INDEX idx_referrals_referrer_id ON referrals(referrer_id);
CREATE INDEX idx_referral_relationships_referrer_id ON referral_relationships(referrer_id);
CREATE INDEX idx_referral_relationships_referred_id ON referral_relationships(referred_id);
CREATE INDEX idx_support_tickets_user_id ON support_tickets(user_id);
CREATE INDEX idx_support_tickets_status ON support_tickets(status);
CREATE INDEX idx_support_messages_ticket_id ON support_messages(ticket_id);
CREATE INDEX idx_app_settings_user_id ON app_settings(user_id);

-- RLS
ALTER TABLE subscription_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_usage ENABLE ROW LEVEL SECURITY;
ALTER TABLE referrals ENABLE ROW LEVEL SECURITY;
ALTER TABLE referral_relationships ENABLE ROW LEVEL SECURITY;
ALTER TABLE support_tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE support_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE app_settings ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "All users can view active plans"
    ON subscription_plans FOR SELECT USING (is_active = true);

CREATE POLICY "Users can view own subscriptions"
    ON user_subscriptions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own subscriptions"
    ON user_subscriptions FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own subscriptions"
    ON user_subscriptions FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own payments"
    ON payments FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own payments"
    ON payments FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own AI usage"
    ON ai_usage FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own AI usage"
    ON ai_usage FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own AI usage"
    ON ai_usage FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own referrals"
    ON referrals FOR SELECT USING (auth.uid() = referrer_id);
CREATE POLICY "Users can insert own referrals"
    ON referrals FOR INSERT WITH CHECK (auth.uid() = referrer_id);
CREATE POLICY "Users can update own referrals"
    ON referrals FOR UPDATE USING (auth.uid() = referrer_id);

CREATE POLICY "Users can view own referral relationships"
    ON referral_relationships FOR SELECT USING (auth.uid() = referrer_id OR auth.uid() = referred_id);
CREATE POLICY "Users can insert own referral relationships"
    ON referral_relationships FOR INSERT WITH CHECK (auth.uid() = referrer_id);

CREATE POLICY "Users can view own support tickets"
    ON support_tickets FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own support tickets"
    ON support_tickets FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own support tickets"
    ON support_tickets FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can view messages for own tickets"
    ON support_messages FOR SELECT USING (
    EXISTS (SELECT 1 FROM support_tickets WHERE support_tickets.id = support_messages.ticket_id AND support_tickets.user_id = auth.uid())
    );
CREATE POLICY "Users can insert messages for own tickets"
    ON support_messages FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM support_tickets WHERE support_tickets.id = support_messages.ticket_id AND support_tickets.user_id = auth.uid())
    );

CREATE POLICY "Users can view own app settings"
    ON app_settings FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own app settings"
    ON app_settings FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own app settings"
    ON app_settings FOR UPDATE USING (auth.uid() = user_id);

-- Triggers
CREATE TRIGGER update_user_subscriptions_updated_at BEFORE UPDATE ON user_subscriptions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_support_tickets_updated_at BEFORE UPDATE ON support_tickets
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_app_settings_updated_at BEFORE UPDATE ON app_settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert default subscription plans
INSERT INTO subscription_plans (name, description, price_monthly, price_yearly, features, ai_daily_limit, ai_monthly_limit, image_limit, voice_limit, materials_limit) VALUES
('Free', 'Basic access to AI Tutor features', 0, 0, '["10 AI questions/day", "Basic tutoring", "Limited quizzes", "Basic study plans"]'::jsonb, 10, 300, 5, 10, 10),
('Premium', 'Full access to all AI features', 9.99, 99.99, '["Unlimited AI questions", "Advanced tutoring", "Image solving", "Voice tutor", "Advanced quizzes", "Personalized study plans", "AI notes", "Flashcards", "Detailed analytics", "Ad-free"]'::jsonb, 1000, 30000, 100, 500, 100),
('Professional', 'For serious learners and professionals', 19.99, 199.99, '["All Premium features", "Higher AI limits", "Priority processing", "Advanced analytics", "More storage", "Premium recommendations"]'::jsonb, 5000, 150000, 500, 2000, 500);
