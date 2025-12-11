import 'package:keqr/keqr.dart';

void main() {
  // The following testQr string has been sanitized to remove PII.
  final testQr =
      '00020101021228230008ke.go.qr0107987654329120008ke.go.qr5204000053034045802KE5921Jane Elizabeth Doe_Po610200620605020182320008ke.go.qr0116343122025 04124283380010m-pesa.com01020203050000204050000063041307';

  print('''--- Attempting to parse provided QR code string ---''');
  print(testQr);

  try {
    var parsedPayload = QrCodeParser.parse(testQr);
    print('\nSuccessfully parsed QR Code String:');
    print('  Payload Format Indicator: ${parsedPayload.payloadFormatIndicator}');
    print(
        '  Point of Initiation Method: ${parsedPayload.pointOfInitiationMethod}');
    print(
        '  Merchant Category Code: ${parsedPayload.merchantCategoryCode ?? "N/A"}');
    print('  Transaction Currency: ${parsedPayload.transactionCurrency}');
    print('  Transaction Amount: ${parsedPayload.transactionAmount ?? "N/A"}');
    print('  Country Code: ${parsedPayload.countryCode}');
    print('  Merchant Name: ${parsedPayload.merchantName}');
    print('  Merchant City: ${parsedPayload.merchantCity ?? "N/A"}');

    // Print Merchant Account Information
    if (parsedPayload.merchantAccountInformation.isNotEmpty) {
      print('  Merchant Account Information:');
      for (var i = 0; i < parsedPayload.merchantAccountInformation.length; i++) {
        var account = parsedPayload.merchantAccountInformation[i];
        print('    [${i + 1}] Field ID: ${account.fieldId}');
        print(
            '        Globally Unique ID: ${account.globallyUniqueIdentifier ?? "N/A"}');
        if (account.paymentNetworkSpecificData.isNotEmpty) {
          print(
              '        Payment Network Data: ${account.paymentNetworkSpecificData}');
        }
        if (account.isPspAccount) {
          print('        Type: PSP Merchant Account');
        } else if (account.isBankWalletAccount) {
          print('        Type: Bank Wallet Merchant Account');
        }
      }
    }

    // Print Merchant USSD Information (nested)
    if (parsedPayload.merchantUssdInformation != null) {
      print('  Merchant USSD Information:');
      print(
          '    Globally Unique ID: ${parsedPayload.merchantUssdInformation!.globallyUniqueIdentifier ?? "N/A"}');
      print(
          '    Payment Network Data: ${parsedPayload.merchantUssdInformation!.paymentNetworkSpecificData}');
    }

    // Print QR Timestamp Information (nested)
    if (parsedPayload.qrTimestampInformation != null) {
      print('  QR Timestamp Information:');
      print(
          '    Globally Unique ID: ${parsedPayload.qrTimestampInformation!.globallyUniqueIdentifier ?? "N/A"}');
      print(
          '    Timestamp Data: ${parsedPayload.qrTimestampInformation!.timestampData}');
    }

    // Print Additional Templates (nested)
    if (parsedPayload.additionalTemplates != null &&
        parsedPayload.additionalTemplates!.isNotEmpty) {
      print('  Additional Templates:');
      for (var i = 0; i < parsedPayload.additionalTemplates!.length; i++) {
        var template = parsedPayload.additionalTemplates![i];
        print('    [${i + 1}] Field ID: ${template.fieldId}');
        print(
            '        Globally Unique ID: ${template.globallyUniqueIdentifier ?? "N/A"}');
        print('        Template Data: ${template.templateData}');
      }
    }

    if (parsedPayload.additionalData != null) {
      print('  Additional Data:');
      print(
          '    Bill Number: ${parsedPayload.additionalData?.billNumber ?? "N/A"}');
      print(
          '    Purpose of Transaction: ${parsedPayload.additionalData?.purposeOfTransaction ?? "N/A"}');
      print(
          '    Merchant Tax ID: ${parsedPayload.additionalData?.merchantTaxId ?? "N/A"}');
      print(
          '    Merchant Channel: ${parsedPayload.additionalData?.merchantChannel ?? "N/A"}');
    }
    if (parsedPayload.merchantInformationLanguageTemplate != null) {
      print('  Merchant Information Language Template:');
      print(
          '    Language Preference: ${parsedPayload.merchantInformationLanguageTemplate?.languagePreference ?? "N/A"}');
      print(
          '    Merchant Name: ${parsedPayload.merchantInformationLanguageTemplate?.merchantName ?? "N/A"}');
      print(
          '    Merchant City: ${parsedPayload.merchantInformationLanguageTemplate?.merchantCity ?? "N/A"}');
    }
    print('  CRC: ${parsedPayload.crc}');
  } catch (e) {
    print('\nError parsing QR code: $e');
  }

  print('\n--- Attempting to generate a new QR code string ---');
  // Create a KeqrPayload object for generation
  var payloadToGenerate = KeqrPayload(
    payloadFormatIndicator: '01',
    pointOfInitiationMethod: '12', // '11' for static, '12' for dynamic
    merchantAccountInformation: [
      MerchantAccountInformation(
        fieldId: '28', // PSP merchant account identifier
        globallyUniqueIdentifier: 'ke.go.qr',
        paymentNetworkSpecificData: {
          '01': '4449562', // Payment network specific merchant ID
        },
      )
    ],
    merchantCity: 'Nairobi',
    merchantUssdInformation: MerchantUssdInformation(
      globallyUniqueIdentifier: 'ke.go.qr',
      paymentNetworkSpecificData: {
        '00': '*123#'
      }
    ),
    transactionAmount: '100.00',
    merchantCategoryCode: '0000', // Transportation (Optional now)
    transactionCurrency: '404', // Kenyan Shilling (ISO 4217 code)
    countryCode: 'KE',
    merchantName: '',
    postalCode: '00',
    qrTimestampInformation: QrTimestampInformation(
      globallyUniqueIdentifier: 'ke.go.qr',
      timestampData: {
        '01': '2025-12-11T12:56:36',
      },
    ),
    // M-PESA doesn't support the merchant premise location. In case it's needed later, include it here
    /*merchantPremisesLocation: MerchantPremisesLocation(
      locationDataProvider: LocationDataProvider.gpsCoordinates,
      locationData: '-1.284680,36.825531'
    ),*/
    additionalData: AdditionalData(
      // On M-PESA, 01 represents till numbers, while 04 represents mobile numbers
      referenceLabel: '01',
      // Merchant Tax ID (Subfield 10) - Kenya IPRS/BRS identifier
      merchantTaxId: 'A123456789',
      // Merchant Channel (Subfield 11) - Use helper to build valid channel
      // '000' = Print sticker at merchant premises, attended
      merchantChannel: MerchantChannelBuilder.build(
        MerchantChannelMedia.printSticker,
        MerchantChannelScanLocation.atMerchantPremises,
        MerchantChannelPresence.attended,
      ),
    ),
    additionalTemplates: [
      TemplateInformation(fieldId: '83', templateData: {'01': '02', '03': '00002', '04': '00000'}, globallyUniqueIdentifier: 'm-pesa.com')
    ]
  );

  try {
    var generatedQrCode = QrCodeGenerator.generate(payloadToGenerate);
    print('\nGenerated QR Code String:');
    print(generatedQrCode);

    // Also attempt to parse the generated QR code to verify
    var parsedGeneratedPayload = QrCodeParser.parse(generatedQrCode);
    print('\nSuccessfully parsed GENERATED QR Code String:');
    print('  Merchant Name: ${parsedGeneratedPayload.merchantName}');
    print('  Transaction Amount: ${parsedGeneratedPayload.transactionAmount}');
    if (parsedGeneratedPayload.merchantUssdInformation != null) {
      print('  Merchant USSD Information:');
      print(
          '    Globally Unique ID: ${parsedGeneratedPayload.merchantUssdInformation!.globallyUniqueIdentifier}');
      print(
          '    USSD Code: ${parsedGeneratedPayload.merchantUssdInformation!.paymentNetworkSpecificData['01']}');
    }
    if (parsedGeneratedPayload.qrTimestampInformation != null) {
      print('  QR Timestamp Information:');
      print(
          '    Globally Unique ID: ${parsedGeneratedPayload.qrTimestampInformation!.globallyUniqueIdentifier}');
      print(
          '    Timestamp: ${parsedGeneratedPayload.qrTimestampInformation!.timestampData['01']}');
    }
  } catch (e) {
    print('\nError generating or parsing generated QR code: $e');
  }
}
