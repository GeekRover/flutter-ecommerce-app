import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();
  
  List<ProductModel> _products = [];
  List<ProductModel> _featuredProducts = [];
  List<String> _categories = [];
  ProductModel? _selectedProduct;
  String _selectedCategory = '';
  bool _isLoading = false;
  String _error = '';

  List<ProductModel> get products => _products;
  List<ProductModel> get featuredProducts => _featuredProducts;
  List<String> get categories => _categories;
  ProductModel? get selectedProduct => _selectedProduct;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String get error => _error;

  ProductProvider() {
    _init();
  }

  void _init() async {
    // Load categories
    await fetchCategories();
    
    // Listen to products stream
    _productService.getProducts().listen((productsList) {
      _products = productsList;
      notifyListeners();
    });
    
    // Listen to featured products stream
    _productService.getFeaturedProducts().listen((featuredList) {
      _featuredProducts = featuredList;
      notifyListeners();
    });
  }

  Future<void> fetchCategories() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      List<String> categoriesList = await _productService.getCategories();
      _categories = categoriesList;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
    
    // If category is selected, listen to products by category
    if (category.isNotEmpty) {
      _productService.getProductsByCategory(category).listen((productsList) {
        _products = productsList;
        notifyListeners();
      });
    } else {
      // If no category is selected, listen to all products
      _productService.getProducts().listen((productsList) {
        _products = productsList;
        notifyListeners();
      });
    }
  }
Future<void> addCategory(String name) async {
  try {
    _isLoading = true;
    _error = '';
    notifyListeners();
    
    await _productService.addCategory(name);
    await fetchCategories(); // Refresh categories
    
    _isLoading = false;
    notifyListeners();
  } catch (e) {
    _isLoading = false;
    _error = e.toString();
    notifyListeners();
  }
}

  Future<void> selectProduct(String id) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();
      
      ProductModel? product = await _productService.getProductById(id);
      _selectedProduct = product;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();
      
      List<ProductModel> searchResults = await _productService.searchProducts(query);
      
      _isLoading = false;
      notifyListeners();
      
      return searchResults;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Admin functions
  Future<bool> addProduct(ProductModel product) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();
      
      await _productService.addProduct(product);
      
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

  Future<bool> updateProduct(ProductModel product) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();
      
      await _productService.updateProduct(product);
      
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

  Future<bool> deleteProduct(String id) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();
      
      await _productService.deleteProduct(id);
      
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