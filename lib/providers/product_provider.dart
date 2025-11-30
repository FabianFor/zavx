import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
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

  Future<void> loadProducts() async {
    if (_isInitialized) {
      print('✅ Productos ya en caché, no se recarga');
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? productsJson = prefs.getString('products');

      if (productsJson != null && productsJson.isNotEmpty) {
        final List<dynamic> decodedList = json.decode(productsJson);
        _products = decodedList.map((item) => Product.fromJson(item as Map<String, dynamic>)).toList();
        print('✅ ${_products.length} productos cargados desde disco');
      } else {
        _products = [];
        print('ℹ️ No hay productos guardados, lista vacía');
      }

      _isInitialized = true;
    } catch (e) {
      _error = 'Error al cargar productos: $e';
      print('❌ $_error');
      _products = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> _saveProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encodedData = json.encode(
        _products.map((product) => product.toJson()).toList(),
      );
      
      final bool saved = await prefs.setString('products', encodedData);
      
      if (saved) {
        print('✅ ${_products.length} productos guardados exitosamente');
        
        // Verificar que se guardó
        final String? verification = prefs.getString('products');
        if (verification != null) {
          print('✅ Verificación: datos guardados correctamente');
          return true;
        } else {
          print('❌ ERROR: No se pudo verificar el guardado');
          return false;
        }
      } else {
        print('❌ ERROR: SharedPreferences retornó false');
        return false;
      }
    } catch (e) {
      print('❌ Error crítico al guardar productos: $e');
      _error = 'Error al guardar: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> addProduct(Product product) async {
    // Validaciones
    if (product.name.trim().isEmpty) {
      _error = 'El nombre del producto no puede estar vacío';
      notifyListeners();
      return false;
    }

    if (product.price <= 0) {
      _error = 'El precio debe ser mayor a 0';
      notifyListeners();
      return false;
    }

    if (product.stock < 0) {
      _error = 'El stock no puede ser negativo';
      notifyListeners();
      return false;
    }

    try {
      print('🔄 Agregando producto: ${product.name}');
      _products.add(product);
      
      final bool saved = await _saveProducts();
      
      if (saved) {
        _error = null;
        notifyListeners();
        print('✅ Producto agregado y guardado: ${product.name}');
        return true;
      } else {
        // Revertir cambio si no se guardó
        _products.removeLast();
        _error = 'No se pudo guardar el producto';
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('❌ Error al agregar producto: $e');
      _error = 'Error al agregar producto: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct(Product updatedProduct) async {
    if (updatedProduct.name.trim().isEmpty) {
      _error = 'El nombre del producto no puede estar vacío';
      notifyListeners();
      return false;
    }

    if (updatedProduct.price <= 0) {
      _error = 'El precio debe ser mayor a 0';
      notifyListeners();
      return false;
    }

    if (updatedProduct.stock < 0) {
      _error = 'El stock no puede ser negativo';
      notifyListeners();
      return false;
    }

    try {
      final index = _products.indexWhere((p) => p.id == updatedProduct.id);
      if (index != -1) {
        final oldProduct = _products[index];
        _products[index] = updatedProduct;
        
        final bool saved = await _saveProducts();
        
        if (saved) {
          _error = null;
          notifyListeners();
          return true;
        } else {
          // Revertir cambio
          _products[index] = oldProduct;
          _error = 'No se pudo guardar la actualización';
          notifyListeners();
          return false;
        }
      }
      return false;
    } catch (e) {
      _error = 'Error al actualizar producto: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        final removed = _products.removeAt(index);
        final bool saved = await _saveProducts();
        
        if (saved) {
          _error = null;
          notifyListeners();
          print('✅ Producto eliminado: ${removed.name}');
        } else {
          // Revertir
          _products.insert(index, removed);
          _error = 'No se pudo eliminar el producto';
          notifyListeners();
        }
      }
    } catch (e) {
      _error = 'Error al eliminar producto: $e';
      notifyListeners();
    }
  }

  Future<bool> updateStock(String productId, int newStock) async {
    try {
      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        final oldStock = _products[index].stock;
        _products[index] = _products[index].copyWith(stock: newStock);
        
        final bool saved = await _saveProducts();
        
        if (saved) {
          notifyListeners();
          return true;
        } else {
          // Revertir
          _products[index] = _products[index].copyWith(stock: oldStock);
          return false;
        }
      }
      return false;
    } catch (e) {
      _error = 'Error al actualizar stock: $e';
      notifyListeners();
      return false;
    }
  }

  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;
    
    final lowerQuery = query.toLowerCase();
    return _products.where((product) {
      return product.name.toLowerCase().contains(lowerQuery) ||
             product.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Forzar recarga completa
  Future<void> reload() async {
    _isInitialized = false;
    await loadProducts();
  }
}
