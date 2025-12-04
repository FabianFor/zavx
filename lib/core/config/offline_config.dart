import 'package:connectivity_plus/connectivity_plus.dart';
import '../utils/app_logger.dart';

/// Configuración y verificación del modo offline
/// ✅ LA APP FUNCIONA 100% SIN INTERNET
/// Solo compartir/descargar boletas requiere conexión
class OfflineConfig {
  /// Verifica si hay conexión (opcional, solo para features no críticos)
  static Future<bool> hasConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      
      // ✅ CORRECCIÓN: Manejo correcto de la nueva API de connectivity_plus
      final hasConnection = connectivityResult.contains(ConnectivityResult.mobile) ||
                           connectivityResult.contains(ConnectivityResult.wifi) ||
                           connectivityResult.contains(ConnectivityResult.ethernet);
      
      if (hasConnection) {
        AppLogger.info('📶 Conexión detectada');
      } else {
        AppLogger.info('📵 Sin conexión (modo offline)');
      }
      
      return hasConnection;
    } catch (e) {
      // ✅ CORRECCIÓN: AppLogger.warning solo acepta 1 parámetro
      AppLogger.warning('No se pudo verificar conexión (error: $e), asumiendo offline');
      return false;
    }
  }

  /// Features que funcionan 100% OFFLINE
  static const List<String> offlineFeatures = [
    '✅ Gestión de productos (crear, editar, eliminar)',
    '✅ Registro de pedidos',
    '✅ Generación de boletas',
    '✅ Visualización de historial',
    '✅ Búsqueda de productos/pedidos/boletas',
    '✅ Configuración de idioma y moneda',
    '✅ Perfil del negocio',
    '✅ Estadísticas y reportes',
    '✅ Toma de fotos de productos',
    '✅ Guardar boletas en galería',
  ];

  /// Features que REQUIEREN internet (no críticos)
  static const List<String> onlineFeatures = [
    '📶 Compartir boletas por WhatsApp/Email (requiere internet)',
    '📶 Sincronización en la nube (futura implementación)',
  ];

  /// Muestra info sobre modo offline
  static void logOfflineCapabilities() {
    AppLogger.info('═══════════════════════════════════════');
    AppLogger.info('📱 MODO OFFLINE COMPLETAMENTE FUNCIONAL');
    AppLogger.info('═══════════════════════════════════════');
    
    for (final feature in offlineFeatures) {
      AppLogger.info(feature);
    }
    
    AppLogger.info('');
    AppLogger.info('Features opcionales (requieren internet):');
    for (final feature in onlineFeatures) {
      AppLogger.info(feature);
    }
    
    AppLogger.info('═══════════════════════════════════════');
  }

  /// Verifica si una acción específica requiere conexión
  static bool requiresConnection(String action) {
    const actionsRequiringConnection = [
      'share_invoice',
      'cloud_sync',
    ];
    
    return actionsRequiringConnection.contains(action);
  }

  /// Maneja intentos de acciones que requieren conexión
  static Future<bool> canPerformOnlineAction(String action) async {
    if (!requiresConnection(action)) {
      return true; // Acción offline, siempre disponible
    }

    final connected = await hasConnection();
    
    if (!connected) {
      AppLogger.warning('Acción "$action" requiere conexión pero no está disponible');
    }
    
    return connected;
  }
}
