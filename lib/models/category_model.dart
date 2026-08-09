class CategoryModel {
  final int? id;
  final String name;
  final String description;
  final bool isActive;
  final DateTime createdAt;

  CategoryModel({
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

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      isActive: (map['isActive'] ?? 1) == 1,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  CategoryModel copyWith({
    int? id,
    String? name,
    String? description,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
