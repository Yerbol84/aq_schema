/// Тестовый домен для проверки миграций.
///
/// Version 1.0.0: id, title, content
/// Version 2.0.0: id, title, author, summary (content удалён)
library;

import 'package:aq_schema/aq_schema.dart';

/// Тестовый документ v1.0.0
class TestDocumentV1 implements DirectStorable {
  @override
  final String id;
  @override
  final String tenantId;
  final String title;
  final String content;
  final DateTime? deletedAt;

  TestDocumentV1({
    required this.id,
    required this.tenantId,
    required this.title,
    required this.content,
    this.deletedAt,
  });

  factory TestDocumentV1.fromMap(Map<String, dynamic> map) {
    return TestDocumentV1(
      id: map['id'] as String,
      tenantId: map['tenantId'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      deletedAt: map['deletedAt'] != null
          ? DateTime.tryParse(map['deletedAt'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tenantId': tenantId,
      'title': title,
      'content': content,
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  @override
  Map<String, dynamic> get jsonSchema => {
        'type': 'object',
        'properties': {
          'id': {'type': 'string'},
          'tenantId': {'type': 'string'},
          'title': {'type': 'string'},
          'content': {'type': 'string'},
        },
        'required': ['id', 'tenantId', 'title', 'content'],
      };

  @override
  String get collectionName => kCollection;

  @override
  bool get softDelete => true;

  @override
  Map<String, dynamic> get indexFields => {};

  static const String kCollection = 'test_documents';
}

/// Тестовый документ v2.0.0
class TestDocumentV2 implements DirectStorable {
  @override
  final String id;
  @override
  final String tenantId;
  final String title;
  final String author;
  final String summary;
  final DateTime? deletedAt;

  TestDocumentV2({
    required this.id,
    required this.tenantId,
    required this.title,
    required this.author,
    required this.summary,
    this.deletedAt,
  });

  factory TestDocumentV2.fromMap(Map<String, dynamic> map) {
    return TestDocumentV2(
      id: map['id'] as String,
      tenantId: map['tenantId'] as String,
      title: map['title'] as String,
      author: map['author'] as String,
      summary: map['summary'] as String,
      deletedAt: map['deletedAt'] != null
          ? DateTime.tryParse(map['deletedAt'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tenantId': tenantId,
      'title': title,
      'author': author,
      'summary': summary,
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  @override
  Map<String, dynamic> get jsonSchema => {
        'type': 'object',
        'properties': {
          'id': {'type': 'string'},
          'tenantId': {'type': 'string'},
          'title': {'type': 'string'},
          'author': {'type': 'string'},
          'summary': {'type': 'string'},
        },
        'required': ['id', 'tenantId', 'title', 'author', 'summary'],
      };

  @override
  String get collectionName => kCollection;

  @override
  bool get softDelete => true;

  @override
  Map<String, dynamic> get indexFields => {};

  static const String kCollection = 'test_documents';
}

/// Миграция v1 -> v2
Map<String, dynamic>? migrateV1toV2(Map<String, dynamic> data) {
  // Извлекаем content
  final content = data['content'] as String? ?? '';

  // Создаём summary (первые 50 символов)
  final summary = content.length > 50 ? content.substring(0, 50) + '...' : content;

  // Возвращаем новую структуру
  return {
    'id': data['id'],
    'tenantId': data['tenantId'],
    'title': data['title'],
    'author': 'Unknown', // Дефолтное значение
    'summary': summary,
    // content удалён
  };
}

/// Обратная миграция v2 -> v1 (для отката)
Map<String, dynamic>? migrateV2toV1(Map<String, dynamic> data) {
  return {
    'id': data['id'],
    'tenantId': data['tenantId'],
    'title': data['title'],
    'content': data['summary'] ?? '', // Восстанавливаем из summary
    // author и summary удалены
  };
}
