# План полного тестирования Graph Engine

## Роль: Тестировщик
**Цель:** Дотошно покрыть тестами ВСЮ бизнес-логику Graph Engine - от создания графов до их выполнения, сохранения, получения через проект, изменения, запуска, результатов.

**Принцип:** Tools делаем через моки (MockHand) - tools будут отдельным сервисом.

---

## ✅ ВЫПОЛНЕНО (164 теста)

### 1. Workflow Nodes - Automatic (13 тестов)
- ✅ LlmActionNode: execute, error handling, serialization
- ✅ FileReadNode: execute, variable substitution, error handling, serialization
- ✅ FileWriteNode: execute, error handling, serialization
- ✅ GitCommitNode: execute, variable substitution, serialization

### 2. Workflow Nodes - Interactive (18 тестов)
- ✅ UserInputNode: suspend/resume, UI config, serialization
- ✅ ManualReviewNode: suspend/resume, error handling, UI config, serialization
- ✅ FileUploadNode: suspend/resume, UI config, serialization
- ✅ CoCreationChatNode: suspend/resume, chat history, UI config, serialization

### 3. Graph Data Structures (92 теста)
- ✅ WorkflowGraph (29 тестов): Creation, CRUD nodes/edges, Serialization, copyWith, Storable interface, WorkflowNode, WorkflowEdge
- ✅ InstructionGraph (35 тестов): Creation, CRUD nodes/edges, Contract operations, Tests, Serialization, copyWith, Storable interface, InstructionNode, InstructionEdge
- ✅ PromptGraph (28 тестов): Creation, CRUD nodes/edges, Serialization, copyWith, Storable interface, PromptNode, PromptEdge

### 4. Engine Components (41 тест)
- ✅ RunContext (20 тестов): Creation, State management, Logging, ISandboxContext interface, Variable substitution, Branch tracking, Real-world scenarios
- ✅ ToolRegistry (21 тест): Registration, Retrieval, Schemas, System tools, Real-world scenarios, Edge cases, Schema structure

---

## 📋 ПЛАН ТЕСТИРОВАНИЯ (по категориям)

## КАТЕГОРИЯ 1: GRAPH DATA STRUCTURES (Структуры данных графов)

### 1.1 WorkflowGraph (lib/graph/graphs/workflow_graph.dart)
**Что тестируем:** CRUD операции, serialization, validation

**Тесты:**
- [ ] `test/graph/graphs/workflow_graph_test.dart`
  - Создание пустого графа (empty factory)
  - Добавление узла (addNode)
  - Удаление узла (removeNode) - проверить что edges тоже удаляются
  - Добавление edge (addEdge)
  - Удаление edge (removeEdge)
  - Serialization: toMap() → fromMap() - проверить все поля
  - Serialization с accessGrants
  - copyWith() - изменение name, nodes, edges
  - indexFields - проверить что возвращает ownerId и name
  - Проверка что ownerId = projectId (семантика)

**Моки:** Не нужны, чистые data structures

---

### 1.2 InstructionGraph (lib/graph/graphs/instruction_graph.dart)
**Что тестируем:** CRUD, contract, tests, serialization

**Тесты:**
- [ ] `test/graph/graphs/instruction_graph_test.dart`
  - Создание пустого графа с дефолтным contract
  - Добавление/удаление узлов и edges
  - updateContract() - изменение contract
  - updateTests() - добавление test cases
  - Serialization с contract и tests
  - Serialization с contractSchema
  - getContractSchema() - дефолтный и кастомный
  - copyWith() со всеми полями
  - Проверка что ownerId = projectId

**Моки:** Не нужны

---

### 1.3 PromptGraph (lib/graph/graphs/prompt_graph.dart)
**Что тестируем:** CRUD, serialization

**Тесты:**
- [ ] `test/graph/graphs/prompt_graph_test.dart`
  - Создание пустого графа
  - Добавление/удаление узлов и edges
  - Serialization: toMap() → fromMap()
  - copyWith()
  - indexFields

**Моки:** Не нужны

---

## КАТЕГОРИЯ 2: WORKFLOW NODES - COMPOSITE (Составные узлы)

### 2.1 SubGraphNode (lib/graph/nodes/workflow/composite/sub_graph_node.dart)
**Что тестируем:** Выполнение вложенного графа, передача контекста

**Тесты:**
- [ ] `test/graph/nodes/workflow_composite_nodes_test.dart`
  - execute() с вложенным графом - проверить что subGraph выполняется
  - Передача переменных в subGraph через inputMapping
  - Получение результатов из subGraph через outputMapping
  - Ошибка если subGraphId не найден
  - Serialization: toJson() → fromJson()
  - copyWith()

**Моки:** MockToolRegistry, MockHand для узлов внутри subGraph

---

### 2.2 RunInstructionNode (lib/graph/nodes/workflow/composite/run_instruction_node.dart)
**Что тестируем:** Вызов InstructionGraph из WorkflowGraph

**Тесты:**
- [ ] `test/graph/nodes/workflow_composite_nodes_test.dart`
  - execute() с instructionId - проверить что instruction выполняется
  - Передача параметров через inputParams
  - Получение результата из instruction
  - Ошибка если instructionId не найден
  - Ошибка если contract не соблюдён (missing required input)
  - Serialization
  - copyWith()

**Моки:** MockToolRegistry, mock InstructionGraph

---

## КАТЕГОРИЯ 3: INSTRUCTION NODES (Узлы инструкций)

### 3.1 ToolCallNode (lib/graph/nodes/instruction/tool_call_node.dart)
**Что тестируем:** Вызов tool через ToolRegistry

**Тесты:**
- [ ] `test/graph/nodes/instruction_nodes_test.dart`
  - execute() с toolId - проверить что tool вызывается
  - Передача параметров в tool
  - Получение результата от tool
  - Подстановка переменных в параметрах {{variable}}
  - Ошибка если tool не найден
  - Ошибка если параметры невалидны
  - Serialization
  - copyWith()

**Моки:** MockToolRegistry, MockHand

---

### 3.2 LlmQueryNode (lib/graph/nodes/instruction/llm_query_node.dart)
**Что тестируем:** LLM запрос с промптом

**Тесты:**
- [ ] `test/graph/nodes/instruction_nodes_test.dart`
  - execute() с prompt - проверить что LLM вызывается
  - Подстановка переменных в prompt
  - Сохранение результата в outputVar
  - Ошибка если LLM недоступен
  - Serialization
  - copyWith()

**Моки:** MockToolRegistry с mock LLM hand

---

### 3.3 ConditionNode (lib/graph/nodes/instruction/condition_node.dart)
**Что тестируем:** Условная логика (if/else)

**Тесты:**
- [ ] `test/graph/nodes/instruction_nodes_test.dart`
  - execute() с condition = true - возвращает trueValue
  - execute() с condition = false - возвращает falseValue
  - Вычисление condition expression (например: "{{quality}} > 80")
  - Подстановка переменных в condition
  - Ошибка если condition невалиден
  - Serialization
  - copyWith()

**Моки:** Не нужны (чистая логика)

---

### 3.4 TransformNode (lib/graph/nodes/instruction/transform_node.dart)
**Что тестируем:** Трансформация данных

**Тесты:**
- [ ] `test/graph/nodes/instruction_nodes_test.dart`
  - execute() с transform expression - применяет трансформацию
  - Подстановка переменных
  - Различные типы трансформаций (map, filter, reduce)
  - Ошибка если expression невалиден
  - Serialization
  - copyWith()

**Моки:** Не нужны

---

## КАТЕГОРИЯ 4: PROMPT NODES (Узлы промптов)

### 4.1 TextBlockNode (lib/graph/nodes/prompt/text_block_node.dart)
**Что тестируем:** Статический текстовый блок

**Тесты:**
- [ ] `test/graph/nodes/prompt_nodes_test.dart`
  - execute() - возвращает text
  - Serialization
  - copyWith()

**Моки:** Не нужны

---

### 4.2 VariableInsertNode (lib/graph/nodes/prompt/variable_insert_node.dart)
**Что тестируем:** Вставка переменной в промпт

**Тесты:**
- [ ] `test/graph/nodes/prompt_nodes_test.dart`
  - execute() - возвращает значение переменной из context
  - Ошибка если переменная не найдена
  - Форматирование переменной (toString, JSON, etc)
  - Serialization
  - copyWith()

**Моки:** Не нужны (используем RunContext)

---

### 4.3 ConditionalBlockNode (lib/graph/nodes/prompt/conditional_block_node.dart)
**Что тестируем:** Условный блок в промпте

**Тесты:**
- [ ] `test/graph/nodes/prompt_nodes_test.dart`
  - execute() с condition = true - возвращает trueBlock
  - execute() с condition = false - возвращает falseBlock
  - Вычисление condition из context
  - Serialization
  - copyWith()

**Моки:** Не нужны

---

## КАТЕГОРИЯ 5: GRAPH EXECUTION (Выполнение графов)

### 5.1 WorkflowRun (lib/graph/engine/workflow_run.dart)
**Что тестируем:** Состояние выполнения workflow

**Тесты:**
- [ ] `test/graph/engine/workflow_run_test.dart`
  - Создание нового run
  - Обновление статуса (running, suspended, completed, failed)
  - Сохранение переменных в context
  - Получение переменных из context
  - Добавление событий в лог
  - Serialization: toMap() → fromMap()
  - Проверка timestamps (startedAt, completedAt)

**Моки:** Не нужны

---

### 5.2 RunContext (lib/graph/engine/run_context.dart)
**Что тестируем:** Контекст выполнения

**Тесты:**
- [ ] `test/graph/engine/run_context_test.dart`
  - Создание контекста с runId, projectId, projectPath
  - setVar() / getVar() - сохранение и получение переменных
  - log() - добавление записей в лог
  - Проверка currentBranch
  - Клонирование контекста для subGraph

**Моки:** Не нужны

---

### 5.3 ToolRegistry (lib/graph/engine/tool_registry.dart)
**Что тестируем:** Регистрация и получение tools

**Тесты:**
- [ ] `test/graph/engine/tool_registry_test.dart`
  - Регистрация hand через registerHand()
  - Получение hand через getHand()
  - Ошибка если hand не найден
  - Список всех зарегистрированных hands
  - Проверка isSystemTool flag

**Моки:** MockHand

---

## КАТЕГОРИЯ 6: GRAPH PERSISTENCE (Сохранение и загрузка графов)

### 6.1 Сохранение WorkflowGraph через Vault
**Что тестируем:** Интеграция с dart_vault для сохранения

**Тесты:**
- [ ] `test/graph/persistence/workflow_graph_persistence_test.dart`
  - Создание нового WorkflowGraph
  - Сохранение через VersionedRepository.save()
  - Загрузка через VersionedRepository.getById()
  - Обновление графа (изменение nodes/edges)
  - Сохранение новой версии (semver bump)
  - Получение истории версий
  - Создание ветки (branch)
  - Публикация версии (publish)
  - Удаление графа

**Моки:** Mock VersionedRepository (или in-memory implementation)

---

### 6.2 Сохранение InstructionGraph через Vault
**Что тестируем:** То же что WorkflowGraph + contract и tests

**Тесты:**
- [ ] `test/graph/persistence/instruction_graph_persistence_test.dart`
  - Сохранение с contract
  - Обновление contract
  - Сохранение с tests
  - Обновление tests
  - Версионирование при изменении contract

**Моки:** Mock VersionedRepository

---

### 6.3 Сохранение PromptGraph через Vault
**Тесты:**
- [ ] `test/graph/persistence/prompt_graph_persistence_test.dart`
  - Сохранение и загрузка
  - Версионирование

**Моки:** Mock VersionedRepository

---

## КАТЕГОРИЯ 7: PROJECT INTEGRATION (Интеграция с проектом)

### 7.1 Получение графов через projectId
**Что тестируем:** Фильтрация графов по ownerId (projectId)

**Тесты:**
- [ ] `test/graph/integration/project_graphs_test.dart`
  - Создание нескольких графов для одного проекта
  - Получение всех графов проекта через repository.query(ownerId: projectId)
  - Проверка что графы других проектов не возвращаются
  - Фильтрация по tenantId (multi-tenancy)
  - Поиск графа по имени внутри проекта

**Моки:** Mock VersionedRepository с in-memory storage

---

### 7.2 Access Control (accessGrants)
**Что тестируем:** Права доступа к графам

**Тесты:**
- [ ] `test/graph/integration/graph_access_control_test.dart`
  - Создание графа с accessGrants
  - Проверка доступа для пользователя с grant
  - Проверка отказа для пользователя без grant
  - Обновление accessGrants
  - Удаление accessGrants

**Моки:** Mock security context

---

## КАТЕГОРИЯ 8: GRAPH EXECUTION SCENARIOS (Сценарии выполнения)

### 8.1 Простой линейный workflow
**Что тестируем:** Последовательное выполнение узлов

**Тесты:**
- [ ] `test/graph/scenarios/linear_workflow_test.dart`
  - Граф: Node1 → Node2 → Node3
  - Выполнение от начала до конца
  - Проверка что каждый узел выполнился
  - Проверка порядка выполнения
  - Проверка финального статуса (completed)

**Моки:** MockToolRegistry, MockHand для каждого узла

---

### 8.2 Workflow с ветвлением (conditional edges)
**Что тестируем:** Условные переходы

**Тесты:**
- [ ] `test/graph/scenarios/conditional_workflow_test.dart`
  - Граф: Node1 → (if success) Node2A, (if error) Node2B
  - Выполнение с успехом - проверить что пошли в Node2A
  - Выполнение с ошибкой - проверить что пошли в Node2B
  - Проверка что только один путь выполнился

**Моки:** MockToolRegistry, MockHand с контролируемым success/error

---

### 8.3 Workflow с suspend/resume (interactive nodes)
**Что тестируем:** Приостановка и возобновление

**Тесты:**
- [ ] `test/graph/scenarios/suspend_resume_workflow_test.dart`
  - Граф: Node1 → UserInputNode → Node3
  - Выполнение до UserInputNode - проверить suspend
  - Проверка статуса (suspended)
  - Предоставление user input
  - Resume выполнения
  - Проверка что Node3 выполнился
  - Проверка финального статуса (completed)

**Моки:** MockToolRegistry, симуляция user input

---

### 8.4 Workflow с SubGraph
**Что тестируем:** Вложенные графы

**Тесты:**
- [ ] `test/graph/scenarios/subgraph_workflow_test.dart`
  - Главный граф: Node1 → SubGraphNode → Node3
  - SubGraph: SubNode1 → SubNode2
  - Выполнение главного графа
  - Проверка что SubGraph выполнился полностью
  - Проверка передачи переменных в SubGraph
  - Проверка получения результатов из SubGraph
  - Проверка что Node3 получил результаты SubGraph

**Моки:** MockToolRegistry для обоих графов

---

### 8.5 Workflow с RunInstruction
**Что тестируем:** Вызов InstructionGraph из WorkflowGraph

**Тесты:**
- [ ] `test/graph/scenarios/run_instruction_workflow_test.dart`
  - WorkflowGraph: Node1 → RunInstructionNode → Node3
  - InstructionGraph с contract (inputs/outputs)
  - Выполнение workflow
  - Проверка что instruction выполнился
  - Проверка соблюдения contract
  - Проверка передачи результатов в Node3

**Моки:** MockToolRegistry, mock InstructionGraph

---

### 8.6 Сложный workflow (комбинация всего)
**Что тестируем:** Реальный сценарий

**Тесты:**
- [ ] `test/graph/scenarios/complex_workflow_test.dart`
  - Граф:
    1. FileReadNode (читает файл)
    2. LlmActionNode (анализирует содержимое)
    3. ManualReviewNode (пользователь проверяет)
    4. Conditional edge: if approved → FileWriteNode, if rejected → Node1 (retry)
    5. GitCommitNode (коммит результата)
  - Полное выполнение с suspend на ManualReviewNode
  - Проверка всех переходов
  - Проверка финального результата

**Моки:** MockToolRegistry для всех hands

---

## КАТЕГОРИЯ 9: ERROR HANDLING (Обработка ошибок)

### 9.1 Ошибки в узлах
**Что тестируем:** Обработка исключений

**Тесты:**
- [ ] `test/graph/error_handling/node_errors_test.dart`
  - Node выбрасывает exception - проверить что workflow останавливается
  - Проверка статуса (failed)
  - Проверка error message в логе
  - OnError edge - проверить что переход на error handler
  - Retry logic (если есть)

**Моки:** MockHand который выбрасывает exception

---

### 9.2 Ошибки в данных
**Что тестируем:** Невалидные данные

**Тесты:**
- [ ] `test/graph/error_handling/data_errors_test.dart`
  - Отсутствующая переменная в context
  - Невалидный JSON в config
  - Несоответствие contract в InstructionGraph
  - Циклические зависимости в графе

**Моки:** Не нужны

---

### 9.3 Ошибки в persistence
**Что тестируем:** Проблемы с сохранением/загрузкой

**Тесты:**
- [ ] `test/graph/error_handling/persistence_errors_test.dart`
  - Граф не найден (getById возвращает null)
  - Ошибка при сохранении (DB недоступна)
  - Конфликт версий (concurrent modification)

**Моки:** Mock repository с контролируемыми ошибками

---

## КАТЕГОРИЯ 10: VALIDATION (Валидация)

### 10.1 Graph Contract Validator
**Что тестируем:** Валидация структуры графа

**Тесты:**
- [ ] `test/graph/validation/graph_validator_test.dart`
  - Валидный граф - проходит валидацию
  - Граф без узлов - ошибка
  - Граф с edge на несуществующий узел - ошибка
  - Граф с циклом - ошибка (или warning)
  - Граф без start node - ошибка
  - Граф с несколькими start nodes - ошибка

**Моки:** Не нужны

---

### 10.2 Contract Validator (для InstructionGraph)
**Что тестируем:** Валидация contract

**Тесты:**
- [ ] `test/graph/validation/contract_validator_test.dart`
  - Валидный contract - проходит
  - Contract без required inputs - ошибка
  - Contract с невалидными типами - ошибка
  - Проверка соответствия inputs при вызове

**Моки:** Не нужны

---

## КАТЕГОРИЯ 11: LOGGING & EVENTS (Логирование)

### 11.1 WorkflowEventLogger
**Что тестируем:** Логирование событий выполнения

**Тесты:**
- [ ] `test/graph/logging/workflow_logger_test.dart`
  - Логирование старта workflow
  - Логирование выполнения каждого узла
  - Логирование ошибок
  - Логирование suspend/resume
  - Логирование завершения
  - Проверка структуры событий (timestamp, nodeId, message, level)

**Моки:** Не нужны (проверяем что события добавляются в список)

---

## КАТЕГОРИЯ 12: TRANSPORT (Транспорт для удалённого выполнения)

### 12.1 RunRequest / RunResponse
**Что тестируем:** Сообщения для запуска графа

**Тесты:**
- [ ] `test/graph/transport/run_messages_test.dart`
  - Создание RunRequest
  - Serialization RunRequest
  - Создание RunResponse
  - Serialization RunResponse
  - RunStatus (running, suspended, completed, failed)
  - RunEvent serialization

**Моки:** Не нужны

---

### 12.2 UserInputResponse
**Что тестируем:** Ответ пользователя для resume

**Тесты:**
- [ ] `test/graph/transport/user_input_test.dart`
  - Создание UserInputResponse
  - Serialization
  - Применение к suspended workflow

**Моки:** Не нужны

---

## ИТОГО: ПЛАН ТЕСТИРОВАНИЯ

### Статистика:
- **Категорий:** 12
- **Файлов тестов:** ~25
- **Примерное количество тестов:** ~300-400

### Приоритеты:

**P0 (Критично):**
1. Graph Data Structures (WorkflowGraph, InstructionGraph, PromptGraph)
2. Graph Execution Scenarios (linear, conditional, suspend/resume)
3. Graph Persistence (save/load через Vault)
4. Error Handling (node errors, data errors)

**P1 (Важно):**
5. Composite Nodes (SubGraph, RunInstruction)
6. Instruction Nodes (ToolCall, LlmQuery, Condition, Transform)
7. Prompt Nodes (TextBlock, VariableInsert, ConditionalBlock)
8. Project Integration (получение графов через projectId)

**P2 (Желательно):**
9. Validation (graph structure, contract)
10. Logging & Events
11. Transport (messages)
12. Access Control

### Порядок реализации:

**Sprint 1 (Фундамент):**
1. Graph Data Structures (3 файла)
2. RunContext, WorkflowRun (2 файла)
3. ToolRegistry (1 файл)

**Sprint 2 (Persistence):**
4. Graph Persistence (3 файла)
5. Project Integration (1 файл)

**Sprint 3 (Execution):**
6. Linear Workflow (1 файл)
7. Conditional Workflow (1 файл)
8. Suspend/Resume Workflow (1 файл)

**Sprint 4 (Composite & Instruction):**
9. Composite Nodes (1 файл)
10. Instruction Nodes (1 файл)
11. Prompt Nodes (1 файл)

**Sprint 5 (Advanced Scenarios):**
12. SubGraph Workflow (1 файл)
13. RunInstruction Workflow (1 файл)
14. Complex Workflow (1 файл)

**Sprint 6 (Error Handling & Validation):**
15. Error Handling (3 файла)
16. Validation (2 файла)

**Sprint 7 (Logging & Transport):**
17. Logging (1 файл)
18. Transport (2 файла)

---

## Следующий шаг:
Начинаем с **Sprint 1: Graph Data Structures** - создаём тесты для WorkflowGraph, InstructionGraph, PromptGraph.
