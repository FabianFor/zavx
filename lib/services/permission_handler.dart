import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class AppPermissionHandler {
  static Future<bool> requestStoragePermission(BuildContext context) async {
    try {
      // Obtener versión de Android
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;
      
      print('📱 Android SDK: $sdkInt');
      
      PermissionStatus status;

      if (sdkInt >= 33) {
        // Android 13+ (API 33+)
        status = await Permission.photos.status;
        print('📋 Estado actual photos: $status');
        
        // ✅ SI YA ESTÁ CONCEDIDO, NO PEDIR DE NUEVO
        if (status.isGranted || status.isLimited) {
          print('✅ Permiso photos ya concedido');
          return true;
        }
        
        // Solo pedir si no está concedido
        status = await Permission.photos.request();
        print('📋 Nuevo estado photos: $status');
        
      } else if (sdkInt >= 30) {
        // Android 11-12 (API 30-32)
        status = await Permission.storage.status;
        print('📋 Estado actual storage: $status');
        
        // ✅ SI YA ESTÁ CONCEDIDO, NO PEDIR DE NUEVO
        if (status.isGranted) {
          print('✅ Permiso storage ya concedido');
          return true;
        }
        
        status = await Permission.storage.request();
        print('📋 Nuevo estado storage: $status');
        
      } else {
        // Android 10 y anteriores
        status = await Permission.storage.status;
        print('📋 Estado actual storage: $status');
        
        // ✅ SI YA ESTÁ CONCEDIDO, NO PEDIR DE NUEVO
        if (status.isGranted) {
          print('✅ Permiso storage ya concedido');
          return true;
        }
        
        status = await Permission.storage.request();
        print('📋 Nuevo estado storage: $status');
      }

      // Verificar si fue denegado permanentemente
      if (status.isPermanentlyDenied) {
        print('⚠️ Permiso denegado permanentemente');
        if (context.mounted) {
          _showPermissionDialog(context);
        }
        return false;
      }

      // Verificar si fue concedido
      if (status.isGranted || status.isLimited) {
        print('✅ Permiso concedido');
        return true;
      }

      // Si llegamos aquí, fue denegado pero no permanentemente
      if (status.isDenied) {
        print('❌ Permiso denegado (no permanente)');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ Necesitas dar permiso para seleccionar imágenes'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
        return false;
      }

      return false;
      
    } catch (e) {
      print('❌ Error al solicitar permisos: $e');
      
      // Fallback: intentar abrir galería sin permisos explícitos
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Intenta seleccionar la imagen de todos modos'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return true; // Intentar de todos modos
    }
  }

  static void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 12),
            Expanded(child: Text('Permisos necesarios')),
          ],
        ),
        content: const Text(
          'Esta app necesita acceso a tus fotos para agregar imágenes a los productos.\n\n'
          'Ve a:\n'
          'Configuración → Apps → MiNegocio → Permisos → Fotos y multimedia',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
            ),
            child: const Text('Abrir Configuración'),
          ),
        ],
      ),
    );
  }
}
