import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cart_model.dart';
import '../models/product_model.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get cart items
  Stream<List<CartItemModel>> getCartItems() {
    String? userId = _auth.currentUser?.uid;
    
    if (userId == null) {
      return Stream.value([]);
    }
    
    return _firestore
        .collection('carts')
        .doc(userId)
        .collection('items')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CartItemModel.fromJson(doc.data()))
            .toList());
  }

  // Add item to cart
  Future<void> addToCart(ProductModel product, int quantity) async {
    try {
      String? userId = _auth.currentUser?.uid;
      
      if (userId == null) {
        throw Exception('User not logged in');
      }
      
      // Check if item already exists in cart
      QuerySnapshot existingItems = await _firestore
          .collection('carts')
          .doc(userId)
          .collection('items')
          .where('productId', isEqualTo: product.id)
          .get();
      
      if (existingItems.docs.isNotEmpty) {
        // Update existing item
        String itemId = existingItems.docs.first.id;
        CartItemModel existingItem = 
            CartItemModel.fromJson(existingItems.docs.first.data() as Map<String, dynamic>);
        
        await _firestore
            .collection('carts')
            .doc(userId)
            .collection('items')
            .doc(itemId)
            .update({
              'quantity': existingItem.quantity + quantity,
            });
      } else {
        // Add new item
        CartItemModel cartItem = CartItemModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          productId: product.id,
          productName: product.name,
          price: product.discountPrice > 0 ? product.discountPrice : product.price,
          quantity: quantity,
          image: product.images.isNotEmpty ? product.images[0] : '',
        );
        
        await _firestore
            .collection('carts')
            .doc(userId)
            .collection('items')
            .add(cartItem.toJson());
      }
    } catch (e) {
      print('Error adding to cart: $e');
      throw e;
    }
  }

  // Update cart item quantity
  Future<void> updateCartItem(String itemId, int quantity) async {
    try {
      String? userId = _auth.currentUser?.uid;
      
      if (userId == null) {
        throw Exception('User not logged in');
      }
      
      if (quantity <= 0) {
        // Remove item if quantity is 0 or less
        await removeCartItem(itemId);
      } else {
        // Update quantity
        await _firestore
            .collection('carts')
            .doc(userId)
            .collection('items')
            .doc(itemId)
            .update({
              'quantity': quantity,
            });
      }
    } catch (e) {
      print('Error updating cart item: $e');
      throw e;
    }
  }

  // Remove item from cart
  Future<void> removeCartItem(String itemId) async {
    try {
      String? userId = _auth.currentUser?.uid;
      
      if (userId == null) {
        throw Exception('User not logged in');
      }
      
      await _firestore
          .collection('carts')
          .doc(userId)
          .collection('items')
          .doc(itemId)
          .delete();
    } catch (e) {
      print('Error removing cart item: $e');
      throw e;
    }
  }

  // Clear cart
  Future<void> clearCart() async {
    try {
      String? userId = _auth.currentUser?.uid;
      
      if (userId == null) {
        throw Exception('User not logged in');
      }
      
      QuerySnapshot cartItems = await _firestore
          .collection('carts')
          .doc(userId)
          .collection('items')
          .get();
      
      for (var doc in cartItems.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error clearing cart: $e');
      throw e;
    }
  }

  // Get cart total
  Future<double> getCartTotal() async {
    try {
      String? userId = _auth.currentUser?.uid;
      
      if (userId == null) {
        return 0.0;
      }
      
      QuerySnapshot cartItems = await _firestore
          .collection('carts')
          .doc(userId)
          .collection('items')
          .get();
      
      double total = 0.0;
      
      for (var doc in cartItems.docs) {
        CartItemModel item = CartItemModel.fromJson(doc.data() as Map<String, dynamic>);
        total += item.price * item.quantity;
      }
      
      return total;
    } catch (e) {
      print('Error calculating cart total: $e');
      return 0.0;
    }
  }
}