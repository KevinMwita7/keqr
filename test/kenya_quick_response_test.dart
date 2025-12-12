import 'package:kenya_quick_response/kenya_quick_response.dart';
import 'package:test/test.dart';

void main() {
  group('QR Code Generation and Parsing', () {
    test('Round-trip test', () {
      final payload = KenyaQuickResponsePayload(
        payloadFormatIndicator: '01',
        pointOfInitiationMethod: '12',
        merchantAccountInformation: [
          MerchantAccountInformation(
            fieldId: '28',
            globallyUniqueIdentifier: 'com.testpsp.payments',
            paymentNetworkSpecificData: {'01': 'MERCHANT123456'},
          ),
        ],
        merchantCategoryCode: '4111',
        transactionCurrency: '404',
        transactionAmount: '100.00',
        tipOrConvenienceIndicator:
            TipOrConvenienceIndicator.fixedConvenienceFee,
        convenienceFeeFixed: '10.00',
        countryCode: 'KE',
        merchantName: 'Awesome Merchant',
        merchantCity: 'Nairobi',
        postalCode: '00100',
        merchantUssdInformation: MerchantUssdInformation(
          globallyUniqueIdentifier: 'com.testpsp.ussd',
          paymentNetworkSpecificData: {'01': '*123#'},
        ),
        qrTimestampInformation: QrTimestampInformation(
          globallyUniqueIdentifier: 'com.testpsp.timestamp',
          timestampData: {'01': '20231215120000'},
        ),
        additionalData: AdditionalData(
          billNumber: '12345',
          purposeOfTransaction: 'Test Transaction',
        ),
        merchantInformationLanguageTemplate:
            MerchantInformationLanguageTemplate(
              languagePreference: 'EN',
              merchantName: 'Awesome Merchant',
              merchantCity: 'Nairobi',
            ),
        merchantPremisesLocation: MerchantPremisesLocation(
          locationDataProvider: LocationDataProvider.gpsCoordinates,
          locationData: '-1.286389,36.817223',
          locationAccuracy: '10',
        ),
      );

      final qrCodeString = QrCodeGenerator.generate(payload);
      final parsedPayload = QrCodeParser.parse(qrCodeString);

      expect(
        parsedPayload.payloadFormatIndicator,
        payload.payloadFormatIndicator,
      );
      expect(
        parsedPayload.pointOfInitiationMethod,
        payload.pointOfInitiationMethod,
      );

      // Verify merchant account information
      expect(parsedPayload.merchantAccountInformation.length, 1);
      expect(parsedPayload.merchantAccountInformation[0].fieldId, '28');
      expect(
        parsedPayload.merchantAccountInformation[0].globallyUniqueIdentifier,
        'com.testpsp.payments',
      );
      expect(
        parsedPayload
            .merchantAccountInformation[0]
            .paymentNetworkSpecificData['01'],
        'MERCHANT123456',
      );
      expect(parsedPayload.merchantAccountInformation[0].isPspAccount, true);

      expect(parsedPayload.merchantCategoryCode, payload.merchantCategoryCode);
      expect(parsedPayload.transactionCurrency, payload.transactionCurrency);
      expect(parsedPayload.transactionAmount, payload.transactionAmount);
      expect(
        parsedPayload.tipOrConvenienceIndicator,
        payload.tipOrConvenienceIndicator,
      );
      expect(parsedPayload.convenienceFeeFixed, payload.convenienceFeeFixed);
      expect(parsedPayload.countryCode, payload.countryCode);
      expect(parsedPayload.merchantName, payload.merchantName);
      expect(parsedPayload.merchantCity, payload.merchantCity);
      expect(parsedPayload.postalCode, payload.postalCode);

      // Verify nested USSD information
      expect(
        parsedPayload.merchantUssdInformation?.globallyUniqueIdentifier,
        payload.merchantUssdInformation?.globallyUniqueIdentifier,
      );
      expect(
        parsedPayload.merchantUssdInformation?.paymentNetworkSpecificData['01'],
        payload.merchantUssdInformation?.paymentNetworkSpecificData['01'],
      );

      // Verify nested timestamp information
      expect(
        parsedPayload.qrTimestampInformation?.globallyUniqueIdentifier,
        payload.qrTimestampInformation?.globallyUniqueIdentifier,
      );
      expect(
        parsedPayload.qrTimestampInformation?.timestampData['01'],
        payload.qrTimestampInformation?.timestampData['01'],
      );

      expect(
        parsedPayload.additionalData?.billNumber,
        payload.additionalData?.billNumber,
      );
      expect(
        parsedPayload.additionalData?.purposeOfTransaction,
        payload.additionalData?.purposeOfTransaction,
      );
      expect(
        parsedPayload.merchantInformationLanguageTemplate?.languagePreference,
        payload.merchantInformationLanguageTemplate?.languagePreference,
      );
      expect(
        parsedPayload.merchantInformationLanguageTemplate?.merchantName,
        payload.merchantInformationLanguageTemplate?.merchantName,
      );
      expect(
        parsedPayload.merchantInformationLanguageTemplate?.merchantCity,
        payload.merchantInformationLanguageTemplate?.merchantCity,
      );

      // Verify Merchant Premises Location
      expect(
        parsedPayload.merchantPremisesLocation?.locationDataProvider,
        payload.merchantPremisesLocation?.locationDataProvider,
      );
      expect(
        parsedPayload.merchantPremisesLocation?.locationData,
        payload.merchantPremisesLocation?.locationData,
      );
      expect(
        parsedPayload.merchantPremisesLocation?.locationAccuracy,
        payload.merchantPremisesLocation?.locationAccuracy,
      );
    });

    test('Round-trip test with merchantTaxId and merchantChannel', () {
      final payload = KenyaQuickResponsePayload(
        payloadFormatIndicator: '01',
        pointOfInitiationMethod: '12',
        merchantAccountInformation: [
          MerchantAccountInformation(
            fieldId: '28',
            globallyUniqueIdentifier: 'com.testpsp.payments',
            paymentNetworkSpecificData: {'01': 'MERCHANT123456'},
          ),
        ],
        transactionCurrency: '404',
        countryCode: 'KE',
        merchantName: 'Test Merchant',
        merchantUssdInformation: MerchantUssdInformation(
          globallyUniqueIdentifier: 'com.testpsp.ussd',
          paymentNetworkSpecificData: {'01': '*123#'},
        ),
        qrTimestampInformation: QrTimestampInformation(
          globallyUniqueIdentifier: 'com.testpsp.timestamp',
          timestampData: {'01': '20231215120000'},
        ),
        additionalData: AdditionalData(
          merchantTaxId: 'TAX12345',
          merchantChannel: MerchantChannelBuilder.build(
            MerchantChannelMedia.printSticker,
            MerchantChannelScanLocation.atMerchantPremises,
            MerchantChannelPresence.attended,
          ),
        ),
      );

      final qrCodeString = QrCodeGenerator.generate(payload);
      final parsedPayload = QrCodeParser.parse(qrCodeString);

      expect(parsedPayload.additionalData?.merchantTaxId, 'TAX12345');
      expect(parsedPayload.additionalData?.merchantChannel, '000');
    });
  });

  group('AdditionalData Validation', () {
    test('merchantTaxId accepts valid alphanumeric up to 20 characters', () {
      expect(
        () => AdditionalData(merchantTaxId: 'ABC123XYZ789'),
        returnsNormally,
      );
      expect(
        () => AdditionalData(merchantTaxId: '12345678901234567890'),
        returnsNormally,
      );
    });

    test('merchantTaxId rejects over 20 characters', () {
      expect(
        () => AdditionalData(merchantTaxId: '123456789012345678901'),
        throwsArgumentError,
      );
    });

    test('merchantTaxId rejects non-alphanumeric', () {
      expect(
        () => AdditionalData(merchantTaxId: 'ABC-123'),
        throwsArgumentError,
      );
      expect(
        () => AdditionalData(merchantTaxId: 'ABC 123'),
        throwsArgumentError,
      );
    });

    test('merchantChannel accepts valid 3-digit codes', () {
      expect(() => AdditionalData(merchantChannel: '001'), returnsNormally);
      expect(() => AdditionalData(merchantChannel: '830'), returnsNormally);
    });

    test('merchantChannel rejects invalid length', () {
      expect(() => AdditionalData(merchantChannel: '01'), throwsArgumentError);
      expect(
        () => AdditionalData(merchantChannel: '0011'),
        throwsArgumentError,
      );
    });

    test('merchantChannel rejects non-numeric', () {
      expect(() => AdditionalData(merchantChannel: 'ABC'), throwsArgumentError);
    });

    test('merchantChannel validates position 1 (media) range 0-8', () {
      expect(() => AdditionalData(merchantChannel: '801'), returnsNormally);
      expect(() => AdditionalData(merchantChannel: '901'), throwsArgumentError);
    });

    test('merchantChannel validates position 2 (scan location) range 0-3', () {
      expect(() => AdditionalData(merchantChannel: '031'), returnsNormally);
      expect(() => AdditionalData(merchantChannel: '041'), throwsArgumentError);
    });

    test(
      'merchantChannel validates position 3 (merchant presence) range 0-3',
      () {
        expect(() => AdditionalData(merchantChannel: '003'), returnsNormally);
        expect(
          () => AdditionalData(merchantChannel: '004'),
          throwsArgumentError,
        );
      },
    );
  });

  group('MerchantChannelBuilder', () {
    test('builds correct channel codes', () {
      // Print sticker at merchant premises, attended
      expect(
        MerchantChannelBuilder.build(
          MerchantChannelMedia.printSticker,
          MerchantChannelScanLocation.atMerchantPremises,
          MerchantChannelPresence.attended,
        ),
        '000',
      );

      // App at merchant premises, unattended
      expect(
        MerchantChannelBuilder.build(
          MerchantChannelMedia.screenApp,
          MerchantChannelScanLocation.atMerchantPremises,
          MerchantChannelPresence.unattended,
        ),
        '601',
      );

      // ATM at remote commerce, semi-attended
      expect(
        MerchantChannelBuilder.build(
          MerchantChannelMedia.screenAtm,
          MerchantChannelScanLocation.remoteCommerce,
          MerchantChannelPresence.semiAttended,
        ),
        '822',
      );
    });
  });
}
