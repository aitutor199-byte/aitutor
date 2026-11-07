# Setup Guide for AI Tutor

## Important: Do NOT commit credentials

The `.env` file is in `.gitignore` for security. Never commit API keys or secrets to GitHub.

## Step 1: Create .env file

Create a file named `.env` in the project root (same folder as pubspec.yaml) with the following content:

```env
# Supabase Configuration
SUPABASE_URL=your_actual_supabase_url_here
SUPABASE_ANON_KEY=your_actual_supabase_anon_key_here

# Gemini API Configuration
# This is ONLY for Supabase Edge Functions setup
GEMINI_API_KEY=your_actual_gemini_api_key_here
```

## Step 2: Get Supabase Credentials

1. Go to [supabase.com](https://supabase.com) and sign in
2. Create a new project or select existing one
3. Go to Settings > API
4. Copy:
   - Project URL (e.g., https://xyz.supabase.co)
   - anon public key (starts with `eyJhbGci...`)
5. Paste these into your `.env` file

## Step 3: Set up Database

1. In Supabase, go to SQL Editor
2. Copy the content from `supabase/migrations/001_initial_schema.sql`
3. Paste and run the SQL
4. This will create all tables and security policies

## Step 4: Get Gemini API Key

1. Go to [makersuite.google.com/app/apikey](https://makersuite.google.com/app/apikey)
2. Create a new API key
3. Copy the key
4. Save it - you'll need it for the Edge Function setup

## Step 5: Deploy Supabase Edge Function

The Edge Function handles AI requests securely without exposing your Gemini key in the Flutter app.

### Option A: Using Supabase CLI (Recommended)

1. Install Supabase CLI:
   ```bash
   npm install -g supabase
   ```

2. Link to your project:
   ```bash
   supabase link --project-ref your-project-id
   ```

3. Deploy the function:
   ```bash
   supabase functions deploy ai-tutor
   ```

4. Add the environment variable:
   ```bash
   supabase secrets set GEMINI_API_KEY=your_actual_gemini_key
   ```

### Option B: Using Supabase Dashboard

1. Go to Edge Functions in Supabase dashboard
2. Click "New Function"
3. Name it: `ai-tutor`
4. Copy the code from `supabase/functions/ai-tutor/index.ts`
5. Paste it into the function editor
6. Click "Deploy"
7. Go to function settings
8. Add environment variable:
   - Name: `GEMINI_API_KEY`
   - Value: your actual Gemini API key

## Step 6: Install Flutter Dependencies

```bash
flutter pub get
```

## Step 7: Run the App

For Web:
```bash
flutter run -d chrome
```

For Android:
```bash
flutter run -d android
```

For Windows:
```bash
flutter run -d windows
```

## Testing Checklist

- [ ] App launches without errors
- [ ] Welcome screen displays correctly
- [ ] Can navigate to login/register
- [ ] Can create account
- [ ] Can sign in
- [ ] Onboarding completes
- [ ] Dashboard shows user profile
- [ ] Can start a new chat
- [ ] Can send messages
- [ ] AI responds (requires Edge Function setup)
- [ ] Voice features work (if supported on platform)

## Troubleshooting

### "Supabase initialization failed"
- Check your `.env` file exists
- Verify SUPABASE_URL and SUPABASE_ANON_KEY are correct
- Restart the app after changing `.env`

### "AI response failed"
- Verify Edge Function is deployed
- Check GEMINI_API_KEY is set in Supabase Edge Functions
- Check Supabase logs for errors

### Voice features not working
- Check app permissions (microphone)
- Voice support varies by platform and language
- English works best on all platforms
- Urdu/Pashto may have limited TTS support

## Security Notes

- Never commit `.env` file
- Never share API keys in chat or code
- Rotate keys if accidentally exposed
- Use anon key (not service role key) in Flutter app
- Service role key bypasses RLS - never use in client apps
