import 'package:flutter/material.dart';
import '../models/cart_model.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  final CartService _cartService = CartService();
  
  List<CartItemModel> _cartItems = [];
  double _total = 0.0;
  bool _isLoading = false;
  String _error = '';

  List<CartItemModel> get cartItems => _cartItems;
  double get total => _total;
  bool get isLoading => _isLoading;
  String get error => _error;
  int get itemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  CartProvider() {
    _init();
  }

  void _init() {
    // Listen to cart items stream
    _cartService.getCartItems().listen((items) {
      _cartItems = items;
      _calculateTotal();
      notifyListeners();
    });
  }

  void _calculateTotal() {
    _total = _cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  Future<void> addToCart(ProductModel product, int quantity) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();
      
      await _cartService.addToCart(product, quantity);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateCartItem(String itemId, int quantity) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();
      
      await _cartService.updateCartItem(itemId, quantity);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> removeCartItem(String itemId) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();
      
      await _cartService.removeCartItem(itemId);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();
      
      await _cartService.clearCart();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}