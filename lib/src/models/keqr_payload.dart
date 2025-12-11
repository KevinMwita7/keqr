import 'additional_data.dart';
import 'merchant_account_information.dart';
import 'merchant_information_language_template.dart';
import 'merchant_premises_location.dart';
import 'merchant_ussd_information.dart';
import 'qr_timestamp_information.dart';
import 'template_information.dart';
import 'tip_or_convenience_indicator.dart';

class KeqrPayload {
  final String payloadFormatIndicator;
  final String pointOfInitiationMethod;

  /// Merchant Account Information (Fields 02-51)
  /// At least one MUST be present according to KE-QR Standard Table 7.3
  final List<MerchantAccountInformation> merchantAccountInformation;

  final String? merchantCategoryCode; // Optional
  final String transactionCurrency;
  final String? transactionAmount; // Conditional
  final TipOrConvenienceIndicator? tipOrConvenienceIndicator; // Optional
  final String? convenienceFeeFixed; // Conditional
  final String? convenienceFeePercentage; // Conditional
  final String countryCode;
  final String merchantName;
  final String? merchantCity; // Optional
  final String? postalCode; // Optional

  /// Merchant USSD Information (Field 81) - Nested TLV structure
  /// Mandatory in KE-QR Standard
  final MerchantUssdInformation? merchantUssdInformation;

  /// QR Timestamp Information (Field 82) - Nested TLV structure
  /// Mandatory in KE-QR Standard
  final QrTimestampInformation? qrTimestampInformation;

  /// Additional Templates (Fields 83-99) - Nested TLV structures
  /// Optional fields for provider-specific data (e.g., M-Pesa)
  final List<TemplateInformation>? additionalTemplates;

  final AdditionalData? additionalData;
  final MerchantInformationLanguageTemplate? merchantInformationLanguageTemplate;
  final MerchantPremisesLocation? merchantPremisesLocation;
  final String? crc;

  KeqrPayload({
    required this.payloadFormatIndicator,
    required this.pointOfInitiationMethod,
    required this.merchantAccountInformation,
    this.merchantCategoryCode,
    required this.transactionCurrency,
    this.transactionAmount,
    this.tipOrConvenienceIndicator,
    this.convenienceFeeFixed,
    this.convenienceFeePercentage,
    required this.countryCode,
    required this.merchantName,
    this.merchantCity,
    this.postalCode,
    this.merchantUssdInformation,
    this.qrTimestampInformation,
    this.additionalTemplates,
    this.additionalData,
    this.merchantInformationLanguageTemplate,
    this.merchantPremisesLocation,
    this.crc,
  });
}
