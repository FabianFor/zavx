import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import '../l10n/app_localizations.dart';

/// 🔒 Manejador de permisos compatible con Google Play Store
/// 
/// ✅ POLÍTICAS DE PLAY STORE:
/// - Android 10+ (API 29+): Usa MediaStore API SIN permisos
/// - Android 6-9 (API 23-28): Pide WRITE_EXTERNAL_STORAGE
/// - Android 5- (API < 23): Sin runtime permissions
/// 
/// ❌ NO USA permisos rechazados:
/// - MANAGE_EXTERNAL_STORAGE (solo para gestores de archivos)
/// - READ_MEDIA_* para GUARDAR (solo para LEER fotos del usuario)
/// 
/// 📌 MediaStore API (Android 10+) permite guardar en:
/// - Pictures/Proion/Receipts/ → Imágenes
/// - Documents/Proion/Documents/ → PDFs
/// - Documents/Proion/Backups/ → Backups
class AppPermissionHandler {
  
  static const String _tag = '🔒 Permissions';
  
  /// 📋 Solicitar permisos para GUARDAR archivos
  /// 
  /// Retorna true si la app puede guardar archivos en almacenamiento público
  /// 
  /// Estrategia por versión:
  /// - Android 10+: Siempre true (MediaStore sin permisos)
  /// - Android 6-9: Pide WRITE_EXTERNAL_STORAGE
  /// - Android 5-: Siempre true (permisos en instalación)
  static Future<bool> requestStoragePermission(BuildContext context) async {
    try {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;
      
      _log('📱 Android SDK: $sdkInt');
      
      // ==========================================
      // ✅ ANDROID 10+ (API 29+)
      // MediaStore API - SIN PERMISOS
      // ==========================================
      if (sdkInt >= 29) {
        _log('✅ Android 10+: MediaStore API sin permisos');
        return true;
      }
      
      // ==========================================
      // ⚠️ ANDROID 6-9 (API 23-28)
      // Requiere WRITE_EXTERNAL_STORAGE
      // ==========================================
      else if (sdkInt >= 23) {
        return await _requestLegacyStoragePermission(context);
      }
      
      // ==========================================
      // ✅ ANDROID 5- (API < 23)
      // Permisos en instalación
      // ==========================================
      else {
        _log('✅ Android < 6: Permisos en instalación');
        return true;
      }
      
    } catch (e, stackTrace) {
      _logError('Error solicitando permisos', e, stackTrace);
      
      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ ${l10n.error}: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return false;
    }
  }
  
  /// 📖 Solicitar permisos para LEER fotos del usuario
  /// 
  /// Usar solo cuando necesites acceder a fotos existentes:
  /// - Seleccionar logo del negocio
  /// - Adjuntar imágenes de productos
  /// 
  /// ⚠️ NO usar para guardar, solo para leer
  static Future<bool> requestMediaReadPermission(BuildContext context) async {
    try {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;
      
      _log('📱 Android SDK: $sdkInt (lectura de media)');
      
      // ==========================================
      // ANDROID 13+ (API 33+)
      // Usa READ_MEDIA_IMAGES
      // ==========================================
      if (sdkInt >= 33) {
        return await _requestPhotosPermission(context);
      }
      
      // ==========================================
      // ANDROID 6-12 (API 23-32)
      // Usa READ_EXTERNAL_STORAGE
      // ==========================================
      else if (sdkInt >= 23) {
        return await _requestLegacyStoragePermission(context);
      }
      
      // ==========================================
      // ANDROID 5- (API < 23)
      // ==========================================
      else {
        _log('✅ Android < 6: Permisos en instalación');
        return true;
      }
      
    } catch (e, stackTrace) {
      _logError('Error solicitando permisos de lectura', e, stackTrace);
      
      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ ${l10n.error}: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return false;
    }
  }
  
  // ═══════════════════════════════════════════════════════════════
  // IMPLEMENTACIONES INTERNAS
  // ═══════════════════════════════════════════════════════════════
  
  /// Android 13+ - READ_MEDIA_IMAGES
  static Future<bool> _requestPhotosPermission(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    _log('Verificando Permission.photos');
    
    PermissionStatus status = await Permission.photos.status;
    _log('Estado actual: $status');
    
    // Ya concedido
    if (status.isGranted || status.isLimited) {
      _log('✅ Permiso ya concedido');
      return true;
    }
    
    // Denegado permanentemente
    if (status.isPermanentlyDenied) {
      _log('⛔ Denegado permanentemente');
      if (context.mounted) {
        await _showSettingsDialog(
          context,
          title: l10n.photosAccessTitle,
          message: l10n.photosAccessMessage,
        );
      }
      return false;
    }
    
    // ✅ Pedir permiso directamente sin diálogo previo
    if (status.isDenied) {
      _log('Pidiendo permiso directamente...');
    }
    
    // Solicitar
    status = await Permission.photos.request();
    _log('Resultado: $status');
    
    if (status.isGranted || status.isLimited) {
      _log('✅ Permiso concedido');
      return true;
    }
    
    if (status.isPermanentlyDenied && context.mounted) {
      await _showSettingsDialog(
        context,
        title: l10n.permissionDeniedTitle,
        message: l10n.permissionDeniedMessage,
      );
    }
    
    return false;
  }
  
  /// Android 6-9 - WRITE_EXTERNAL_STORAGE
  static Future<bool> _requestLegacyStoragePermission(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    _log('Verificando Permission.storage');
    
    PermissionStatus status = await Permission.storage.status;
    _log('Estado actual: $status');
    
    // Ya concedido
    if (status.isGranted) {
      _log('✅ Permiso ya concedido');
      return true;
    }
    
    // Denegado permanentemente
    if (status.isPermanentlyDenied) {
      _log('⛔ Denegado permanentemente');
      if (context.mounted) {
        await _showSettingsDialog(
          context,
          title: l10n.storageAccessTitle,
          message: l10n.storageAccessMessage,
        );
      }
      return false;
    }
    
    // ✅ Pedir permiso directamente sin diálogo previo
    if (status.isDenied) {
      _log('Pidiendo permiso directamente...');
    }
    
    // Solicitar
    status = await Permission.storage.request();
    _log('Resultado: $status');
    
    if (status.isGranted) {
      _log('✅ Permiso concedido');
      return true;
    }
    
    if (status.isPermanentlyDenied && context.mounted) {
      await _showSettingsDialog(
        context,
        title: l10n.permissionDeniedTitle,
        message: l10n.permissionDeniedMessage,
      );
    }
    
    return false;
  }
  
  // ═══════════════════════════════════════════════════════════════
  // DIÁLOGOS
  // ═══════════════════════════════════════════════════════════════
  
  /// Diálogo para abrir configuración (solo cuando está denegado permanentemente)
  static Future<void> _showSettingsDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    final l10n = AppLocalizations.of(context)!;
    
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.settings, color: Colors.orange, size: 28),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 18))),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 14, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            icon: const Icon(Icons.settings, size: 18),
            label: Text(l10n.openSettings),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
  
  // ═══════════════════════════════════════════════════════════════
  // VERIFICACIONES (SIN SOLICITAR)
  // ═══════════════════════════════════════════════════════════════
  
  /// Verifica si puede guardar archivos (sin solicitar permiso)
  static Future<bool> hasStoragePermission() async {
    try {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;
      
      if (sdkInt >= 29) return true; // MediaStore sin permisos
      if (sdkInt >= 23) return await Permission.storage.isGranted;
      return true; // Android 5-
      
    } catch (e) {
      _logError('Error verificando permisos', e);
      return false;
    }
  }
  
  /// Verifica si puede leer fotos (sin solicitar permiso)
  static Future<bool> hasMediaReadPermission() async {
    try {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;
      
      if (sdkInt >= 33) {
        final status = await Permission.photos.status;
        return status.isGranted || status.isLimited;
      }
      
      if (sdkInt >= 23) return await Permission.storage.isGranted;
      return true;
      
    } catch (e) {
      _logError('Error verificando permisos de lectura', e);
      return false;
    }
  }
  
  // ═══════════════════════════════════════════════════════════════
  // LOGGING
  // ═══════════════════════════════════════════════════════════════
  
  static void _log(String message) {
    if (kDebugMode) print('$_tag $message');
  }
  
  static void _logError(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('$_tag ❌ $message');
      if (error != null) print('$_tag    Error: $error');
      if (stackTrace != null) print('$_tag    Stack: $stackTrace');
    }
  }
}
