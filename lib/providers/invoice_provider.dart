// lib/providers/invoice_provider.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/invoice.dart';
import '../core/constants/validation_limits.dart';

class InvoiceProvider with ChangeNotifier {
  Box<Invoice>? _box;
  List<Invoice> _invoices = [];
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  List<Invoice> get invoices => _invoices;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalRevenue {
    return _invoices.fold(0.0, (sum, invoice) => sum + invoice.total);
  }

  double get monthlyRevenue {
    final now = DateTime.now();
    return _invoices
        .where((invoice) =>
            invoice.createdAt.year == now.year &&
            invoice.createdAt.month == now.month)
        .fold(0.0, (sum, invoice) => sum + invoice.total);
  }

  int get totalInvoices => _invoices.length;

  @override
  void dispose() {
    _box?.close();
    super.dispose();
  }

  Future<void> loadInvoices() async {
    if (_isInitialized) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _box = await Hive.openBox<Invoice>('invoices');
      _invoices = _box!.values.toList();
      _isInitialized = true;
    } catch (e) {
      _error = 'Error al cargar facturas: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addInvoice(Invoice invoice) async {
    if (invoice.customerName.trim().isEmpty ||
        invoice.customerName.trim().length < ValidationLimits.minCustomerNameLength) {
      _error = 'El nombre del cliente debe tener al menos ${ValidationLimits.minCustomerNameLength} caracteres';
      notifyListeners();
      return false;
    }

    if (invoice.items.isEmpty) {
      _error = 'La factura debe tener al menos un producto';
      notifyListeners();
      return false;
    }

    if (invoice.total <= 0) {
      _error = 'El total debe ser mayor a 0';
      notifyListeners();
      return false;
    }

    try {
      // Guardar en Hive
      await _box!.put(invoice.id, invoice);
      
      // Insertar al inicio
      _invoices.insert(0, invoice);
      
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al agregar factura: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteInvoice(String invoiceId) async {
    try {
      final index = _invoices.indexWhere((inv) => inv.id == invoiceId);
      if (index == -1) {
        _error = 'Factura no encontrada';
        notifyListeners();
        return;
      }

      // Eliminar de Hive
      await _box!.delete(invoiceId);
      
      // Eliminar de memoria
      _invoices.removeAt(index);
      
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Error al eliminar factura: $e';
      notifyListeners();
    }
  }

  // ✅ BÚSQUEDA POR NOMBRE, NÚMERO Y TELÉFONO
  List<Invoice> searchInvoices(String query) {
    if (query.isEmpty) return _invoices;
    
    final lowerQuery = query.toLowerCase();
    return _invoices.where((invoice) {
      return invoice.customerName.toLowerCase().contains(lowerQuery) ||
             invoice.invoiceNumber.toString().contains(query) ||
             invoice.customerPhone.contains(query);
    }).toList();
  }

  // ✅ BÚSQUEDA POR ID (instantánea)
  Invoice? getInvoiceById(String id) {
    return _box?.get(id);
  }

  List<Invoice> getInvoicesByDateRange(DateTime start, DateTime end) {
    return _invoices.where((invoice) {
      return invoice.createdAt.isAfter(start) &&
             invoice.createdAt.isBefore(end);
    }).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
