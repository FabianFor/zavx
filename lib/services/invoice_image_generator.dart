import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/invoice.dart';
import '../models/business_profile.dart';
import '../providers/settings_provider.dart';
import '../core/utils/app_logger.dart';

/// ✅ FUNCIONA 100% OFFLINE - No requiere internet
class InvoiceImageGenerator {
  static final GlobalKey _globalKey = GlobalKey();

  static Future<String> generateImage({
    required Invoice invoice,
    required BusinessProfile businessProfile,
    required BuildContext context,
    required SettingsProvider settingsProvider,
  }) async {
    OverlayEntry? overlayEntry; // ✅ Variable nullable para cleanup
    
    try {
      AppLogger.info('📸 Generando boleta minimalista...');
      
      final overlay = Overlay.of(context);
      
      overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          left: -10000,
          top: -10000,
          child: RepaintBoundary(
            key: _globalKey,
            child: Material(
              child: Container(
                width: 600,
                color: const Color(0xFFF5F3EE),
                child: MinimalistInvoiceWidget(
                  invoice: invoice,
                  businessProfile: businessProfile,
                  settingsProvider: settingsProvider,
                ),
              ),
            ),
          ),
        ),
      );

      overlay.insert(overlayEntry);
      
      // Esperar a que se renderice
      await Future.delayed(const Duration(milliseconds: 500));

      // ✅ VALIDACIÓN: Verificar que el context existe
      if (_globalKey.currentContext == null) {
        throw Exception('No se pudo obtener el contexto del RepaintBoundary');
      }

      RenderRepaintBoundary boundary =
          _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      // ✅ VALIDACIÓN: Verificar que se obtuvo data
      if (byteData == null) {
        throw Exception('No se pudo convertir la imagen a bytes');
      }
      
      Uint8List pngBytes = byteData.buffer.asUint8List();
      AppLogger.success('Imagen capturada: ${pngBytes.length} bytes');

      // ✅ CLEANUP: Remover overlay en finally
      overlayEntry.remove();
      overlayEntry = null;

      final directory = await getTemporaryDirectory();
      final tempPath = '${directory.path}/temp_invoice_${invoice.invoiceNumber}_${DateTime.now().millisecondsSinceEpoch}.png';
      
      final file = File(tempPath);
      await file.writeAsBytes(pngBytes);
      
      // ✅ VALIDACIÓN: Verificar que se guardó
      if (!await file.exists()) {
        throw Exception('No se pudo guardar la imagen temporal');
      }

      AppLogger.success('Imagen guardada: $tempPath');
      return tempPath;
      
    } catch (e, stackTrace) {
      AppLogger.error('Error crítico al generar imagen', e, stackTrace);
      rethrow;
    } finally {
      // ✅ CLEANUP GARANTIZADO: Remover overlay si existe
      try {
        overlayEntry?.remove();
      } catch (e) {
        AppLogger.warning('Error al remover overlay (no crítico)', e);
      }
    }
  }
}

class MinimalistInvoiceWidget extends StatelessWidget {
  final Invoice invoice;
  final BusinessProfile businessProfile;
  final SettingsProvider settingsProvider;

  const MinimalistInvoiceWidget({
    super.key,
    required this.invoice,
    required this.businessProfile,
    required this.settingsProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,
      color: const Color(0xFFF5F3EE),
      padding: const EdgeInsets.all(50),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'N° ${invoice.invoiceNumber.toString().padLeft(7, '0')}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C2C2C),
                  letterSpacing: 1,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (businessProfile.logoPath.isNotEmpty)
                    Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(businessProfile.logoPath),
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.transparent,
                              child: const Icon(
                                Icons.store,
                                size: 60,
                                color: Color(0xFF4A7C8C),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  Text(
                    businessProfile.businessName.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A7C8C),
                      letterSpacing: 1.5,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 8),
                  if (businessProfile.email.isNotEmpty)
                    Text(
                      businessProfile.email,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF5C5C5C),
                      ),
                    ),
                  if (businessProfile.address.isNotEmpty)
                    Text(
                      businessProfile.address,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF5C5C5C),
                      ),
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (businessProfile.phone.isNotEmpty)
                    Text(
                      businessProfile.phone,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF5C5C5C),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFE8E8E8),
              border: Border(
                top: BorderSide(color: Color(0xFF2C2C2C), width: 1.5),
                bottom: BorderSide(color: Color(0xFF2C2C2C), width: 1.5),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text(
                      'Lista de productos',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    'Unitario',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C2C2C),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(width: 20),
                SizedBox(
                  width: 80,
                  child: Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C2C2C),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ...invoice.items.map((item) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF2C2C2C),
                            height: 1.4,
                          ),
                          children: [
                            TextSpan(
                              text: item.productName,
                              style: const TextStyle(
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            TextSpan(
                              text: '\n${item.quantity}x',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF666666),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    child: Text(
                      settingsProvider.formatPrice(item.price),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 80,
                    child: Text(
                      settingsProvider.formatPrice(item.total),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C2C2C),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFE8E8E8),
              border: Border(
                top: BorderSide(color: Color(0xFF2C2C2C), width: 2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
                const SizedBox(width: 40),
                Text(
                  settingsProvider.formatPrice(invoice.total),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C2C2C),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Center(
            child: Text(
              _getThankYouMessage(settingsProvider.locale.languageCode),
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF5C5C5C),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              DateFormat('dd/MM/yyyy HH:mm').format(invoice.createdAt),
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF8C8C8C),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getThankYouMessage(String languageCode) {
    switch (languageCode) {
      case 'es':
        return 'Gracias por su preferencia.';
      case 'en':
        return 'Thank you for your preference.';
      case 'pt':
        return 'Obrigado pela sua preferência.';
      case 'zh':
        return '感谢您的惠顾。';
      default:
        return 'Thank you for your preference.';
    }
  }
}