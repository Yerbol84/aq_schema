import 'dart:convert';

/// Records the before/after values of a single field change.
final class FieldDiff {
  final dynamic before;
  final dynamic after;

  const FieldDiff({this.before, this.after});

  Map<String, dynamic> toMap() => {
        'before': _safeJson(before),
        'after': _safeJson(after),
      };

  factory FieldDiff.fromMap(Map<String, dynamic> m) => FieldDiff(
        before: m['before'],
        after: m['after'],
      );

  dynamic _safeJson(dynamic v) {
    if (v == null || v is String || v is num || v is bool) return v;
    if (v is Map || v is List) {
      try {
        jsonEncode(v); // validate
        return v;
      } catch (_) {
        return v.toString();
      }
    }
    return v.toString();
  }

  @override
  String toString() => 'FieldDiff($before → $after)';
}
