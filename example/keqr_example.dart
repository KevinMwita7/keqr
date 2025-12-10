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
    print('  Merchant USSD Displayed Code: ${parsedPayload.merchantUssdDisplayedCode}');
    print('  QR Timestamp Information: ${parsedPayload.qrTimestampInformation}');

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
    merchantCategoryCode: '4111', // Transportation (Optional now)
    transactionCurrency: '356', // Kenyan Shilling
    transactionAmount: '100.00', // Conditional
    countryCode: 'KE',
    merchantName: 'Generated Merchant',
    merchantCity: 'Nairobi', // Optional now
    merchantUssdDisplayedCode: '123456', // Mandatory
    qrTimestampInformation: '20231210103000', // Mandatory
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
    print('  Merchant USSD Displayed Code: ${parsedGeneratedPayload.merchantUssdDisplayedCode}');
  } catch (e) {
    print('\nError generating or parsing generated QR code: $e');
  }
}
