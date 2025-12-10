import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../l10n/app_localizations.dart';
import '../core/utils/theme_helper.dart';
import '../screens/login_screen.dart';

class RoleSelector extends StatelessWidget {
  const RoleSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeHelper(context);
    final authProvider = context.watch<AuthProvider>();
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: theme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: theme.primary.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: () => _showRoleMenu(context, theme, l10n, authProvider),
        borderRadius: BorderRadius.circular(20.r),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              authProvider.esAdmin ? Icons.admin_panel_settings : Icons.person,
              color: theme.primary,
              size: 18.sp,
            ),
            SizedBox(width: 6.w),
            Text(
              authProvider.esAdmin ? l10n.admin : l10n.user,
              style: TextStyle(
                color: theme.primary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.arrow_drop_down,
              color: theme.primary,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  void _showRoleMenu(
    BuildContext context,
    ThemeHelper theme,
    AppLocalizations l10n,
    AuthProvider authProvider,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) => Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 20.h),
              decoration: BoxDecoration(
                color: theme.textHint.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),

            Text(
              l10n.selectRole,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: theme.textPrimary,
              ),
            ),
            SizedBox(height: 20.h),

            _buildMenuItem(
              context: ctx,
              icon: Icons.logout,
              iconColor: theme.error,
              title: l10n.logout,
              subtitle: l10n.logoutSubtitle,
              onTap: () {
                Navigator.pop(ctx);
                _confirmLogout(context, theme, l10n, authProvider);
              },
              theme: theme,
            ),

            SizedBox(height: 12.h),

            if (authProvider.esAdmin)
              _buildMenuItem(
                context: ctx,
                icon: Icons.person,
                iconColor: theme.info,
                title: l10n.switchToUser,
                subtitle: l10n.switchToUserSubtitle,
                onTap: () {
                  Navigator.pop(ctx);
                  _switchToUser(context, theme, l10n, authProvider);
                },
                theme: theme,
              ),

            if (authProvider.esUsuario)
              _buildMenuItem(
                context: ctx,
                icon: Icons.admin_panel_settings,
                iconColor: theme.warning,
                title: l10n.switchToAdmin,
                subtitle: l10n.switchToAdminSubtitle,
                onTap: () {
                  Navigator.pop(ctx);
                  _switchToAdmin(context, theme, l10n, authProvider);
                },
                theme: theme,
              ),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required ThemeHelper theme,
  }) {
    return Material(
      color: theme.cardBackground,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            border: Border.all(
              color: iconColor.withOpacity(0.2),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: iconColor, size: 24.sp),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: theme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: theme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: theme.iconColor,
                size: 18.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(
    BuildContext context,
    ThemeHelper theme,
    AppLocalizations l10n,
    AuthProvider authProvider,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          l10n.logout,
          style: TextStyle(color: theme.textPrimary),
        ),
        content: Text(
          l10n.logoutConfirmMessage,
          style: TextStyle(color: theme.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: theme.error),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await authProvider.logout();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _switchToUser(
    BuildContext context,
    ThemeHelper theme,
    AppLocalizations l10n,
    AuthProvider authProvider,
  ) async {
    await authProvider.logout();
    if (context.mounted) {
      await authProvider.loginUsuario();
    }
  }

  Future<void> _switchToAdmin(
    BuildContext context,
    ThemeHelper theme,
    AppLocalizations l10n,
    AuthProvider authProvider,
  ) async {
    await authProvider.logout();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }
}
