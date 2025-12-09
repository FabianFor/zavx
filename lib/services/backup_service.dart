// lib/services/backup_service.dart
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:image/image.dart' as img;
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_filex/open_filex.dart'; // ✅ NUEVO
import '../models/product.dart';
import '../models/invoice.dart';

// ✅✅ CLASE PARA RESULTADOS DE BACKUP ✅✅
class BackupResult<T> {
  final bool success;
  final T? data;
  final String? filePath;
  final String? error;

  BackupResult.success({this.data, this.filePath})
      : success = true,
        error = null;

  BackupResult.error({required this.error})
      : success = false,
        data = null,
        filePath = null;
}

class BackupService {
  // Configuración
  static const int _maxImageWidth = 512;
  static const int _jpegQuality = 70;
  static const String _backupFolderName = 'Zavx_Backups';

  /// Solicita permisos de almacenamiento
  static Future<bool> requestStoragePermission() async {
    if (!Platform.isAndroid) return true;

    // Android 13+ (API 33+)
    if (await Permission.photos.isGranted || await Permission.videos.isGranted) {
      return true;
    }

    // Android 11-12 (API 30-32)
    if (await Permission.storage.isGranted) {
      return true;
    }

    // Android 11+ necesita MANAGE_EXTERNAL_STORAGE
    if (await Permission.manageExternalStorage.isGranted) {
      return true;
    }

    // Pedir permiso
    final status = await Permission.manageExternalStorage.request();
    
    if (status.isGranted) {
      return true;
    }

    // Si no otorga MANAGE_EXTERNAL_STORAGE, intentar con storage normal
    final storageStatus = await Permission.storage.request();
    return storageStatus.isGranted;
  }

  /// Obtiene la carpeta de backups (Downloads/Zavx_Backups)
  static Future<Directory?> getBackupDirectory() async {
    // Verificar y pedir permisos primero
    if (!await requestStoragePermission()) {
      print('❌ Permisos de almacenamiento denegados');
      return null;
    }

    Directory? directory;
    
    if (Platform.isAndroid) {
      // Intentar usar Downloads público
      try {
        directory = Directory('/storage/emulated/0/Download/$_backupFolderName');
        
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
        
        print('✅ Carpeta de backups: ${directory.path}');
      } catch (e) {
        print('⚠️ Error creando carpeta en Downloads, usando carpeta de app: $e');
        // Fallback a la carpeta de la app
        final appDir = await getApplicationDocumentsDirectory();
        directory = Directory('${appDir.path}/$_backupFolderName');
        
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
      }
    } else if (Platform.isIOS) {
      final appDir = await getApplicationDocumentsDirectory();
      directory = Directory('${appDir.path}/$_backupFolderName');
    } else {
      final appDir = await getApplicationDocumentsDirectory();
      directory = Directory('${appDir.path}/$_backupFolderName');
    }
    
    if (directory != null && !await directory.exists()) {
      await directory.create(recursive: true);
    }
    
    return directory;
  }

  /// Genera nombre de archivo de backup
  static String generateBackupFileName(String type) {
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    return 'zavx_${type}_$timestamp.json';
  }

  /// Comprime imagen a Base64 optimizado
  static Future<String?> compressImageToBase64(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      
      if (!await imageFile.exists()) return null;
      
      // Leer imagen original
      final bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);
      
      if (image == null) return null;
      
      // Redimensionar solo si es muy grande
      if (image.width > _maxImageWidth || image.height > _maxImageWidth) {
        image = img.copyResize(
          image,
          width: image.width > image.height ? _maxImageWidth : null,
          height: image.height > image.width ? _maxImageWidth : null,
        );
      }
      
      // Comprimir a JPEG
      final compressed = img.encodeJpg(image, quality: _jpegQuality);
      
      return base64Encode(compressed);
    } catch (e) {
      print('Error comprimiendo imagen: $e');
      return null;
    }
  }

  /// Guarda imagen de Base64 a archivo
  static Future<String?> saveBase64ToImage(
    String base64Image,
    String productId,
  ) async {
    try {
      final bytes = base64Decode(base64Image);
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/product_images');
      
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }
      
      final fileName = 'product_${productId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File('${imagesDir.path}/$fileName');
      await file.writeAsBytes(bytes);
      
      return file.path;
    } catch (e) {
      print('Error guardando imagen: $e');
      return null;
    }
  }

  /// Valida formato de backup
  static bool validateBackupFormat(Map<String, dynamic> data) {
    return data.containsKey('version') &&
           data.containsKey('backupType') &&
           data.containsKey('items') &&
           data['items'] is List;
  }

  /// Calcula tamaño estimado del backup
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // ✅✅✅ MÉTODOS PARA EXPORT/IMPORT ✅✅✅

  /// Exportar Productos
  static Future<BackupResult<List<Product>>> exportProducts(List<Product> products) async {
    try {
      final directory = await getBackupDirectory();
      
      if (directory == null) {
        return BackupResult.error(error: 'Permisos de almacenamiento denegados');
      }
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/products_backup_$timestamp.json';
      
      final jsonData = products.map((p) => p.toJson()).toList();
      final jsonString = jsonEncode(jsonData);
      
      final file = File(filePath);
      await file.writeAsString(jsonString);
      
      print('✅ Archivo guardado en: $filePath');
      
      return BackupResult.success(data: products, filePath: filePath);
    } catch (e) {
      print('❌ Error exportando: $e');
      return BackupResult.error(error: e.toString());
    }
  }

  /// Importar Productos
  static Future<BackupResult<List<Product>>> importProducts() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      
      if (result == null || result.files.isEmpty) {
        return BackupResult.error(error: 'No se seleccionó archivo');
      }
      
      final filePath = result.files.single.path;
      if (filePath == null) {
        return BackupResult.error(error: 'Ruta de archivo inválida');
      }
      
      final file = File(filePath);
      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString) as List;
      
      final products = jsonData.map((json) => Product.fromJson(json)).toList();
      
      return BackupResult.success(data: products, filePath: filePath);
    } catch (e) {
      print('❌ Error importando: $e');
      return BackupResult.error(error: e.toString());
    }
  }

  /// Exportar Invoices
  static Future<BackupResult<List<Invoice>>> exportInvoices(List<Invoice> invoices) async {
    try {
      final directory = await getBackupDirectory();
      
      if (directory == null) {
        return BackupResult.error(error: 'Permisos de almacenamiento denegados');
      }
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/invoices_backup_$timestamp.json';
      
      final jsonData = invoices.map((inv) => inv.toJson()).toList();
      final jsonString = jsonEncode(jsonData);
      
      final file = File(filePath);
      await file.writeAsString(jsonString);
      
      print('✅ Archivo guardado en: $filePath');
      
      return BackupResult.success(data: invoices, filePath: filePath);
    } catch (e) {
      print('❌ Error exportando: $e');
      return BackupResult.error(error: e.toString());
    }
  }

  /// Importar Invoices
  static Future<BackupResult<List<Invoice>>> importInvoices() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      
      if (result == null || result.files.isEmpty) {
        return BackupResult.error(error: 'No se seleccionó archivo');
      }
      
      final filePath = result.files.single.path;
      if (filePath == null) {
        return BackupResult.error(error: 'Ruta de archivo inválida');
      }
      
      final file = File(filePath);
      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString) as List;
      
      final invoices = jsonData.map((json) => Invoice.fromJson(json)).toList();
      
      return BackupResult.success(data: invoices, filePath: filePath);
    } catch (e) {
      print('❌ Error importando: $e');
      return BackupResult.error(error: e.toString());
    }
  }

  /// ✅✅ ABRIR ARCHIVO CON EL VISOR DEL SISTEMA ✅✅
  static Future<void> openFileLocation(String filePath) async {
    try {
      final result = await OpenFilex.open(filePath);
      print('📂 Resultado de abrir archivo: ${result.message}');
      
      if (result.type != ResultType.done) {
        print('⚠️ No se pudo abrir el archivo: ${result.message}');
      }
    } catch (e) {
      print('❌ Error al abrir archivo: $e');
    }
  }
}
