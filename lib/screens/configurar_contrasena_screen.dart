import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../l10n/app_localizations.dart';
import 'login_screen.dart';

class ConfigurarContrasenaScreen extends StatefulWidget {
  const ConfigurarContrasenaScreen({super.key});

  @override
  State<ConfigurarContrasenaScreen> createState() =>
      _ConfigurarContrasenaScreenState();
}

class _ConfigurarContrasenaScreenState extends State<ConfigurarContrasenaScreen> {
  final _contrasenaController = TextEditingController();
  final _confirmarController = TextEditingController();
  bool _ocultarContrasena = true;
  bool _ocultarConfirmar = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _contrasenaController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  Future<void> _configurarContrasena() async {
    final l10n = AppLocalizations.of(context)!;
    final contrasena = _contrasenaController.text.trim();
    final confirmar = _confirmarController.text.trim();

    if (contrasena.isEmpty || confirmar.isEmpty) {
      _mostrarMensaje(l10n.completeAllFields, esError: true);
      return;
    }

    if (contrasena.length < 4) {
      _mostrarMensaje(l10n.passwordMinLength, esError: true);
      return;
    }

    if (contrasena != confirmar) {
      _mostrarMensaje(l10n.passwordsDoNotMatch, esError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final exito = await authProvider.configurarContrasenaAdmin(contrasena);

      setState(() => _isLoading = false);

      if (exito) {
        _mostrarMensaje(l10n.passwordConfiguredSuccessfully);
        await Future.delayed(const Duration(seconds: 1));
        
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      } else {
        _mostrarMensaje(l10n.errorConfiguringPassword, esError: true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _mostrarMensaje('${l10n.error}: ${e.toString()}', esError: true);
      debugPrint('Error al configurar contraseña: $e');
    }
  }

  void _mostrarMensaje(String mensaje, {bool esError = false}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: esError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // ✅ RESPONSIVE
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isVerySmall = screenHeight < 700;
    final isSmall = screenHeight < 800;
    final isTablet = screenWidth > 600;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 48.w : (isVerySmall ? 16.w : 20.w),
              vertical: isVerySmall ? 16.h : 24.h,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 400.w : double.infinity,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ✅ ICONO RESPONSIVO
                  Container(
                    width: isVerySmall ? 70.w : (isSmall ? 85.w : 100.w),
                    height: isVerySmall ? 70.w : (isSmall ? 85.w : 100.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.lock_outline,
                      size: isVerySmall ? 35.sp : (isSmall ? 42.sp : 50.sp),
                      color: Colors.black,
                    ),
                  ),

                  SizedBox(height: isVerySmall ? 20.h : (isSmall ? 26.h : 32.h)),

                  // Título
                  Text(
                    l10n.initialSetup,
                    style: TextStyle(
                      fontSize: isVerySmall ? 22.sp : (isSmall ? 25.sp : 28.sp),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: isVerySmall ? 6.h : 8.h),

                  Text(
                    l10n.configureAdminPassword,
                    style: TextStyle(
                      fontSize: isVerySmall ? 13.sp : (isSmall ? 14.sp : 16.sp),
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: isVerySmall ? 24.h : (isSmall ? 32.h : 40.h)),

                  // Tarjeta de configuración
                  Container(
                    padding: EdgeInsets.all(isVerySmall ? 16.w : (isSmall ? 20.w : 24.w)),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A237E),
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mensaje informativo
                        Container(
                          padding: EdgeInsets.all(isVerySmall ? 10.w : 12.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFF283593),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: const Color(0xFF3949AB)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.white,
                                size: isVerySmall ? 20.sp : 24.sp,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  l10n.firstTimeMessage,
                                  style: TextStyle(
                                    fontSize: isVerySmall ? 11.sp : 13.sp,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: isVerySmall ? 18.h : (isSmall ? 20.h : 24.h)),

                        // Campo contraseña
                        TextField(
                          controller: _contrasenaController,
                          obscureText: _ocultarContrasena,
                          enabled: !_isLoading,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isVerySmall ? 13.sp : 14.sp,
                          ),
                          decoration: InputDecoration(
                            labelText: l10n.newPassword,
                            labelStyle: TextStyle(
                              color: Colors.white70,
                              fontSize: isVerySmall ? 12.sp : 14.sp,
                            ),
                            hintText: l10n.minimumCharacters,
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: isVerySmall ? 11.sp : 13.sp,
                            ),
                            prefixIcon: Icon(
                              Icons.lock,
                              color: Colors.white,
                              size: isVerySmall ? 20.sp : 24.sp,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _ocultarContrasena ? Icons.visibility_off : Icons.visibility,
                                color: Colors.white,
                                size: isVerySmall ? 20.sp : 24.sp,
                              ),
                              onPressed: () {
                                setState(() {
                                  _ocultarContrasena = !_ocultarContrasena;
                                });
                              },
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: const BorderSide(color: Colors.white54),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: const BorderSide(color: Colors.white, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: isVerySmall ? 12.h : 16.h,
                            ),
                          ),
                        ),

                        SizedBox(height: isVerySmall ? 14.h : 16.h),

                        // Campo confirmar contraseña
                        TextField(
                          controller: _confirmarController,
                          obscureText: _ocultarConfirmar,
                          enabled: !_isLoading,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isVerySmall ? 13.sp : 14.sp,
                          ),
                          decoration: InputDecoration(
                            labelText: l10n.confirmPasswordLabel,
                            labelStyle: TextStyle(
                              color: Colors.white70,
                              fontSize: isVerySmall ? 12.sp : 14.sp,
                            ),
                            hintText: l10n.repeatPassword,
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: isVerySmall ? 11.sp : 13.sp,
                            ),
                            prefixIcon: Icon(
                              Icons.lock_clock,
                              color: Colors.white,
                              size: isVerySmall ? 20.sp : 24.sp,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _ocultarConfirmar ? Icons.visibility_off : Icons.visibility,
                                color: Colors.white,
                                size: isVerySmall ? 20.sp : 24.sp,
                              ),
                              onPressed: () {
                                setState(() {
                                  _ocultarConfirmar = !_ocultarConfirmar;
                                });
                              },
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: const BorderSide(color: Colors.white54),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: const BorderSide(color: Colors.white, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: isVerySmall ? 12.h : 16.h,
                            ),
                          ),
                          onSubmitted: (_) => _configurarContrasena(),
                        ),

                        SizedBox(height: isVerySmall ? 18.h : (isSmall ? 20.h : 24.h)),

                        // Botón configurar
                        SizedBox(
                          width: double.infinity,
                          height: isVerySmall ? 44.h : (isSmall ? 46.h : 50.h),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _configurarContrasena,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF1A237E),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    width: 20.w,
                                    height: 20.w,
                                    child: const CircularProgressIndicator(
                                      color: Color(0xFF1A237E),
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    l10n.configureAndContinue,
                                    style: TextStyle(
                                      fontSize: isVerySmall ? 14.sp : (isSmall ? 15.sp : 16.sp),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: isVerySmall ? 16.h : (isSmall ? 20.h : 24.h)),

                  // Nota de seguridad
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Text(
                      l10n.savePasswordSecurely,
                      style: TextStyle(
                        fontSize: isVerySmall ? 10.sp : 12.sp,
                        color: Colors.white.withOpacity(0.9),
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  SizedBox(height: isVerySmall ? 8.h : 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
