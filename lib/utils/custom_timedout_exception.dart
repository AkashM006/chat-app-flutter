class CustomTimedOutException implements Exception {
  final String message;

  CustomTimedOutException(this.message);
}
