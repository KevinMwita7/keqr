import 'package:keqr/keqr.dart';

void main() {
  // Create a KeqrPayload object
  var payload = KeqrPayload(
    payloadFormatIndicator: '01',
    pointOfInitiationMethod: '12', // '11' for static, '12' for dynamic
    merchantCategoryCode: '4111', // Transportation
    transactionCurrency: '404', // Kenyan Shilling
    transactionAmount: '100.00',
    countryCode: 'KE',
    merchantName: 'Awesome Merchant',
    merchantCity: 'Nairobi',
  );

  // Generate the QR code string
  var qrCodeString = QrCodeGenerator.generate(payload);

  print('Generated QR Code String:');
  print(qrCodeString);

  // Parse the QR code string
  try {
    var parsedPayload = QrCodeParser.parse(qrCodeString);
    print('\nParsed Payload:');
    print('  Merchant Name: ${parsedPayload.merchantName}');
    print('  Transaction Amount: ${parsedPayload.transactionAmount}');
  } on UnimplementedError {
    print('\nParsing not yet implemented.');
  }
}