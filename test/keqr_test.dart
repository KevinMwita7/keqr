import 'package:keqr/keqr.dart';
import 'package:test/test.dart';

void main() {
  group('QR Code Generation and Parsing', () {
    test('Round-trip test', () {
      final payload = KeqrPayload(
        payloadFormatIndicator: '01',
        pointOfInitiationMethod: '12',
        merchantCategoryCode: '4111',
        transactionCurrency: '356',
        transactionAmount: '100.00',
        countryCode: 'KE',
        merchantName: 'Awesome Merchant',
        merchantCity: 'Nairobi',
        additionalData: AdditionalData(
          billNumber: '12345',
          purposeOfTransaction: 'Test Transaction',
        ),
        merchantInformationLanguageTemplate: MerchantInformationLanguageTemplate(
          languagePreference: 'EN',
          merchantName: 'Awesome Merchant',
          merchantCity: 'Nairobi',
        ),
      );

      final qrCodeString = QrCodeGenerator.generate(payload);
      final parsedPayload = QrCodeParser.parse(qrCodeString);

      expect(parsedPayload.payloadFormatIndicator, payload.payloadFormatIndicator);
      expect(parsedPayload.pointOfInitiationMethod, payload.pointOfInitiationMethod);
      expect(parsedPayload.merchantCategoryCode, payload.merchantCategoryCode);
      expect(parsedPayload.transactionCurrency, payload.transactionCurrency);
      expect(parsedPayload.transactionAmount, payload.transactionAmount);
      expect(parsedPayload.countryCode, payload.countryCode);
      expect(parsedPayload.merchantName, payload.merchantName);
      expect(parsedPayload.merchantCity, payload.merchantCity);
      expect(parsedPayload.additionalData?.billNumber, payload.additionalData?.billNumber);
      expect(parsedPayload.additionalData?.purposeOfTransaction, payload.additionalData?.purposeOfTransaction);
      expect(parsedPayload.merchantInformationLanguageTemplate?.languagePreference,
          payload.merchantInformationLanguageTemplate?.languagePreference);
      expect(parsedPayload.merchantInformationLanguageTemplate?.merchantName,
          payload.merchantInformationLanguageTemplate?.merchantName);
      expect(parsedPayload.merchantInformationLanguageTemplate?.merchantCity,
          payload.merchantInformationLanguageTemplate?.merchantCity);
    });
  });
}
