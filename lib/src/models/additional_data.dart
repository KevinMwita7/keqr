class AdditionalData {
  final String? billNumber;
  final String? mobileNumber;
  final String? storeLabel;
  final String? loyaltyNumber;
  final String? referenceLabel;
  final String? customerLabel;
  final String? terminalLabel;
  final String? purposeOfTransaction;
  final String? additionalConsumerDataRequest;

  /// Subfield ID 10: Merchant Tax ID
  ///
  /// Used for Kenya's IPRS (small merchant) or BRS (larger merchant) as a unique
  /// identifier in a QR registry. May be used by consumer mobile applications for
  /// receipt display.
  ///
  /// Format: Alphanumeric, Max Length: 20
  final String? merchantTaxId;

  /// Subfield ID 11: Merchant Channel
  ///
  /// A 3-position field identifying transaction channel characteristics:
  /// - Position 1: Media (0-8)
  ///   - 0: Print - merchant sticker
  ///   - 1: Print - Bill/Invoice
  ///   - 2: Print - Magazine/Poster
  ///   - 3: Print - Other
  ///   - 4: Screen/Electronic - Merchant POS/POI
  ///   - 5: Screen/Electronic - Website
  ///   - 6: Screen/Electronic - App
  ///   - 7: Screen/Electronic - Other
  ///   - 8: Screen/Electronic - ATM
  /// - Position 2: Scan Location (0-3)
  ///   - 0: At Merchant premises/registered address
  ///   - 1: Not at Merchant premises/registered address
  ///   - 2: Remote Commerce
  ///   - 3: Other
  /// - Position 3: Merchant Presence (0-3)
  ///   - 0: Attended POI
  ///   - 1: Unattended
  ///   - 2: Semi-attended (self-checkout)
  ///   - 3: Other
  ///
  /// Example: '000' = Print sticker at merchant premises, attended
  ///          '601' = App/screen at merchant premises, unattended
  ///
  /// Format: Alphanumeric, Length: exactly 03
  final String? merchantChannel;

  AdditionalData({
    this.billNumber,
    this.mobileNumber,
    this.storeLabel,
    this.loyaltyNumber,
    this.referenceLabel,
    this.customerLabel,
    this.terminalLabel,
    this.purposeOfTransaction,
    this.additionalConsumerDataRequest,
    this.merchantTaxId,
    this.merchantChannel,
  }) {
    // Validate merchantTaxId (Subfield 10)
    if (merchantTaxId != null) {
      if (merchantTaxId!.length > 20) {
        throw ArgumentError(
          'merchantTaxId must be at most 20 characters, got ${merchantTaxId!.length}',
        );
      }
      if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(merchantTaxId!)) {
        throw ArgumentError(
          'merchantTaxId must be alphanumeric',
        );
      }
    }

    // Validate merchantChannel (Subfield 11)
    if (merchantChannel != null) {
      if (merchantChannel!.length != 3) {
        throw ArgumentError(
          'merchantChannel must be exactly 3 characters, got ${merchantChannel!.length}',
        );
      }
      if (!RegExp(r'^[0-9]{3}$').hasMatch(merchantChannel!)) {
        throw ArgumentError(
          'merchantChannel must be 3 numeric digits',
        );
      }

      // Validate individual positions
      var media = int.parse(merchantChannel![0]);
      var scanLocation = int.parse(merchantChannel![1]);
      var merchantPresence = int.parse(merchantChannel![2]);

      if (media < 0 || media > 8) {
        throw ArgumentError(
          'merchantChannel position 1 (media) must be 0-8, got $media',
        );
      }
      if (scanLocation < 0 || scanLocation > 3) {
        throw ArgumentError(
          'merchantChannel position 2 (scan location) must be 0-3, got $scanLocation',
        );
      }
      if (merchantPresence < 0 || merchantPresence > 3) {
        throw ArgumentError(
          'merchantChannel position 3 (merchant presence) must be 0-3, got $merchantPresence',
        );
      }
    }
  }
}
