import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/product_model.dart';
import 'package:uuid/uuid.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final uuid = Uuid();

  // Get all products
  Stream<List<ProductModel>> getProducts() {
    return _firestore
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromJson(doc.data()))
            .toList());
  }

  // Get product by id
  Future<ProductModel?> getProductById(String id) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('products').doc(id).get();
      
      if (doc.exists) {
        return ProductModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      
      return null;
    } catch (e) {
      print('Error getting product: $e');
      throw e;
    }
  }

  // Get featured products
  Stream<List<ProductModel>> getFeaturedProducts() {
    return _firestore
        .collection('products')
        .where('isFeatured', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromJson(doc.data()))
            .toList());
  }

  // Get products by category
  Stream<List<ProductModel>> getProductsByCategory(String category) {
    return _firestore
        .collection('products')
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromJson(doc.data()))
            .toList());
  }

  // Search products
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      // This is a simple implementation, Firestore doesn't support full-text search natively
      // For a production app, consider using Algolia or Firebase Extensions
      QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .get();
      
      return snapshot.docs
          .map((doc) => ProductModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error searching products: $e');
      throw e;
    }
  }

  // Upload product image
  Future<String> uploadProductImage(File image) async {
    try {
      String fileName = uuid.v4();
      Reference storageRef = _storage.ref().child('product_images/$fileName');
      UploadTask uploadTask = storageRef.putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading product image: $e');
      throw e;
    }
  }

  // Add product (admin only)
  Future<void> addProduct(ProductModel product) async {
    try {
      String id = uuid.v4();
      ProductModel newProduct = product.copyWith(
        id: id,
        createdAt: DateTime.now(),
      );
      
      await _firestore.collection('products').doc(id).set(newProduct.toJson());
    } catch (e) {
      print('Error adding product: $e');
      throw e;
    }
  }

  // Update product (admin only)
  Future<void> updateProduct(ProductModel product) async {
    try {
      await _firestore
          .collection('products')
          .doc(product.id)
          .update(product.toJson());
    } catch (e) {
      print('Error updating product: $e');
      throw e;
    }
  }

  // Delete product (admin only)
  Future<void> deleteProduct(String id) async {
    try {
      await _firestore.collection('products').doc(id).delete();
    } catch (e) {
      print('Error deleting product: $e');
      throw e;
    }
  }

  // Get all categories
  Future<List<String>> getCategories() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('categories').get();
      
      return snapshot.docs
          .map((doc) => doc['name'] as String)
          .toList();
    } catch (e) {
      print('Error getting categories: $e');
      throw e;
    }
  }
  
  // Add category (admin only)
  Future<void> addCategory(String name) async {
    try {
      String id = uuid.v4();
      await _firestore.collection('categories').doc(id).set({
        'id': id,
        'name': name,
      });
    } catch (e) {
      print('Error adding category: $e');
      throw e;
    }
  }
}