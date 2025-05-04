import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();
  
  List<OrderModel> _orders = [];
  OrderModel? _selectedOrder;
  bool _isLoading = false;
  String _error = '';
  bool _isAdmin = false;

  List<OrderModel> get orders => _orders;
  OrderModel? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  String get error => _error;

  OrderProvider({bool isAdmin = false}) {
    _isAdmin = isAdmin;
    _init();
  }

  void _init() {
    // Listen to orders stream based on user role
    if (_isAdmin) {
      _orderService.getAllOrders().listen((ordersList) {
        _orders = ordersList;
        notifyListeners();
      });
    } else {
      _orderService.getUserOrders().listen((ordersList) {
        _orders = ordersList;
        notifyListeners();
      });
    }
  }

  Future<void> selectOrder(String id) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();
      
      OrderModel? order = await _orderService.getOrderById(id);
      _selectedOrder = order;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<String?> createOrder(
      String shippingAddress, String paymentMethod) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();
      
      String orderId = await _orderService.createOrder(
        shippingAddress,
        paymentMethod,
      );
      
      _isLoading = false;
      notifyListeners();
      
      return orderId;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Admin function
  Future<bool> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();
      
      await _orderService.updateOrderStatus(orderId, status);
      
      // Update selected order if it's the one being updated
      if (_selectedOrder != null && _selectedOrder!.id == orderId) {
        _selectedOrder = _selectedOrder!.copyWith(status: status);
      }
      
      _isLoading = false;
      notifyListeners();
      
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}