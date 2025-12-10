import 'dart:convert';
import 'package:crclib/catalog.dart';
import '../models/additional_data.dart';
import '../models/keqr_payload.dart';
import '../models/merchant_information_language_template.dart';

class QrCodeParser {
  static KeqrPayload parse(String qrCode) {
    // Check for minimum length (e.g., Payload Format Indicator + CRC)
    if (qrCode.length < 12) { // 000201 + 6304XXXX
      throw ArgumentError('QR code string is too short to be valid.');
    }

    final payloadWithoutCrc = qrCode.substring(0, qrCode.length - 8);
    final crcData = qrCode.substring(qrCode.length - 8);

    if (crcData.substring(0, 2) != '63' || crcData.substring(2, 4) != '04') {
      throw ArgumentError('Invalid CRC tag or length for the CRC block.');
    }

    final crcValue = crcData.substring(4);

    var calculatedCrc = Crc16CcittFalse().convert(utf8.encode(payloadWithoutCrc + '6304'));
    var calculatedCrcString =
        calculatedCrc.toRadixString(16).toUpperCase().padLeft(4, '0');

    if (calculatedCrcString != crcValue) {
      throw ArgumentError('CRC mismatch: Expected $calculatedCrcString, got $crcValue');
    }

    var data = _parseTlv(payloadWithoutCrc);
    // print('Parsed top-level data: $data'); // Debug print - removed for clean output

    // Helper function to get required value or throw error
    String getRequired(String tag, String fieldName) {
      if (!data.containsKey(tag) || data[tag]!.isEmpty) {
        throw ArgumentError('Missing or empty $fieldName (Tag $tag).');
      }
      return data[tag]!;
    }

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
        languagePreference: getRequired('00', 'Language Preference'),
        merchantName: getRequired('01', 'Merchant Name'),
        merchantCity: getRequired('02', 'Merchant City'),
      );
    }

    return KeqrPayload(
      payloadFormatIndicator: getRequired('00', 'Payload Format Indicator'),
      pointOfInitiationMethod: getRequired('01', 'Point of Initiation Method'),
      merchantCategoryCode: data['52'], // Optional field
      transactionCurrency: getRequired('53', 'Transaction Currency'),
      transactionAmount: data['54'], // Conditional field
      countryCode: getRequired('58', 'Country Code'),
      merchantName: getRequired('59', 'Merchant Name'),
      merchantCity: data['60'], // Optional field
      merchantUssdDisplayedCode: getRequired('81', 'Merchant USSD Displayed Code'), // Mandatory field
      qrTimestampInformation: getRequired('82', 'QR Timestamp Information'), // Mandatory field
      additionalData: additionalData,
      merchantInformationLanguageTemplate: merchantInformationLanguageTemplate,
      crc: crcValue,
    );
  }

  static Map<String, String> _parseTlv(String data) {
    var map = <String, String>{};
    var i = 0;
    while (i < data.length) {
      if (i + 4 > data.length) {
        throw ArgumentError('Malformed TLV string: Not enough characters for tag and length at index $i.');
      }
      var tag = data.substring(i, i + 2);
      var lengthStr = data.substring(i + 2, i + 4);
      int length;
      try {
        length = int.parse(lengthStr);
      } catch (e) {
        throw ArgumentError('Malformed TLV string: Invalid length "$lengthStr" for tag "$tag" at index $i.');
      }

      if (i + 4 + length > data.length) {
        throw ArgumentError('Malformed TLV string: Declared length $length for tag $tag exceeds available data at index $i. (Remaining: ${data.substring(i)})');
      }
      var value = data.substring(i + 4, i + 4 + length);
      map[tag] = value;
      i += 4 + length;
    }
    return map;
  }
}
