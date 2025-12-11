/// Represents QR Timestamp Information (Field 82 in KE-QR Standard)
/// This field contains nested TLV data for QR code timestamp and validity
class QrTimestampInformation {
  /// Globally Unique Identifier (sub-tag 00)
  final String? globallyUniqueIdentifier;

  /// Timestamp or other validity data (sub-tags 01+)
  final Map<String, String> timestampData;

  QrTimestampInformation({
    this.globallyUniqueIdentifier,
    required this.timestampData,
  });

  @override
  String toString() {
    return 'QrTimestampInformation(globallyUniqueIdentifier: $globallyUniqueIdentifier, timestampData: $timestampData)';
  }
}
