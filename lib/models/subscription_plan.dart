class SubscriptionPlan {
  final String id;
  final String name;
  final String? description;
  final double? priceMonthly;
  final double? priceYearly;
  final String currency;
  final Map<String, dynamic>? features;
  final int? aiDailyLimit;
  final int? aiMonthlyLimit;
  final int? imageLimit;
  final int? voiceLimit;
  final int? materialsLimit;
  final bool isActive;

  SubscriptionPlan({
    required this.id,
    required this.name,
    this.description,
    this.priceMonthly,
    this.priceYearly,
    required this.currency,
    this.features,
    this.aiDailyLimit,
    this.aiMonthlyLimit,
    this.imageLimit,
    this.voiceLimit,
    this.materialsLimit,
    required this.isActive,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      priceMonthly: (json['price_monthly'] as num?)?.toDouble(),
      priceYearly: (json['price_yearly'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      features: json['features'] as Map<String, dynamic>?,
      aiDailyLimit: json['ai_daily_limit'] as int?,
      aiMonthlyLimit: json['ai_monthly_limit'] as int?,
      imageLimit: json['image_limit'] as int?,
      voiceLimit: json['voice_limit'] as int?,
      materialsLimit: json['materials_limit'] as int?,
      isActive: json['is_active'] as bool,
    );
  }
}
