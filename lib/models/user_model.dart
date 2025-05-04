import 'package:cloud_firestore/cloud_firestore.dart';
class UserModel {
  final String id;
  final String email;
  final String name;
  final String phone;
  final String address;
  final String profileImage;
  final String role; // 'user' or 'admin'
  final DateTime createdAt;
  final List<String> favorites;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.phone = '',
    this.address = '',
    this.profileImage = '',
    this.role = 'user',
    required this.createdAt,
    this.favorites = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      profileImage: json['profileImage'] ?? '',
      role: json['role'] ?? 'user',
          createdAt: json['createdAt'] != null
              ? (json['createdAt'] is Timestamp 
                  ? json['createdAt'].toDate() 
                  : DateTime.now())
              : DateTime.now(), 
      favorites: List<String>.from(json['favorites'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'address': address,
      'profileImage': profileImage,
      'role': role,
      'createdAt': createdAt,
      'favorites': favorites,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? address,
    String? profileImage,
    String? role,
    DateTime? createdAt,
    List<String>? favorites,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      profileImage: profileImage ?? this.profileImage,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      favorites: favorites ?? this.favorites,
    );
  }
}