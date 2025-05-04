import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double discountPrice;
  final List<String> images;
  final String category;
  final int stock;
  final double rating;
  final int reviewCount;
  final bool isFeatured;
  final DateTime createdAt;
  final Map<String, dynamic> specifications;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice = 0.0,
    required this.images,
    required this.category,
    required this.stock,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isFeatured = false,
    required this.createdAt,
    this.specifications = const {},
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      discountPrice: (json['discountPrice'] ?? 0.0).toDouble(),
      images: List<String>.from(json['images'] ?? []),
      category: json['category'] ?? '',
      stock: json['stock'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      isFeatured: json['isFeatured'] ?? false,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      specifications: json['specifications'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'discountPrice': discountPrice,
      'images': images,
      'category': category,
      'stock': stock,
      'rating': rating,
      'reviewCount': reviewCount,
      'isFeatured': isFeatured,
      'createdAt': createdAt,
      'specifications': specifications,
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? discountPrice,
    List<String>? images,
    String? category,
    int? stock,
    double? rating,
    int? reviewCount,
    bool? isFeatured,
    DateTime? createdAt,
    Map<String, dynamic>? specifications,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      images: images ?? this.images,
      category: category ?? this.category,
      stock: stock ?? this.stock,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
      specifications: specifications ?? this.specifications,
    );
  }
}