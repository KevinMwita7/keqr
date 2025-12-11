import 'package:keqr/keqr.dart';

void main() {
  final testQr = '00020101021228230008ke.go.qr0107444956229120008ke.go.qr5204000053034045802KE5921Faith Chepkirui Kirui610200620605020182320008ke.go.qr0116343122025 04124283380010m-pesa.com010202030500002040500000630425A7';

  print('''--- Attempting to parse provided QR code string ---''');
  print(testQr);

  try {
    var parsedPayload = QrCodeParser.parse(testQr);
    print('\nSuccessfully parsed QR Code String:');
    print('  Payload Format Indicator: ${parsedPayload.payloadFormatIndicator}');
    print('  Point of Initiation Method: ${parsedPayload.pointOfInitiationMethod}');
    print('  Merchant Category Code: ${parsedPayload.merchantCategoryCode ?? "N/A"}');
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
        print('        Globally Unique ID: ${account.globallyUniqueIdentifier ?? "N/A"}');
        if (account.paymentNetworkSpecificData.isNotEmpty) {
          print('        Payment Network Data: ${account.paymentNetworkSpecificData}');
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
      print('    Globally Unique ID: ${parsedPayload.merchantUssdInformation!.globallyUniqueIdentifier ?? "N/A"}');
      print('    Payment Network Data: ${parsedPayload.merchantUssdInformation!.paymentNetworkSpecificData}');
    }

    // Print QR Timestamp Information (nested)
    if (parsedPayload.qrTimestampInformation != null) {
      print('  QR Timestamp Information:');
      print('    Globally Unique ID: ${parsedPayload.qrTimestampInformation!.globallyUniqueIdentifier ?? "N/A"}');
      print('    Timestamp Data: ${parsedPayload.qrTimestampInformation!.timestampData}');
    }

    // Print Additional Templates (nested)
    if (parsedPayload.additionalTemplates != null && parsedPayload.additionalTemplates!.isNotEmpty) {
      print('  Additional Templates:');
      for (var i = 0; i < parsedPayload.additionalTemplates!.length; i++) {
        var template = parsedPayload.additionalTemplates![i];
        print('    [${i + 1}] Field ID: ${template.fieldId}');
        print('        Globally Unique ID: ${template.globallyUniqueIdentifier ?? "N/A"}');
        print('        Template Data: ${template.templateData}');
      }
    }

    if (parsedPayload.additionalData != null) {
      print('  Additional Data:');
      print('    Bill Number: ${parsedPayload.additionalData?.billNumber ?? "N/A"}');
      print('    Purpose of Transaction: ${parsedPayload.additionalData?.purposeOfTransaction ?? "N/A"}');
    }
    if (parsedPayload.merchantInformationLanguageTemplate != null) {
      print('  Merchant Information Language Template:');
      print('    Language Preference: ${parsedPayload.merchantInformationLanguageTemplate?.languagePreference ?? "N/A"}');
      print('    Merchant Name: ${parsedPayload.merchantInformationLanguageTemplate?.merchantName ?? "N/A"}');
      print('    Merchant City: ${parsedPayload.merchantInformationLanguageTemplate?.merchantCity ?? "N/A"}');
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
        globallyUniqueIdentifier: 'com.examplepsp.payments',
        paymentNetworkSpecificData: {
          '01': 'MERCHANT789012', // Payment network specific merchant ID
        },
      ),
    ],
    merchantCategoryCode: '4111', // Transportation (Optional now)
    transactionCurrency: '404', // Kenyan Shilling (ISO 4217 code)
    transactionAmount: '100.00', // Conditional
    countryCode: 'KE',
    merchantName: 'Generated Merchant',
    merchantCity: 'Nairobi', // Optional now
    merchantUssdInformation: MerchantUssdInformation(
      globallyUniqueIdentifier: 'com.examplepsp.ussd',
      paymentNetworkSpecificData: {
        '01': '*123#',
      },
    ),
    qrTimestampInformation: QrTimestampInformation(
      globallyUniqueIdentifier: 'com.examplepsp.timestamp',
      timestampData: {
        '01': '20231210103000',
      },
    ),
    additionalData: AdditionalData(
      billNumber: 'BILL123',
      purposeOfTransaction: 'Payment',
    ),
  );

  try {
    var generatedQrCode = QrCodeGenerator.generate(payloadToGenerate);
    print('Generated QR Code String:');
    print(generatedQrCode);

    // Also attempt to parse the generated QR code to verify
    var parsedGeneratedPayload = QrCodeParser.parse(generatedQrCode);
    print('\nSuccessfully parsed GENERATED QR Code String:');
    print('  Merchant Name: ${parsedGeneratedPayload.merchantName}');
    print('  Transaction Amount: ${parsedGeneratedPayload.transactionAmount}');
    if (parsedGeneratedPayload.merchantUssdInformation != null) {
      print('  Merchant USSD Information:');
      print('    Globally Unique ID: ${parsedGeneratedPayload.merchantUssdInformation!.globallyUniqueIdentifier}');
      print('    USSD Code: ${parsedGeneratedPayload.merchantUssdInformation!.paymentNetworkSpecificData['01']}');
    }
    if (parsedGeneratedPayload.qrTimestampInformation != null) {
      print('  QR Timestamp Information:');
      print('    Globally Unique ID: ${parsedGeneratedPayload.qrTimestampInformation!.globallyUniqueIdentifier}');
      print('    Timestamp: ${parsedGeneratedPayload.qrTimestampInformation!.timestampData['01']}');
    }
  } catch (e) {
    print('\nError generating or parsing generated QR code: $e');
  }
}
