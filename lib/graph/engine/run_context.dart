// pkgs/aq_schema/lib/graph/engine/run_context.dart

import 'dart:convert';
import '../../sandbox/interfaces/i_sandbox_context.dart';
import '../../sandbox/interfaces/i_sandbox.dart';
import '../../sandbox/interfaces/i_sandbox_as_environment.dart';
import '../../sandbox/interfaces/i_sandbox_event.dart';
import '../../sandbox/policy/sandbox_policy.dart';

class RunContext implements ISandboxContext {
  // ── Идентификация ────────────────────────────────────────────────────
  @override
  final String runId;
  @override
  final String projectId;
  @override
  final String projectPath;
  @override
  final String currentBranch;

  // ── Состояние ────────────────────────────────────────────────────────
  @override
  final Map<String, dynamic> state = {};

  // ── Sandbox ──────────────────────────────────────────────────────────
  @override
  final ISandbox sandbox;

  @override
  SandboxPolicy get activePolicy {
    final s = sandbox;
    return s is ISandboxAsEnvironment ? s.effectivePolicy : s.policy;
  }

  // ── Логирование (реализация, не часть ISandboxContext) ───────────────
  // Приватное поле — callback передаётся в конструктор как раньше.
  // Публичный метод log() — удовлетворяет вызывающим context.log(...).
  // Существующий код вне класса не меняется.
  final void Function(
    String message, {
    String type,
    int depth,
    required String branch,
    String? details,
  }) _log;

  void log(
    String message, {
    String type = 'info',
    int depth = 0,
    required String branch,
    String? details,
  }) =>
      _log(message, type: type, depth: depth, branch: branch, details: details);

  // ── Конструктор ──────────────────────────────────────────────────────
  // Параметр называется `log` как раньше — все места создания RunContext
  // работают без изменений.
  RunContext({
    required this.runId,
    required this.projectId,
    required this.projectPath,
    required void Function(
      String, {
      String type,
      int depth,
      required String branch,
      String? details,
    }) log,
    this.currentBranch = 'main',
    ISandbox? sandbox,
  })  : _log = log,
        sandbox = sandbox ?? _FallbackSandbox(runId);

  // ── Методы состояния ─────────────────────────────────────────────────
  @override
  void setVar(String key, dynamic value) {
    state[key] = value;
    _log('Memory updated: [$key]',
        type: 'system', depth: 0, branch: currentBranch);
  }

  @override
  dynamic getVar(String name) {
    if (!name.contains('.')) return state[name];
    final parts = name.split('.');
    dynamic current = state[parts[0]];
    for (int i = 1; i < parts.length; i++) {
      if (current is Map) {
        current = current[parts[i]];
      } else {
        return null;
      }
    }
    return current;
  }

  @override
  ISandboxContext cloneForBranch(String branchName) {
    final newCtx = RunContext(
      runId: runId,
      projectId: projectId,
      projectPath: projectPath,
      log: _log,
      currentBranch: branchName,
      sandbox: sandbox,
    );
    newCtx.state.addAll(state);
    return newCtx;
  }

  // ── Сериализация (без изменений) ─────────────────────────────────────
  Map<String, dynamic> toJson() => {
        'runId': runId,
        'projectId': projectId,
        'projectPath': projectPath,
        'state': state,
        'currentBranch': currentBranch,
      };

  factory RunContext.fromJson(
    Map<String, dynamic> json,
    void Function(
      String, {
      String type,
      int depth,
      required String branch,
      String? details,
    }) log, {
    ISandbox? sandbox,
  }) {
    final ctx = RunContext(
      runId: json['runId'] as String,
      projectId: json['projectId'] as String,
      projectPath: json['projectPath'] as String,
      currentBranch: json['currentBranch'] as String? ?? 'main',
      log: log,
      sandbox: sandbox,
    );
    if (json['state'] != null) {
      ctx.state.addAll(Map<String, dynamic>.from(json['state'] as Map));
    }
    return ctx;
  }
}

// ── Fallback sandbox (backward compat) ────────────────────────────────────────
// Используется пока WorkflowRunner не передаёт реальный sandbox.
// Не ограничивает ничего. Будет заменён в Sprint 2 когда WorkflowRunner
// реализует ISandboxAsProcess и передаёт себя в RunContext.

class _FallbackSandbox implements ISandbox {
  const _FallbackSandbox(this._id);
  final String _id;

  @override
  String get sandboxId => _id;
  @override
  String get displayName => 'Unrestricted';
  @override
  SandboxPolicy get policy => SandboxPolicy.unrestricted;
  @override
  Stream<ISandboxEvent> get events => const Stream.empty();
  @override
  Future<void> dispose() async {}
}
