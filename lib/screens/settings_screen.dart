import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';
import 'profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsProvider = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isLargeTablet = screenWidth > 900;
    
    // Ancho máximo para tablets
    final double maxWidth = isLargeTablet ? 900 : (isTablet ? 700 : double.infinity);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: isDark ? null : const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: ListView(
            padding: EdgeInsets.all(isTablet ? 24 : 16),
            children: [
              // MODO OSCURO
              _buildSettingCard(
                context: context,
                icon: settingsProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                iconColor: const Color(0xFF2196F3),
                title: _getDarkModeText(l10n),
                subtitle: _getDarkModeSubtitleText(l10n),
                trailing: Switch(
                  value: settingsProvider.isDarkMode,
                  onChanged: (value) => settingsProvider.toggleDarkMode(),
                  activeColor: const Color(0xFF2196F3),
                ),
                isTablet: isTablet,
              ),
              
              SizedBox(height: isTablet ? 20 : 16),

              // PERFIL DEL NEGOCIO
              _buildSettingCard(
                context: context,
                icon: Icons.store,
                iconColor: const Color(0xFF2196F3),
                title: l10n.businessProfile,
                subtitle: _getBusinessProfileSubtitleText(l10n),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ),
                isTablet: isTablet,
              ),

              SizedBox(height: isTablet ? 20 : 16),

              // IDIOMA
              _buildSettingCard(
                context: context,
                icon: Icons.language,
                iconColor: const Color(0xFF4CAF50),
                title: l10n.language,
                subtitle: '${settingsProvider.currentLanguageFlag} ${settingsProvider.currentLanguageName}',
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showLanguageDialog(context, isTablet),
                isTablet: isTablet,
              ),

              SizedBox(height: isTablet ? 20 : 16),

              // MONEDA
              _buildSettingCard(
                context: context,
                icon: Icons.attach_money,
                iconColor: const Color(0xFF9C27B0),
                title: l10n.currency,
                subtitle: '${settingsProvider.currentCurrencyFlag} ${settingsProvider.currentCurrencyName}',
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showCurrencyDialog(context, isTablet),
                isTablet: isTablet,
              ),

              SizedBox(height: isTablet ? 48 : 32),

              // INFO DE LA APP
              Center(
                child: Column(
                  children: [
                    Text(
                      'MiNegocio',
                      style: TextStyle(
                        fontSize: isTablet ? 22 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Versión 1.0.0',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
    required bool isTablet,
  }) {
    final fontSize = isTablet ? 18.0 : 16.0;
    final subtitleSize = isTablet ? 15.0 : 13.0;
    final iconSize = isTablet ? 32.0 : 28.0;
    final padding = isTablet ? 20.0 : 16.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: padding,
            vertical: padding * 0.75,
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 14 : 12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: iconSize,
                ),
              ),
              SizedBox(width: isTablet ? 20 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: subtitleSize,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12),
              trailing,
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, bool isTablet) {
    final l10n = AppLocalizations.of(context)!;
    final settingsProvider = context.read<SettingsProvider>();
    final screenHeight = MediaQuery.of(context).size.height;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isTablet ? 500 : 400,
            maxHeight: screenHeight * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(isTablet ? 24 : 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.language,
                      color: Colors.white,
                      size: isTablet ? 28 : 24,
                    ),
                    SizedBox(width: isTablet ? 16 : 12),
                    Expanded(
                      child: Text(
                        l10n.selectLanguage,
                        style: TextStyle(
                          fontSize: isTablet ? 22 : 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                      iconSize: isTablet ? 26 : 24,
                    ),
                  ],
                ),
              ),
              
              // Lista de idiomas
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: SettingsProvider.supportedLanguages.length,
                  itemBuilder: (context, index) {
                    final entry = SettingsProvider.supportedLanguages.entries.elementAt(index);
                    final isSelected = settingsProvider.locale.languageCode == entry.key;
                    
                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 28 : 24,
                        vertical: isTablet ? 12 : 8,
                      ),
                      leading: Text(
                        entry.value['flag']!,
                        style: TextStyle(fontSize: isTablet ? 32 : 28),
                      ),
                      title: Text(
                        entry.value['name']!,
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected 
                          ? Icon(
                              Icons.check_circle,
                              color: const Color(0xFF2196F3),
                              size: isTablet ? 28 : 24,
                            )
                          : null,
                      selected: isSelected,
                      selectedTileColor: const Color(0xFF2196F3).withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      onTap: () {
                        settingsProvider.setLanguage(entry.key);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context, bool isTablet) {
    final l10n = AppLocalizations.of(context)!;
    final settingsProvider = context.read<SettingsProvider>();
    final screenHeight = MediaQuery.of(context).size.height;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isTablet ? 600 : 450,
            maxHeight: screenHeight * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(isTablet ? 24 : 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF9C27B0),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      color: Colors.white,
                      size: isTablet ? 28 : 24,
                    ),
                    SizedBox(width: isTablet ? 16 : 12),
                    Expanded(
                      child: Text(
                        l10n.selectCurrency,
                        style: TextStyle(
                          fontSize: isTablet ? 22 : 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                      iconSize: isTablet ? 26 : 24,
                    ),
                  ],
                ),
              ),
              
              // Lista de monedas
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: SettingsProvider.supportedCurrencies.length,
                  itemBuilder: (context, index) {
                    final entry = SettingsProvider.supportedCurrencies.entries.elementAt(index);
                    final isSelected = settingsProvider.currencyCode == entry.key;
                    
                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 28 : 24,
                        vertical: isTablet ? 12 : 8,
                      ),
                      leading: Text(
                        entry.value['flag']!,
                        style: TextStyle(fontSize: isTablet ? 32 : 28),
                      ),
                      title: Text(
                        entry.value['name']!,
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        entry.value['symbol']!,
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      trailing: isSelected 
                          ? Icon(
                              Icons.check_circle,
                              color: const Color(0xFF9C27B0),
                              size: isTablet ? 28 : 24,
                            )
                          : null,
                      selected: isSelected,
                      selectedTileColor: const Color(0xFF9C27B0).withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      onTap: () {
                        settingsProvider.setCurrency(entry.key);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDarkModeText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es': return 'Modo oscuro';
      case 'en': return 'Dark mode';
      case 'pt': return 'Modo escuro';
      case 'zh': return '深色模式';
      default: return 'Dark mode';
    }
  }

  String _getDarkModeSubtitleText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es': return 'Activa el tema oscuro';
      case 'en': return 'Activate dark theme';
      case 'pt': return 'Ativar tema escuro';
      case 'zh': return '激活深色主题';
      default: return 'Activate dark theme';
    }
  }

  String _getBusinessProfileSubtitleText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es': return 'Edita la información de tu negocio';
      case 'en': return 'Edit your business information';
      case 'pt': return 'Edite as informações do seu negócio';
      case 'zh': return '编辑您的企业信息';
      default: return 'Edit your business information';
    }
  }
}