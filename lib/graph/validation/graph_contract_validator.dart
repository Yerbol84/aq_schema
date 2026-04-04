// Адаптирован из lib/infrastructure/validation/json_schema_validator.dart
// Перенесён в пакет, так как является частью доменной логики графов.
import 'package:json_schema/json_schema.dart';
import '../graphs/contract_schema.dart';

class GraphContractValidator {
  Future<List<SchemaValidationError>> validate({
    required Map<String, dynamic> data,
    required Map<String, dynamic> schema,
  }) async {
    try {
      final jsonSchema = await JsonSchema.create(schema);
      final validation = jsonSchema.validate(data);
      if (validation.isValid) return [];
      return validation.errors
          .map(
            (error) => SchemaValidationError(
              path: error.schemaPath,
              message: error.message,
            ),
          )
          .toList();
    } catch (e) {
      return [SchemaValidationError(path: '/', message: 'Schema error: $e')];
    }
  }

  Future<List<SchemaValidationError>> validateInstructionContract({
    required Map<String, dynamic> contract,
  }) async {
    final defaultSchema = ContractSchema.defaultInstructionContract();
    return await validate(data: contract, schema: defaultSchema.schema);
  }

  Future<List<SchemaValidationError>> validateWithContractSchema({
    required Map<String, dynamic> contract,
    required ContractSchema contractSchema,
  }) async {
    return await validate(data: contract, schema: contractSchema.schema);
  }

  bool isLegacyContractCompatible(Map<String, dynamic> contract) {
    return ContractSchema.defaultInstructionContract()
        .isCompatibleWithLegacyFormat(contract);
  }

  Map<String, dynamic> convertLegacyContract(Map<String, dynamic> contract) {
    return ContractSchema.defaultInstructionContract().convertLegacyContract(
      contract,
    );
  }

  Future<bool> isValid({
    required Map<String, dynamic> data,
    required Map<String, dynamic> schema,
  }) async {
    return (await validate(data: data, schema: schema)).isEmpty;
  }
}
