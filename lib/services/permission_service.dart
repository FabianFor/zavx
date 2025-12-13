import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import '../core/utils/app_logger.dart';

class PermissionService {
  /// 📖 LEER de la galería (para seleccionar imágenes)
  /// LÓGICA: API 33+ pide photos, API 23-32 pide storage.
  static Future<bool> requestStoragePermission() async {
    try {
      if (!Platform.isAndroid) return true;

      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;
      
      AppLogger.info('📱 Solicitando permisos de LECTURA para Android SDK: $sdkInt');

      // Android 13+ (API 33+) - READ_MEDIA_IMAGES
      if (sdkInt >= 33) {
        final status = await Permission.photos.request();
        AppLogger.info('📋 Permiso photos: $status');
        
        if (status.isPermanentlyDenied) {
          AppLogger.warning('⚠️ Permiso photos denegado permanentemente');
        }
        
        return status.isGranted;
      }
      
      // Android 6-12 (API 23-32) - READ_EXTERNAL_STORAGE
      else if (sdkInt >= 23) {
        final status = await Permission.storage.request();
        AppLogger.info('📋 Permiso storage: $status');
        
        if (status.isPermanentlyDenied) {
          AppLogger.warning('⚠️ Permiso storage denegado permanentemente');
        }
        
        return status.isGranted;
      }
      
      // Android < 6 - No necesita permisos runtime
      AppLogger.info('✅ Android < 6: No requiere permisos runtime');
      return true;
      
    } catch (e) {
      AppLogger.error('❌ Error al solicitar permisos de lectura', e);
      return false;
    }
  }

  /// 💾 GUARDAR en la galería (para boletas/facturas)
  static Future<bool> requestSaveToGalleryPermission() async {
    try {
      if (!Platform.isAndroid) return true;

      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;
      
      AppLogger.info('💾 Solicitando permisos de ESCRITURA para Android SDK: $sdkInt');

      // Android 13+ (API 33+)
      if (sdkInt >= 33) {
        final status = await Permission.photos.request();
        AppLogger.info('📋 Permiso photos (Guardar): $status');
        
        if (status.isPermanentlyDenied) {
          AppLogger.warning('⚠️ Permiso photos denegado permanentemente');
        }
        
        return status.isGranted;
      }
      
      // Android 6-12 (API 23-32)
      else if (sdkInt >= 23) {
        final status = await Permission.storage.request();
        AppLogger.info('📋 Permiso storage (Guardar): $status');
        
        if (status.isPermanentlyDenied) {
          AppLogger.warning('⚠️ Permiso storage denegado permanentemente');
        }
        
        return status.isGranted;
      }
      
      // Android < 6 - No necesita permisos runtime
      AppLogger.info('✅ Android < 6: No requiere permisos runtime');
      return true;
      
    } catch (e) {
      AppLogger.error('❌ Error al solicitar permisos de escritura', e);
      return false;
    }
  }

  /// 🔍 Verificar permiso de LECTURA (sin solicitarlo)
  static Future<bool> hasStoragePermission() async {
    try {
      if (!Platform.isAndroid) return true;

      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        return await Permission.photos.isGranted;
      } else if (sdkInt >= 23) {
        return await Permission.storage.isGranted;
      }
      
      return true;
      
    } catch (e) {
      AppLogger.error('❌ Error al verificar permisos de lectura', e);
      return false;
    }
  }

  /// 🔍 Verificar permiso de ESCRITURA (sin solicitarlo)
  static Future<bool> hasSaveToGalleryPermission() async {
    try {
      if (!Platform.isAndroid) return true;

      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      // Android 13+ chequea Permission.photos
      if (sdkInt >= 33) {
        return await Permission.photos.isGranted;
      }
      
      // Android 6-12 chequea Permission.storage
      else if (sdkInt >= 23) {
        return await Permission.storage.isGranted;
      }
      
      return true;
      
    } catch (e) {
      AppLogger.error('❌ Error al verificar permisos de escritura', e);
      return false;
    }
  }

  /// 🚫 Verificar si fue denegado permanentemente
  static Future<bool> isPermissionPermanentlyDenied() async {
    try {
      if (!Platform.isAndroid) return false;

      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      // API 33+ chequea photos
      if (sdkInt >= 33) {
        return await Permission.photos.isPermanentlyDenied;
      } 
      // API 23+ chequea storage
      else if (sdkInt >= 23) {
        return await Permission.storage.isPermanentlyDenied;
      }
      
      return false;
      
    } catch (e) {
      AppLogger.error('❌ Error al verificar si está permanentemente denegado', e);
      return false;
    }
  }

  /// ⚙️ Abrir configuración de la app
  static Future<bool> openSettings() async {
    try {
      final opened = await openAppSettings();
      if (opened) {
        AppLogger.info('✅ Configuración abierta correctamente');
      } else {
        AppLogger.warning('⚠️ No se pudo abrir la configuración');
      }
      return opened;
    } catch (e) {
      AppLogger.error('❌ Error al abrir configuración', e);
      return false;
    }
  }

  /// 📦 Solicitar TODOS los permisos necesarios de una vez
  static Future<Map<String, bool>> requestAllPermissions() async {
    final results = <String, bool>{};
    
    AppLogger.info('🔄 Solicitando todos los permisos...');
    
    results['read_storage'] = await requestStoragePermission();
    results['write_storage'] = await requestSaveToGalleryPermission();
    
    AppLogger.info('✅ Resultados de permisos: $results');
    
    return results;
  }

  /// 🎯 MÉTODO SIMPLE PARA USAR EN TU APP
  static Future<bool> requestPermissionForAction({
    required bool isReading, // true = leer imagen, false = guardar imagen
  }) async {
    if (isReading) {
      return await requestStoragePermission();
    } else {
      return await requestSaveToGalleryPermission();
    }
  }
}
