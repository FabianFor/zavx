import 'package:logger/logger.dart';

/// Logger centralizado para toda la app
/// Reemplaza todos los print() por logs estructurados
/// 
/// USO:
/// ```dart
/// import '../core/utils/app_logger.dart';
/// 
/// AppLogger.debug('Mensaje de debug');
/// AppLogger.info('Información general');
/// AppLogger.warning('Advertencia');
/// AppLogger.error('Error', exception, stackTrace);
/// AppLogger.success('Operación exitosa');
/// ```
class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0, // No mostrar call stack por defecto
      errorMethodCount: 5, // Mostrar 5 niveles en errores
      lineLength: 80, // Ancho de línea
      colors: true, // Colores en consola
      printEmojis: true, // Usar emojis
      printTime: true, // Mostrar timestamp
    ),
  );

  /// 🐛 LOG DE DEBUG
  /// Usar para información técnica detallada
  /// Solo visible en modo debug
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// ℹ️ LOG DE INFO
  /// Usar para información general del flujo de la app
  static void info(String message) {
    _logger.i(message);
  }

  /// ⚠️ LOG DE WARNING
  /// Usar para situaciones anormales pero no críticas
  static void warning(String message, [dynamic error]) {
    _logger.w(message, error: error);
  }

  /// ❌ LOG DE ERROR
  /// Usar para errores que requieren atención
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// ✅ LOG DE ÉXITO
  /// Usar para operaciones completadas exitosamente
  static void success(String message) {
    _logger.i('✅ $message');
  }

  /// 💾 LOG DE GUARDADO
  /// Usar cuando se guarden datos
  static void saved(String message) {
    _logger.i('💾 $message');
  }

  /// 📥 LOG DE CARGA
  /// Usar cuando se carguen datos
  static void loaded(String message) {
    _logger.i('📥 $message');
  }

  /// 🗑️ LOG DE ELIMINACIÓN
  /// Usar cuando se eliminen datos
  static void deleted(String message) {
    _logger.i('🗑️ $message');
  }

  /// 🔄 LOG DE ACTUALIZACIÓN
  /// Usar cuando se actualicen datos
  static void updated(String message) {
    _logger.i('🔄 $message');
  }

  /// 📱 LOG DE SISTEMA
  /// Usar para información del dispositivo
  static void system(String message) {
    _logger.i('📱 $message');
  }

  /// 📶 LOG DE CONECTIVIDAD
  /// Usar para estado de red
  static void connectivity(String message) {
    _logger.i('📶 $message');
  }

  /// 🎯 LOG DE ACCIÓN DE USUARIO
  /// Usar para trackear acciones del usuario
  static void userAction(String message) {
    _logger.i('🎯 $message');
  }
}

/// Ejemplo de uso en otros archivos:
/// 
/// ```dart
/// import '../core/utils/app_logger.dart';
/// 
/// class ProductProvider {
///   Future<void> addProduct(Product product) async {
///     try {
///       AppLogger.info('Agregando producto: ${product.name}');
///       
///       await _saveProduct(product);
///       
///       AppLogger.success('Producto guardado exitosamente');
///     } catch (e, stackTrace) {
///       AppLogger.error('Error al guardar producto', e, stackTrace);
///     }
///   }
/// }
/// ```