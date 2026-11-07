import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/subscription_plan.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  List<SubscriptionPlan> _plans = [];
  String _currentPlan = 'Free';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  void _loadPlans() {
    // Load plans from Supabase
    setState(() {
      _isLoading = false;
      _plans = [
        SubscriptionPlan(
          id: '1',
          name: 'Free',
          description: 'Basic access to AI Tutor features',
          priceMonthly: 0,
          priceYearly: 0,
          currency: 'USD',
          features: {
            '10 AI questions/day': true,
            'Basic tutoring': true,
            'Limited quizzes': true,
            'Basic study plans': true,
          },
          aiDailyLimit: 10,
          aiMonthlyLimit: 300,
          imageLimit: 5,
          voiceLimit: 10,
          materialsLimit: 10,
          isActive: true,
        ),
        SubscriptionPlan(
          id: '2',
          name: 'Premium',
          description: 'Full access to all AI features',
          priceMonthly: 9.99,
          priceYearly: 99.99,
          currency: 'USD',
          features: {
            'Unlimited AI questions': true,
            'Advanced tutoring': true,
            'Image solving': true,
            'Voice tutor': true,
            'Advanced quizzes': true,
            'Personalized study plans': true,
            'AI notes': true,
            'Flashcards': true,
            'Detailed analytics': true,
            'Ad-free': true,
          },
          aiDailyLimit: 1000,
          aiMonthlyLimit: 30000,
          imageLimit: 100,
          voiceLimit: 500,
          materialsLimit: 100,
          isActive: true,
        ),
        SubscriptionPlan(
          id: '3',
          name: 'Professional',
          description: 'For serious learners and professionals',
          priceMonthly: 19.99,
          priceYearly: 199.99,
          currency: 'USD',
          features: {
            'All Premium features': true,
            'Higher AI limits': true,
            'Priority processing': true,
            'Advanced analytics': true,
            'More storage': true,
            'Premium recommendations': true,
          },
          aiDailyLimit: 5000,
          aiMonthlyLimit: 150000,
          imageLimit: 500,
          voiceLimit: 2000,
          materialsLimit: 500,
          isActive: true,
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Plans'),
        backgroundColor: AppTheme.primaryGreen,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCurrentPlanCard(),
                  const SizedBox(height: 24),
                  const Text(
                    'Choose Your Plan',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ..._plans.map((plan) => _buildPlanCard(plan)),
                ],
              ),
            ),
    );
  }

  Widget _buildCurrentPlanCard() {
    return Card(
      color: AppTheme.lightGreen,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(Icons.workspace_premium, size: 48, color: AppTheme.primaryGreen),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Current Plan', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(_currentPlan, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const Text('Renews on December 7, 2026'),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Manage'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan) {
    final isCurrent = plan.name == _currentPlan;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isCurrent ? 4 : 1,
      borderOnForeground: isCurrent,
      child: Container(
        decoration: BoxDecoration(
          border: isCurrent ? Border.all(color: AppTheme.primaryGreen, width: 2) : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    plan.name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  if (isCurrent)
                    const Chip(
                      label: Text('Current'),
                      backgroundColor: AppTheme.primaryGreen,
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(plan.description ?? ''),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (plan.priceMonthly != null)
                    Text(
                      '\$${plan.priceMonthly}/month',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  if (plan.priceYearly != null) ...[
                    const SizedBox(width: 16),
                    Text(
                      '\$${plan.priceYearly}/year',
                      style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              if (plan.features != null)
                ...plan.features!.keys.map((feature) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: AppTheme.primaryGreen, size: 20),
                        const SizedBox(width: 8),
                        Text(feature),
                      ],
                    ),
                  );
                }),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isCurrent ? null : () => _subscribeToPlan(plan),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCurrent ? Colors.grey : AppTheme.primaryGreen,
                  ),
                  child: Text(isCurrent ? 'Current Plan' : 'Subscribe'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _subscribeToPlan(SubscriptionPlan plan) {
    // Navigate to payment processing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Proceeding to payment for ${plan.name}...')),
    );
  }
}
