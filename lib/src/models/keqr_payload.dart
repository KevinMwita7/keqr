import 'additional_data.dart';
import 'merchant_information_language_template.dart';

class KeqrPayload {
  final String payloadFormatIndicator;
  final String pointOfInitiationMethod;
  final String? merchantCategoryCode; // Optional
  final String transactionCurrency;
  final String? transactionAmount; // Conditional
  final String countryCode;
  final String merchantName;
  final String? merchantCity; // Optional
  final String? merchantUssdDisplayedCode; // Mandatory, but can be optional in KeqrPayload if parser enforces
  final String? qrTimestampInformation; // Mandatory, but can be optional in KeqrPayload if parser enforces

  final AdditionalData? additionalData;
  final MerchantInformationLanguageTemplate? merchantInformationLanguageTemplate;
  final String? crc;

  KeqrPayload({
    required this.payloadFormatIndicator,
    required this.pointOfInitiationMethod,
    this.merchantCategoryCode,
    required this.transactionCurrency,
    this.transactionAmount,
    required this.countryCode,
    required this.merchantName,
    this.merchantCity,
    this.merchantUssdDisplayedCode,
    this.qrTimestampInformation,
    this.additionalData,
    this.merchantInformationLanguageTemplate,
    this.crc,
  });
}
