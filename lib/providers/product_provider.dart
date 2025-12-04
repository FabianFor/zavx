// lib/providers/product_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product.dart';
import '../core/constants/validation_limits.dart';

class ProductProvider with ChangeNotifier {
  Box<Product>? _box;
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalProducts => _products.length;

  List<Product> get lowStockProducts => 
      _products.where((p) => p.stock <= 5).toList();

  @override
  void dispose() {
    _box?.close();
    super.dispose();
  }

  Future<void> loadProducts() async {
    if (_isInitialized) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _box = await Hive.openBox<Product>('products');
      _products = _box!.values.toList();
      _isInitialized = true;
    } catch (e) {
      _error = 'Error al cargar productos: $e';
      _products = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _validateProductName(String name) {
    final sanitized = _sanitizeInput(name.trim());
    if (sanitized.isEmpty) {
      _error = 'El nombre del producto no puede estar vacío';
      return false;
    }
    if (sanitized.length > ValidationLimits.maxProductNameLength) {
      _error = 'El nombre es demasiado largo (máx. ${ValidationLimits.maxProductNameLength} caracteres)';
      return false;
    }
    return true;
  }

  bool _validateProductPrice(double price) {
    if (price <= 0 || price > ValidationLimits.maxProductPrice) {
      _error = 'Precio inválido';
      return false;
    }
    return true;
  }

  bool _validateProductStock(int stock) {
    if (stock < 0 || stock > ValidationLimits.maxProductStock) {
      _error = 'Stock inválido';
      return false;
    }
    return true;
  }

  Future<bool> addProduct(Product product) async {
    if (!_validateProductName(product.name)) {
      notifyListeners();
      return false;
    }
    if (!_validateProductPrice(product.price)) {
      notifyListeners();
      return false;
    }
    if (!_validateProductStock(product.stock)) {
      notifyListeners();
      return false;
    }

    try {
      final sanitizedProduct = Product(
        id: product.id,
        name: _sanitizeInput(product.name.trim()),
        description: _sanitizeInput(product.description.trim()),
        price: product.price,
        stock: product.stock,
        imagePath: product.imagePath,
      );
      
      // Guardar en Hive
      await _box!.put(sanitizedProduct.id, sanitizedProduct);
      
      // Actualizar lista en memoria
      _products.add(sanitizedProduct);
      
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al agregar producto: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct(Product updatedProduct) async {
    if (!_validateProductName(updatedProduct.name)) {
      notifyListeners();
      return false;
    }
    if (!_validateProductPrice(updatedProduct.price)) {
      notifyListeners();
      return false;
    }
    if (!_validateProductStock(updatedProduct.stock)) {
      notifyListeners();
      return false;
    }

    try {
      final index = _products.indexWhere((p) => p.id == updatedProduct.id);
      if (index == -1) {
        _error = 'Producto no encontrado';
        notifyListeners();
        return false;
      }

      final sanitizedProduct = Product(
        id: updatedProduct.id,
        name: _sanitizeInput(updatedProduct.name.trim()),
        description: _sanitizeInput(updatedProduct.description.trim()),
        price: updatedProduct.price,
        stock: updatedProduct.stock,
        imagePath: updatedProduct.imagePath,
      );
      
      // Actualizar en Hive
      await _box!.put(sanitizedProduct.id, sanitizedProduct);
      
      // Actualizar en memoria
      _products[index] = sanitizedProduct;
      
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al actualizar producto: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      final index = _products.indexWhere((p) => p.id == productId);
      if (index == -1) {
        _error = 'Producto no encontrado';
        notifyListeners();
        return;
      }

      // Eliminar de Hive
      await _box!.delete(productId);
      
      // Eliminar de memoria
      _products.removeAt(index);
      
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Error al eliminar producto: $e';
      notifyListeners();
    }
  }

  Future<bool> updateStock(String productId, int newStock) async {
    if (!_validateProductStock(newStock)) {
      notifyListeners();
      return false;
    }

    try {
      final index = _products.indexWhere((p) => p.id == productId);
      if (index == -1) {
        _error = 'Producto no encontrado';
        notifyListeners();
        return false;
      }

      final updatedProduct = _products[index].copyWith(stock: newStock);
      
      // Actualizar en Hive
      await _box!.put(productId, updatedProduct);
      
      // Actualizar en memoria
      _products[index] = updatedProduct;
      
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al actualizar stock: $e';
      notifyListeners();
      return false;
    }
  }

  // ✅ BÚSQUEDA POR NOMBRE Y DESCRIPCIÓN (eficiente)
  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;
    
    final lowerQuery = _sanitizeInput(query.toLowerCase());
    return _products.where((product) {
      return product.name.toLowerCase().contains(lowerQuery) ||
             product.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // ✅ BÚSQUEDA POR ID (instantánea O(1))
  Product? getProductById(String id) {
    return _box?.get(id);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> reload() async {
    _isInitialized = false;
    await loadProducts();
  }

  String _sanitizeInput(String input) {
    input = input.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');
    if (input.length > ValidationLimits.maxInputLength) {
      input = input.substring(0, ValidationLimits.maxInputLength);
    }
    return input;
  }
}
