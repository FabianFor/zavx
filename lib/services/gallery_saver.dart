import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 🎯 Guarda archivos en DCIM/MiNegocio usando MediaStore (Android 10+)
class GallerySaver {
  static const platform = MethodChannel('com.example.mi_negocio_app/media_store');

  /// 📥 GUARDAR ARCHIVO EN DCIM (Compatible con TODAS las versiones)
  static Future<String> saveFileToGallery({
    required String tempFilePath,
    required String fileName,
  }) async {
    try {
      if (kDebugMode) {
        print('💾 [1/5] Iniciando guardado: $fileName');
      }
      
      final tempFile = File(tempFilePath);
      if (!await tempFile.exists()) {
        throw Exception('❌ Archivo temporal no existe: $tempFilePath');
      }

      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final sdkInt = androidInfo.version.sdkInt;
        
        if (kDebugMode) {
          print('📱 [2/5] Android SDK: $sdkInt');
        }

        // ✅ ANDROID 10+ (API 29+): Usar MediaStore
        if (sdkInt >= 29) {
          return await _saveUsingMediaStore(tempFilePath, fileName);
        }
        // ✅ ANDROID 9 y anteriores: Copiar directamente
        else {
          return await _saveUsingDirectCopy(tempFilePath, fileName);
        }
        
      } else {
        // iOS u otras plataformas
        final directory = await getApplicationDocumentsDirectory();
        final finalPath = '${directory.path}/$fileName';
        await tempFile.copy(finalPath);
        return finalPath;
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error al guardar en galería: $e');
        print('Stack trace: $stackTrace');
      }
      rethrow;
    }
  }

  /// 📱 ANDROID 10+ - Usar MediaStore API
  static Future<String> _saveUsingMediaStore(String tempFilePath, String fileName) async {
    try {
      if (kDebugMode) {
        print('📱 [3/5] Usando MediaStore API (Android 10+)');
      }

      final tempFile = File(tempFilePath);
      final bytes = await tempFile.readAsBytes();
      
      final isPdf = fileName.toLowerCase().endsWith('.pdf');
      final mimeType = isPdf ? 'application/pdf' : 'image/png';
      
      // Llamar al método nativo de Android
      final String? savedPath = await platform.invokeMethod('saveToMediaStore', {
        'fileName': fileName,
        'mimeType': mimeType,
        'bytes': bytes,
      });

      if (savedPath == null || savedPath.isEmpty) {
        throw Exception('MediaStore devolvió ruta vacía');
      }

      if (kDebugMode) {
        print('✅ [5/5] Guardado exitoso con MediaStore: $savedPath');
      }

      return savedPath;
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error en MediaStore: $e');
      }
      rethrow;
    }
  }

  /// 📁 ANDROID 6-9 - Copiar directamente a DCIM
  static Future<String> _saveUsingDirectCopy(String tempFilePath, String fileName) async {
    try {
      if (kDebugMode) {
        print('📁 [3/5] Usando copia directa (Android 6-9)');
      }

      final Directory? externalDir = await getExternalStorageDirectory();
      
      if (externalDir == null) {
        throw Exception('❌ No se pudo acceder al almacenamiento externo');
      }

      final String basePath = externalDir.path.split('/Android')[0];
      final String dcimFolderPath = '$basePath/DCIM/MiNegocio';
      
      if (kDebugMode) {
        print('📁 [4/5] Carpeta destino: $dcimFolderPath');
      }
      
      final Directory dcimFolder = Directory(dcimFolderPath);
      if (!await dcimFolder.exists()) {
        await dcimFolder.create(recursive: true);
      }

      final String finalFilePath = '$dcimFolderPath/$fileName';
      final tempFile = File(tempFilePath);
      
      await tempFile.copy(finalFilePath);
      
      if (kDebugMode) {
        print('✅ [5/5] Guardado exitoso en DCIM');
      }
      
      // Notificar al Media Scanner
      await _notifyMediaScanner(finalFilePath, dcimFolderPath);
      
      return finalFilePath;
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error en copia directa: $e');
      }
      rethrow;
    }
  }

  /// 📢 Notificar al Media Scanner (solo Android 6-9)
  static Future<void> _notifyMediaScanner(String filePath, String folderPath) async {
    try {
      if (!Platform.isAndroid) return;
      
      if (kDebugMode) {
        print('📷 Notificando al Media Scanner...');
      }
      
      await Process.run('am', [
        'broadcast',
        '-a',
        'android.intent.action.MEDIA_SCANNER_SCAN_FILE',
        '-d',
        'file://$filePath'
      ]);
      
    } catch (e) {
      // No crítico si falla
      if (kDebugMode) {
        print('⚠️ Media Scanner falló (no crítico): $e');
      }
    }
  }

  /// 🏷️ Generar nombre de archivo único
  static String generateFileName(int invoiceNumber, {bool isPdf = false}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = isPdf ? 'pdf' : 'png';
    return 'Boleta_${invoiceNumber}_$timestamp.$extension';
  }

  /// 💾 MÉTODO PRINCIPAL
  static Future<String> saveInvoiceToGallery({
    required String tempFilePath,
    required int invoiceNumber,
    bool isPdf = false,
  }) async {
    try {
      if (kDebugMode) {
        print('📥 Guardando boleta $invoiceNumber (${isPdf ? "PDF" : "PNG"})');
      }
      
      final fileName = generateFileName(invoiceNumber, isPdf: isPdf);
      
      final savedPath = await saveFileToGallery(
        tempFilePath: tempFilePath,
        fileName: fileName,
      );
      
      // Borrar archivo temporal
      try {
        await File(tempFilePath).delete();
        if (kDebugMode) {
          print('🗑️ Temporal eliminado');
        }
      } catch (e) {
        // No crítico
      }
      
      return savedPath;
      
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error en saveInvoiceToGallery: $e');
        print('Stack: $stackTrace');
      }
      rethrow;
    }
  }
}