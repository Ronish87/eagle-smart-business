class ProductModel {
  final int? id;

  final String code;
  final String barcode;

  final String name;

  final String category;
  final String brand;
  final String supplier;

  final String unit;

  final double purchasePrice;
  final double sellingPrice;

  final int stock;
  final int minimumStock;

  final String image;

  final bool active;

  const ProductModel({
    this.id,
    required this.code,
    required this.barcode,
    required this.name,
    required this.category,
    required this.brand,
    required this.supplier,
    required this.unit,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.stock,
    required this.minimumStock,
    this.image = '',
    this.active = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'barcode': barcode,
      'name': name,
      'category': category,
      'brand': brand,
      'supplier': supplier,
      'unit': unit,
      'purchase_price': purchasePrice,
      'selling_price': sellingPrice,
      'stock': stock,
      'minimum_stock': minimumStock,
      'image': image,
      'active': active ? 1 : 0,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as int?,
      code: map['code'] ?? '',
      barcode: map['barcode'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      brand: map['brand'] ?? '',
      supplier: map['supplier'] ?? '',
      unit: map['unit'] ?? '',
      purchasePrice: ((map['purchase_price'] ?? 0) as num).toDouble(),
      sellingPrice: ((map['selling_price'] ?? 0) as num).toDouble(),
      stock: map['stock'] ?? 0,
      minimumStock: map['minimum_stock'] ?? 0,
      image: map['image'] ?? '',
      active: (map['active'] ?? 1) == 1,
    );
  }

  ProductModel copyWith({
    int? id,
    String? code,
    String? barcode,
    String? name,
    String? category,
    String? brand,
    String? supplier,
    String? unit,
    double? purchasePrice,
    double? sellingPrice,
    int? stock,
    int? minimumStock,
    String? image,
    bool? active,
  }) {
    return ProductModel(
      id: id ?? this.id,
      code: code ?? this.code,
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      supplier: supplier ?? this.supplier,
      unit: unit ?? this.unit,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      stock: stock ?? this.stock,
      minimumStock: minimumStock ?? this.minimumStock,
      image: image ?? this.image,
      active: active ?? this.active,
    );
  }

  @override
  String toString() {
    return 'ProductModel(id: $id, code: $code, name: $name)';
  }
}
