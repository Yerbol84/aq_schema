class AqValidationResult {
  final bool isValid;
  final String? detectedVersion;
  final List<AqValidationError> errors;
  final List<String> warnings;

  const AqValidationResult({
    required this.isValid,
    this.detectedVersion,
    this.errors = const [],
    this.warnings = const [],
  });
}

class AqValidationError {
  final String path;
  final String message;

  const AqValidationError({required this.path, required this.message});
}
