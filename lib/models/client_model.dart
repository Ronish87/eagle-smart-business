class ClientModel {
  final int? id;

  final String companyName;
  final String ownerName;
  final String adminName;

  final String mobile;
  final String whatsapp;
  final String email;

  final String businessType;

  final String address;
  final String district;
  final String province;
  final String country;

  final String panNo;
  final String vatNo;
  final String registrationNo;

  final bool webAccess;
  final bool mobileAccess;

  final String status;

  final String createdDate;

  ClientModel({
    this.id,
    required this.companyName,
    required this.ownerName,
    required this.adminName,
    required this.mobile,
    required this.whatsapp,
    required this.email,
    required this.businessType,
    required this.address,
    required this.district,
    required this.province,
    required this.country,
    required this.panNo,
    required this.vatNo,
    required this.registrationNo,
    required this.webAccess,
    required this.mobileAccess,
    required this.status,
    required this.createdDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'company_name': companyName,
      'owner_name': ownerName,
      'admin_name': adminName,
      'mobile': mobile,
      'whatsapp': whatsapp,
      'email': email,
      'business_type': businessType,
      'address': address,
      'district': district,
      'province': province,
      'country': country,
      'pan_no': panNo,
      'vat_no': vatNo,
      'registration_no': registrationNo,
      'web_access': webAccess ? 1 : 0,
      'mobile_access': mobileAccess ? 1 : 0,
      'status': status,
      'created_date': createdDate,
    };
  }

  factory ClientModel.fromMap(Map<String, dynamic> map) {
    return ClientModel(
      id: map['id'],
      companyName: map['company_name'] ?? '',
      ownerName: map['owner_name'] ?? '',
      adminName: map['admin_name'] ?? '',
      mobile: map['mobile'] ?? '',
      whatsapp: map['whatsapp'] ?? '',
      email: map['email'] ?? '',
      businessType: map['business_type'] ?? '',
      address: map['address'] ?? '',
      district: map['district'] ?? '',
      province: map['province'] ?? '',
      country: map['country'] ?? '',
      panNo: map['pan_no'] ?? '',
      vatNo: map['vat_no'] ?? '',
      registrationNo: map['registration_no'] ?? '',
      webAccess: map['web_access'] == 1,
      mobileAccess: map['mobile_access'] == 1,
      status: map['status'] ?? 'Active',
      createdDate: map['created_date'] ?? '',
    );
  }
}
