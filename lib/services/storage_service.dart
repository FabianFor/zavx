import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Servicio para gestionar el almacenamiento organizado de la app
/// Estructura: /Proion/Invoices/ y /Proion/Backups/
class StorageService {
  static const String _appFolderName = 'Proion';
  static const String _invoicesFolderName = 'Invoices';
  static const String _backupsFolderName = 'Backups';

  /// Obtener el directorio base de la app
  static Future<Directory?> _getAppDirectory() async {
    try {
      if (Platform.isAndroid) {
        return await getExternalStorageDirectory();
      } else if (Platform.isIOS) {
        return await getApplicationDocumentsDirectory();
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error obteniendo directorio base: $e');
      return null;
    }
  }

  /// Crear la estructura de carpetas completa
  static Future<bool> initializeStorage() async {
    try {
      debugPrint('📁 Inicializando estructura de carpetas...');
      
      final baseDir = await _getAppDirectory();
      if (baseDir == null) {
        debugPrint('❌ No se pudo obtener directorio base');
        return false;
      }

      // Crear carpeta principal Proion
      final proionDir = Directory('${baseDir.path}/$_appFolderName');
      if (!await proionDir.exists()) {
        await proionDir.create(recursive: true);
        debugPrint('✅ Carpeta Proion creada: ${proionDir.path}');
      }

      // Crear subcarpeta Invoices
      final invoicesDir = Directory('${proionDir.path}/$_invoicesFolderName');
      if (!await invoicesDir.exists()) {
        await invoicesDir.create(recursive: true);
        debugPrint('✅ Carpeta Invoices creada: ${invoicesDir.path}');
      }

      // Crear subcarpeta Backups
      final backupsDir = Directory('${proionDir.path}/$_backupsFolderName');
      if (!await backupsDir.exists()) {
        await backupsDir.create(recursive: true);
        debugPrint('✅ Carpeta Backups creada: ${backupsDir.path}');
      }

      debugPrint('✅ Estructura de carpetas inicializada correctamente');
      return true;
    } catch (e) {
      debugPrint('❌ Error inicializando almacenamiento: $e');
      return false;
    }
  }

  /// Obtener la ruta completa de la carpeta Invoices
  static Future<String?> getInvoicesPath() async {
    try {
      final baseDir = await _getAppDirectory();
      if (baseDir == null) return null;
      
      final invoicesPath = '${baseDir.path}/$_appFolderName/$_invoicesFolderName';
      final invoicesDir = Directory(invoicesPath);
      
      if (!await invoicesDir.exists()) {
        await invoicesDir.create(recursive: true);
      }
      
      return invoicesPath;
    } catch (e) {
      debugPrint('❌ Error obteniendo ruta de Invoices: $e');
      return null;
    }
  }

  /// Obtener la ruta completa de la carpeta Backups
  static Future<String?> getBackupsPath() async {
    try {
      final baseDir = await _getAppDirectory();
      if (baseDir == null) return null;
      
      final backupsPath = '${baseDir.path}/$_appFolderName/$_backupsFolderName';
      final backupsDir = Directory(backupsPath);
      
      if (!await backupsDir.exists()) {
        await backupsDir.create(recursive: true);
      }
      
      return backupsPath;
    } catch (e) {
      debugPrint('❌ Error obteniendo ruta de Backups: $e');
      return null;
    }
  }

  /// Guardar una factura (PDF o imagen) en la carpeta Invoices
  static Future<String?> saveInvoice({
    required File file,
    required String fileName,
  }) async {
    try {
      final invoicesPath = await getInvoicesPath();
      if (invoicesPath == null) return null;

      final destinationPath = '$invoicesPath/$fileName';
      final savedFile = await file.copy(destinationPath);
      
      debugPrint('✅ Factura guardada: ${savedFile.path}');
      return savedFile.path;
    } catch (e) {
      debugPrint('❌ Error guardando factura: $e');
      return null;
    }
  }

  /// Guardar un backup en la carpeta Backups
  static Future<String?> saveBackup({
    required File file,
    required String fileName,
  }) async {
    try {
      final backupsPath = await getBackupsPath();
      if (backupsPath == null) return null;

      final destinationPath = '$backupsPath/$fileName';
      final savedFile = await file.copy(destinationPath);
      
      debugPrint('✅ Backup guardado: ${savedFile.path}');
      return savedFile.path;
    } catch (e) {
      debugPrint('❌ Error guardando backup: $e');
      return null;
    }
  }

  /// Listar todas las facturas guardadas
  static Future<List<FileSystemEntity>> listInvoices() async {
    try {
      final invoicesPath = await getInvoicesPath();
      if (invoicesPath == null) return [];

      final invoicesDir = Directory(invoicesPath);
      if (!await invoicesDir.exists()) return [];

      final files = invoicesDir.listSync()
        ..sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
      
      return files;
    } catch (e) {
      debugPrint('❌ Error listando facturas: $e');
      return [];
    }
  }

  /// Listar todos los backups guardados
  static Future<List<FileSystemEntity>> listBackups() async {
    try {
      final backupsPath = await getBackupsPath();
      if (backupsPath == null) return [];

      final backupsDir = Directory(backupsPath);
      if (!await backupsDir.exists()) return [];

      final files = backupsDir.listSync()
        ..sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
      
      return files;
    } catch (e) {
      debugPrint('❌ Error listando backups: $e');
      return [];
    }
  }

  /// Eliminar un archivo específico
  static Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('🗑️ Archivo eliminado: $filePath');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error eliminando archivo: $e');
      return false;
    }
  }

  /// Obtener el tamaño total de la carpeta Invoices (en MB)
  static Future<double> getInvoicesFolderSize() async {
    try {
      final files = await listInvoices();
      int totalBytes = 0;
      
      for (var file in files) {
        if (file is File) {
          totalBytes += await file.length();
        }
      }
      
      return totalBytes / (1024 * 1024);
    } catch (e) {
      debugPrint('❌ Error calculando tamaño de Invoices: $e');
      return 0.0;
    }
  }

  /// Obtener el tamaño total de la carpeta Backups (en MB)
  static Future<double> getBackupsFolderSize() async {
    try {
      final files = await listBackups();
      int totalBytes = 0;
      
      for (var file in files) {
        if (file is File) {
          totalBytes += await file.length();
        }
      }
      
      return totalBytes / (1024 * 1024);
    } catch (e) {
      debugPrint('❌ Error calculando tamaño de Backups: $e');
      return 0.0;
    }
  }

  /// Obtener información completa del almacenamiento
  static Future<Map<String, dynamic>> getStorageInfo() async {
    final invoicesSize = await getInvoicesFolderSize();
    final backupsSize = await getBackupsFolderSize();
    final invoicesCount = (await listInvoices()).length;
    final backupsCount = (await listBackups()).length;
    final invoicesPath = await getInvoicesPath();
    final backupsPath = await getBackupsPath();

    return {
      'invoices': {
        'path': invoicesPath,
        'size': invoicesSize,
        'count': invoicesCount,
      },
      'backups': {
        'path': backupsPath,
        'size': backupsSize,
        'count': backupsCount,
      },
      'total_size': invoicesSize + backupsSize,
    };
  }
}
