class ValidationLimits {
  // Stock limits
  static const int minStock = 0;
  static const int maxStock = 999999;
  static const int maxProductStock = 999999;  // ✅ Agregado
  
  // Price limits
  static const double minPrice = 0.01;
  static const double maxPrice = 99999999.99;
  static const double maxProductPrice = 99999999.99;  // ✅ Agregado
  
  // Customer name limits
  static const int minCustomerNameLength = 2;
  static const int maxCustomerNameLength = 100;
  
  // Phone limits
  static const int minPhoneLength = 7;
  static const int maxPhoneLength = 20;
  
  // Product name limits
  static const int minProductNameLength = 2;
  static const int maxProductNameLength = 100;
  
  // Description limits
  static const int maxDescriptionLength = 500;
  
  // Generic input limits
  static const int maxInputLength = 100;  // ✅ Agregado
  
  // Debounce (para búsquedas)
  static const int debounceMilliseconds = 300;
}
