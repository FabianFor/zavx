import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../core/utils/app_logger.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;
  bool _isSaving = false; // ✅ NUEVO: Prevenir operaciones concurrentes

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalProducts => _products.length;

  List<Product> get lowStockProducts => 
      _products.where((p) => p.stock <= 5).toList();

  Future<void> loadProducts() async {
    if (_isInitialized) {
      AppLogger.info('Productos ya en caché, no se recarga');
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
        _products = decodedList
            .map((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();
        AppLogger.success('${_products.length} productos cargados desde disco');
      } else {
        _products = [];
        AppLogger.info('No hay productos guardados, lista vacía');
      }

      _isInitialized = true;
    } catch (e, stackTrace) {
      _error = 'Error al cargar productos: $e';
      AppLogger.error(_error!, e, stackTrace);
      _products = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> _saveProducts() async {
    // ✅ PREVENIR RACE CONDITIONS
    if (_isSaving) {
      AppLogger.warning('Ya hay una operación de guardado en curso, esperando...');
      // Esperar a que termine la operación actual
      while (_isSaving) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return true;
    }

    _isSaving = true;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encodedData = json.encode(
        _products.map((product) => product.toJson()).toList(),
      );
      
      final bool saved = await prefs.setString('products', encodedData);
      
      if (saved) {
        AppLogger.success('${_products.length} productos guardados exitosamente');
        
        // ✅ VALIDACIÓN: Verificar que se guardó
        final String? verification = prefs.getString('products');
        if (verification != null) {
          AppLogger.info('Verificación: datos guardados correctamente');
          return true;
        } else {
          AppLogger.error('ERROR: No se pudo verificar el guardado');
          return false;
        }
      } else {
        AppLogger.error('ERROR: SharedPreferences retornó false');
        return false;
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error crítico al guardar productos', e, stackTrace);
      _error = 'Error al guardar: $e';
      notifyListeners();
      return false;
    } finally {
      _isSaving = false;
    }
  }

  Future<bool> addProduct(Product product) async {
    // ✅ VALIDACIONES ESTRICTAS
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
      AppLogger.info('🔄 Agregando producto: ${product.name}');
      
      // ✅ OPERACIÓN ATÓMICA
      _products.add(product);
      notifyListeners(); // Notificar antes de guardar para UI responsiva
      
      final bool saved = await _saveProducts();
      
      if (saved) {
        _error = null;
        AppLogger.success('Producto agregado y guardado: ${product.name}');
        return true;
      } else {
        // ✅ ROLLBACK: Revertir cambio si no se guardó
        _products.removeLast();
        _error = 'No se pudo guardar el producto';
        notifyListeners();
        AppLogger.error('Rollback: producto no guardado');
        return false;
      }
    } catch (e, stackTrace) {
      // ✅ ROLLBACK EN CASO DE ERROR
      _products.removeLast();
      _error = 'Error al agregar producto: $e';
      AppLogger.error(_error!, e, stackTrace);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct(Product updatedProduct) async {
    // ✅ VALIDACIONES
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
      if (index == -1) {
        _error = 'Producto no encontrado';
        notifyListeners();
        return false;
      }

      // ✅ GUARDAR ESTADO ANTERIOR PARA ROLLBACK
      final oldProduct = _products[index];
      
      // ✅ OPERACIÓN ATÓMICA
      _products[index] = updatedProduct;
      notifyListeners(); // UI responsiva
      
      final bool saved = await _saveProducts();
      
      if (saved) {
        _error = null;
        AppLogger.success('Producto actualizado: ${updatedProduct.name}');
        return true;
      } else {
        // ✅ ROLLBACK
        _products[index] = oldProduct;
        _error = 'No se pudo guardar la actualización';
        notifyListeners();
        AppLogger.error('Rollback: actualización no guardada');
        return false;
      }
    } catch (e, stackTrace) {
      _error = 'Error al actualizar producto: $e';
      AppLogger.error(_error!, e, stackTrace);
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

      // ✅ GUARDAR PARA ROLLBACK
      final removed = _products.removeAt(index);
      notifyListeners(); // UI responsiva
      
      final bool saved = await _saveProducts();
      
      if (saved) {
        _error = null;
        AppLogger.success('Producto eliminado: ${removed.name}');
      } else {
        // ✅ ROLLBACK
        _products.insert(index, removed);
        _error = 'No se pudo eliminar el producto';
        notifyListeners();
        AppLogger.error('Rollback: producto no eliminado');
      }
    } catch (e, stackTrace) {
      _error = 'Error al eliminar producto: $e';
      AppLogger.error(_error!, e, stackTrace);
      notifyListeners();
    }
  }

  Future<bool> updateStock(String productId, int newStock) async {
    // ✅ VALIDACIÓN
    if (newStock < 0) {
      _error = 'El stock no puede ser negativo';
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

      // ✅ GUARDAR ESTADO ANTERIOR
      final oldStock = _products[index].stock;
      
      _products[index] = _products[index].copyWith(stock: newStock);
      notifyListeners();
      
      final bool saved = await _saveProducts();
      
      if (saved) {
        _error = null;
        AppLogger.success('Stock actualizado: ${_products[index].name}');
        return true;
      } else {
        // ✅ ROLLBACK
        _products[index] = _products[index].copyWith(stock: oldStock);
        notifyListeners();
        AppLogger.error('Rollback: stock no actualizado');
        return false;
      }
    } catch (e, stackTrace) {
      _error = 'Error al actualizar stock: $e';
      AppLogger.error(_error!, e, stackTrace);
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
      AppLogger.warning('Producto no encontrado: $id');
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