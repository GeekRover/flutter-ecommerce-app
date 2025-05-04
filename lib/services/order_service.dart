import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order_model.dart';
import '../models/cart_model.dart';
import 'cart_service.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CartService _cartService = CartService();

  // Get user orders
  Stream<List<OrderModel>> getUserOrders() {
    String? userId = _auth.currentUser?.uid;
    
    if (userId == null) {
      return Stream.value([]);
    }
    
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromJson(doc.data()))
            .toList());
  }

  // Get order by id
  Future<OrderModel?> getOrderById(String id) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('orders').doc(id).get();
      
      if (doc.exists) {
        return OrderModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      
      return null;
    } catch (e) {
      print('Error getting order: $e');
      throw e;
    }
  }

  // Create order
  Future<String> createOrder(
      String shippingAddress, String paymentMethod) async {
    try {
      String? userId = _auth.currentUser?.uid;
      
      if (userId == null) {
        throw Exception('User not logged in');
      }
      
      // Get cart items
      List<CartItemModel> cartItems = await _cartService.getCartItems().first;
      
      if (cartItems.isEmpty) {
        throw Exception('Cart is empty');
      }
      
      // Calculate totals
      double subtotal = 0.0;
      for (var item in cartItems) {
        subtotal += item.price * item.quantity;
      }
      
      double shipping = 10.0; // Fixed shipping fee
      double tax = subtotal * 0.05; // 5% tax
      double total = subtotal + shipping + tax;
      
      // Create order
      String orderId = DateTime.now().millisecondsSinceEpoch.toString();
      OrderModel order = OrderModel(
        id: orderId,
        userId: userId,
        items: cartItems,
        subtotal: subtotal,
        shipping: shipping,
        tax: tax,
        total: total,
        paymentMethod: paymentMethod,
        status: OrderStatus.pending,
        shippingAddress: shippingAddress,
        createdAt: DateTime.now(),
      );
      
      // Save order to Firestore
      await _firestore.collection('orders').doc(orderId).set(order.toJson());
      
      // Clear cart
      await _cartService.clearCart();
      
      return orderId;
    } catch (e) {
      print('Error creating order: $e');
      throw e;
    }
  }

  // Get all orders (admin only)
  Stream<List<OrderModel>> getAllOrders() {
    return _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromJson(doc.data()))
            .toList());
  }

  // Update order status (admin only)
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status.toString().split('.').last,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      print('Error updating order status: $e');
      throw e;
    }
  }
}