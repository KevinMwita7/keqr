import 'dart:convert';
import 'package:crclib/catalog.dart';
import '../models/additional_data.dart';
import '../models/keqr_payload.dart';
import '../models/merchant_information_language_template.dart';

class QrCodeParser {
  static KeqrPayload parse(String qrCode) {
    final payloadWithoutCrc = qrCode.substring(0, qrCode.length - 8);
    final crcData = qrCode.substring(qrCode.length - 8);

    if (crcData.substring(0, 2) != '63' || crcData.substring(2, 4) != '04') {
      throw ArgumentError('Invalid CRC tag or length');
    }

    final crcValue = crcData.substring(4);

    var calculatedCrc = Crc16CcittFalse().convert(utf8.encode(payloadWithoutCrc + '6304'));
    var calculatedCrcString =
        calculatedCrc.toRadixString(16).toUpperCase().padLeft(4, '0');

    if (calculatedCrcString != crcValue) {
      throw ArgumentError('Invalid CRC');
    }

    var data = _parseTlv(payloadWithoutCrc);

    AdditionalData? additionalData;
    if (data.containsKey('62')) {
      var additionalDataMap = _parseTlv(data['62']!);
      additionalData = AdditionalData(
        billNumber: additionalDataMap['01'],
        mobileNumber: additionalDataMap['02'],
        storeLabel: additionalDataMap['03'],
        loyaltyNumber: additionalDataMap['04'],
        referenceLabel: additionalDataMap['05'],
        customerLabel: additionalDataMap['06'],
        terminalLabel: additionalDataMap['07'],
        purposeOfTransaction: additionalDataMap['08'],
        additionalConsumerDataRequest: additionalDataMap['09'],
      );
    }

    MerchantInformationLanguageTemplate? merchantInformationLanguageTemplate;
    if (data.containsKey('64')) {
      var merchantInfoMap = _parseTlv(data['64']!);
      merchantInformationLanguageTemplate = MerchantInformationLanguageTemplate(
        languagePreference: merchantInfoMap['00']!,
        merchantName: merchantInfoMap['01']!,
        merchantCity: merchantInfoMap['02']!,
      );
    }

    return KeqrPayload(
      payloadFormatIndicator: data['00']!,
      pointOfInitiationMethod: data['01']!,
      merchantCategoryCode: data['52']!,
      transactionCurrency: data['53']!,
      transactionAmount: data['54'],
      countryCode: data['58']!,
      merchantName: data['59']!,
      merchantCity: data['60']!,
      additionalData: additionalData,
      merchantInformationLanguageTemplate: merchantInformationLanguageTemplate,
      crc: crcValue,
    );
  }

  static Map<String, String> _parseTlv(String data) {
    var map = <String, String>{};
    var i = 0;
    while (i < data.length) {
      var tag = data.substring(i, i + 2);
      var length = int.parse(data.substring(i + 2, i + 4));
      var value = data.substring(i + 4, i + 4 + length);
      map[tag] = value;
      i += 4 + length;
    }
    return map;
  }
}
