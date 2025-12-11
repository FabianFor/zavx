import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 🎯 Servicio para guardar archivos en almacenamiento público
/// - Imágenes de recibos → Galería (Pictures/Proion/Receipts)
/// - PDFs y backups → Documentos (Documents/Proion)
class GallerySaver {
  static const platform = MethodChannel('com.proion.zavx/media_store');

  /// 📥 Guardar archivo en almacenamiento público
  static Future<String> _saveFile({
    required File file,
    required String fileName,
    required String subfolder,
    required String mimeType,
  }) async {
    try {
      if (kDebugMode) {
        print('💾 Guardando: $fileName en $subfolder');
      }

      if (!await file.exists()) {
        throw Exception('Archivo no existe: ${file.path}');
      }

      final bytes = await file.readAsBytes();
      
      if (bytes.isEmpty) {
        throw Exception('Archivo vacío');
      }

      // Llamar al plugin nativo
      final String? savedPath = await platform.invokeMethod('saveToPublicStorage', {
        'fileName': fileName,
        'subfolder': subfolder,
        'mimeType': mimeType,
        'bytes': bytes,
      });

      if (savedPath == null || savedPath.isEmpty) {
        throw Exception('Error al guardar');
      }

      if (kDebugMode) {
        print('✅ Guardado: $savedPath');
      }

      return savedPath;
      
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error: $e');
        print('Stack: $stackTrace');
      }
      rethrow;
    }
  }

  /// 🖼️ Guardar IMAGEN de RECIBO
  /// Ruta: Pictures/Proion/Receipts/Recibo_XXX.png
  /// ✅ APARECE EN GALERÍA
  static Future<String> saveReceiptImage({
    required String tempFilePath,
    required int receiptNumber,
  }) async {
    try {
      if (kDebugMode) {
        print('🖼️ Guardando imagen de recibo #$receiptNumber');
      }

      final tempFile = File(tempFilePath);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'Recibo_${receiptNumber}_$timestamp.png';
      
      final savedPath = await _saveFile(
        file: tempFile,
        fileName: fileName,
        subfolder: 'Receipts', // ← Carpeta para recibos en Galería
        mimeType: 'image/png',
      );

      // Borrar archivo temporal
      try {
        await tempFile.delete();
        if (kDebugMode) {
          print('🗑️ Temporal eliminado');
        }
      } catch (e) {
        // No crítico
      }

      return savedPath;
      
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error guardando imagen de recibo: $e');
        print('Stack: $stackTrace');
      }
      rethrow;
    }
  }

  /// 📄 Guardar PDF de RECIBO
  /// Ruta: Documents/Proion/Documents/Recibo_XXX.pdf
  /// ✅ SOLO EN APP ARCHIVOS
  static Future<String> saveReceiptPDF({
    required String tempFilePath,
    required int receiptNumber,
  }) async {
    try {
      if (kDebugMode) {
        print('📄 Guardando PDF de recibo #$receiptNumber');
      }

      final tempFile = File(tempFilePath);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'Recibo_${receiptNumber}_$timestamp.pdf';
      
      final savedPath = await _saveFile(
        file: tempFile,
        fileName: fileName,
        subfolder: 'Documents', // ← Carpeta para PDFs
        mimeType: 'application/pdf',
      );

      // Borrar archivo temporal
      try {
        await tempFile.delete();
        if (kDebugMode) {
          print('🗑️ Temporal eliminado');
        }
      } catch (e) {
        // No crítico
      }

      return savedPath;
      
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error guardando PDF: $e');
        print('Stack: $stackTrace');
      }
      rethrow;
    }
  }

  /// 💾 Guardar BACKUP de base de datos
  /// Ruta: Documents/Proion/Backups/Backup_YYYY-MM-DD.db
  /// ✅ SOLO EN APP ARCHIVOS
  static Future<String> saveBackup(File dbFile) async {
    try {
      if (kDebugMode) {
        print('💾 Guardando backup');
      }

      final now = DateTime.now();
      final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}';
      final fileName = 'Backup_$dateStr.db';
      
      return await _saveFile(
        file: dbFile,
        fileName: fileName,
        subfolder: 'Backups', // ← Carpeta para backups
        mimeType: 'application/octet-stream',
      );
      
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error guardando backup: $e');
        print('Stack: $stackTrace');
      }
      rethrow;
    }
  }

  /// 📷 Guardar FOTO de PRODUCTO
  /// Ruta: Pictures/Proion/Products/Producto_XXX.png
  /// ✅ APARECE EN GALERÍA
  static Future<String> saveProductImage({
    required File imageFile,
    required String productName,
  }) async {
    try {
      if (kDebugMode) {
        print('📷 Guardando foto de producto: $productName');
      }

      final cleanName = productName
          .replaceAll(RegExp(r'[^\w\s-]'), '')
          .replaceAll(' ', '_')
          .substring(0, productName.length > 30 ? 30 : productName.length);
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'Producto_${cleanName}_$timestamp.png';
      
      return await _saveFile(
        file: imageFile,
        fileName: fileName,
        subfolder: 'Products', // ← Carpeta para productos en Galería
        mimeType: 'image/png',
      );
      
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error guardando foto de producto: $e');
        print('Stack: $stackTrace');
      }
      rethrow;
    }
  }

  /// 🏷️ Generar nombre de archivo (compatible con código viejo)
  @Deprecated('Usa saveReceiptImage() o saveReceiptPDF() directamente')
  static String generateFileName(int receiptNumber, {bool isPdf = false}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = isPdf ? 'pdf' : 'png';
    return 'Recibo_${receiptNumber}_$timestamp.$extension';
  }

  /// 💾 MÉTODO PRINCIPAL (compatible con código viejo)
  @Deprecated('Usa saveReceiptImage() para PNG o saveReceiptPDF() para PDF')
  static Future<String> saveInvoiceToGallery({
    required String tempFilePath,
    required int invoiceNumber,
    bool isPdf = false,
  }) async {
    if (isPdf) {
      return await saveReceiptPDF(
        tempFilePath: tempFilePath,
        receiptNumber: invoiceNumber,
      );
    } else {
      return await saveReceiptImage(
        tempFilePath: tempFilePath,
        receiptNumber: invoiceNumber,
      );
    }
  }
}
