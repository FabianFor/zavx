import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../l10n/app_localizations.dart';
import 'dashboard_screen.dart';
import 'configurar_contrasena_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _contrasenaController = TextEditingController();
  bool _ocultarContrasena = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _contrasenaController.dispose();
    super.dispose();
  }

  Future<void> _loginAdmin() async {
    final l10n = AppLocalizations.of(context)!;
    
    if (_contrasenaController.text.trim().isEmpty) {
      _mostrarMensaje(l10n.pleaseEnterPassword, esError: true);
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final exito = await authProvider.loginAdmin(_contrasenaController.text.trim());

    setState(() => _isLoading = false);

    if (exito) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    } else {
      _mostrarMensaje(l10n.incorrectPassword, esError: true);
      _contrasenaController.clear();
    }
  }

  Future<void> _loginUsuario() async {
    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final exito = await authProvider.loginUsuario();

    setState(() => _isLoading = false);

    if (exito && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    }
  }

  void _mostrarMensaje(String mensaje, {bool esError = false}) {
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
    final authProvider = context.watch<AuthProvider>();
    
    // ✅ RESPONSIVE: Detectar tamaño de pantalla
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isVerySmall = screenHeight < 700; // Pantallas pequeñas
    final isSmall = screenHeight < 800;     // Pantallas medianas
    final isTablet = screenWidth > 600;     // Tablets

    // Si el admin no tiene contraseña configurada, mostrar pantalla de configuración
    if (!authProvider.adminTieneContrasena()) {
      return const ConfigurarContrasenaScreen();
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.7),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              // ✅ PADDING RESPONSIVO
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 48.w : (isVerySmall ? 16.w : 20.w),
                vertical: isVerySmall ? 16.h : 24.h,
              ),
              child: ConstrainedBox(
                // ✅ LIMITAR ANCHO EN TABLETS
                constraints: BoxConstraints(
                  maxWidth: isTablet ? 400.w : double.infinity,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ✅ LOGO RESPONSIVO
                    Container(
                      width: isVerySmall ? 90.w : (isSmall ? 110.w : 130.w),
                      height: isVerySmall ? 90.w : (isSmall ? 110.w : 130.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Padding(
                          padding: EdgeInsets.all(2.w),
                          child: Image.asset(
                            'assets/icon/logo2.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                    // ✅ ESPACIADO RESPONSIVO
                    SizedBox(height: isVerySmall ? 16.h : (isSmall ? 24.h : 32.h)),

                    // Título
                    Text(
                      l10n.proioApp,
                      style: TextStyle(
                        fontSize: isVerySmall ? 24.sp : (isSmall ? 28.sp : 32.sp),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: isVerySmall ? 4.h : 8.h),

                    Text(
                      l10n.businessManagementSystem,
                      style: TextStyle(
                        fontSize: isVerySmall ? 13.sp : (isSmall ? 14.sp : 16.sp),
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    // ✅ ESPACIADO ANTES DE TARJETA MÁS PEQUEÑO
                    SizedBox(height: isVerySmall ? 20.h : (isSmall ? 32.h : 40.h)),

                    // Tarjeta de Login
                    Container(
                      // ✅ PADDING INTERNO RESPONSIVO
                      padding: EdgeInsets.all(isVerySmall ? 16.w : (isSmall ? 20.w : 24.w)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Login Admin
                          Text(
                            l10n.loginAsAdministrator,
                            style: TextStyle(
                              fontSize: isVerySmall ? 15.sp : (isSmall ? 16.sp : 18.sp),
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          SizedBox(height: isVerySmall ? 16.h : (isSmall ? 20.h : 24.h)),

                          // Campo de contraseña
                          TextField(
                            controller: _contrasenaController,
                            obscureText: _ocultarContrasena,
                            enabled: !_isLoading,
                            style: TextStyle(fontSize: isVerySmall ? 13.sp : 14.sp),
                            decoration: InputDecoration(
                              labelText: l10n.password,
                              labelStyle: TextStyle(fontSize: isVerySmall ? 12.sp : 14.sp),
                              hintText: l10n.enterPassword,
                              hintStyle: TextStyle(fontSize: isVerySmall ? 12.sp : 14.sp),
                              prefixIcon: Icon(Icons.lock, size: isVerySmall ? 20.sp : 24.sp),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _ocultarContrasena
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  size: isVerySmall ? 20.sp : 24.sp,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _ocultarContrasena = !_ocultarContrasena;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: isVerySmall ? 12.h : 16.h,
                              ),
                            ),
                            onSubmitted: (_) => _loginAdmin(),
                          ),

                          SizedBox(height: isVerySmall ? 14.h : (isSmall ? 16.h : 20.h)),

                          // Botón Login Admin
                          SizedBox(
                            width: double.infinity,
                            height: isVerySmall ? 44.h : (isSmall ? 46.h : 50.h),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _loginAdmin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                      width: 20.w,
                                      height: 20.w,
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      l10n.loginButton,
                                      style: TextStyle(
                                        fontSize: isVerySmall ? 14.sp : (isSmall ? 15.sp : 16.sp),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),

                          SizedBox(height: isVerySmall ? 12.h : (isSmall ? 14.h : 16.h)),

                          // Divisor
                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.grey.shade300)),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12.w),
                                child: Text(
                                  'O',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: isVerySmall ? 12.sp : 14.sp,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: Colors.grey.shade300)),
                            ],
                          ),

                          SizedBox(height: isVerySmall ? 12.h : (isSmall ? 14.h : 16.h)),

                          // Botón Login Usuario
                          SizedBox(
                            width: double.infinity,
                            height: isVerySmall ? 44.h : (isSmall ? 46.h : 50.h),
                            child: OutlinedButton(
                              onPressed: _isLoading ? null : _loginUsuario,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Theme.of(context).primaryColor,
                                side: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: Text(
                                l10n.continueAsUser,
                                style: TextStyle(
                                  fontSize: isVerySmall ? 14.sp : (isSmall ? 15.sp : 16.sp),
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ✅ ESPACIADO DESPUÉS DE TARJETA
                    SizedBox(height: isVerySmall ? 12.h : (isSmall ? 16.h : 24.h)),

                    // Información adicional
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text(
                        l10n.userOnlyMode,
                        style: TextStyle(
                          fontSize: isVerySmall ? 10.sp : (isSmall ? 11.sp : 12.sp),
                          color: Colors.white.withOpacity(0.8),
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    // ✅ ESPACIADO FINAL PARA EVITAR CORTES
                    SizedBox(height: isVerySmall ? 8.h : 0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
