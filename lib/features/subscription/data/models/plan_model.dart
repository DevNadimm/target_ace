class PlanModel {
  final String id;
  final String name;
  final int durationDays;
  final double price;
  final List<String> features;
  final bool isActive;

  PlanModel({
    required this.id,
    required this.name,
    required this.durationDays,
    required this.price,
    required this.features,
    this.isActive = true,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    final rawFeatures = json['features'];
    List<String> parsedFeatures = [];
    if (rawFeatures is List) {
      parsedFeatures = rawFeatures.map((e) => e.toString()).toList();
    }

    return PlanModel(
      id: json['id'] as String,
      name: json['name'] as String,
      durationDays: json['duration_days'] as int? ?? 30,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      features: parsedFeatures,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'duration_days': durationDays,
      'price': price,
      'features': features,
      'is_active': isActive,
    };
  }
}
