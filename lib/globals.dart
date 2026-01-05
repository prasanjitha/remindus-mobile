class CustomException implements Exception {
  final String message;
  final int? errorCode;
  final String? functionName;

  CustomException({required this.message, this.errorCode, this.functionName});

  @override
  String toString() {
    return 'CustomException: $message (Error Code: $errorCode)';
  }
}
