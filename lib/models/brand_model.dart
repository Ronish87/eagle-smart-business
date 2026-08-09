class BrandModel {
  final int? id;
  final String name;
  final String description;
  final bool isActive;
  final DateTime createdAt;

  BrandModel({
    this.id,
    required this.name,
    required this.description,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BrandModel.fromMap(Map<String, dynamic> map) {
    return BrandModel(
      id: map['id'] as int?,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      isActive: (map['isActive'] ?? 1) == 1,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  BrandModel copyWith({
    int? id,
    String? name,
    String? description,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return BrandModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'BrandModel(id: $id, name: $name)';
  }
}
