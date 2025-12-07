import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class AuthProvider extends ChangeNotifier {
  User? _usuarioActual;
  bool _isAuthenticated = false;
  Box<User>? _usersBox;

  User? get usuarioActual => _usuarioActual;
  bool get isAuthenticated => _isAuthenticated;
  bool get esAdmin => _usuarioActual?.esAdmin ?? false;
  bool get esUsuario => _usuarioActual?.esUsuario ?? false;

  // Inicializar el provider y crear admin por defecto
  Future<void> initialize() async {
    try {
      _usersBox = await Hive.openBox<User>('users');
      
      debugPrint('📦 Users box abierto. Usuarios: ${_usersBox!.length}');
      
      // Si no hay usuarios, crear admin por defecto
      if (_usersBox!.isEmpty) {
        await _crearAdminPorDefecto();
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error al inicializar AuthProvider: $e');
    }
  }

  // Crear admin por defecto (primera vez)
  Future<void> _crearAdminPorDefecto() async {
    try {
      final adminPorDefecto = User(
        id: 'admin_${DateTime.now().millisecondsSinceEpoch}',
        nombre: 'Administrador',
        rol: RolUsuario.admin,
        contrasena: null,
        fechaCreacion: DateTime.now(),
      );

      await _usersBox!.put(adminPorDefecto.id, adminPorDefecto);
      debugPrint('✅ Admin por defecto creado: ${adminPorDefecto.id}');
    } catch (e) {
      debugPrint('❌ Error al crear admin por defecto: $e');
    }
  }

  // Verificar si admin tiene contraseña configurada
  bool adminTieneContrasena() {
    final admin = _obtenerAdmin();
    final tieneContrasena = admin?.contrasena != null && admin!.contrasena!.isNotEmpty;
    debugPrint('🔍 Admin tiene contraseña: $tieneContrasena');
    return tieneContrasena;
  }

  // Obtener el usuario admin
  User? _obtenerAdmin() {
    try {
      final usuarios = _usersBox?.values.toList() ?? [];
      debugPrint('📋 Total usuarios en box: ${usuarios.length}');
      
      final admin = usuarios.firstWhere((u) => u.rol == RolUsuario.admin);
      debugPrint('👤 Admin encontrado: ${admin.id}, Contraseña: ${admin.contrasena != null ? "Configurada" : "No configurada"}');
      return admin;
    } catch (e) {
      debugPrint('❌ No se encontró admin: $e');
      return null;
    }
  }

  // Configurar contraseña de admin (primera vez)
  Future<bool> configurarContrasenaAdmin(String contrasena) async {
    try {
      debugPrint('🔐 Iniciando configuración de contraseña...');
      
      final admin = _obtenerAdmin();
      if (admin == null) {
        debugPrint('❌ No se encontró el admin');
        return false;
      }

      final contrasenaHash = _hashContrasena(contrasena);
      debugPrint('🔒 Hash generado: ${contrasenaHash.substring(0, 10)}...');
      
      // Crear nuevo admin con contraseña
      final adminActualizado = User(
        id: admin.id,
        nombre: admin.nombre,
        rol: admin.rol,
        contrasena: contrasenaHash,
        fechaCreacion: admin.fechaCreacion,
        ultimoAcceso: admin.ultimoAcceso,
      );
      
      await _usersBox!.put(admin.id, adminActualizado);
      
      // Verificar que se guardó
      final verificar = _usersBox!.get(admin.id);
      debugPrint('✅ Contraseña guardada. Verificación: ${verificar?.contrasena != null}');
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ Error al configurar contraseña: $e');
      return false;
    }
  }

  // Login como admin con contraseña
  Future<bool> loginAdmin(String contrasena) async {
    try {
      debugPrint('🔑 Intentando login admin...');
      
      final admin = _obtenerAdmin();
      if (admin == null) {
        debugPrint('❌ Admin no encontrado');
        return false;
      }
      
      if (admin.contrasena == null) {
        debugPrint('❌ Admin sin contraseña configurada');
        return false;
      }

      final contrasenaHash = _hashContrasena(contrasena);
      debugPrint('🔒 Hash ingresado: ${contrasenaHash.substring(0, 10)}...');
      debugPrint('🔒 Hash guardado: ${admin.contrasena!.substring(0, 10)}...');
      
      if (admin.contrasena == contrasenaHash) {
        _usuarioActual = User(
          id: admin.id,
          nombre: admin.nombre,
          rol: admin.rol,
          contrasena: admin.contrasena,
          fechaCreacion: admin.fechaCreacion,
          ultimoAcceso: DateTime.now(),
        );
        
        await _usersBox!.put(admin.id, _usuarioActual!);
        _isAuthenticated = true;
        notifyListeners();
        debugPrint('✅ Login exitoso');
        return true;
      }
      
      debugPrint('❌ Contraseña incorrecta');
      return false;
    } catch (e) {
      debugPrint('❌ Error en login admin: $e');
      return false;
    }
  }

  // Login como usuario (sin contraseña)
  Future<bool> loginUsuario() async {
    try {
      debugPrint('👤 Iniciando login como usuario...');
      
      final usuarios = _usersBox?.values.toList() ?? [];
      User? usuario;
      
      try {
        usuario = usuarios.firstWhere((u) => u.rol == RolUsuario.usuario);
        debugPrint('✅ Usuario existente encontrado');
      } catch (e) {
        debugPrint('📝 Creando nuevo usuario...');
        usuario = User(
          id: 'usuario_${DateTime.now().millisecondsSinceEpoch}',
          nombre: 'Usuario',
          rol: RolUsuario.usuario,
          fechaCreacion: DateTime.now(),
        );
        await _usersBox!.put(usuario.id, usuario);
      }

      _usuarioActual = User(
        id: usuario.id,
        nombre: usuario.nombre,
        rol: usuario.rol,
        fechaCreacion: usuario.fechaCreacion,
        ultimoAcceso: DateTime.now(),
      );
      
      await _usersBox!.put(usuario.id, _usuarioActual!);
      _isAuthenticated = true;
      notifyListeners();
      debugPrint('✅ Login usuario exitoso');
      return true;
    } catch (e) {
      debugPrint('❌ Error en login usuario: $e');
      return false;
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    _usuarioActual = null;
    _isAuthenticated = false;
    notifyListeners();
    debugPrint('👋 Sesión cerrada');
  }

  // Cambiar contraseña del admin
  Future<bool> cambiarContrasenaAdmin(String contrasenaActual, String nuevaContrasena) async {
    try {
      final admin = _obtenerAdmin();
      if (admin == null) return false;

      final contrasenaActualHash = _hashContrasena(contrasenaActual);
      if (admin.contrasena != contrasenaActualHash) return false;

      final nuevaContrasenaHash = _hashContrasena(nuevaContrasena);
      final adminActualizado = User(
        id: admin.id,
        nombre: admin.nombre,
        rol: admin.rol,
        contrasena: nuevaContrasenaHash,
        fechaCreacion: admin.fechaCreacion,
        ultimoAcceso: admin.ultimoAcceso,
      );
      
      await _usersBox!.put(admin.id, adminActualizado);
      
      if (_usuarioActual?.id == admin.id) {
        _usuarioActual = adminActualizado;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ Error al cambiar contraseña: $e');
      return false;
    }
  }

  // Hash de contraseña
  String _hashContrasena(String contrasena) {
    final bytes = utf8.encode(contrasena);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Limpiar datos (para testing/reset)
  Future<void> resetearDatos() async {
    await _usersBox?.clear();
    await _crearAdminPorDefecto();
    await logout();
    debugPrint('🔄 Datos reseteados');
  }
}
