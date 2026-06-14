class Plan {
  final String id;
  final String name;
  final double price;
  final String durationType; // 'monthly', 'quarterly', 'annual'
  final bool isActive;

  Plan({
    required this.id,
    required this.name,
    required this.price,
    required this.durationType,
    required this.isActive,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'] as String,
      name: json['name'] as String,
      price: double.parse(json['price'].toString()),
      durationType: json['duration_type'] as String,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'duration_type': durationType,
      'is_active': isActive,
    };
  }
}
