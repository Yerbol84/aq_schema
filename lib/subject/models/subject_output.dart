// aq_schema/lib/subject/models/subject_output.dart

/// Выходные данные от Subject.
final class SubjectOutput {
  final bool success;
  final Map<String, dynamic> data;
  final String? error;

  const SubjectOutput({
    required this.success,
    required this.data,
    this.error,
  });

  factory SubjectOutput.success({required Map<String, dynamic> data}) =>
      SubjectOutput(success: true, data: data);

  factory SubjectOutput.failure({required String error}) =>
      SubjectOutput(success: false, data: const {}, error: error);

  Map<String, dynamic> toJson() => {
        'success': success,
        'data': data,
        if (error != null) 'error': error,
      };
}
