import 'vault_filter.dart';
import 'vault_operator.dart';
import 'vault_sort.dart';

/// Immutable query descriptor for dart_vault.
///
/// Build queries with the fluent API:
///
/// ```dart
/// final q = VaultQuery()
///     .where('status', VaultOperator.equals, 'active')
///     .where('score', VaultOperator.greaterThan, 50)
///     .orderBy('createdAt', descending: true)
///     .page(limit: 20, offset: 0);
/// ```
final class VaultQuery {
  final List<VaultFilter> filters;
  final VaultSort? sort;
  final int? limit;
  final int? offset;

  const VaultQuery({
    this.filters = const [],
    this.sort,
    this.limit,
    this.offset,
  });

  // ── Fluent builder ─────────────────────────────────────────────────────────

  VaultQuery where(String field, VaultOperator operator, dynamic value) =>
      VaultQuery(
        filters: [...filters, VaultFilter(field, operator, value)],
        sort: sort,
        limit: limit,
        offset: offset,
      );

  VaultQuery orderBy(String field, {bool descending = false}) => VaultQuery(
        filters: filters,
        sort: VaultSort(field: field, descending: descending),
        limit: limit,
        offset: offset,
      );

  /// Set pagination parameters.
  VaultQuery page({required int limit, int offset = 0}) => VaultQuery(
        filters: filters,
        sort: sort,
        limit: limit,
        offset: offset,
      );

  /// Set the maximum number of records to return.
  VaultQuery withLimit(int limit) => VaultQuery(
        filters: filters,
        sort: sort,
        limit: limit,
        offset: offset,
      );

  /// Set the number of records to skip.
  VaultQuery withOffset(int offset) => VaultQuery(
        filters: filters,
        sort: sort,
        limit: limit,
        offset: offset,
      );

  // ── In-memory application ──────────────────────────────────────────────────

  /// Apply this query to an in-memory list of maps.
  /// Used by [InMemoryVaultStorage]; SQL-capable backends bypass this.
  List<Map<String, dynamic>> apply(List<Map<String, dynamic>> all) {
    var result = all.where((m) {
      for (final f in filters) {
        if (!f.matches(m)) return false;
      }
      return true;
    }).toList();

    if (sort != null) {
      result.sort((a, b) {
        final av = _comparable(a[sort!.field]);
        final bv = _comparable(b[sort!.field]);
        final cmp = av.compareTo(bv);
        return sort!.descending ? -cmp : cmp;
      });
    }

    if (offset != null && offset! > 0) {
      result = result.skip(offset!).toList();
    }
    if (limit != null) {
      result = result.take(limit!).toList();
    }

    return result;
  }

  /// Apply only the filter predicates — without sort / pagination.
  /// Used internally for [count] and [queryPage] total calculation.
  List<Map<String, dynamic>> applyFiltersOnly(
    List<Map<String, dynamic>> all,
  ) =>
      all.where((m) {
        for (final f in filters) {
          if (!f.matches(m)) return false;
        }
        return true;
      }).toList();

  // ── Helpers ────────────────────────────────────────────────────────────────

  Comparable _comparable(dynamic v) {
    if (v == null) return '';
    if (v is Comparable) return v;
    return v.toString();
  }
}
