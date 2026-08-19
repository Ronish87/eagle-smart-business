class StockTransactionModel {
  const StockTransactionModel({
    this.id,
    this.productId,
    required this.productCode,
    required this.productName,
    required this.transactionType,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    this.referenceNo = '',
    this.createdBy = '',
    required this.transactionDate,
    this.remarks = '',
  });

  final int? id;
  final int? productId;
  final String productCode;
  final String productName;
  final String transactionType;
  final int quantity;
  final double unitPrice;
  final double totalAmount;
  final String referenceNo;
  final String createdBy;
  final String transactionDate;
  final String remarks;

  bool get isStockIn => transactionType.trim().toUpperCase() == 'IN';

  bool get isStockOut => transactionType.trim().toUpperCase() == 'OUT';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'product_code': productCode.trim(),
      'product_name': productName.trim(),
      'transaction_type': transactionType.trim().toUpperCase(),
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_amount': totalAmount,
      'reference_no': referenceNo.trim(),
      'created_by': createdBy.trim(),
      'transaction_date': transactionDate,
      'remarks': remarks.trim(),
    };
  }

  factory StockTransactionModel.fromMap(Map<String, dynamic> map) {
    return StockTransactionModel(
      id: _toIntOrNull(map['id']),
      productId: _toIntOrNull(map['product_id']),
      productCode: map['product_code']?.toString() ?? '',
      productName: map['product_name']?.toString() ?? '',
      transactionType: map['transaction_type']?.toString() ?? '',
      quantity: _toInt(map['quantity']),
      unitPrice: _toDouble(map['unit_price']),
      totalAmount: _toDouble(map['total_amount']),
      referenceNo: map['reference_no']?.toString() ?? '',
      createdBy: map['created_by']?.toString() ?? '',
      transactionDate: map['transaction_date']?.toString() ?? '',
      remarks: map['remarks']?.toString() ?? '',
    );
  }

  StockTransactionModel copyWith({
    int? id,
    int? productId,
    String? productCode,
    String? productName,
    String? transactionType,
    int? quantity,
    double? unitPrice,
    double? totalAmount,
    String? referenceNo,
    String? createdBy,
    String? transactionDate,
    String? remarks,
  }) {
    return StockTransactionModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productCode: productCode ?? this.productCode,
      productName: productName ?? this.productName,
      transactionType: transactionType ?? this.transactionType,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalAmount: totalAmount ?? this.totalAmount,
      referenceNo: referenceNo ?? this.referenceNo,
      createdBy: createdBy ?? this.createdBy,
      transactionDate: transactionDate ?? this.transactionDate,
      remarks: remarks ?? this.remarks,
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _toIntOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
