import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/utils/theme_helper.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ThemeHelper(context);
    final screenWidth = MediaQuery.of(context).size.width;
    
    // ✅ TAMAÑO FIJO PARA TODAS LAS PANTALLAS
    final bool isTablet = screenWidth > 600;
    final double fontSize = isTablet ? 20.sp : 18.sp;

    return AppBar(
      backgroundColor: theme.appBarBackground,
      foregroundColor: theme.appBarForeground,
      elevation: 2,
      toolbarHeight: 56.h, // ✅ ALTURA FIJA
      leading: showBackButton
          ? IconButton(
              icon: Icon(Icons.arrow_back, size: 24.sp),
              onPressed: onBackPressed ?? () => Navigator.pop(context),
            )
          : null,
      title: Text(
        title,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(56.h);
}
