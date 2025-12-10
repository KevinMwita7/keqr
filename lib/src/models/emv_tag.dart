abstract class EmvTag {
  String get tag;
  String get length;
  String get value;

  @override
  String toString() {
    return '$tag$length$value';
  }
}
