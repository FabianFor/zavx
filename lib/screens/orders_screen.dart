import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../l10n/app_localizations.dart';
import '../models/order.dart';
import '../models/invoice.dart';
import '../providers/order_provider.dart';
import '../providers/product_provider.dart';
import '../providers/invoice_provider.dart';
import '../providers/settings_provider.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedStatus = 'all';
  
  // Variables para crear pedido
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final Map<String, int> _cart = {}; // productId -> quantity
  String _productSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    super.dispose();
  }

  void _addToCart(String productId) {
    setState(() {
      _cart[productId] = (_cart[productId] ?? 0) + 1;
    });
  }

  void _removeFromCart(String productId) {
    setState(() {
      if (_cart[productId] != null) {
        if (_cart[productId]! > 1) {
          _cart[productId] = _cart[productId]! - 1;
        } else {
          _cart.remove(productId);
        }
      }
    });
  }

  double _calculateTotal(ProductProvider productProvider) {
    double total = 0;
    _cart.forEach((productId, quantity) {
      final product = productProvider.getProductById(productId);
      if (product != null) {
        total += product.price * quantity;
      }
    });
    return total;
  }

  Future<void> _createOrderAndInvoice() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Agrega al menos un producto al pedido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final productProvider = context.read<ProductProvider>();
    final orderProvider = context.read<OrderProvider>();
    final invoiceProvider = context.read<InvoiceProvider>();

    // Verificar stock
    for (var entry in _cart.entries) {
      final product = productProvider.getProductById(entry.key);
      if (product == null || product.stock < entry.value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Stock insuficiente para ${product?.name ?? "producto"}'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Crear items
    final items = <OrderItem>[];
    for (var entry in _cart.entries) {
      final product = productProvider.getProductById(entry.key)!;
      items.add(OrderItem(
        productId: product.id,
        productName: product.name,
        quantity: entry.value,
        price: product.price,
        total: product.price * entry.value,
      ));
    }

    final subtotal = _calculateTotal(productProvider);
    final tax = 0.0;
    final total = subtotal + tax;

    // Crear orden
    final order = Order(
      id: const Uuid().v4(),
      orderNumber: orderProvider.orders.length + 1,
      customerName: _customerNameController.text.trim(),
      customerPhone: _customerPhoneController.text.trim(),
      items: items,
      subtotal: subtotal,
      tax: tax,
      total: total,
      status: 'pending',
      createdAt: DateTime.now(),
    );

    // Crear boleta
    final invoice = Invoice(
      id: const Uuid().v4(),
      invoiceNumber: invoiceProvider.invoices.length + 1,
      customerName: _customerNameController.text.trim(),
      customerPhone: _customerPhoneController.text.trim(),
      items: items,
      createdAt: DateTime.now(),
      total: total,
    );

    // Guardar
    final orderSuccess = await orderProvider.addOrder(order);
    final invoiceSuccess = await invoiceProvider.addInvoice(invoice);

    if (orderSuccess && invoiceSuccess) {
      // Actualizar stock
      for (var entry in _cart.entries) {
        final product = productProvider.getProductById(entry.key)!;
        await productProvider.updateStock(
          product.id,
          product.stock - entry.value,
        );
      }

      if (mounted) {
        setState(() {
          _cart.clear();
          _customerNameController.clear();
          _customerPhoneController.clear();
          _productSearchQuery = '';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Pedido y boleta creados exitosamente'),
            backgroundColor: Colors.green,
          ),
        );

        // Cambiar a pestaña de historial
        _tabController.animateTo(1);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Error al crear pedido'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.orders),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.add_shopping_cart), text: 'Crear Pedido'),
            Tab(icon: Icon(Icons.list), text: 'Historial'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCreateOrderTab(isTablet),
          _buildHistoryTab(isTablet, l10n),
        ],
      ),
    );
  }

  // TAB 1: CREAR PEDIDO
  Widget _buildCreateOrderTab(bool isTablet) {
    final productProvider = context.watch<ProductProvider>();
    final settingsProvider = context.watch<SettingsProvider>();

    final filteredProducts = _productSearchQuery.isEmpty
        ? productProvider.products
        : productProvider.searchProducts(_productSearchQuery);

    return Column(
      children: [
        // Formulario de cliente
        Container(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          color: Colors.white,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _customerNameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre del Cliente *',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre es obligatorio';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _customerPhoneController,
                  decoration: InputDecoration(
                    labelText: 'Teléfono (opcional)',
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
        ),

        // Buscador de productos
        Padding(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          child: TextField(
            onChanged: (value) {
              setState(() {
                _productSearchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Buscar productos...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _productSearchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _productSearchQuery = '';
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),
        ),

        // Lista de productos
        Expanded(
          child: filteredProducts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: isTablet ? 100 : 80,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay productos disponibles',
                        style: TextStyle(
                          fontSize: isTablet ? 20 : 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 16),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    final inCart = _cart[product.id] ?? 0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // Imagen
                            Container(
                              width: isTablet ? 80 : 70,
                              height: isTablet ? 80 : 70,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: product.imagePath.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(product.imagePath),
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(
                                            Icons.broken_image,
                                            color: Colors.grey,
                                          );
                                        },
                                      ),
                                    )
                                  : const Icon(
                                      Icons.inventory_2,
                                      color: Colors.grey,
                                    ),
                            ),
                            const SizedBox(width: 12),

                            // Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: TextStyle(
                                      fontSize: isTablet ? 17 : 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    settingsProvider.formatPrice(product.price),
                                    style: TextStyle(
                                      fontSize: isTablet ? 18 : 16,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF4CAF50),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Stock: ${product.stock}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: product.stock <= 5
                                          ? Colors.red
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Controles
                            if (inCart > 0)
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2196F3).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      onPressed: () => _removeFromCart(product.id),
                                      icon: const Icon(Icons.remove),
                                      color: const Color(0xFF2196F3),
                                      iconSize: 20,
                                    ),
                                    Text(
                                      '$inCart',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: inCart < product.stock
                                          ? () => _addToCart(product.id)
                                          : null,
                                      icon: const Icon(Icons.add),
                                      color: const Color(0xFF2196F3),
                                      iconSize: 20,
                                    ),
                                  ],
                                ),
                              )
                            else
                              ElevatedButton.icon(
                                onPressed: product.stock > 0
                                    ? () => _addToCart(product.id)
                                    : null,
                                icon: const Icon(Icons.add_shopping_cart, size: 18),
                                label: const Text('Agregar'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2196F3),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),

        // Resumen y botón
        if (_cart.isNotEmpty)
          Container(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total (${_cart.values.fold(0, (sum, qty) => sum + qty)} items):',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      settingsProvider.formatPrice(
                        _calculateTotal(productProvider),
                      ),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _cart.clear();
                          });
                        },
                        icon: const Icon(Icons.clear),
                        label: const Text('Limpiar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _createOrderAndInvoice,
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Crear Pedido'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  // TAB 2: HISTORIAL
  Widget _buildHistoryTab(bool isTablet, AppLocalizations l10n) {
    final orderProvider = context.watch<OrderProvider>();
    final settingsProvider = context.watch<SettingsProvider>();

    List<Order> filteredOrders = orderProvider.orders;

    if (_searchQuery.isNotEmpty) {
      filteredOrders = orderProvider.searchOrders(_searchQuery);
    }

    if (_selectedStatus != 'all') {
      filteredOrders = filteredOrders
          .where((o) => o.status == _selectedStatus)
          .toList();
    }

    return Column(
      children: [
        // Barra de búsqueda
        Container(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Buscar pedidos...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              PopupMenuButton<String>(
                icon: const Icon(Icons.filter_list),
                onSelected: (value) {
                  setState(() {
                    _selectedStatus = value;
                  });
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'all', child: Text('Todos')),
                  const PopupMenuItem(value: 'pending', child: Text('Pendientes')),
                  const PopupMenuItem(value: 'completed', child: Text('Completados')),
                ],
              ),
            ],
          ),
        ),

        // Lista de pedidos
        Expanded(
          child: filteredOrders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: isTablet ? 100 : 80,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay pedidos',
                        style: TextStyle(
                          fontSize: isTablet ? 20 : 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(isTablet ? 20 : 16),
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          'Pedido #${order.orderNumber}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2196F3),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              order.customerName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: order.status == 'pending'
                                    ? Colors.orange.withOpacity(0.2)
                                    : Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                order.status == 'pending' ? 'Pendiente' : 'Completado',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: order.status == 'pending'
                                      ? Colors.orange[800]
                                      : Colors.green[800],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              settingsProvider.formatPrice(order.total),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4CAF50),
                              ),
                            ),
                          ],
                        ),
                        onTap: () => _showOrderDetails(order, settingsProvider),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showOrderDetails(Order order, SettingsProvider settingsProvider) {
    final screenHeight = MediaQuery.of(context).size.height;
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: screenHeight * 0.85,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pedido #${order.orderNumber}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: order.status == 'pending'
                            ? Colors.orange.withOpacity(0.2)
                            : Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        order.status == 'pending' ? 'Pendiente' : 'Completado',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: order.status == 'pending'
                              ? Colors.orange[800]
                              : Colors.green[800],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      order.customerName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (order.customerPhone.isNotEmpty)
                      Text(
                        order.customerPhone,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt),
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Productos:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ...order.items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${item.productName} x${item.quantity}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            Text(
                              settingsProvider.formatPrice(item.total),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    const Divider(height: 32, thickness: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          settingsProvider.formatPrice(order.total),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (order.status == 'pending')
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await orderProvider.updateOrderStatus(order.id, 'completed');
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Pedido completado'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Marcar como Completado'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}