// aq_schema/lib/sandbox/capability_matcher.dart
//
// S-01 fix: capability negotiation проверяет path patterns, не только типы.
//
// Проблема: _negotiate() выдавал FsWriteCap('/etc') если policy содержала
// любой FsWriteCap — без проверки pathPattern.
//
// Решение: DefaultCapabilityMatcher.allows() проверяет совместимость
// конкретного запроса с конкретным разрешением через glob-matching.

import '../tools/models/tool_capability.dart';

/// Интерфейс проверки совместимости capabilities.
abstract interface class CapabilityMatcher {
  bool allows(ToolCapability requested, ToolCapability granted);
}

/// Реализация по умолчанию с glob-matching для path patterns.
final class DefaultCapabilityMatcher implements CapabilityMatcher {
  const DefaultCapabilityMatcher();

  @override
  bool allows(ToolCapability requested, ToolCapability granted) {
    return switch ((requested, granted)) {
      (FsReadCap r, FsReadCap g)       => _globMatch(r.pathPattern, g.pathPattern),
      (FsWriteCap r, FsWriteCap g)     => _globMatch(r.pathPattern, g.pathPattern),
      (FsReadCap r, FsWriteCap g)      => _globMatch(r.pathPattern, g.pathPattern), // write implies read
      (NetOutCap r, NetOutCap g)       => _hostMatch(r.hostPattern, g.hostPattern),
      (ProcSpawnCap r, ProcSpawnCap g) => _binaryAllowed(r, g),
      _                                => false,
    };
  }

  /// Glob matching для путей файловой системы.
  ///
  /// Поддерживаемые паттерны:
  ///   `**`       — любой путь (полный wildcard)
  ///   `*`        — любой путь без разделителей
  ///   `/tmp/**`  — всё внутри /tmp/
  ///   `/tmp/*`   — файлы непосредственно в /tmp/
  bool _globMatch(String requested, String granted) {
    // Полный wildcard — разрешает всё
    if (granted == '**' || granted == '*') return true;

    // Точное совпадение
    if (requested == granted) return true;

    // Паттерн с /** — разрешает всё внутри директории
    if (granted.endsWith('/**')) {
      final prefix = granted.substring(0, granted.length - 3); // убираем /**
      return requested.startsWith('$prefix/') || requested == prefix;
    }

    // Паттерн с /* — разрешает файлы непосредственно в директории
    if (granted.endsWith('/*')) {
      final prefix = granted.substring(0, granted.length - 2); // убираем /*
      if (!requested.startsWith('$prefix/')) return false;
      // Нет вложенных директорий после prefix/
      final rest = requested.substring(prefix.length + 1);
      return !rest.contains('/');
    }

    return false;
  }

  /// Matching для host patterns.
  ///
  /// Поддерживаемые паттерны:
  ///   `*`           — любой хост
  ///   `*.example.com` — любой поддомен example.com
  ///   `api.example.com` — точное совпадение
  bool _hostMatch(String requested, String granted) {
    if (granted == '*') return true;
    if (requested == granted) return true;

    // Wildcard поддомен: *.example.com
    if (granted.startsWith('*.')) {
      final suffix = granted.substring(1); // '.example.com'
      return requested.endsWith(suffix) || requested == suffix.substring(1);
    }

    return false;
  }

  /// Проверка разрешённых бинарных файлов.
  bool _binaryAllowed(ProcSpawnCap requested, ProcSpawnCap granted) {
    // Если granted разрешает всё — OK
    if (granted.allowedBinaries.isEmpty) return true;
    // Все запрошенные бинарники должны быть в granted
    return requested.allowedBinaries.every(
      (b) => granted.allowedBinaries.contains(b),
    );
  }
}
