abstract final class SupabaseConstants {
  static const String propertiesTable   = 'properties';
  static const String installmentsTable = 'installments';
  static const String receiptsBucket    = 'receipts';
  static const String paymentPlansBucket = 'payment-plans';
  static const String extractFunctionUrl = 'extract-installments';
  static const int    signedUrlTtlSeconds = 300; // 5 minutes
}
