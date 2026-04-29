// aq_schema/lib/subject/models/subject_descriptor.dart
//
// Полное описание Subject — metadata + spec.
// Это то что пользователь создаёт и передаёт в Registry.

import 'subject_metadata.dart';
import 'subject_spec.dart';

/// Полное описание Subject.
///
/// Содержит:
/// • metadata — идентификация и описание
/// • spec — спецификация выполнения
///
/// Это то что пользователь создаёт:
/// ```dart
/// final descriptor = SubjectDescriptor(
///   metadata: SubjectMetadata(name: 'my-agent', ...),
///   spec: SubjectSpec(kind: SubjectKind.aqGraph, ...),
/// );
/// await subjectRegistry.register(descriptor);
/// ```
final class SubjectDescriptor {
  static final _SubjectDescriptorKeys _keys = _SubjectDescriptorKeys._();
  static _SubjectDescriptorKeys get keys => _keys;

  final SubjectMetadata metadata;
  final SubjectSpec spec;

  const SubjectDescriptor({
    required this.metadata,
    required this.spec,
  });

  Map<String, dynamic> toJson() => {
        SubjectDescriptor.keys.metadata: metadata.toJson(),
        SubjectDescriptor.keys.spec: spec.toJson(),
      };

  factory SubjectDescriptor.fromJson(Map<String, dynamic> json) =>
      SubjectDescriptor(
        metadata: SubjectMetadata.fromJson(
            json[SubjectDescriptor.keys.metadata] as Map<String, dynamic>),
        spec: SubjectSpec.fromJson(
            json[SubjectDescriptor.keys.spec] as Map<String, dynamic>),
      );

  @override
  String toString() => 'SubjectDescriptor(${metadata.fullId}@${metadata.version})';
}

class _SubjectDescriptorKeys {
  _SubjectDescriptorKeys._();
  final String metadata = 'metadata';
  final String spec = 'spec';
}
