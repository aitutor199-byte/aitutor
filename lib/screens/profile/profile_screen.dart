import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/app_config.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../welcome/welcome_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    settingsProvider.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.currentUser == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileCard(authProvider),
                const SizedBox(height: 24),
                _buildLearningSettings(authProvider),
                const SizedBox(height: 24),
                _buildVoiceSettings(),
                const SizedBox(height: 24),
                _buildAccountActions(authProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileCard(AuthProvider authProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: AppTheme.primaryGreen,
              child: Text(
                authProvider.currentUser!.displayName[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              authProvider.currentUser!.displayName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              authProvider.currentUser!.email ?? '',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildInfoChip(
                  icon: Icons.school,
                  label: authProvider.currentUser!.educationLevel,
                ),
                const SizedBox(width: 12),
                _buildInfoChip(
                  icon: Icons.translate,
                  label: authProvider.currentUser!.preferredLanguage,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      backgroundColor: AppTheme.lightGreen,
    );
  }

  Widget _buildLearningSettings(AuthProvider authProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Learning Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Education Level'),
              subtitle: Text(authProvider.currentUser!.educationLevel),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showEducationLevelDialog(authProvider),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.translate),
              title: const Text('Preferred Language'),
              subtitle: Text(authProvider.currentUser!.preferredLanguage),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showLanguageDialog(authProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceSettings() {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Voice Settings',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Voice Output'),
                  subtitle: const Text('Read AI responses aloud'),
                  value: settingsProvider.voiceEnabled,
                  onChanged: (value) {
                    settingsProvider.setVoiceEnabled(value);
                  },
                ),
                SwitchListTile(
                  title: const Text('Speech Recognition'),
                  subtitle: const Text('Use voice to ask questions'),
                  value: settingsProvider.speechEnabled,
                  onChanged: (value) {
                    settingsProvider.setSpeechEnabled(value);
                  },
                ),
                if (settingsProvider.voiceEnabled) ...[
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.speed),
                    title: const Text('Speech Rate'),
                    subtitle: Text('${settingsProvider.speechRate}x'),
                    trailing: Slider(
                      value: settingsProvider.speechRate,
                      min: 0.5,
                      max: 2.0,
                      divisions: 3,
                      onChanged: (value) {
                        settingsProvider.setSpeechRate(value);
                      },
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.music_note),
                    title: const Text('Speech Pitch'),
                    subtitle: Text('${settingsProvider.speechPitch}x'),
                    trailing: Slider(
                      value: settingsProvider.speechPitch,
                      min: 0.5,
                      max: 2.0,
                      divisions: 3,
                      onChanged: (value) {
                        settingsProvider.setSpeechPitch(value);
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAccountActions(AuthProvider authProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () async {
                await authProvider.signOut();
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WelcomeScreen(),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEducationLevelDialog(AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Education Level'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: Appconfig.educationLevels.length,
            itemBuilder: (context, index) {
              final level = Appconfig.educationLevels[index];
              return ListTile(
                title: Text(level),
                trailing: authProvider.currentUser!.educationLevel == level
                    ? const Icon(Icons.check, color: AppTheme.primaryGreen)
                    : null,
                onTap: () async {
                  await authProvider.updateProfile(
                    educationLevel: level,
                  );
                  if (mounted) {
                    Navigator.pop(context);
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: Appconfig.supportedLanguages.length,
            itemBuilder: (context, index) {
              final language = Appconfig.supportedLanguages[index];
              return ListTile(
                title: Text(language),
                trailing: authProvider.currentUser!.preferredLanguage == language
                    ? const Icon(Icons.check, color: AppTheme.primaryGreen)
                    : null,
                onTap: () async {
                  await authProvider.updateProfile(
                    preferredLanguage: language,
                  );
                  if (mounted) {
                    Navigator.pop(context);
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
