// Manual Review Node - ручная проверка и одобрение

import 'package:aq_schema/graph/nodes/base/interactive_node.dart';
import 'package:aq_schema/graph/nodes/base/i_workflow_node.dart';
import 'package:aq_schema/graph/engine/run_context.dart';

/// Узел для ручной проверки и одобрения
///
/// Показывает данные для проверки и ждет approve/reject
class ManualReviewNode extends InteractiveNode {
  @override
  final String id;

  @override
  final String nodeType = 'manualReview';

  /// Заголовок формы проверки
  final String title;

  /// Описание что нужно проверить
  final String message;

  /// Переменная с данными для проверки
  final String reviewVar;

  /// Переменная для сохранения решения (approved/rejected)
  final String outputVar;

  ManualReviewNode({
    required this.id,
    required this.title,
    required this.message,
    required this.reviewVar,
    required this.outputVar,
  });

  @override
  Future<dynamic> execute(
    RunContext context,
  ) async {
    // Проверить, есть ли уже решение (resume после suspend)
    if (hasUserResponse(context, outputVar)) {
      final decision = context.getVar(outputVar);
      context.log(
        'Manual review decision: $decision',
        branch: context.currentBranch,
      );
      return decision;
    }

    // Получить данные для проверки
    final reviewData = context.getVar(reviewVar);
    if (reviewData == null) {
      throw Exception('ManualReviewNode: variable $reviewVar not found');
    }

    // Нет решения - приостановить выполнение
    throwSuspendException(id, 'Waiting for manual review: $title');
  }

  @override
  Map<String, dynamic> getUiConfig() => {
        'title': title,
        'message': message,
        'type': 'approval',
        'review_var': reviewVar,
        'output_var': outputVar,
      };

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': nodeType,
        'config': {
          'title': title,
          'message': message,
          'review_var': reviewVar,
          'output_var': outputVar,
        },
      };

  factory ManualReviewNode.fromJson(Map<String, dynamic> json) {
    final config = json['config'] as Map<String, dynamic>? ?? {};
    return ManualReviewNode(
      id: json['id'] as String,
      title: config['title'] as String? ?? '',
      message: config['message'] as String? ?? '',
      reviewVar: config['review_var'] as String? ?? 'review_data',
      outputVar: config['output_var'] as String? ?? 'review_decision',
    );
  }

  @override
  IWorkflowNode copyWith({
    String? id,
    String? title,
    String? message,
    String? reviewVar,
    String? outputVar,
  }) {
    return ManualReviewNode(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      reviewVar: reviewVar ?? this.reviewVar,
      outputVar: outputVar ?? this.outputVar,
    );
  }
}
