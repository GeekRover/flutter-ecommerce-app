import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_model.dart';

enum OrderStatus {
  pending,
  processing,
  shipped,
  delivered,
  cancelled,
}

class OrderModel {
  final String id;
  final String userId;
  final List<CartItemModel> items;
  final double subtotal;
  final double shipping;
  final double tax;
  final double total;
  final String paymentMethod;
  final OrderStatus status;
  final String shippingAddress;
  final DateTime createdAt;
  final DateTime? updatedAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.shipping,
    required this.tax,
    required this.total,
    required this.paymentMethod,
    required this.status,
    required this.shippingAddress,
    required this.createdAt,
    this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      items: (json['items'] as List?)
              ?.map((item) => CartItemModel.fromJson(item))
              .toList() ??
          [],
      subtotal: (json['subtotal'] ?? 0.0).toDouble(),
      shipping: (json['shipping'] ?? 0.0).toDouble(),
      tax: (json['tax'] ?? 0.0).toDouble(),
      total: (json['total'] ?? 0.0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? '',
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == 'OrderStatus.${json['status'] ?? 'pending'}',
        orElse: () => OrderStatus.pending,
      ),
      shippingAddress: json['shippingAddress'] ?? '',
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'shipping': shipping,
      'tax': tax,
      'total': total,
      'paymentMethod': paymentMethod,
      'status': status.toString().split('.').last,
      'shippingAddress': shippingAddress,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  OrderModel copyWith({
    String? id,
    String? userId,
    List<CartItemModel>? items,
    double? subtotal,
    double? shipping,
    double? tax,
    double? total,
    String? paymentMethod,
    OrderStatus? status,
    String? shippingAddress,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      shipping: shipping ?? this.shipping,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}