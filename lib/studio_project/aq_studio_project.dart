// lib/domain/models/aq_project.dart
//
// Единственная доменная модель проекта.
// Используется везде — в UI, провайдерах, и обоих репозиториях (local + remote).
// Не зависит ни от Drift, ни от dart_vault.

import 'package:aq_schema/aq_schema.dart';

class AqStudioProject implements DirectStorable {
  @override
  final String id;
  final String name;
  final String path;
  final String projectType;
  final DateTime lastOpened;

  const AqStudioProject({
    required this.id,
    required this.name,
    required this.path,
    required this.projectType,
    required this.lastOpened,
  });
  factory AqStudioProject.create({
    required String id,
    required String name,
    required String projectType,
  }) =>
      AqStudioProject(
          id: id,
          name: name,
          path: '',
          projectType: projectType,
          lastOpened: DateTime.now());
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'path': path,
        'projectType': projectType,
        'lastOpened': lastOpened.toIso8601String(),
      };

  factory AqStudioProject.fromMap(Map<String, dynamic> m) => AqStudioProject(
        id: m['id'] as String,
        name: m['name'] as String? ?? '',
        path: m['path'] as String? ?? '',
        projectType: m['projectType'] as String? ?? 'coder',
        lastOpened: DateTime.tryParse(m['lastOpened'] as String? ?? '') ??
            DateTime.now(),
      );

  AqStudioProject copyWith({DateTime? lastOpened}) => AqStudioProject(
        id: id,
        name: name,
        path: path,
        projectType: projectType,
        lastOpened: lastOpened ?? this.lastOpened,
      );

  @override
  // TODO: implement indexFields
  Map<String, dynamic> get indexFields => throw UnimplementedError();
}
