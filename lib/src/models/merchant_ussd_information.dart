/// Represents Merchant USSD Information (Field 81 in KE-QR Standard)
/// This field contains nested TLV data for USSD-based merchant identification
class MerchantUssdInformation {
  /// Globally Unique Identifier (sub-tag 00)
  final String? globallyUniqueIdentifier;

  /// USSD Code or other payment network specific data (sub-tags 01+)
  final Map<String, String> paymentNetworkSpecificData;

  MerchantUssdInformation({
    this.globallyUniqueIdentifier,
    required this.paymentNetworkSpecificData,
  });

  @override
  String toString() {
    return 'MerchantUssdInformation(globallyUniqueIdentifier: $globallyUniqueIdentifier, paymentNetworkSpecificData: $paymentNetworkSpecificData)';
  }
}
