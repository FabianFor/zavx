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
  
  // ✅ CACHE DE BÚSQUEDA (evita recalcular en cada keystroke)
  String _lastSearchQuery = '';
  List<Product> _lastSearchResults = [];

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
      
      // ✅ LAZY LOADING: Solo carga los primeros 50
      final allKeys = _box!.keys.toList();
      final limitedKeys = allKeys.take(50).toList();
      _products = limitedKeys.map((key) => _box!.get(key)!).toList();
      
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
    // ✅ VALIDACIÓN SIN notifyListeners() innecesario
    if (!_validateProductName(product.name) ||
        !_validateProductPrice(product.price) ||
        !_validateProductStock(product.stock)) {
      return false; // ← No llama notifyListeners()
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
      
      // ✅ Escribir primero en Hive
      await _box!.put(sanitizedProduct.id, sanitizedProduct);
      
      // ✅ Solo agregar a memoria si no excede límite
      if (_products.length < 200) {
        _products.insert(0, sanitizedProduct); // Más reciente primero
      }
      
      _error = null;
      notifyListeners(); // Solo UNA llamada al final
      return true;
    } catch (e) {
      _error = 'Error al agregar producto: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct(Product updatedProduct) async {
    if (!_validateProductName(updatedProduct.name) ||
        !_validateProductPrice(updatedProduct.price) ||
        !_validateProductStock(updatedProduct.stock)) {
      return false;
    }

    try {
      final index = _products.indexWhere((p) => p.id == updatedProduct.id);
      
      final sanitizedProduct = Product(
        id: updatedProduct.id,
        name: _sanitizeInput(updatedProduct.name.trim()),
        description: _sanitizeInput(updatedProduct.description.trim()),
        price: updatedProduct.price,
        stock: updatedProduct.stock,
        imagePath: updatedProduct.imagePath,
      );
      
      await _box!.put(sanitizedProduct.id, sanitizedProduct);
      
      // ✅ Actualizar solo si está en memoria
      if (index != -1) {
        _products[index] = sanitizedProduct;
      }
      
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
      await _box!.delete(productId);
      _products.removeWhere((p) => p.id == productId);
      
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Error al eliminar producto: $e';
      notifyListeners();
    }
  }

  Future<bool> updateStock(String productId, int newStock) async {
    if (!_validateProductStock(newStock)) {
      return false;
    }

    try {
      final index = _products.indexWhere((p) => p.id == productId);
      
      if (index != -1) {
        final updatedProduct = _products[index].copyWith(stock: newStock);
        await _box!.put(productId, updatedProduct);
        _products[index] = updatedProduct;
      } else {
        // ✅ Cargar desde Hive si no está en memoria
        final product = _box!.get(productId);
        if (product != null) {
          final updatedProduct = product.copyWith(stock: newStock);
          await _box!.put(productId, updatedProduct);
        }
      }
      
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al actualizar stock: $e';
      notifyListeners();
      return false;
    }
  }

  // ✅ BÚSQUEDA CON CACHE (mucho más rápida)
  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;
    
    // Si es la misma búsqueda, devolver resultado cacheado
    if (query == _lastSearchQuery) {
      return _lastSearchResults;
    }
    
    final lowerQuery = _sanitizeInput(query.toLowerCase());
    
    // ✅ BUSCAR PRIMERO EN MEMORIA (rápido)
    final memoryResults = _products.where((product) {
      return product.name.toLowerCase().contains(lowerQuery) ||
             product.description.toLowerCase().contains(lowerQuery);
    }).toList();
    
    // ✅ Si hay pocos resultados, buscar en Hive también
    if (memoryResults.length < 5) {
      final allProducts = _box!.values.toList();
      _lastSearchResults = allProducts.where((product) {
        return product.name.toLowerCase().contains(lowerQuery) ||
               product.description.toLowerCase().contains(lowerQuery);
      }).toList();
    } else {
      _lastSearchResults = memoryResults;
    }
    
    _lastSearchQuery = query;
    return _lastSearchResults;
  }

  Product? getProductById(String id) {
    return _box?.get(id);
  }

  void clearError() {
    _error = null;
    // ❌ NO llamar notifyListeners() aquí
  }

  Future<void> reload() async {
    _isInitialized = false;
    _lastSearchQuery = '';
    _lastSearchResults = [];
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
