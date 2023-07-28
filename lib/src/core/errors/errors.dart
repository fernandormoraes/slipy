class SlipyError implements Exception {
  final String message;

  SlipyError(this.message);

  @override
  String toString() {
    return '$runtimeType: $message';
  }
}
