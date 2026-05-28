import 'package:flutter/foundation.dart';

abstract final class SupabaseConstants {
  static const String propertiesTable = 'properties';
  static const String installmentsTable = 'installments';
  static const String receiptsBucket = 'receipts';
  static const String paymentPlansBucket = 'payment-plans';
  static const String extractFunctionUrl = 'extract-installments';
  static const int signedUrlTtlSeconds = 300; // 5 minutes

  // OAuth / deep-link callbacks. Web rounds back to the dev server on port
  // 3000 (must match the Supabase + Google console redirect config); native
  // platforms use the custom URL scheme registered in iOS Info.plist and
  // Android intent filters.
  static const String _webRedirect = 'http://localhost:3000';
  static const String _nativeRedirect =
      'io.supabase.proptrack://login-callback/';

  /// Redirect URL for the OAuth login callback, chosen per platform.
  static String get oauthRedirectUrl => kIsWeb ? _webRedirect : _nativeRedirect;
}
