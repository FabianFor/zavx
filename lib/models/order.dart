import 'package:hive/hive.dart';
import '../core/utils/app_logger.dart';

part 'order.g.dart';

@HiveType(typeId: 1)
class Order {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final int orderNumber;
  
  @HiveField(2)
  final String customerName;
  
  @HiveField(3)
  final String customerPhone;
  
  @HiveField(4)
  final List<OrderItem> items;
  
  @HiveField(5)
  final double subtotal;
  
  @HiveField(6)
  final double tax;
  
  @HiveField(7)
  final double total;
  
  @HiveField(8)
  final String status;
  
  @HiveField(9)
  final DateTime createdAt;

  Order({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.customerPhone,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.status,
    required this.createdAt,
  }) {
    _validateIntegrity();
  }

  void _validateIntegrity() {
    final calculatedSubtotal = items.fold(0.0, (sum, item) => sum + item.total);
    
    if ((calculatedSubtotal - subtotal).abs() > 0.01) {
      AppLogger.warning(
        'INCONSISTENCIA: Subtotal esperado: $calculatedSubtotal, actual: $subtotal'
      );
    }
    
    final expectedTotal = subtotal + tax;
    if ((expectedTotal - total).abs() > 0.01) {
      AppLogger.warning(
        'INCONSISTENCIA: Total esperado: $expectedTotal, actual: $total'
      );
    }
    
    for (final item in items) {
      if (item.quantity <= 0) {
        AppLogger.error('ITEM INVÁLIDO: Cantidad debe ser > 0');
      }
      if (item.price < 0) {
        AppLogger.error('ITEM INVÁLIDO: Precio no puede ser negativo');
      }
      
      final expectedItemTotal = item.price * item.quantity;
      if ((expectedItemTotal - item.total).abs() > 0.01) {
        AppLogger.warning(
          'ITEM INCONSISTENTE: ${item.productName} - '
          'Total esperado: $expectedItemTotal, actual: ${item.total}'
        );
      }
    }
  }

  Order copyWith({
    String? id,
    int? orderNumber,
    String? customerName,
    String? customerPhone,
    List<OrderItem>? items,
    double? subtotal,
    double? tax,
    double? total,
    String? status,
    DateTime? createdAt,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

@HiveType(typeId: 2)
class OrderItem {
  @HiveField(0)
  final String productId;
  
  @HiveField(1)
  final String productName;
  
  @HiveField(2)
  final int quantity;
  
  @HiveField(3)
  final double price;
  
  @HiveField(4)
  final double total;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.total,
  }) {
    if (quantity <= 0) {
      throw ArgumentError('Quantity must be > 0');
    }
    if (price < 0) {
      throw ArgumentError('Price cannot be negative');
    }
    
    final expectedTotal = price * quantity;
    if ((expectedTotal - total).abs() > 0.01) {
      AppLogger.warning(
        'OrderItem total mismatch: expected $expectedTotal, got $total'
      );
    }
  }

  OrderItem copyWith({
    String? productId,
    String? productName,
    int? quantity,
    double? price,
    double? total,
  }) {
    return OrderItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      total: total ?? this.total,
    );
  }
}
