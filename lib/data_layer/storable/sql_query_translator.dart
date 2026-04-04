import 'package:aq_schema/aq_schema.dart';

/// Optional interface for storage backends that support SQL-level query
/// translation (pushdown optimisation).
///
/// When a [VaultStorage] implementation also implements [SqlQueryTranslator],
/// repositories will call [toSql] instead of filtering records in-memory,
/// enabling the database engine to use indexes and optimise execution plans.
///
/// ## Usage
///
/// ```dart
/// class PostgresVaultStorage implements VaultStorage, SqlQueryTranslator {
///   @override
///   SqlFragment toSql(VaultQuery query) {
///     final wheres = <String>[];
///     final params  = <Object?>[];
///     for (final f in query.filters) {
///       wheres.add('${f.field} ${f.operator.sql} \$${params.length + 1}');
///       params.add(f.value);
///     }
///     return SqlFragment(
///       where: wheres.isEmpty ? null : wheres.join(' AND '),
///       orderBy: query.sortField,
///       limit: query.limit,
///       offset: query.offset,
///       params: params,
///     );
///   }
/// }
/// ```
abstract interface class SqlQueryTranslator {
  /// Translate [query] into a [SqlFragment] for native SQL execution.
  SqlFragment toSql(VaultQuery query);
}

/// Holds the parts of a translated SQL query.
final class SqlFragment {
  /// WHERE clause (without "WHERE" keyword), e.g. `"name = $1 AND active = $2"`.
  final String? where;

  /// ORDER BY column name (without direction).
  final String? orderBy;

  /// ASC / DESC direction string.
  final String orderDirection;

  /// LIMIT value, or null for no limit.
  final int? limit;

  /// OFFSET value, or null.
  final int? offset;

  /// Positional parameters matching placeholders in [where].
  final List<Object?> params;

  const SqlFragment({
    this.where,
    this.orderBy,
    this.orderDirection = 'ASC',
    this.limit,
    this.offset,
    this.params = const [],
  });
}
