import 'dart:convert';
import 'package:crclib/catalog.dart';
import '../models/keqr_payload.dart';
import '../models/merchant_premises_location.dart';
import '../models/tip_or_convenience_indicator.dart';

class QrCodeGenerator {
  static String generate(KeqrPayload payload) {
    var parts = <String>[];

    // Mandatory fields
    parts.add(_tlv('00', payload.payloadFormatIndicator));
    parts.add(_tlv('01', payload.pointOfInitiationMethod));

    // Merchant Account Information (Fields 02-51) - At least one MUST be present
    if (payload.merchantAccountInformation.isEmpty) {
      throw ArgumentError(
        'At least one Merchant Account Information field (02-51) must be present according to KE-QR Standard Table 7.3.',
      );
    }

    // Generate TLV for each merchant account information field
    for (var merchantAccount in payload.merchantAccountInformation) {
      var merchantAccountParts = <String>[];

      // Add globally unique identifier (sub-tag 00) if present
      if (merchantAccount.globallyUniqueIdentifier != null) {
        merchantAccountParts.add(_tlv('00', merchantAccount.globallyUniqueIdentifier!));
      }

      // Add payment network specific data (sub-tags 01 and beyond)
      for (var entry in merchantAccount.paymentNetworkSpecificData.entries) {
        merchantAccountParts.add(_tlv(entry.key, entry.value));
      }

      parts.add(_tlv(merchantAccount.fieldId, merchantAccountParts.join()));
    }

    if (payload.merchantCategoryCode != null) {
      parts.add(_tlv('52', payload.merchantCategoryCode!));
    }

    parts.add(_tlv('53', payload.transactionCurrency));

    if (payload.transactionAmount != null) {
      parts.add(_tlv('54', payload.transactionAmount!));
    }

    if (payload.tipOrConvenienceIndicator != null) {
      String indicatorValue;
      switch (payload.tipOrConvenienceIndicator!) {
        case TipOrConvenienceIndicator.promptToEnterTip:
          indicatorValue = '01';
          parts.add(_tlv('55', indicatorValue));
          break;
        case TipOrConvenienceIndicator.fixedConvenienceFee:
          indicatorValue = '02';
          parts.add(_tlv('55', indicatorValue));
          if (payload.convenienceFeeFixed != null) {
            parts.add(_tlv('56', payload.convenienceFeeFixed!));
          }
          break;
        case TipOrConvenienceIndicator.percentageConvenienceFee:
          indicatorValue = '03';
          parts.add(_tlv('55', indicatorValue));
          if (payload.convenienceFeePercentage != null) {
            parts.add(_tlv('57', payload.convenienceFeePercentage!));
          }
          break;
      }
    }

    parts.add(_tlv('58', payload.countryCode));
    parts.add(_tlv('59', payload.merchantName));

    if (payload.merchantCity != null) {
      parts.add(_tlv('60', payload.merchantCity!));
    }
    if (payload.postalCode != null) {
      parts.add(_tlv('61', payload.postalCode!));
    }

    // Field 62
    if (payload.additionalData != null) {
      var additionalDataParts = <String>[];
      if (payload.additionalData!.billNumber != null) {
        additionalDataParts.add(_tlv('01', payload.additionalData!.billNumber!));
      }
      if (payload.additionalData!.mobileNumber != null) {
        additionalDataParts.add(_tlv('02', payload.additionalData!.mobileNumber!));
      }
      if (payload.additionalData!.storeLabel != null) {
        additionalDataParts.add(_tlv('03', payload.additionalData!.storeLabel!));
      }
      if (payload.additionalData!.loyaltyNumber != null) {
        additionalDataParts.add(_tlv('04', payload.additionalData!.loyaltyNumber!));
      }
      if (payload.additionalData!.referenceLabel != null) {
        additionalDataParts.add(_tlv('05', payload.additionalData!.referenceLabel!));
      }
      if (payload.additionalData!.customerLabel != null) {
        additionalDataParts.add(_tlv('06', payload.additionalData!.customerLabel!));
      }
      if (payload.additionalData!.terminalLabel != null) {
        additionalDataParts.add(_tlv('07', payload.additionalData!.terminalLabel!));
      }
      if (payload.additionalData!.purposeOfTransaction != null) {
        additionalDataParts.add(_tlv('08', payload.additionalData!.purposeOfTransaction!));
      }
      if (payload.additionalData!.additionalConsumerDataRequest != null) {
        additionalDataParts.add(_tlv('09', payload.additionalData!.additionalConsumerDataRequest!));
      }
      if (payload.additionalData!.merchantTaxId != null) {
        additionalDataParts.add(_tlv('10', payload.additionalData!.merchantTaxId!));
      }
      if (payload.additionalData!.merchantChannel != null) {
        additionalDataParts.add(_tlv('11', payload.additionalData!.merchantChannel!));
      }
      parts.add(_tlv('62', additionalDataParts.join()));
    }

    // Field 64
    if (payload.merchantInformationLanguageTemplate != null) {
      var merchantInfoParts = <String>[];
      merchantInfoParts.add(_tlv('00', payload.merchantInformationLanguageTemplate!.languagePreference));
      merchantInfoParts.add(_tlv('01', payload.merchantInformationLanguageTemplate!.merchantName));
      merchantInfoParts.add(_tlv('02', payload.merchantInformationLanguageTemplate!.merchantCity));
      parts.add(_tlv('64', merchantInfoParts.join()));
    }

    // Field 80
    if (payload.merchantPremisesLocation != null) {
      var locationParts = <String>[];
      if (payload.merchantPremisesLocation!.locationDataProvider != null) {
        String providerValue;
        switch (payload.merchantPremisesLocation!.locationDataProvider!) {
          case LocationDataProvider.gpsCoordinates:
            providerValue = '01';
            break;
          case LocationDataProvider.what3words:
            providerValue = '02';
            break;
          case LocationDataProvider.googlePlusCodes:
            providerValue = '03';
            break;
        }
        locationParts.add(_tlv('01', providerValue));
      }
      if (payload.merchantPremisesLocation!.locationData != null) {
        locationParts.add(_tlv('02', payload.merchantPremisesLocation!.locationData!));
      }
      if (payload.merchantPremisesLocation!.locationAccuracy != null) {
        locationParts.add(_tlv('03', payload.merchantPremisesLocation!.locationAccuracy!));
      }
      if (locationParts.isNotEmpty) {
        parts.add(_tlv('80', locationParts.join()));
      }
    }

    // Field 81: Merchant USSD Information (nested TLV)
    if (payload.merchantUssdInformation != null) {
      var ussdParts = <String>[];
      if (payload.merchantUssdInformation!.globallyUniqueIdentifier != null) {
        ussdParts.add(_tlv('00', payload.merchantUssdInformation!.globallyUniqueIdentifier!));
      }
      for (var entry in payload.merchantUssdInformation!.paymentNetworkSpecificData.entries) {
        ussdParts.add(_tlv(entry.key, entry.value));
      }
      parts.add(_tlv('81', ussdParts.join()));
    }

    // Field 82: QR Timestamp Information (nested TLV)
    if (payload.qrTimestampInformation != null) {
      var timestampParts = <String>[];
      if (payload.qrTimestampInformation!.globallyUniqueIdentifier != null) {
        timestampParts.add(_tlv('00', payload.qrTimestampInformation!.globallyUniqueIdentifier!));
      }
      for (var entry in payload.qrTimestampInformation!.timestampData.entries) {
        timestampParts.add(_tlv(entry.key, entry.value));
      }
      parts.add(_tlv('82', timestampParts.join()));
    }

    // Fields 83-99: Additional Templates (nested TLV)
    if (payload.additionalTemplates != null) {
      for (var template in payload.additionalTemplates!) {
        var templateParts = <String>[];
        if (template.globallyUniqueIdentifier != null) {
          templateParts.add(_tlv('00', template.globallyUniqueIdentifier!));
        }
        for (var entry in template.templateData.entries) {
          templateParts.add(_tlv(entry.key, entry.value));
        }
        parts.add(_tlv(template.fieldId, templateParts.join()));
      }
    }

    var payloadString = parts.join();
    var crc = Crc16CcittFalse().convert(utf8.encode('${payloadString}6304'));
    var crcString = crc.toRadixString(16).toUpperCase().padLeft(4, '0');

    return '${payloadString}6304$crcString';
  }

  static String _tlv(String tag, String value) {
    var length = value.length.toString().padLeft(2, '0');
    return '$tag$length$value';
  }
}
