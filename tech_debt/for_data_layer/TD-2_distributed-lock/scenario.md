# Сценарий использования TD-2: Distributed Lock

## Как будет использоваться

```dart
// aq_graph_engine/lib/src/server/storage/data_layer_run_repository.dart

@override
Future<bool> tryAcquireLock({
  required String runId,
  required String workerId,
  required Duration ttl,
}) async {
  // Реализация от data layer — атомарный захват
  return await IDataLayer.instance.tryAcquireLock(
    key: 'workflow_run:$runId',
    owner: workerId,
    ttl: ttl,
  );
}

@override
Future<bool> releaseLock({
  required String runId,
  required String workerId,
}) async {
  return await IDataLayer.instance.releaseLock(
    key: 'workflow_run:$runId',
    owner: workerId,
  );
}
```

## Где вызывается в движке

```dart
// aq_graph_worker/lib/src/worker_loop.dart (упрощённо)

final acquired = await runRepo.tryAcquireLock(
  runId: run.id,
  workerId: workerId,
  ttl: const Duration(minutes: 5),
);

if (!acquired) {
  // Другой воркер уже взял этот run — пропускаем
  return;
}

try {
  await engine.run(run);
} finally {
  await runRepo.releaseLock(runId: run.id, workerId: workerId);
}
```

## Ожидаемое поведение

| Ситуация | Результат |
|----------|-----------|
| Lock свободен | `tryAcquireLock` → `true`, воркер выполняет run |
| Lock занят другим воркером | `tryAcquireLock` → `false`, воркер пропускает run |
| Воркер упал, TTL истёк | Следующий `tryAcquireLock` → `true` |
| Тот же воркер повторно | `tryAcquireLock` → `true` (idempotent) |
| `releaseLock` чужим воркером | → `false`, lock не снимается |
