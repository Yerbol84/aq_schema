import 'storable.dart';

/// Marker interface for logged storage.
/// Every change is automatically recorded as a [LogEntry] with field diffs.
abstract interface class LoggedStorable implements Storable {
  /// Fields whose changes are tracked in the log.
  /// Empty set means ALL fields from [toMap()] are tracked.
  Set<String> get trackedFields;
}
