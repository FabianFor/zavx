import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/business_provider.dart';
import '../providers/product_provider.dart';
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

    final screenWidth = MediaQuery.of(context).size.width;
    
    // Breakpoints mejorados
    final isVerySmall = screenWidth < 360;
    final isLarge = screenWidth >= 900;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: isVerySmall ? 20.h : (isLarge ? 40.h : 24.h),
                  horizontal: isVerySmall ? 16.w : (isLarge ? 40.w : 20.w),
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            businessProvider.profile.businessName.isEmpty
                                ? 'MiNegocio'
                                : businessProvider.profile.businessName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isVerySmall ? 20.sp : (isLarge ? 32.sp : 24.sp),
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            l10n.businessManagement,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: isVerySmall ? 12.sp : 14.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (productProvider.lowStockProducts.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isVerySmall ? 10.w : 12.w,
                          vertical: isVerySmall ? 6.h : 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.white,
                              size: isVerySmall ? 16.sp : 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              '${productProvider.lowStockProducts.length}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isVerySmall ? 14.sp : 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.all(isVerySmall ? 16.w : (isLarge ? 40.w : 20.w)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    Text(
                      'Inicio',
                      style: TextStyle(
                        fontSize: isVerySmall ? 24.sp : (isLarge ? 36.sp : 28.sp),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Gestiona rápidamente tu negocio desde aquí.',
                      style: TextStyle(
                        fontSize: isVerySmall ? 12.sp : 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),

                    SizedBox(height: isVerySmall ? 24.h : 32.h),

                    // Accesos rápidos
                    Text(
                      'Accesos rápidos',
                      style: TextStyle(
                        fontSize: isVerySmall ? 18.sp : (isLarge ? 26.sp : 20.sp),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Botones en grid para tablets, lista para móviles
                    if (isLarge)
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 20.w,
                        mainAxisSpacing: 20.h,
                        childAspectRatio: 3,
                        children: [
                          _buildQuickAccessButton(
                            context: context,
                            icon: Icons.inventory_2,
                            label: l10n.products,
                            color: const Color(0xFF4CAF50),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductsScreen())),
                          ),
                          _buildQuickAccessButton(
                            context: context,
                            icon: Icons.shopping_cart,
                            label: l10n.orders,
                            color: const Color(0xFF2196F3),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen())),
                          ),
                          _buildQuickAccessButton(
                            context: context,
                            icon: Icons.receipt_long,
                            label: l10n.invoices,
                            color: const Color(0xFFFF9800),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InvoicesScreen())),
                          ),
                          _buildQuickAccessButton(
                            context: context,
                            icon: Icons.settings,
                            label: l10n.settings,
                            color: const Color(0xFF607D8B),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          _buildQuickAccessButton(
                            context: context,
                            icon: Icons.inventory_2,
                            label: l10n.products,
                            color: const Color(0xFF4CAF50),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductsScreen())),
                          ),
                          SizedBox(height: 16.h),
                          _buildQuickAccessButton(
                            context: context,
                            icon: Icons.shopping_cart,
                            label: l10n.orders,
                            color: const Color(0xFF2196F3),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen())),
                          ),
                          SizedBox(height: 16.h),
                          _buildQuickAccessButton(
                            context: context,
                            icon: Icons.receipt_long,
                            label: l10n.invoices,
                            color: const Color(0xFFFF9800),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InvoicesScreen())),
                          ),
                          SizedBox(height: 16.h),
                          _buildQuickAccessButton(
                            context: context,
                            icon: Icons.settings,
                            label: l10n.settings,
                            color: const Color(0xFF607D8B),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                          ),
                        ],
                      ),

                    SizedBox(height: 32.h),

                    // Alerta de stock bajo
                    if (productProvider.lowStockProducts.isNotEmpty) ...[
                      Text(
                        'Productos con poco stock',
                        style: TextStyle(
                          fontSize: isVerySmall ? 16.sp : 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.warning_amber_rounded, color: Colors.red, size: isVerySmall ? 20.sp : 24.sp),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    'Productos con stock bajo',
                                    style: TextStyle(
                                      fontSize: isVerySmall ? 14.sp : 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red[900],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            ...productProvider.lowStockProducts.take(5).map((product) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: 8.h),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        product.name,
                                        style: TextStyle(fontSize: isVerySmall ? 12.sp : 14.sp),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      '${l10n.stock}: ${product.stock}',
                                      style: TextStyle(
                                        fontSize: isVerySmall ? 12.sp : 14.sp,
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
                      ),
                      SizedBox(height: 24.h),
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

  Widget _buildQuickAccessButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isVerySmall = screenWidth < 360;
    final isLarge = screenWidth >= 900;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(isVerySmall ? 14.w : 16.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: color.withOpacity(0.3), width: 2),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isVerySmall ? 10.w : 12.w),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: isVerySmall ? 24.sp : (isLarge ? 32.sp : 28.sp),
                ),
              ),
              SizedBox(width: isVerySmall ? 12.w : 16.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: isVerySmall ? 14.sp : (isLarge ? 20.sp : 18.sp),
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
                size: isVerySmall ? 16.sp : 20.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
