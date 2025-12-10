import 'dart:convert';
import 'package:crclib/catalog.dart';
import '../models/keqr_payload.dart';

class QrCodeGenerator {
  static String generate(KeqrPayload payload) {
    var parts = <String>[];

    // Mandatory fields
    parts.add(_tlv('00', payload.payloadFormatIndicator));
    parts.add(_tlv('01', payload.pointOfInitiationMethod));
    parts.add(_tlv('53', payload.transactionCurrency));
    parts.add(_tlv('58', payload.countryCode));
    parts.add(_tlv('59', payload.merchantName));

    // Optional fields
    if (payload.merchantCategoryCode != null) {
      parts.add(_tlv('52', payload.merchantCategoryCode!));
    }
    if (payload.transactionAmount != null) {
      parts.add(_tlv('54', payload.transactionAmount!));
    }
    if (payload.merchantCity != null) {
      parts.add(_tlv('60', payload.merchantCity!));
    }

    // Mandatory fields that are not in KeqrPayload constructor
    if (payload.merchantUssdDisplayedCode == null) {
      throw ArgumentError('Merchant USSD Displayed Code (Tag 81) is mandatory.');
    }
    parts.add(_tlv('81', payload.merchantUssdDisplayedCode!));

    if (payload.qrTimestampInformation == null) {
      throw ArgumentError('QR Timestamp Information (Tag 82) is mandatory.');
    }
    parts.add(_tlv('82', payload.qrTimestampInformation!));

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
      parts.add(_tlv('62', additionalDataParts.join()));
    }

    if (payload.merchantInformationLanguageTemplate != null) {
      var merchantInfoParts = <String>[];
      merchantInfoParts.add(_tlv('00', payload.merchantInformationLanguageTemplate!.languagePreference));
      merchantInfoParts.add(_tlv('01', payload.merchantInformationLanguageTemplate!.merchantName));
      merchantInfoParts.add(_tlv('02', payload.merchantInformationLanguageTemplate!.merchantCity));
      parts.add(_tlv('64', merchantInfoParts.join()));
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
