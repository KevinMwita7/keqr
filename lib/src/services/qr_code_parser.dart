import 'dart:convert';
import 'package:crclib/catalog.dart';
import '../models/additional_data.dart';
import '../models/kenya_quick_response_payload.dart';
import '../models/merchant_account_information.dart';
import '../models/merchant_information_language_template.dart';
import '../models/merchant_premises_location.dart';
import '../models/merchant_ussd_information.dart';
import '../models/qr_timestamp_information.dart';
import '../models/template_information.dart';
import '../models/tip_or_convenience_indicator.dart';

class QrCodeParser {
  static KenyaQuickResponsePayload parse(String qrCode) {
    // Check for minimum length (e.g., Payload Format Indicator + CRC)
    if (qrCode.length < 12) {
      // 000201 + 6304XXXX
      throw ArgumentError('QR code string is too short to be valid.');
    }

    final payloadWithoutCrc = qrCode.substring(0, qrCode.length - 8);
    final crcData = qrCode.substring(qrCode.length - 8);

    if (crcData.substring(0, 2) != '63' || crcData.substring(2, 4) != '04') {
      throw ArgumentError('Invalid CRC tag or length for the CRC block.');
    }

    final crcValue = crcData.substring(4);

    var calculatedCrc = Crc16CcittFalse().convert(
      utf8.encode('${payloadWithoutCrc}6304'),
    );
    var calculatedCrcString = calculatedCrc
        .toRadixString(16)
        .toUpperCase()
        .padLeft(4, '0');

    if (calculatedCrcString != crcValue) {
      throw ArgumentError(
        'CRC mismatch: Expected $calculatedCrcString, got $crcValue',
      );
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

    // Check if this is an M-Pesa QR code
    bool isMpesaQr =
        data.containsKey('83') && data['83']!.contains('m-pesa.com');

    // Parse Merchant Account Information (Fields 02-51)
    // According to KE-QR Standard Table 7.3, at least one MUST be present
    var merchantAccountInformation = <MerchantAccountInformation>[];
    for (var i = 2; i <= 51; i++) {
      var fieldId = i.toString().padLeft(2, '0');
      if (data.containsKey(fieldId)) {
        var merchantAccountData = _parseTlv(data[fieldId]!);
        merchantAccountInformation.add(
          MerchantAccountInformation(
            fieldId: fieldId,
            globallyUniqueIdentifier: merchantAccountData['00'],
            paymentNetworkSpecificData: Map.from(merchantAccountData)
              ..remove('00'),
          ),
        );
      }
    }

    // Validate that at least one merchant account field is present
    if (merchantAccountInformation.isEmpty) {
      throw ArgumentError(
        'At least one Merchant Account Information field (02-51) must be present according to KE-QR Standard Table 7.3.',
      );
    }

    TipOrConvenienceIndicator? tipOrConvenienceIndicator;
    if (data.containsKey('55')) {
      switch (data['55']) {
        case '01':
          tipOrConvenienceIndicator =
              TipOrConvenienceIndicator.promptToEnterTip;
          break;
        case '02':
          tipOrConvenienceIndicator =
              TipOrConvenienceIndicator.fixedConvenienceFee;
          break;
        case '03':
          tipOrConvenienceIndicator =
              TipOrConvenienceIndicator.percentageConvenienceFee;
          break;
      }
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
        merchantTaxId: additionalDataMap['10'],
        merchantChannel: additionalDataMap['11'],
      );
    }

    MerchantInformationLanguageTemplate? merchantInformationLanguageTemplate;
    if (data.containsKey('64')) {
      var merchantInfoMap = _parseTlv(data['64']!);
      // Create a local helper function for getRequired on merchantInfoMap
      String getRequiredMerchantInfo(String tag, String fieldName) {
        if (!merchantInfoMap.containsKey(tag) ||
            merchantInfoMap[tag]!.isEmpty) {
          throw ArgumentError(
            'Missing or empty $fieldName (Tag $tag) in Merchant Information Language Template.',
          );
        }
        return merchantInfoMap[tag]!;
      }

      merchantInformationLanguageTemplate = MerchantInformationLanguageTemplate(
        languagePreference: getRequiredMerchantInfo(
          '00',
          'Language Preference',
        ),
        merchantName: getRequiredMerchantInfo('01', 'Merchant Name'),
        merchantCity: getRequiredMerchantInfo('02', 'Merchant City'),
      );
    }

    MerchantPremisesLocation? merchantPremisesLocation;
    if (data.containsKey('80')) {
      var locationMap = _parseTlv(data['80']!);
      LocationDataProvider? provider;
      if (locationMap.containsKey('01')) {
        switch (locationMap['01']) {
          case '01':
            provider = LocationDataProvider.gpsCoordinates;
            break;
          case '02':
            provider = LocationDataProvider.what3words;
            break;
          case '03':
            provider = LocationDataProvider.googlePlusCodes;
            break;
        }
      }
      merchantPremisesLocation = MerchantPremisesLocation(
        locationDataProvider: provider,
        locationData: locationMap['02'],
        locationAccuracy: locationMap['03'],
      );
    }

    // Parse Field 81: Merchant USSD Information (nested TLV)
    MerchantUssdInformation? merchantUssdInformation;
    if (data.containsKey('81')) {
      var ussdData = _parseTlv(data['81']!);
      merchantUssdInformation = MerchantUssdInformation(
        globallyUniqueIdentifier: ussdData['00'],
        paymentNetworkSpecificData: Map.from(ussdData)..remove('00'),
      );
    } else if (!isMpesaQr) {
      throw ArgumentError('Merchant USSD Information (Tag 81) is mandatory.');
    }

    // Parse Field 82: QR Timestamp Information (nested TLV)
    QrTimestampInformation? qrTimestampInformation;
    if (data.containsKey('82')) {
      var timestampData = _parseTlv(data['82']!);
      qrTimestampInformation = QrTimestampInformation(
        globallyUniqueIdentifier: timestampData['00'],
        timestampData: Map.from(timestampData)..remove('00'),
      );
    } else if (!isMpesaQr) {
      throw ArgumentError('QR Timestamp Information (Tag 82) is mandatory.');
    }

    // Parse Fields 83-99: Additional Templates (nested TLV)
    var additionalTemplates = <TemplateInformation>[];
    for (var i = 83; i <= 99; i++) {
      var fieldId = i.toString().padLeft(2, '0');
      if (data.containsKey(fieldId)) {
        var templateData = _parseTlv(data[fieldId]!);
        additionalTemplates.add(
          TemplateInformation(
            fieldId: fieldId,
            globallyUniqueIdentifier: templateData['00'],
            templateData: Map.from(templateData)..remove('00'),
          ),
        );
      }
    }

    return KenyaQuickResponsePayload(
      payloadFormatIndicator: getRequired('00', 'Payload Format Indicator'),
      pointOfInitiationMethod: getRequired('01', 'Point of Initiation Method'),
      merchantAccountInformation: merchantAccountInformation,
      merchantCategoryCode: data['52'], // Optional field
      transactionCurrency: getRequired('53', 'Transaction Currency'),
      transactionAmount: data['54'], // Conditional field
      tipOrConvenienceIndicator: tipOrConvenienceIndicator,
      convenienceFeeFixed: data['56'],
      convenienceFeePercentage: data['57'],
      countryCode: getRequired('58', 'Country Code'),
      merchantName: getRequired('59', 'Merchant Name'),
      merchantCity: data['60'], // Optional field
      postalCode: data['61'], // Optional field
      merchantUssdInformation: merchantUssdInformation,
      qrTimestampInformation: qrTimestampInformation,
      additionalTemplates: additionalTemplates.isNotEmpty
          ? additionalTemplates
          : null,
      additionalData: additionalData,
      merchantInformationLanguageTemplate: merchantInformationLanguageTemplate,
      merchantPremisesLocation: merchantPremisesLocation,
      crc: crcValue,
    );
  }

  static Map<String, String> _parseTlv(String data) {
    var map = <String, String>{};
    var i = 0;
    while (i < data.length) {
      if (i + 4 > data.length) {
        throw ArgumentError(
          'Malformed TLV string: Not enough characters for tag and length at index $i.',
        );
      }
      var tag = data.substring(i, i + 2);
      var lengthStr = data.substring(i + 2, i + 4);
      int length;
      try {
        length = int.parse(lengthStr);
      } catch (e) {
        throw ArgumentError(
          'Malformed TLV string: Invalid length "$lengthStr" for tag "$tag" at index $i.',
        );
      }

      if (i + 4 + length > data.length) {
        throw ArgumentError(
          'Malformed TLV string: Declared length $length for tag $tag exceeds available data at index $i. (Remaining: ${data.substring(i)})',
        );
      }
      var value = data.substring(i + 4, i + 4 + length);
      map[tag] = value;
      i += 4 + length;
    }
    return map;
  }
}
