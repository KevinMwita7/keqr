/// Media type for merchant channel (position 1)
enum MerchantChannelMedia {
  /// Print - merchant sticker
  printSticker(0),

  /// Print - Bill/Invoice
  printBillInvoice(1),

  /// Print - Magazine/Poster
  printMagazinePoster(2),

  /// Print - Other
  printOther(3),

  /// Screen/Electronic - Merchant POS/POI
  screenMerchantPos(4),

  /// Screen/Electronic - Website
  screenWebsite(5),

  /// Screen/Electronic - App
  screenApp(6),

  /// Screen/Electronic - Other
  screenOther(7),

  /// Screen/Electronic - ATM
  screenAtm(8);

  final int value;
  const MerchantChannelMedia(this.value);
}

/// Scan location for merchant channel (position 2)
enum MerchantChannelScanLocation {
  /// At Merchant premises/registered address
  atMerchantPremises(0),

  /// Not at Merchant premises/registered address
  notAtMerchantPremises(1),

  /// Remote Commerce
  remoteCommerce(2),

  /// Other
  other(3);

  final int value;
  const MerchantChannelScanLocation(this.value);
}

/// Merchant presence for merchant channel (position 3)
enum MerchantChannelPresence {
  /// Attended POI
  attended(0),

  /// Unattended
  unattended(1),

  /// Semi-attended (self-checkout)
  semiAttended(2),

  /// Other
  other(3);

  final int value;
  const MerchantChannelPresence(this.value);
}

/// Helper class to build a valid merchant channel string
class MerchantChannelBuilder {
  /// Builds a 3-character merchant channel string from the provided components
  ///
  /// Example:
  /// ```dart
  /// // Creates '000' - Print sticker at merchant premises, attended
  /// var channel = MerchantChannelBuilder.build(
  ///   MerchantChannelMedia.printSticker,
  ///   MerchantChannelScanLocation.atMerchantPremises,
  ///   MerchantChannelPresence.attended,
  /// );
  ///
  /// // Creates '601' - App at merchant premises, unattended
  /// var channel = MerchantChannelBuilder.build(
  ///   MerchantChannelMedia.screenApp,
  ///   MerchantChannelScanLocation.atMerchantPremises,
  ///   MerchantChannelPresence.unattended,
  /// );
  /// ```
  static String build(
    MerchantChannelMedia media,
    MerchantChannelScanLocation scanLocation,
    MerchantChannelPresence presence,
  ) {
    return '${media.value}${scanLocation.value}${presence.value}';
  }
}
