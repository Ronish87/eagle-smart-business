```dart
class SupplierModel {
  final int? id;

  final String supplierCode;
  final String supplierName;

  final String contactPerson;
  final String phone;
  final String email;

  final String address;
  final String panNumber;

  final String remarks;

  final bool isActive;

  final String createdAt;

  const SupplierModel({
    this.id,
    required this.supplierCode,
    required this.supplierName,
    this.contactPerson = '',
    this.phone = '',
    this.email = '',
    this.address = '',
    this.panNumber = '',
    this.remarks = '',
    this.isActive = true,
    required this.createdAt,
  });

  // ============================================================
  // TO MAP
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'id': id,

      'supplierCode':
          supplierCode.trim(),

      'supplierName':
          supplierName.trim(),

      'contactPerson':
          contactPerson.trim(),

      'phone':
          phone.trim(),

      'email':
          email.trim(),

      'address':
          address.trim(),

      'panNumber':
          panNumber.trim(),

      'remarks':
          remarks.trim(),

      'isActive':
          isActive ? 1 : 0,

      'createdAt':
          createdAt,
    };
  }

  // ============================================================
  // FROM MAP
  // ============================================================

  factory SupplierModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return SupplierModel(
      id: map['id'] as int?,

      supplierCode:
          map['supplierCode']
                  ?.toString() ??
              '',

      supplierName:
          map['supplierName']
                  ?.toString() ??
              '',

      contactPerson:
          map['contactPerson']
                  ?.toString() ??
              '',

      phone:
          map['phone']
                  ?.toString() ??
              '',

      email:
          map['email']
                  ?.toString() ??
              '',

      address:
          map['address']
                  ?.toString() ??
              '',

      panNumber:
          map['panNumber']
                  ?.toString() ??
              '',

      remarks:
          map['remarks']
                  ?.toString() ??
              '',

      isActive:
          _parseBool(
        map['isActive'],
      ),

      createdAt:
          map['createdAt']
                  ?.toString() ??
              '',
    );
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  SupplierModel copyWith({
    int? id,
    String? supplierCode,
    String? supplierName,
    String? contactPerson,
    String? phone,
    String? email,
    String? address,
    String? panNumber,
    String? remarks,
    bool? isActive,
    String? createdAt,
  }) {
    return SupplierModel(
      id: id ?? this.id,

      supplierCode:
          supplierCode ??
              this.supplierCode,

      supplierName:
          supplierName ??
              this.supplierName,

      contactPerson:
          contactPerson ??
              this.contactPerson,

      phone:
          phone ??
              this.phone,

      email:
          email ??
              this.email,

      address:
          address ??
              this.address,

      panNumber:
          panNumber ??
              this.panNumber,

      remarks:
          remarks ??
              this.remarks,

      isActive:
          isActive ??
              this.isActive,

      createdAt:
          createdAt ??
              this.createdAt,
    );
  }

  // ============================================================
  // BOOL PARSER
  // ============================================================

  static bool _parseBool(
    dynamic value,
  ) {
    if (value == null) {
      return true;
    }

    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    if (value is String) {
      final text =
          value.toLowerCase().trim();

      return text == '1' ||
          text == 'true' ||
          text == 'yes';
    }

    return true;
  }

  // ============================================================
  // DISPLAY NAME
  // ============================================================

  String get displayName {
    if (supplierCode.isEmpty) {
      return supplierName;
    }

    return '$supplierName ($supplierCode)';
  }

  // ============================================================
  // STATUS TEXT
  // ============================================================

  String get statusText {
    return isActive
        ? 'Active'
        : 'Inactive';
  }

  // ============================================================
  // JSON STYLE MAP
  // ============================================================

  @override
  String toString() {
    return 'SupplierModel('
        'id: $id, '
        'supplierCode: $supplierCode, '
        'supplierName: $supplierName, '
        'contactPerson: $contactPerson, '
        'phone: $phone, '
        'email: $email, '
        'address: $address, '
        'panNumber: $panNumber, '
        'remarks: $remarks, '
        'isActive: $isActive, '
        'createdAt: $createdAt'
        ')';
  }
}
```
