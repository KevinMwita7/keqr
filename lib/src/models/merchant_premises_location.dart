enum LocationDataProvider { gpsCoordinates, what3words, googlePlusCodes }

class MerchantPremisesLocation {
  final LocationDataProvider? locationDataProvider;
  final String? locationData;
  final String? locationAccuracy;

  MerchantPremisesLocation({
    this.locationDataProvider,
    this.locationData,
    this.locationAccuracy,
  });
}
