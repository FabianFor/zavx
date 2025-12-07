// lib/screens/reports_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../core/utils/theme_helper.dart';
import '../providers/reports_provider.dart';
import '../providers/settings_provider.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = ThemeHelper(context);
    final reportsProvider = context.watch<ReportsProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: theme.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          '📊 ${l10n.statistics}',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: theme.appBarBackground,
        foregroundColor: theme.appBarForeground,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: ListView(
          padding: EdgeInsets.all(isTablet ? 20.w : 16.w),
          children: [
            // 💰 VENTAS
            Text(
              '💰 ${l10n.sales}',
              style: TextStyle(
                fontSize: isTablet ? 18.sp : 20.sp,
                fontWeight: FontWeight.bold,
                color: theme.textPrimary,
              ),
            ),
            SizedBox(height: 12.h),
            
            _buildSalesGrid(
              context,
              theme,
              settingsProvider,
              reportsProvider,
              l10n,
              isTablet,
            ),
            
            SizedBox(height: 24.h),

            // 📈 TOP PRODUCTOS
            Text(
              '📈 ${l10n.topProducts}',
              style: TextStyle(
                fontSize: isTablet ? 18.sp : 20.sp,
                fontWeight: FontWeight.bold,
                color: theme.textPrimary,
              ),
            ),
            SizedBox(height: 12.h),
            
            _buildTopProducts(
              context,
              theme,
              reportsProvider,
              l10n,
              isTablet,
            ),
            
            SizedBox(height: 24.h),

            // ⚠️ STOCK BAJO
            Text(
              '⚠️ ${l10n.stockAlerts}',
              style: TextStyle(
                fontSize: isTablet ? 18.sp : 20.sp,
                fontWeight: FontWeight.bold,
                color: theme.textPrimary,
              ),
            ),
            SizedBox(height: 12.h),
            
            _buildLowStockAlerts(
              context,
              theme,
              reportsProvider,
              l10n,
              isTablet,
            ),
            
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesGrid(
    BuildContext context,
    ThemeHelper theme,
    SettingsProvider settingsProvider,
    ReportsProvider reportsProvider,
    AppLocalizations l10n,
    bool isTablet,
  ) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12.w,
      mainAxisSpacing: 12.h,
      childAspectRatio: isTablet ? 1.6 : 1.3,
      children: [
        _buildSalesCard(
          '📅 ${l10n.today}',
          settingsProvider.formatPrice(reportsProvider.getSalesToday()),
          _getInvoicesCountText(l10n, reportsProvider.getInvoicesToday()),
          theme.success,
          theme,
          isTablet,
        ),
        _buildSalesCard(
          '📆 ${l10n.thisWeek}',
          settingsProvider.formatPrice(reportsProvider.getSalesThisWeek()),
          '',
          theme.primary,
          theme,
          isTablet,
        ),
        _buildSalesCard(
          '📊 ${l10n.thisMonth}',
          settingsProvider.formatPrice(reportsProvider.getSalesThisMonth()),
          '',
          const Color(0xFF9C27B0),
          theme,
          isTablet,
        ),
        _buildSalesCard(
          '💎 ${l10n.allTime}',
          settingsProvider.formatPrice(reportsProvider.getTotalSales()),
          '',
          const Color(0xFFFF9800),
          theme,
          isTablet,
        ),
      ],
    );
  }

  Widget _buildSalesCard(
    String title,
    String amount,
    String subtitle,
    Color color,
    ThemeHelper theme,
    bool isTablet,
  ) {
    return Card(
      color: theme.cardBackground,
      elevation: theme.isDark ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 14.w : 12.w,
          vertical: isTablet ? 16.h : 14.h,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: isTablet ? 13.sp : 14.sp,
                color: theme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8.h),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  amount,
                  style: TextStyle(
                    fontSize: isTablet ? 18.sp : 20.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  maxLines: 1,
                ),
              ),
            ),
            if (subtitle.isNotEmpty) ...[
              SizedBox(height: 4.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: theme.textHint,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTopProducts(
    BuildContext context,
    ThemeHelper theme,
    ReportsProvider reportsProvider,
    AppLocalizations l10n,
    bool isTablet,
  ) {
    final topProducts = reportsProvider.getTopProducts();

    if (topProducts.isEmpty) {
      return Card(
        color: theme.cardBackground,
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Center(
            child: Text(
              l10n.noSalesRecorded,
              style: TextStyle(
                color: theme.textSecondary,
                fontSize: 14.sp,
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      color: theme.cardBackground,
      elevation: theme.isDark ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 14.w : 16.w),
        child: Column(
          children: List.generate(topProducts.length, (index) {
            final product = topProducts[index];
            final position = index + 1;
            
            return Padding(
              padding: EdgeInsets.only(bottom: index < topProducts.length - 1 ? 12.h : 0),
              child: Row(
                children: [
                  Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: _getPositionColor(position).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$position',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: _getPositionColor(position),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product['productName'],
                          style: TextStyle(
                            fontSize: isTablet ? 14.sp : 15.sp,
                            fontWeight: FontWeight.w600,
                            color: theme.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          _getUnitsSoldText(l10n, product['quantity']),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: theme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildLowStockAlerts(
    BuildContext context,
    ThemeHelper theme,
    ReportsProvider reportsProvider,
    AppLocalizations l10n,
    bool isTablet,
  ) {
    final lowStock = reportsProvider.getLowStockProducts();
    final outOfStock = reportsProvider.getOutOfStockProducts();

    if (lowStock.isEmpty && outOfStock.isEmpty) {
      return Card(
        color: theme.cardBackground,
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.check_circle, color: theme.success, size: 48.sp),
                SizedBox(height: 8.h),
                Text(
                  '✅ ${l10n.allGood}',
                  style: TextStyle(
                    color: theme.success,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  l10n.noLowStockProducts,
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        if (outOfStock.isNotEmpty) ...[
          Card(
            color: theme.error.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
              side: BorderSide(color: theme.error, width: 2),
            ),
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 14.w : 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.error, color: theme.error, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        _getStockAlertText(l10n, outOfStock.length, true),
                        style: TextStyle(
                          fontSize: isTablet ? 15.sp : 16.sp,
                          fontWeight: FontWeight.bold,
                          color: theme.error,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  ...outOfStock.map((product) => Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: Row(
                          children: [
                            Icon(Icons.inventory_2, color: theme.error, size: 18.sp),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                product['name'],
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: theme.textPrimary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
        ],

        if (lowStock.isNotEmpty)
          Card(
            color: Colors.orange.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
              side: BorderSide(color: Colors.orange, width: 2),
            ),
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 14.w : 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        _getStockAlertText(l10n, lowStock.length, false),
                        style: TextStyle(
                          fontSize: isTablet ? 15.sp : 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  ...lowStock.map((product) => Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                '${product['stock']}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                product['name'],
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: theme.textPrimary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Color _getPositionColor(int position) {
    switch (position) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return Colors.blue;
    }
  }

  String _getInvoicesCountText(AppLocalizations l10n, int count) {
    switch (l10n.localeName) {
      case 'es':
        return '$count factura${count != 1 ? 's' : ''}';
      case 'en':
        return '$count invoice${count != 1 ? 's' : ''}';
      case 'pt':
        return '$count fatura${count != 1 ? 's' : ''}';
      case 'zh':
        return '$count 张发票';
      default:
        return '$count invoice(s)';
    }
  }

  String _getUnitsSoldText(AppLocalizations l10n, int count) {
    switch (l10n.localeName) {
      case 'es':
        return '$count unidad${count != 1 ? 'es' : ''} vendida${count != 1 ? 's' : ''}';
      case 'en':
        return '$count unit${count != 1 ? 's' : ''} sold';
      case 'pt':
        return '$count unidade${count != 1 ? 's' : ''} vendida${count != 1 ? 's' : ''}';
      case 'zh':
        return '已售出 $count 件';
      default:
        return '$count units sold';
    }
  }

  String _getStockAlertText(AppLocalizations l10n, int count, bool isOutOfStock) {
    if (isOutOfStock) {
      switch (l10n.localeName) {
        case 'es':
          return 'Sin Stock ($count)';
        case 'en':
          return 'Out of Stock ($count)';
        case 'pt':
          return 'Sem Estoque ($count)';
        case 'zh':
          return '缺货 ($count)';
        default:
          return 'Out of Stock ($count)';
      }
    } else {
      switch (l10n.localeName) {
        case 'es':
          return 'Stock Bajo ($count)';
        case 'en':
          return 'Low Stock ($count)';
        case 'pt':
          return 'Estoque Baixo ($count)';
        case 'zh':
          return '库存不足 ($count)';
        default:
          return 'Low Stock ($count)';
      }
    }
  }
}
