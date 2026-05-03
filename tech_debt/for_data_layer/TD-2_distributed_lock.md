# ТЗ: Distributed Lock для WorkflowRun

**От:** aq_graph_engine  
**Кому:** aq_data_layer  
**Приоритет:** HIGH  
**Тип:** Новая функциональность

---

## Контекст

Графовый движок (`aq_graph_engine`) выполняет графы через воркеры (`aq_graph_worker`).
Каждый запуск графа (WorkflowRun) должен выполняться **ровно одним воркером**.

Сейчас в `IRunRepository` есть методы:
```dart
Future<bool> tryAcquireLock({required String runId, required String workerId, required Duration ttl});
Future<bool> releaseLock({required String runId, required String workerId});
```

Текущая реализация в `DataLayerRunRepository`:
```dart
Future<bool> tryAcquireLock(...) async => true;  // всегда true — заглушка
Future<bool> releaseLock(...) async => true;      // всегда true — заглушка
```

---

## Проблема

При горизонтальном масштабировании (несколько воркеров) один и тот же `WorkflowRun` может быть захвачен несколькими воркерами одновременно. Это приводит к:
- Двойному выполнению графа
- Конфликтам при записи логов и статуса
- Некорректным результатам

---

## Что нужно

Реализовать `tryAcquireLock` и `releaseLock` в `DataLayerRunRepository` так, чтобы:

1. **Атомарность** — только один воркер может захватить lock на конкретный `runId` в один момент времени
2. **TTL** — lock автоматически освобождается через `ttl` если воркер упал (не вызвал `releaseLock`)
3. **Идентификация** — lock привязан к `workerId`, только захвативший воркер может освободить
4. **Возврат false** — если lock уже захвачен другим воркером, `tryAcquireLock` возвращает `false` без ожидания

---

## Требования

### Функциональные

- `tryAcquireLock(runId, workerId, ttl)` → `true` если lock захвачен, `false` если уже занят
- `releaseLock(runId, workerId)` → `true` если освобождён, `false` если lock принадлежит другому воркеру
- Lock с истёкшим TTL считается свободным — следующий `tryAcquireLock` должен его захватить
- Повторный вызов `tryAcquireLock` тем же `workerId` на тот же `runId` — допустимо вернуть `true` (idempotent)

### Нефункциональные

- Операция должна быть атомарной (нет race condition между проверкой и захватом)
- Не должна блокировать выполнение (non-blocking, возвращает немедленно)
- Должна работать при нескольких инстансах воркера

---

## Контракт интерфейса (не менять)

```dart
// В IRunRepository (aq_schema) — интерфейс уже определён:
Future<bool> tryAcquireLock({
  required String runId,
  required String workerId,
  required Duration ttl,
});

Future<bool> releaseLock({
  required String runId,
  required String workerId,
});
```

---

## Что вернуть

Реализацию `tryAcquireLock` и `releaseLock` в `DataLayerRunRepository` (файл `aq_graph_engine/lib/src/server/storage/data_layer_run_repository.dart`).

Описание подхода: какой механизм использован, какие гарантии даёт, какие ограничения.

---

## Текущий workaround

До реализации: `tryAcquireLock → true` (single-worker deployment only).  
Задокументировано в коде как TECH DEBT.
