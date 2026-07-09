class Account {
  final String uid;
  final String name;
  final String email;
  final String phoneNumber;
  final String kycStatus;
  final String? verifiedAt;

  Account({
    required this.uid,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.kycStatus = 'UNVERIFIED',
    this.verifiedAt,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      kycStatus: json['kycStatus'] ?? 'UNVERIFIED',
      verifiedAt: json['verifiedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'kycStatus': kycStatus,
      'verifiedAt': verifiedAt,
    };
  }
}
