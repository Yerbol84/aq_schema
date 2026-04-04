import 'package:json_schema/json_schema.dart';

/// Схема контракта для валидации входных и выходных данных инструкций.
/// Соответствует JSON Schema Draft 7.
class ContractSchema {
  /// Идентификатор схемы (опционально)
  final String? id;

  /// Название схемы для отображения
  final String name;

  /// Описание схемы
  final String description;

  /// JSON Schema Draft 7 в виде Map
  final Map<String, dynamic> schema;

  /// Дата создания схемы
  final DateTime createdAt;

  /// Дата последнего обновления
  final DateTime updatedAt;

  ContractSchema({
    this.id,
    required this.name,
    required this.description,
    required this.schema,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Создает схему контракта по умолчанию для инструкций.
  /// Соответствует текущей структуре контрактов AQ Studio.
  factory ContractSchema.defaultInstructionContract() {
    return ContractSchema(
      name: 'Стандартный контракт инструкции',
      description: 'Базовая схема для входных и выходных данных инструкций',
      schema: {
        '\$schema': 'http://json-schema.org/draft-07/schema#',
        'type': 'object',
        'properties': {
          'inputs': {
            'type': 'array',
            'description': 'Входные параметры инструкции',
            'items': {
              'type': 'object',
              'properties': {
                'name': {'type': 'string', 'description': 'Имя параметра'},
                'type': {
                  'type': 'string',
                  'enum': ['string', 'number', 'boolean', 'object', 'array'],
                  'description': 'Тип данных параметра',
                },
                'description': {
                  'type': 'string',
                  'description': 'Описание параметра',
                },
                'required': {
                  'type': 'boolean',
                  'description': 'Обязательность параметра',
                  'default': true,
                },
                'default': {
                  'description': 'Значение по умолчанию',
                  'oneOf': [
                    {'type': 'string'},
                    {'type': 'number'},
                    {'type': 'boolean'},
                    {'type': 'object'},
                    {'type': 'array'},
                  ],
                },
              },
              'required': ['name', 'type'],
              'additionalProperties': false,
            },
          },
          'outputs': {
            'type': 'array',
            'description': 'Выходные параметры инструкции',
            'items': {
              'type': 'object',
              'properties': {
                'name': {'type': 'string', 'description': 'Имя параметра'},
                'type': {
                  'type': 'string',
                  'enum': ['string', 'number', 'boolean', 'object', 'array'],
                  'description': 'Тип данных параметра',
                },
                'description': {
                  'type': 'string',
                  'description': 'Описание параметра',
                },
              },
              'required': ['name', 'type'],
              'additionalProperties': false,
            },
          },
        },
        'required': ['inputs', 'outputs'],
        'additionalProperties': false,
      },
    );
  }

  /// Создает схему контракта для конкретного типа узла.
  /// Например, для узла типа 'userInputRequest' может быть специфичная схема.
  factory ContractSchema.forNodeType(String nodeType) {
    switch (nodeType) {
      case 'userInputRequest':
        return ContractSchema(
          name: 'Контракт запроса ввода пользователя',
          description: 'Схема для узлов, запрашивающих ввод от пользователя',
          schema: {
            '\$schema': 'http://json-schema.org/draft-07/schema#',
            'type': 'object',
            'properties': {
              'message': {
                'type': 'string',
                'description': 'Сообщение для пользователя',
              },
              'inputFields': {
                'type': 'array',
                'description': 'Поля для ввода',
                'items': {
                  'type': 'object',
                  'properties': {
                    'name': {'type': 'string'},
                    'label': {'type': 'string'},
                    'type': {
                      'type': 'string',
                      'enum': ['text', 'number', 'boolean', 'select'],
                    },
                    'required': {'type': 'boolean'},
                    'options': {
                      'type': 'array',
                      'items': {'type': 'string'},
                    },
                  },
                  'required': ['name', 'label', 'type'],
                },
              },
            },
            'required': ['message'],
          },
        );
      case 'validationCheck':
        return ContractSchema(
          name: 'Контракт проверки валидации',
          description: 'Схема для узлов проверки условий',
          schema: {
            '\$schema': 'http://json-schema.org/draft-07/schema#',
            'type': 'object',
            'properties': {
              'condition': {
                'type': 'string',
                'description': 'Условие для проверки в формате выражения',
              },
              'errorMessage': {
                'type': 'string',
                'description': 'Сообщение об ошибке при невыполнении условия',
              },
            },
            'required': ['condition'],
          },
        );
      default:
        return ContractSchema.defaultInstructionContract();
    }
  }

  /// Проверяет, соответствует ли контракт данной схеме.
  /// Возвращает список ошибок валидации.
  Future<List<SchemaValidationError>> validateContract(
    Map<String, dynamic> contract,
  ) async {
    try {
      // Используем JsonSchema.create для создания схемы из Dart-объекта
      final jsonSchema = await JsonSchema.create(schema);
      final validation = jsonSchema.validate(contract);

      if (validation.isValid) {
        return [];
      } else {
        return validation.errors.map((error) {
          return SchemaValidationError(
            path: error.schemaPath,
            message: error.message,
            detail:
                null, // Поле detail может отсутствовать в ValidationError пакета
          );
        }).toList();
      }
    } catch (e) {
      return [
        SchemaValidationError(
          path: '/',
          message: 'Ошибка при создании схемы валидации: $e',
        ),
      ];
    }
  }

  /// Проверяет, совместима ли данная схема с устаревшим форматом контракта.
  /// Возвращает true, если контракт может быть автоматически преобразован.
  bool isCompatibleWithLegacyFormat(Map<String, dynamic> legacyContract) {
    // Проверяем наличие обязательных полей inputs и outputs
    if (legacyContract['inputs'] is! List ||
        legacyContract['outputs'] is! List) {
      return false;
    }

    // Проверяем структуру каждого элемента
    final inputs = legacyContract['inputs'] as List;
    final outputs = legacyContract['outputs'] as List;

    for (final input in inputs) {
      if (input is! Map<String, dynamic>) return false;
      if (input['name'] == null || input['type'] == null) return false;
    }

    for (final output in outputs) {
      if (output is! Map<String, dynamic>) return false;
      if (output['name'] == null || output['type'] == null) return false;
    }

    return true;
  }

  /// Преобразует устаревший формат контракта в формат, соответствующий схеме.
  Map<String, dynamic> convertLegacyContract(
    Map<String, dynamic> legacyContract,
  ) {
    if (!isCompatibleWithLegacyFormat(legacyContract)) {
      throw ArgumentError('Контракт несовместим с устаревшим форматом');
    }

    final inputs = (legacyContract['inputs'] as List).map((item) {
      final map = item as Map<String, dynamic>;
      return {
        'name': map['name'],
        'type': map['type'],
        'description': map['description'] ?? '',
        'required': map['required'] ?? true,
        if (map.containsKey('default')) 'default': map['default'],
      };
    }).toList();

    final outputs = (legacyContract['outputs'] as List).map((item) {
      final map = item as Map<String, dynamic>;
      return {
        'name': map['name'],
        'type': map['type'],
        'description': map['description'] ?? '',
      };
    }).toList();

    return {'inputs': inputs, 'outputs': outputs};
  }

  /// Сериализация в JSON
  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'name': name,
    'description': description,
    'schema': schema,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  /// Десериализация из JSON
  factory ContractSchema.fromJson(Map<String, dynamic> json) {
    return ContractSchema(
      id: json['id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String,
      schema: json['schema'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Копия с обновленными полями
  ContractSchema copyWith({
    String? id,
    String? name,
    String? description,
    Map<String, dynamic>? schema,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ContractSchema(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      schema: schema ?? this.schema,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Ошибка валидации контракта (переименовано, чтобы избежать конфликта с ValidationError из json_schema)
class SchemaValidationError {
  /// Путь к полю в схеме
  final String path;

  /// Сообщение об ошибке
  final String message;

  /// Детальная информация об ошибке
  final String? detail;

  SchemaValidationError({
    required this.path,
    required this.message,
    this.detail,
  });

  @override
  String toString() {
    return detail != null ? '$path: $message ($detail)' : '$path: $message';
  }
}
