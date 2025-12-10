import 'additional_data.dart';
import 'merchant_information_language_template.dart';

class KeqrPayload {
  final String payloadFormatIndicator;
  final String pointOfInitiationMethod;
  final String merchantCategoryCode;
  final String transactionCurrency;
  final String? transactionAmount;
  final String countryCode;
  final String merchantName;
  final String merchantCity;
  final AdditionalData? additionalData;
  final MerchantInformationLanguageTemplate? merchantInformationLanguageTemplate;
  final String? crc;

  KeqrPayload({
    required this.payloadFormatIndicator,
    required this.pointOfInitiationMethod,
    required this.merchantCategoryCode,
    required this.transactionCurrency,
    this.transactionAmount,
    required this.countryCode,
    required this.merchantName,
    required this.merchantCity,
    this.additionalData,
    this.merchantInformationLanguageTemplate,
    this.crc,
  });
}