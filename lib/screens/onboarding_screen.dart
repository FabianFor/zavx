import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../l10n/app_localizations.dart';
import '../core/utils/theme_helper.dart';
import '../providers/settings_provider.dart';
import '../providers/business_provider.dart';
import '../providers/auth_provider.dart';
import '../models/business_profile.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Controllers
  final _businessNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // State
  String? _logoPath;
  String _selectedLanguage = 'en';
  String _selectedCurrency = 'USD';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _pageController.dispose();
    _businessNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _logoPath = image.path;
      });
    }
  }

  void _nextPage() {
    if (_currentPage < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _changeLanguage(String languageCode) async {
    setState(() {
      _selectedLanguage = languageCode;
    });
    
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    await settingsProvider.setLanguage(languageCode);
  }

  Future<void> _finishOnboarding() async {
    final l10n = AppLocalizations.of(context)!;

    if (_businessNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.businessNameRequired),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.passwordTooShort),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.passwordMismatch),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    await settingsProvider.setCurrency(_selectedCurrency);

    final profile = BusinessProfile(
      name: _businessNameController.text.trim(),
      address: _addressController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      logoPath: _logoPath ?? '',
    );
    await businessProvider.updateProfile(profile);

    await authProvider.setPassword(_passwordController.text);
    await settingsProvider.completeOnboarding();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = ThemeHelper(context);
    
    // ✅ RESPONSIVE
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isVerySmall = screenHeight < 700;
    final isSmall = screenHeight < 800;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: theme.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            if (_currentPage > 0)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isVerySmall ? 16.w : 20.w,
                  vertical: isVerySmall ? 12.h : 16.h,
                ),
                child: Row(
                  children: [
                    Text(
                      '${l10n.step} $_currentPage ${l10n.ofPreposition} 5',
                      style: TextStyle(
                        fontSize: isVerySmall ? 12.sp : 14.sp,
                        color: theme.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    if (_currentPage < 5)
                      TextButton(
                        onPressed: () {
                          _pageController.jumpToPage(5);
                        },
                        child: Text(
                          l10n.skip,
                          style: TextStyle(fontSize: isVerySmall ? 12.sp : 14.sp),
                        ),
                      ),
                  ],
                ),
              ),

            if (_currentPage > 0)
              LinearProgressIndicator(
                value: _currentPage / 5,
                backgroundColor: theme.dividerColor,
                valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
              ),

            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildWelcomePage(l10n, theme, isVerySmall, isSmall, isTablet),
                  _buildLanguageSelectionPage(l10n, theme, isVerySmall, isSmall, isTablet),
                  _buildBusinessInfoPage(l10n, theme, isVerySmall, isSmall, isTablet),
                  _buildContactInfoPage(l10n, theme, isVerySmall, isSmall, isTablet),
                  _buildCurrencyPage(l10n, theme, isVerySmall, isSmall, isTablet),
                  _buildSecurityPage(l10n, theme, isVerySmall, isSmall, isTablet),
                ],
              ),
            ),

            // Navigation Buttons
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isVerySmall ? 16.w : 20.w,
                vertical: isVerySmall ? 12.h : 16.h,
              ),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousPage,
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: isVerySmall ? 12.h : 14.h,
                          ),
                          side: BorderSide(color: theme.borderColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          l10n.previous,
                          style: TextStyle(fontSize: isVerySmall ? 14.sp : 16.sp),
                        ),
                      ),
                    ),
                  if (_currentPage > 0) SizedBox(width: 12.w),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: isVerySmall ? 12.h : 14.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        _currentPage == 0 ? l10n.getStarted : (_currentPage == 5 ? l10n.finish : l10n.next),
                        style: TextStyle(
                          fontSize: isVerySmall ? 14.sp : 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ PÁGINA 1: BIENVENIDA RESPONSIVA
  Widget _buildWelcomePage(AppLocalizations l10n, ThemeHelper theme, bool isVerySmall, bool isSmall, bool isTablet) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 48.w : (isVerySmall ? 20.w : 32.w),
          vertical: isVerySmall ? 16.h : 20.h,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: isVerySmall ? 120.w : (isSmall ? 150.w : 180.w),
              height: isVerySmall ? 120.w : (isSmall ? 150.w : 180.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.primary.withOpacity(0.2),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.primary.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/icon/logo2.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: isVerySmall ? 20.h : (isSmall ? 25.h : 30.h)),
            Text(
              'Proïon',
              style: TextStyle(
                fontSize: isVerySmall ? 32.sp : (isSmall ? 37.sp : 42.sp),
                fontWeight: FontWeight.bold,
                color: theme.textPrimary,
              ),
            ),
            SizedBox(height: isVerySmall ? 12.h : 16.h),
            Text(
              l10n.setupYourBusiness,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isVerySmall ? 13.sp : (isSmall ? 14.sp : 16.sp),
                color: theme.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ✅ PÁGINA 2: SELECCIÓN DE IDIOMA RESPONSIVA
  Widget _buildLanguageSelectionPage(AppLocalizations l10n, ThemeHelper theme, bool isVerySmall, bool isSmall, bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 48.w : (isVerySmall ? 16.w : 24.w),
        vertical: isVerySmall ? 12.h : 20.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.selectYourLanguage,
            style: TextStyle(
              fontSize: isVerySmall ? 20.sp : (isSmall ? 22.sp : 24.sp),
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
            ),
          ),
          SizedBox(height: isVerySmall ? 6.h : 8.h),
          Text(
            l10n.preferences,
            style: TextStyle(
              fontSize: isVerySmall ? 12.sp : 14.sp,
              color: theme.textSecondary,
            ),
          ),
          SizedBox(height: isVerySmall ? 20.h : 30.h),

          _buildLanguageOption('es', l10n.spanish, theme, isVerySmall),
          SizedBox(height: 12.h),
          _buildLanguageOption('en', l10n.english, theme, isVerySmall),
          SizedBox(height: 12.h),
          _buildLanguageOption('pt', l10n.portuguese, theme, isVerySmall),
          SizedBox(height: 12.h),
          _buildLanguageOption('zh', l10n.chinese, theme, isVerySmall),
        ],
      ),
    );
  }

  // ✅ PÁGINA 3: INFORMACIÓN DEL NEGOCIO RESPONSIVA
  Widget _buildBusinessInfoPage(AppLocalizations l10n, ThemeHelper theme, bool isVerySmall, bool isSmall, bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 48.w : (isVerySmall ? 16.w : 24.w),
        vertical: isVerySmall ? 12.h : 20.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.businessInfo,
            style: TextStyle(
              fontSize: isVerySmall ? 20.sp : (isSmall ? 22.sp : 24.sp),
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
            ),
          ),
          SizedBox(height: isVerySmall ? 6.h : 8.h),
          Text(
            l10n.setupYourBusiness,
            style: TextStyle(
              fontSize: isVerySmall ? 12.sp : 14.sp,
              color: theme.textSecondary,
            ),
          ),
          SizedBox(height: isVerySmall ? 20.h : 30.h),

          // NOMBRE DEL NEGOCIO
          TextField(
            controller: _businessNameController,
            style: TextStyle(
              fontSize: isVerySmall ? 14.sp : 16.sp,
              color: theme.textPrimary,
            ),
            decoration: InputDecoration(
              labelText: l10n.enterBusinessName,
              labelStyle: TextStyle(fontSize: isVerySmall ? 12.sp : 14.sp),
              hintText: '',
              prefixIcon: Icon(Icons.business, color: theme.iconColor, size: isVerySmall ? 20.sp : 24.sp),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: theme.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: theme.primary, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: isVerySmall ? 12.h : 16.h,
              ),
            ),
          ),
          SizedBox(height: isVerySmall ? 16.h : 20.h),

          // DIRECCIÓN
          TextField(
            controller: _addressController,
            style: TextStyle(
              fontSize: isVerySmall ? 14.sp : 16.sp,
              color: theme.textPrimary,
            ),
            maxLines: 2,
            decoration: InputDecoration(
              labelText: '${l10n.address} ${l10n.optionalField}',
              labelStyle: TextStyle(fontSize: isVerySmall ? 12.sp : 14.sp),
              hintText: '',
              prefixIcon: Icon(Icons.location_on, color: theme.iconColor, size: isVerySmall ? 20.sp : 24.sp),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: theme.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: theme.primary, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: isVerySmall ? 12.h : 16.h,
              ),
            ),
          ),
          SizedBox(height: isVerySmall ? 18.h : 24.h),

          Text(
            l10n.businessLogo,
            style: TextStyle(
              fontSize: isVerySmall ? 14.sp : 16.sp,
              fontWeight: FontWeight.w600,
              color: theme.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),

          // ✅ LOGO RESPONSIVO
          Center(
            child: InkWell(
              onTap: _pickLogo,
              child: Container(
                width: isVerySmall ? 120.w : (isSmall ? 150.w : 180.w),
                height: isVerySmall ? 120.w : (isSmall ? 150.w : 180.w),
                decoration: BoxDecoration(
                  color: theme.surfaceColor,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: theme.borderColor, width: 2),
                ),
                child: _logoPath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Image.file(
                          File(_logoPath!),
                          fit: BoxFit.cover,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            size: isVerySmall ? 30.sp : 40.sp,
                            color: theme.iconColor,
                          ),
                          SizedBox(height: 8.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            child: Text(
                              l10n.tapToAddLogo,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isVerySmall ? 11.sp : 13.sp,
                                color: theme.textSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ PÁGINA 4: INFORMACIÓN DE CONTACTO RESPONSIVA
  Widget _buildContactInfoPage(AppLocalizations l10n, ThemeHelper theme, bool isVerySmall, bool isSmall, bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 48.w : (isVerySmall ? 16.w : 24.w),
        vertical: isVerySmall ? 12.h : 20.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.contactInfo,
            style: TextStyle(
              fontSize: isVerySmall ? 20.sp : (isSmall ? 22.sp : 24.sp),
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
            ),
          ),
          SizedBox(height: isVerySmall ? 6.h : 8.h),
          Text(
            l10n.optionalField,
            style: TextStyle(
              fontSize: isVerySmall ? 12.sp : 14.sp,
              color: theme.textSecondary,
            ),
          ),
          SizedBox(height: isVerySmall ? 20.h : 30.h),

          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: TextStyle(
              fontSize: isVerySmall ? 14.sp : 16.sp,
              color: theme.textPrimary,
            ),
            decoration: InputDecoration(
              labelText: l10n.phoneNumber,
              labelStyle: TextStyle(fontSize: isVerySmall ? 12.sp : 14.sp),
              hintText: '',
              prefixIcon: Icon(Icons.phone, color: theme.iconColor, size: isVerySmall ? 20.sp : 24.sp),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: theme.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: theme.primary, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: isVerySmall ? 12.h : 16.h,
              ),
            ),
          ),
          SizedBox(height: isVerySmall ? 16.h : 20.h),

          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              fontSize: isVerySmall ? 14.sp : 16.sp,
              color: theme.textPrimary,
            ),
            decoration: InputDecoration(
              labelText: l10n.emailAddress,
              labelStyle: TextStyle(fontSize: isVerySmall ? 12.sp : 14.sp),
              hintText: l10n.emailHint,
              hintStyle: TextStyle(fontSize: isVerySmall ? 11.sp : 13.sp),
              prefixIcon: Icon(Icons.email, color: theme.iconColor, size: isVerySmall ? 20.sp : 24.sp),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: theme.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: theme.primary, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: isVerySmall ? 12.h : 16.h,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ PÁGINA 5: MONEDA RESPONSIVA
  Widget _buildCurrencyPage(AppLocalizations l10n, ThemeHelper theme, bool isVerySmall, bool isSmall, bool isTablet) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 48.w : (isVerySmall ? 16.w : 24.w),
        vertical: isVerySmall ? 12.h : 20.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.selectYourCurrency,
            style: TextStyle(
              fontSize: isVerySmall ? 20.sp : (isSmall ? 22.sp : 24.sp),
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
            ),
          ),
          SizedBox(height: isVerySmall ? 6.h : 8.h),
          Text(
            l10n.preferences,
            style: TextStyle(
              fontSize: isVerySmall ? 12.sp : 14.sp,
              color: theme.textSecondary,
            ),
          ),
          SizedBox(height: isVerySmall ? 20.h : 30.h),

          ...SettingsProvider.supportedCurrencies.entries.map((entry) {
            final code = entry.key;
            final currencyData = entry.value;
            final name = settingsProvider.getCurrencyNameForCode(code, _selectedLanguage);
            
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _buildCurrencyOption(
                code,
                name,
                currencyData['symbol']!,
                currencyData['flag']!,
                theme,
                isVerySmall,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // ✅ PÁGINA 6: SEGURIDAD RESPONSIVA
  Widget _buildSecurityPage(AppLocalizations l10n, ThemeHelper theme, bool isVerySmall, bool isSmall, bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 48.w : (isVerySmall ? 16.w : 24.w),
        vertical: isVerySmall ? 12.h : 20.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.security,
            style: TextStyle(
              fontSize: isVerySmall ? 20.sp : (isSmall ? 22.sp : 24.sp),
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
            ),
          ),
          SizedBox(height: isVerySmall ? 6.h : 8.h),
          Text(
            l10n.adminPasswordInfo,
            style: TextStyle(
              fontSize: isVerySmall ? 12.sp : 14.sp,
              color: theme.textSecondary,
            ),
          ),
          SizedBox(height: isVerySmall ? 20.h : 30.h),

          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: TextStyle(
              fontSize: isVerySmall ? 14.sp : 16.sp,
              color: theme.textPrimary,
            ),
            decoration: InputDecoration(
              labelText: l10n.createAdminPassword,
              labelStyle: TextStyle(fontSize: isVerySmall ? 12.sp : 14.sp),
              hintText: l10n.passwordHint,
              hintStyle: TextStyle(fontSize: isVerySmall ? 11.sp : 13.sp),
              prefixIcon: Icon(Icons.lock, color: theme.iconColor, size: isVerySmall ? 20.sp : 24.sp),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: theme.iconColor,
                  size: isVerySmall ? 20.sp : 24.sp,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: theme.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: theme.primary, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: isVerySmall ? 12.h : 16.h,
              ),
            ),
          ),
          SizedBox(height: isVerySmall ? 16.h : 20.h),

          TextField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            style: TextStyle(
              fontSize: isVerySmall ? 14.sp : 16.sp,
              color: theme.textPrimary,
            ),
            decoration: InputDecoration(
              labelText: l10n.confirmPassword,
              labelStyle: TextStyle(fontSize: isVerySmall ? 12.sp : 14.sp),
              hintText: l10n.confirmPasswordHint,
              hintStyle: TextStyle(fontSize: isVerySmall ? 11.sp : 13.sp),
              prefixIcon: Icon(Icons.lock_outline, color: theme.iconColor, size: isVerySmall ? 20.sp : 24.sp),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                  color: theme.iconColor,
                  size: isVerySmall ? 20.sp : 24.sp,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: theme.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: theme.primary, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: isVerySmall ? 12.h : 16.h,
              ),
            ),
          ),
          SizedBox(height: isVerySmall ? 16.h : 20.h),
          
          Container(
            padding: EdgeInsets.all(isVerySmall ? 10.w : 14.w),
            decoration: BoxDecoration(
              color: theme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: theme.primary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: theme.primary, size: isVerySmall ? 18.sp : 22.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    l10n.passwordTooShort,
                    style: TextStyle(
                      fontSize: isVerySmall ? 11.sp : 13.sp,
                      color: theme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String code, String name, ThemeHelper theme, bool isVerySmall) {
    final isSelected = _selectedLanguage == code;
    return InkWell(
      onTap: () async {
        await _changeLanguage(code);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isVerySmall ? 12.w : 16.w,
          vertical: isVerySmall ? 12.h : 14.h,
        ),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryWithOpacity(0.1) : theme.surfaceColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? theme.primary : theme.borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: isVerySmall ? 30.w : 36.w,
              height: isVerySmall ? 30.w : 36.w,
              decoration: BoxDecoration(
                color: theme.primary.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  code.toUpperCase(),
                  style: TextStyle(
                    fontSize: isVerySmall ? 10.sp : 12.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.primary,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: isVerySmall ? 13.sp : 15.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: theme.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: theme.primary, size: isVerySmall ? 18.sp : 22.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyOption(String code, String name, String symbol, String flag, ThemeHelper theme, bool isVerySmall) {
    final isSelected = _selectedCurrency == code;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedCurrency = code;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isVerySmall ? 12.w : 16.w,
          vertical: isVerySmall ? 12.h : 14.h,
        ),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryWithOpacity(0.1) : theme.surfaceColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? theme.primary : theme.borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: TextStyle(fontSize: isVerySmall ? 18.sp : 22.sp)),
            SizedBox(width: 12.w),
            Container(
              width: isVerySmall ? 30.w : 36.w,
              height: isVerySmall ? 30.w : 36.w,
              decoration: BoxDecoration(
                color: theme.primary.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  symbol,
                  style: TextStyle(
                    fontSize: isVerySmall ? 12.sp : 14.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.primary,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    code,
                    style: TextStyle(
                      fontSize: isVerySmall ? 13.sp : 15.sp,
                      fontWeight: FontWeight.bold,
                      color: theme.textPrimary,
                    ),
                  ),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: isVerySmall ? 11.sp : 13.sp,
                      color: theme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: theme.primary, size: isVerySmall ? 18.sp : 22.sp),
          ],
        ),
      ),
    );
  }
}
