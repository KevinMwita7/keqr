/// Represents Template Information (Field 83+ in KE-QR Standard)
/// This field contains nested TLV data for additional templates (e.g., M-Pesa specific data)
class TemplateInformation {
  /// The field ID (83-99)
  final String fieldId;

  /// Globally Unique Identifier (sub-tag 00)
  final String? globallyUniqueIdentifier;

  /// Template specific data (sub-tags 01+)
  final Map<String, String> templateData;

  TemplateInformation({
    required this.fieldId,
    this.globallyUniqueIdentifier,
    required this.templateData,
  });

  @override
  String toString() {
    return 'TemplateInformation(fieldId: $fieldId, globallyUniqueIdentifier: $globallyUniqueIdentifier, templateData: $templateData)';
  }
}
