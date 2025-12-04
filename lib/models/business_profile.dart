import 'package:hive/hive.dart';

part 'business_profile.g.dart';

@HiveType(typeId: 4)
class BusinessProfile extends HiveObject {
  @HiveField(0)
  final String name;
  
  @HiveField(1)
  final String address;
  
  @HiveField(2)
  final String phone;
  
  @HiveField(3)
  final String email;
  
  @HiveField(4)
  final String logoPath;

  BusinessProfile({
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.logoPath,
  });

  // ✅ GETTER para compatibilidad con código antiguo
  String get businessName => name;
  String get businessAddress => address;
  String get businessPhone => phone;
  String get businessEmail => email;
  String get businessLogo => logoPath;

  BusinessProfile copyWith({
    String? name,
    String? address,
    String? phone,
    String? email,
    String? logoPath,
  }) {
    return BusinessProfile(
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      logoPath: logoPath ?? this.logoPath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'logoPath': logoPath,
    };
  }

  factory BusinessProfile.fromJson(Map<String, dynamic> json) {
    return BusinessProfile(
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      logoPath: json['logoPath'] ?? '',
    );
  }
}
