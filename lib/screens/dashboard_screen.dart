import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/business_provider.dart';
import '../providers/product_provider.dart';
import '../providers/order_provider.dart';
import '../providers/invoice_provider.dart';
import '../providers/settings_provider.dart';
import 'products_screen.dart';
import 'orders_screen.dart';
import 'invoices_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final businessProvider = context.watch<BusinessProvider>();
    final productProvider = context.watch<ProductProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final invoiceProvider = context.watch<InvoiceProvider>();
    final settingsProvider = context.watch<SettingsProvider>();

    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final isLargeTablet = screenWidth >= 900;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header con gradiente
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isTablet ? 32 : 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      businessProvider.profile.businessName.isEmpty
                          ? 'MiNegocio'
                          : businessProvider.profile.businessName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isLargeTablet ? 32 : (isTablet ? 28 : 24),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      l10n.businessManagement,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: isTablet ? 16 : 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Contenido principal
              Padding(
                padding: EdgeInsets.all(isTablet ? 32 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    Text(
                      'Panel de Control',
                      style: TextStyle(
                        fontSize: isLargeTablet ? 32 : (isTablet ? 28 : 24),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: isTablet ? 32 : 24),

                    // Estadísticas en Grid
                    _buildStatsGrid(
                      context,
                      productProvider,
                      orderProvider,
                      invoiceProvider,
                      settingsProvider,
                      l10n,
                      isTablet,
                      isLargeTablet,
                    ),

                    SizedBox(height: isTablet ? 40 : 32),

                    // Accesos rápidos
                    Text(
                      'Accesos Rápidos',
                      style: TextStyle(
                        fontSize: isLargeTablet ? 24 : (isTablet ? 22 : 20),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),

                    _buildQuickAccessGrid(
                      context,
                      l10n,
                      isTablet,
                      isLargeTablet,
                    ),

                    // Alerta de stock bajo
                    if (productProvider.lowStockProducts.isNotEmpty) ...[
                      SizedBox(height: isTablet ? 40 : 32),
                      _buildLowStockAlert(
                        context,
                        productProvider,
                        l10n,
                        isTablet,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(
    BuildContext context,
    ProductProvider productProvider,
    OrderProvider orderProvider,
    InvoiceProvider invoiceProvider,
    SettingsProvider settingsProvider,
    AppLocalizations l10n,
    bool isTablet,
    bool isLargeTablet,
  ) {
    final stats = [
      {
        'title': l10n.productsRegistered,
        'value': '${productProvider.totalProducts}',
        'icon': Icons.inventory_2,
        'color': const Color(0xFF4CAF50),
      },
      {
        'title': l10n.ordersPlaced,
        'value': '${orderProvider.totalOrders}',
        'icon': Icons.shopping_cart,
        'color': const Color(0xFF2196F3),
      },
      {
        'title': l10n.invoices,
        'value': '${invoiceProvider.totalInvoices}',
        'icon': Icons.receipt_long,
        'color': const Color(0xFFFF9800),
      },
      {
        'title': l10n.totalRevenue,
        'value': settingsProvider.formatPrice(invoiceProvider.totalRevenue),
        'icon': Icons.attach_money,
        'color': const Color(0xFF9C27B0),
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Determinar número de columnas según ancho
        int crossAxisCount;
        double childAspectRatio;
        
        if (constraints.maxWidth > 1200) {
          crossAxisCount = 4;
          childAspectRatio = 1.4;
        } else if (constraints.maxWidth > 900) {
          crossAxisCount = 4;
          childAspectRatio = 1.2;
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 2;
          childAspectRatio = 1.5;
        } else {
          crossAxisCount = 1;
          childAspectRatio = 2.5;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: isTablet ? 20 : 16,
            mainAxisSpacing: isTablet ? 20 : 16,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final stat = stats[index];
            return _buildStatCard(
              title: stat['title'] as String,
              value: stat['value'] as String,
              icon: stat['icon'] as IconData,
              color: stat['color'] as Color,
              isTablet: isTablet,
              isLargeTablet: isLargeTablet,
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isTablet,
    required bool isLargeTablet,
  }) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 12 : 10),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: isLargeTablet ? 32 : (isTablet ? 28 : 24),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: isTablet ? 15 : 13,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: isLargeTablet ? 28 : (isTablet ? 24 : 22),
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.fade,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessGrid(
    BuildContext context,
    AppLocalizations l10n,
    bool isTablet,
    bool isLargeTablet,
  ) {
    final quickActions = [
      {
        'icon': Icons.inventory_2,
        'label': l10n.products,
        'color': const Color(0xFF4CAF50),
        'route': const ProductsScreen(),
      },
      {
        'icon': Icons.shopping_cart,
        'label': l10n.orders,
        'color': const Color(0xFF2196F3),
        'route': const OrdersScreen(),
      },
      {
        'icon': Icons.receipt_long,
        'label': l10n.invoices,
        'color': const Color(0xFFFF9800),
        'route': const InvoicesScreen(),
      },
      {
        'icon': Icons.settings,
        'label': l10n.settings,
        'color': const Color(0xFF607D8B),
        'route': const SettingsScreen(),
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) {
          // Grid para tablets grandes
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 3.5,
            ),
            itemCount: quickActions.length,
            itemBuilder: (context, index) {
              final action = quickActions[index];
              return _buildQuickAccessButton(
                context: context,
                icon: action['icon'] as IconData,
                label: action['label'] as String,
                color: action['color'] as Color,
                route: action['route'] as Widget,
                isTablet: isTablet,
                isLargeTablet: isLargeTablet,
              );
            },
          );
        } else {
          // Lista vertical para móviles y tablets pequeñas
          return Column(
            children: quickActions.map((action) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildQuickAccessButton(
                  context: context,
                  icon: action['icon'] as IconData,
                  label: action['label'] as String,
                  color: action['color'] as Color,
                  route: action['route'] as Widget,
                  isTablet: isTablet,
                  isLargeTablet: isLargeTablet,
                ),
              );
            }).toList(),
          );
        }
      },
    );
  }

  Widget _buildQuickAccessButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required Widget route,
    required bool isTablet,
    required bool isLargeTablet,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => route),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(isTablet ? 18 : 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3), width: 2),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 14 : 12),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: isLargeTablet ? 32 : (isTablet ? 28 : 24),
                ),
              ),
              SizedBox(width: isTablet ? 18 : 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: isLargeTablet ? 20 : (isTablet ? 18 : 16),
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: color,
                size: isTablet ? 22 : 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLowStockAlert(
    BuildContext context,
    ProductProvider productProvider,
    AppLocalizations l10n,
    bool isTablet,
  ) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: isTablet ? 28 : 24,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Productos con stock bajo',
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[900],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ...productProvider.lowStockProducts.take(5).map((product) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      style: TextStyle(fontSize: isTablet ? 15 : 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    '${l10n.stock}: ${product.stock}',
                    style: TextStyle(
                      fontSize: isTablet ? 15 : 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}