# Tech Debt — Задания для других пакетов

Эта папка содержит ТЗ от `aq_graph_engine` к другим пакетам платформы.

## Структура

```
tech_debt/
  for_data_layer/   — задания для aq_data_layer
```

## Процесс

1. Команда `aq_graph_engine` создаёт ТЗ в соответствующей папке
2. Команда `aq_data_layer` реализует и возвращает описание решения
3. `aq_graph_engine` убирает workaround и закрывает долг

## Открытые задания

| ID | Файл | Приоритет | Статус |
|----|------|-----------|--------|
| TD-2 | `for_data_layer/TD-2_distributed_lock.md` | HIGH | 🔴 Открыт |
| TD-3 | `for_data_layer/TD-3_append_only_logs.md` | MEDIUM | 🔴 Открыт |
