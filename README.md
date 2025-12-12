# KenyaQuickResponse: A Dart KE-QR Code Library

A pure Dart library for generating and parsing KE-QR codes, fully compliant with the **Kenya Quick Response Code Standard 2023** by the Central Bank of Kenya.

## Features

-   **Generate KE-QR Codes**: Create QR code strings from a `KenyaQuickResponse` object with all necessary fields.
-   **Parse KE-QR Codes**: Parse a QR code string back into a structured `KenyaQuickResponse` object.
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

## Specification

This library is based on the official **Kenya Quick Response Code Standard 2023** issued by the Central Bank of Kenya. You can find the full specification here: [Kenya Quick Response Code Standard PDF](https://www.centralbank.go.ke/QR/KenyaQuickResponseCodeStandard.pdf)

## Getting Started

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  kenya_quick_response: ^1.0.0 # Replace with the latest version
```

Then, import the library:

```dart
import 'package:kenya_quick_response/kenya_quick_response.dart';
```

### Generating a QR Code

```dart
void main() {
  final payload = KenyaQuickResponse(
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
