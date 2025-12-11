# Keqr: A Dart KE-QR Code Library

A pure Dart library for generating and parsing KE-QR codes, fully compliant with the **Kenya Quick Response Code Standard 2023** by the Central Bank of Kenya. This package provides an easy way to integrate KE-QR code functionality into your Dart and Flutter applications.

## Features

-   **Generate KE-QR Codes**: Create QR code strings from a `KeqrPayload` object with all necessary fields.
-   **Parse KE-QR Codes**: Parse a QR code string back into a structured `KeqrPayload` object.
-   **Standard Compliant**: Follows the official specification for all fields, including:
    -   Merchant Account Information
    -   Transaction Details
    -   Tip or Convenience Fee Indicators
    -   Additional Data Fields (Bill Number, Customer Label, etc.)
    -   Merchant Premises Location
    -   And more.
-   **Type-Safe**: Uses enums and classes to represent the different parts of the QR code payload, reducing errors.
-   **CRC Validation**: Automatically calculates and validates the CRC checksum.
-   **Well-Tested**: Includes a comprehensive round-trip test to ensure serialization and deserialization work correctly.

## Getting Started

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  keqr: ^1.0.0 # Replace with the latest version
```

Then, import the library:

```dart
import 'package:keqr/keqr.dart';
```

### Generating a QR Code

```dart
void main() {
  final payload = KeqrPayload(
    // ... populate your payload data
  );

  final qrCodeString = QrCodeGenerator.generate(payload);
  print(qrCodeString);
}
```

### Parsing a QR Code

```dart
void main() {
  final qrCodeString = '...'; // Your KE-QR code string

  try {
    final parsedPayload = QrCodeParser.parse(qrCodeString);
    print('Merchant Name: ${parsedPayload.merchantName}');
  } catch (e) {
    print('Error parsing QR code: $e');
  }
}
