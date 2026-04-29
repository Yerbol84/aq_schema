// aq_schema/lib/subject/models/subject_input.dart

/// Входные данные для Subject.
final class SubjectInput {
  final Map<String, dynamic> data;

  const SubjectInput({required this.data});

  Map<String, dynamic> toJson() => data;

  factory SubjectInput.fromJson(Map<String, dynamic> json) =>
      SubjectInput(data: json);
}
