import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  Box<User>? _box;
  User? _currentUser;
  bool _isInitialized = false;
  
  // Contraseña por defecto del admin
  static const String _defaultAdminPassword = 'admin123';

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isEmployee => _currentUser?.isEmployee ?? false;

  // Inicializar
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _box = await Hive.openBox<User>('users');
      
      // Crear admin inicial si no existe
      if (_box!.isEmpty) {
        await _createInitialAdmin();
      }
      
      _isInitialized = true;
      notifyListeners();
      print('✅ AuthProvider inicializado');
    } catch (e) {
      print('❌ Error inicializando: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Crear admin por defecto
  Future<void> _createInitialAdmin() async {
    final admin = User(
      id: 'admin_1',
      username: 'admin',
      password: _defaultAdminPassword,
      role: 'admin',
      createdAt: DateTime.now(),
    );
    await _box!.put(admin.id, admin);
    print('✅ Admin creado: admin / $_defaultAdminPassword');
  }

  // Login como empleado (sin contraseña)
  void loginAsEmployee() {
    _currentUser = User(
      id: 'employee_temp',
      username: 'Empleado',
      password: '',
      role: 'employee',
      createdAt: DateTime.now(),
    );
    notifyListeners();
    print('✅ Login como empleado');
  }

  // Login como admin (con contraseña)
  bool loginAsAdmin(String password) {
    if (password == _defaultAdminPassword) {
      _currentUser = User(
        id: 'admin_1',
        username: 'Administrador',
        password: _defaultAdminPassword,
        role: 'admin',
        createdAt: DateTime.now(),
      );
      notifyListeners();
      print('✅ Login como admin');
      return true;
    }
    print('❌ Contraseña incorrecta');
    return false;
  }

  // Logout
  void logout() {
    _currentUser = null;
    notifyListeners();
    print('👋 Logout');
  }

  // Verificar si puede eliminar
  bool canDelete() => isAdmin;

  // Verificar contraseña de admin (para confirmaciones)
  Future<bool> verifyAdminPassword(String password) async {
    return password == _defaultAdminPassword;
  }

  // Login con usuario y contraseña (para futuro)
  Future<bool> login(String username, String password) async {
    try {
      if (_box == null) await initialize();

      final users = _box!.values.where((user) =>
          user.username.toLowerCase() == username.toLowerCase() && 
          user.password == password);

      if (users.isNotEmpty) {
        _currentUser = users.first;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error en login: $e');
      return false;
    }
  }

  // Registrar empleado
  Future<bool> registerEmployee(String username, String password) async {
    if (!isAdmin) return false;

    try {
      if (_box == null) await initialize();

      final employee = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        username: username,
        password: password,
        role: 'employee',
        createdAt: DateTime.now(),
      );

      await _box!.put(employee.id, employee);
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Error registrando: $e');
      return false;
    }
  }
}
