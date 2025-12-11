/// Represents Merchant Account Information (Fields 02-51 in KE-QR Standard)
///
/// According to Table 7.5 of the Kenya Quick Response Code Standard:
/// - At least one field from 02-51 MUST be present
/// - Field 28: PSP merchant account identifier
/// - Field 29: Bank wallet merchant account identifier
/// - Fields 26-27: Reserved for CBK use
/// - Fields 30-51: Reserved for future domestic schemes
class MerchantAccountInformation {
  /// The field ID (02-51) that identifies this merchant account
  final String fieldId;

  /// Globally Unique Identifier (sub-tag 00)
  /// Can be a UUID without hyphens or a reverse domain name (e.g., "com.psp.name")
  final String? globallyUniqueIdentifier;

  /// Payment network specific data (sub-tag 01 and beyond)
  /// Contains additional merchant identification information
  final Map<String, String> paymentNetworkSpecificData;

  MerchantAccountInformation({
    required this.fieldId,
    this.globallyUniqueIdentifier,
    required this.paymentNetworkSpecificData,
  });

  /// Returns true if this is a PSP merchant account (field 28)
  bool get isPspAccount => fieldId == '28';

  /// Returns true if this is a bank wallet merchant account (field 29)
  bool get isBankWalletAccount => fieldId == '29';

  /// Returns true if this is a CBK reserved field (26-27)
  bool get isCbkReserved => fieldId == '26' || fieldId == '27';

  @override
  String toString() {
    return 'MerchantAccountInformation(fieldId: $fieldId, globallyUniqueIdentifier: $globallyUniqueIdentifier, paymentNetworkSpecificData: $paymentNetworkSpecificData)';
  }
}
