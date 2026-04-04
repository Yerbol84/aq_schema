/// ✅ Typedef для функции логирования из WorkflowRunner
typedef WorkflowLog =
    void Function(
      String message, {
      String type,
      int depth,
      required String branch,
      String? details,
    });

/// ✅ WorkflowEventLogger - красивое логирование действий пользователя
class WorkflowEventLogger {
  final WorkflowLog _log;

  WorkflowEventLogger(this._log);

  /// Логировать действие пользователя
  void logUserAction(String actionType, Map<String, dynamic> data) {
    switch (actionType) {
      case 'button_clicked':
        _logButtonClick(data);
        break;
      case 'form_submitted':
        _logFormSubmit(data);
        break;
      case 'input_changed':
        _logInputChange(data);
        break;
      case 'workflow_resumed':
        _logWorkflowResume(data);
        break;
      case 'action_failed':
        _logActionFailed(data);
        break;
      case 'navigate_requested':
        _logNavigate(data);
        break;
      default:
        _log(
          "📌 User action: $actionType",
          type: 'user_action',
          branch: 'interaction',
          details: data.toString(),
        );
    }
  }

  void _logButtonClick(Map<String, dynamic> data) {
    final buttonId = data['button_id'] ?? 'unknown';
    final label = data['label'] ?? 'Submit';
    final targetVar = data['target_var'] ?? 'unknown';

    _log(
      "👆 User clicked: $label",
      type: 'user_action',
      branch: 'interaction',
      details: 'button=$buttonId, target=$targetVar',
    );

    if (data['collected_data'] != null) {
      final collected = data['collected_data'] as Map;
      collected.forEach((key, value) {
        _log(
          "   ├─ $key = ${_formatValue(value)}",
          type: 'user_data',
          branch: 'interaction',
          depth: 1,
        );
      });
    }
  }

  void _logFormSubmit(Map<String, dynamic> data) {
    final formId = data['form_id'] ?? 'form';
    final fieldCount = (data['fields'] as List?)?.length ?? 0;

    _log(
      "📝 Form submitted: $formId",
      type: 'user_action',
      branch: 'interaction',
      details: 'fields=$fieldCount',
    );

    if (data['validation_errors'] != null) {
      _log(
        "   ⚠️ Validation errors",
        type: 'warning',
        branch: 'interaction',
        depth: 1,
      );
      (data['validation_errors'] as List).forEach((error) {
        _log("   └─ $error", type: 'warning', branch: 'interaction', depth: 2);
      });
    }
  }

  void _logInputChange(Map<String, dynamic> data) {
    final componentId = data['component_id'] ?? 'unknown';
    final oldValue = data['old_value'];
    final newValue = data['new_value'];

    _log(
      "✏️ Input changed: $componentId",
      type: 'user_action',
      branch: 'interaction',
      details: '${_formatValue(oldValue)} → ${_formatValue(newValue)}',
    );
  }

  void _logWorkflowResume(Map<String, dynamic> data) {
    final runId = (data['run_id'] as String?)?.substring(0, 8) ?? 'unknown';

    _log(
      "⚡ Workflow resumed",
      type: 'success',
      branch: 'system',
      details: 'run=$runId',
    );

    if (data['injected'] != null) {
      final injected = data['injected'] as Map;
      injected.forEach((key, value) {
        _log(
          "   ├─ \$$key = ${_formatValue(value)}",
          type: 'success',
          branch: 'system',
          depth: 1,
        );
      });
    }
  }

  void _logActionFailed(Map<String, dynamic> data) {
    final actionType = data['action'] ?? 'unknown';
    final error = data['error'] ?? 'unknown error';

    _log(
      "❌ Action failed: $actionType",
      type: 'error',
      branch: 'system',
      details: error,
    );
  }

  void _logNavigate(Map<String, dynamic> data) {
    final target = data['target'] ?? 'unknown';

    _log("🔗 Navigate to: $target", type: 'user_action', branch: 'interaction');
  }

  /// Форматировать значение для логов
  String _formatValue(dynamic value) {
    if (value == null) return 'null';
    if (value is String) return '"$value"';
    if (value is bool) return value ? 'true' : 'false';
    if (value is List) return '[${value.length} items]';
    if (value is Map) return '{${value.length} keys}';
    if (value is double) return value.toStringAsFixed(2);
    return value.toString();
  }
}
