// lib/providers/order_provider.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/order.dart';
import '../core/constants/validation_limits.dart';

class OrderProvider with ChangeNotifier {
  Box<Order>? _box;
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalOrders => _orders.length;

  List<Order> get pendingOrders =>
      _orders.where((o) => o.status == 'pending').toList();

  List<Order> get completedOrders =>
      _orders.where((o) => o.status == 'completed').toList();

  double get totalSales {
    return _orders
        .where((o) => o.status == 'completed')
        .fold(0.0, (sum, order) => sum + order.total);
  }

  @override
  void dispose() {
    _box?.close();
    super.dispose();
  }

  Future<void> loadOrders() async {
    if (_isInitialized) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _box = await Hive.openBox<Order>('orders');
      _orders = _box!.values.toList();
      _isInitialized = true;
    } catch (e) {
      _error = 'Error al cargar órdenes: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addOrder(Order order) async {
    if (order.customerName.trim().isEmpty || 
        order.customerName.trim().length < ValidationLimits.minCustomerNameLength) {
      _error = 'El nombre del cliente debe tener al menos ${ValidationLimits.minCustomerNameLength} caracteres';
      notifyListeners();
      return false;
    }

    if (order.items.isEmpty) {
      _error = 'La orden debe tener al menos un producto';
      notifyListeners();
      return false;
    }

    if (order.total <= 0) {
      _error = 'El total debe ser mayor a 0';
      notifyListeners();
      return false;
    }

    try {
      // Guardar en Hive
      await _box!.put(order.id, order);
      
      // Insertar al inicio de la lista
      _orders.insert(0, order);
      
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al agregar orden: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    try {
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index == -1) {
        _error = 'Orden no encontrada';
        notifyListeners();
        return false;
      }

      final updatedOrder = _orders[index].copyWith(status: newStatus);
      
      // Actualizar en Hive
      await _box!.put(orderId, updatedOrder);
      
      // Actualizar en memoria
      _orders[index] = updatedOrder;
      
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al actualizar estado: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index == -1) {
        _error = 'Orden no encontrada';
        notifyListeners();
        return;
      }

      // Eliminar de Hive
      await _box!.delete(orderId);
      
      // Eliminar de memoria
      _orders.removeAt(index);
      
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Error al eliminar orden: $e';
      notifyListeners();
    }
  }

  // ✅ BÚSQUEDA POR NOMBRE, NÚMERO Y TELÉFONO
  List<Order> searchOrders(String query) {
    if (query.isEmpty) return _orders;
    
    final lowerQuery = query.toLowerCase();
    return _orders.where((order) {
      return order.customerName.toLowerCase().contains(lowerQuery) ||
             order.orderNumber.toString().contains(query) ||
             order.customerPhone.contains(query);
    }).toList();
  }

  // ✅ BÚSQUEDA POR ID (instantánea)
  Order? getOrderById(String id) {
    return _box?.get(id);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
