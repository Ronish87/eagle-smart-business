class ClientModel {
  String companyName;
  String ownerName;
  String adminName;
  String mobile;
  String whatsapp;
  String email;

  String businessType;

  bool webAccess;
  bool mobileAccess;

  int webUsers;
  int mobileUsers;

  ClientModel({
    required this.companyName,
    required this.ownerName,
    required this.adminName,
    required this.mobile,
    required this.whatsapp,
    required this.email,
    required this.businessType,
    required this.webAccess,
    required this.mobileAccess,
    required this.webUsers,
    required this.mobileUsers,
  });
}
