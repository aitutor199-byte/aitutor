import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/app_config.dart';
import '../../widgets/subject_card.dart';
import 'auth/login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeroSection(context),
              _buildSearchSection(context),
              _buildSubjectSection(context),
              _buildHowItWorksSection(context),
              _buildFeaturesSection(context),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.heroGradient,
      ),
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            return Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.displayLarge,
                          children: const [
                            TextSpan(text: 'Learn '),
                            TextSpan(
                              text: 'Anything',
                              style: TextStyle(color: AppTheme.yellow),
                            ),
                            TextSpan(text: '. '),
                            TextSpan(
                              text: 'Understand',
                              style: TextStyle(color: AppTheme.orange),
                            ),
                            TextSpan(text: ' Everything.'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Your personal AI teacher, available anytime. Learn smarter, ask questions, and understand every concept in your preferred language.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            child: const Text('Get Started'),
                          ),
                          const SizedBox(width: 16),
                          OutlinedButton(
                            onPressed: () {
                              // Navigate to explore subjects
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white),
                            ),
                            child: const Text('Explore Subjects'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 48),
                Expanded(
                  child: _buildHeroIllustration(),
                ),
              ],
            );
          } else {
            return Column(
              children: [
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.displayMedium,
                    children: const [
                      TextSpan(text: 'Learn '),
                      TextSpan(
                        text: 'Anything',
                        style: TextStyle(color: AppTheme.yellow),
                      ),
                      TextSpan(text: '. '),
                      TextSpan(
                        text: 'Understand',
                        style: TextStyle(color: AppTheme.orange),
                      ),
                      TextSpan(text: ' Everything.'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Your personal AI teacher, available anytime.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                      ),
                  ),
                const SizedBox(height: 24),
                _buildHeroIllustration(),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text('Get Started'),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildHeroIllustration() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Icon(
          Icons.school,
          size: 120,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSearchSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Ask your AI Tutor anything...',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Type your question here...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: ElevatedButton(
                    onPressed: () {
                      // Navigate to chat
                    },
                    child: const Text('Ask AI Tutor'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explore Subjects',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: Appconfig.subjects.length,
            itemBuilder: (context, index) {
              return SubjectCard(
                subject: Appconfig.subjects[index],
                onTap: () {
                  // Navigate to subject learning
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: AppTheme.lightBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How It Works',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildStep(
                  context,
                  icon: Icons.person,
                  title: 'Create Account',
                  description: 'Sign up for free',
                ),
              ),
              Expanded(
                child: _buildStep(
                  context,
                  icon: Icons.settings,
                  title: 'Set Preferences',
                  description: 'Choose your level and language',
                ),
              ),
              Expanded(
                child: _buildStep(
                  context,
                  icon: Icons.chat,
                  title: 'Start Learning',
                  description: 'Ask questions and learn',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 48, color: AppTheme.primaryGreen),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Features',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildFeatureChip(
                context,
                icon: Icons.translate,
                label: 'Multilingual',
              ),
              _buildFeatureChip(
                context,
                icon: Icons.mic,
                label: 'Voice Support',
              ),
              _buildFeatureChip(
                context,
                icon: Icons.psychology,
                label: 'AI-Powered',
              ),
              _buildFeatureChip(
                context,
                icon: Icons.auto_stories,
                label: 'Personalized',
              ),
              _buildFeatureChip(
                context,
                icon: Icons.security,
                label: 'Secure',
              ),
              _buildFeatureChip(
                context,
                icon: Icons.phone_android,
                label: 'Cross-Platform',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    return Chip(
      avatar: Icon(icon, color: AppTheme.primaryGreen),
      label: Text(label),
      backgroundColor: AppTheme.lightGreen,
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: AppTheme.mainText,
      child: Column(
        children: [
          Text(
            'AI Tutor',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Learn Anything. Understand Everything.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {},
                child: const Text('Privacy Policy', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: () {},
                child: const Text('Terms of Service', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
