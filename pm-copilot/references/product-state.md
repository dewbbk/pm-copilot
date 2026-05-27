# ProductState — Схема состояния продукта

> Single source of truth. Тесты (pm-copilot-tests) и скиллы ссылаются на этот файл.
> Версия: v6.2 (Sprint 30: PERF Cleanup)

## Формат ProductState

```yaml
ProductState:
  # =============================================
  # LAYER: WORKING MEMORY (загружается каждый ход)
  # Цель: горячие данные для текущего хода
  # Размер: ~500-800 токенов
  # =============================================
  id: string                          # уникальный ID инициативы (автогенерация: initiative-YYYY-MM-DD-HHMM)
  product_id: string                  # ID продукта-родителя (группирует инициативы, например: product-dc-ntb)
  product_scope: string               # Границы продукта для удержания контекста (например: «Дебетовая карта NTB: от лендинга до первой траты»). Copilot формулирует из описания проблемы PM → PM подтверждает
  initiative_title: string            # Краткое название инициативы (макс. 50 символов)
  stage: enum                         # goal | epic | hypothesis | task | comms | launch | post-launch
  path: enum                          # main | short (основной путь или короткий)
  problem: string                     # формулировка проблемы PM
  goals:                              # список целей (ПУТЬ 1 — первична)
    - id: string
      text: string
      smart: boolean                  # пройдена ли SMART-проверка
      status: draft | active | completed | archived
      tsar_metric: string             # царь-метрика цели
      deadline: date                  # срок достижения
      ambition: string                # амбиция (x% к Y дате)
      epics:                          # эпики внутри цели
        - id: string
          title: string
          description: string
          status: planned | active | completed
          tasks:                      # юзер стори / таски эпика
            - id: string
              title: string
              status: draft | in_progress | prd_approved | done
              prd_id: string | null   # ссылка на PRD в active_prd или archive
          active_task_id: string | null
      active_epic_id: string | null
  hypotheses:                         # список гипотез (ПУТЬ 2 — служит цели)
    - id: string
      text: string
      status: draft | validated | invalidated | abandoned
      confidence: 0-1
  active_prd:                         # текущий ПРД
    id: string
    title: string
    status: draft | ready | in_review | approved
  metrics:                            # привязка к царь-метрике
    tsar_metric: string
    current: string
    target: string
  risks: []                           # список рисков (id + текст). При compaction — последние 5
  insights:                           # Insight Buffer (v4.16). При compaction — только new/prioritized
    - id: string                      # формат: insight-YYYY-MM-DD-HHMM
      text: string
      source: string                  # интервью | аналитика | отзыв | пост-запуск | CustDev | конкурент | стейкхолдер
      impact_score: 0-3               # 0=не связано, 1=косвенное, 2=прямое, 3=критичное
      linked_goal_id: string | null
      linked_hypothesis_id: string | null
      linked_decision_id: string | null
      date: datetime
      status: new | prioritized | converted | archived
  last_context:                       # контекст последнего взаимодействия (v4.10)
    skill: string                     # какой скилл был активен
    phase: string                     # на какой фазе остановились
    last_question: string             # последний заданный вопрос
    timestamp: datetime               # когда была последняя активность
  stage_transitions_count: integer    # счётчик переходов за текущую сессию (для анти-цикла)
  phase_turns: integer                # счётчик ходов в текущей фазе sub-skill (v4.14)
  launch_readiness:                     # Launch Readiness (v4.18)
    score: integer                      # 0-100% readiness score
    checklist:                          # результаты чеклиста
      prd_approved: boolean             # ПРД approved
      comms_prepared: boolean           # коммуникации подготовлены
      guards_confirmed: boolean         # ганарды подтверждены
      rollbacks_defined: boolean        # откаты определены
      baseline_captured: boolean        # baseline метрик зафиксирован
    checked_at: datetime | null         # когда последний раз проверяли
  pre_launch_snapshot: object | null    # срез ProductState перед launch (v4.18)
  created: datetime
  updated: datetime

  # =============================================
  # LAYER: INITIATIVE MEMORY (загружается при старте сессии)
  # Цель: контекст текущей инициативы для осознанных решений
  # Размер: ~1,500-2,500 токенов
  # =============================================
  decisions: []                       # ссылки на Decision Log. При compaction — open + последние 3 reviewed
  history: []                         # лог переходов между stage, последние 5
    - from: string
      to: string
      timestamp: datetime
      trigger: string                 # auto_transition | proposed_accepted | back_transition | user_command

  # =============================================
  # LAYER: PRODUCT MEMORY (компактная сводка, детали по запросу)
  # Цель: исторический контекст без перегрузки
  # Размер: ~500-1,000 токенов (сводка)
  # =============================================
  product_memory:                     # история продукта (v4.07)
    past_hypotheses:                   # гипотезы с outcome. При compaction — последние 3 + summary
      - id: string
        text: string
        outcome: validated | invalidated | abandoned
        outcome_date: datetime
        key_learning: string
    past_launches:                    # запуски с результатами. При compaction — последние 3 + summary
      - id: string
        title: string
        launch_date: datetime
        result: scaled | iterated | pivoted | rolled_back
        key_metric_change: string
        key_learning: string
    learned_patterns:                 # автоматические выводы. При compaction — confidence >= 0.5
      - pattern: string
        evidence: string
        source_ids: []
        confidence: 0-1
        created: datetime
    learning_cards:                   # карточки обучения (v4.15). При compaction — последние 3 + summary
      - id: string                    # формат: lc-YYYY-MM-DD-HHMM
        title: string
        what_worked: string
        what_failed: string
        surprises: string
        tib_scenario: string
        key_learning: string
        process_change: string
        source_ids: []
        created: datetime
    summary: string | null            # авто-сводка истории продукта (добавляется при compaction, v4.17)
  learning_cycle_count: integer       # количество полных циклов goal→...→post-launch (v4.15)

  # =============================================
  # LAYER: ARCHIVE (НЕ загружается по умолчанию)
  # Доступен по команде `детали [поле]`
  # =============================================
  archive:                            # компактные данные, перемещённые из активных полей (v4.17)
    goals: []                         # completed/archived цели
    hypotheses: []                    # validated/invalidated/abandoned гипотезы
    decisions: []                     # reviewed/superseded решения (сверх последних 3)
    history: []                       # переходы старше последних 5
    insights: []                      # converted/archived инсайты
    risks: []                         # риски сверх последних 5
    past_hypotheses: []               # гипотезы сверх последних 3
    past_launches: []                 # запуски сверх последних 3
    learning_cards: []                # карточки сверх последних 3
    learned_patterns: []              # паттерны с confidence < 0.5

```

## Жизненный цикл ProductState

1. **Создание**: При первой сессии с новым продуктом — создать ProductState с `stage: goal`, `path: main`, `problem` из первого сообщения PM. `archive` пустой. `company_memory: null`.
2. **Загрузка**: При повторной сессии — загрузить по Layer Loading стратегии (см. ниже)
3. **Обновление**: При каждом ответе скилла — обновить релевантные поля ProductState
4. **Compaction**: При завершении этапа или по команде — компактить детальные данные (см. Compaction Rules)
5. **Сохранение**: При завершении сессии или по команде `итого` — сохранить ProductState

## Memory Layers — Стратегия загрузки

> **Ядро v4.17**: ProductState разделён на логические слои с разной стратегией загрузки. Цель — снизить средний размер загружаемого состояния с 8,000+ до ~2,500-4,300 токенов.

### Таблица загрузки слоёв

| Слой | Когда загружается | Что загружается | Целевой размер |
|------|-------------------|-----------------|----------------|
| **Working** | Каждый ход | Все поля Working Memory (id, stage, problem, goals, hypotheses, active_prd, metrics, risks, insights, last_context, счётчики) | ~500-800 токенов |
| **Initiative** | При старте сессии + при активации sub-skill | decisions[], history[] | ~1,500-2,500 токенов |
| **Product** | При старте сессии (сводка) + по запросу | product_memory (summary + активные подсекции) | ~500-1,000 токенов |
| **Archive** | ТОЛЬКО по команде `детали [поле]` | Конкретное поле из archive | По запросу |
| **Company** | Не реализован | placeholder | 0 |

## Compaction Rules — Правила компактизации

> **Ядро v4.17**: Compaction сжимает детальные данные в сводку, перемещая избыточные записи в archive. Данные не теряются — доступны по команде `детали`.

### Когда срабатывает compaction

| Триггер | Условие | Что компактится |
|---------|---------|-----------------|
| **Авто-compaction** | `history.length > 5` | history → archive.history (оставить последние 5) |
| **Завершение этапа** | Переход stage (кроме back_transition) | Данные завершённого этапа → archive |
| **Ручная команда** | `компактизация` | Полная компактизация всех полей |
| **Завершение сессии** | `итого` | Полная компактизация + генерация summary |


---
## Stage Detection — Определение этапа

### Определение текущего stage по ProductState

| Условие в ProductState | Stage |
|---|---|
| Нет профиля PM | `onboarding` |
| Создан, goals[] пуст, hypotheses[] пуст, active_prd пуст | `goal` |
| goals[] содержит draft/active, active_prd пуст | `goal` |
| goals[] содержит active, эпики определены, нет выбранной таски | `epic` |
| hypotheses[] непуст, goals[] пуст (короткий путь) | `hypothesis` |
| active_prd.status = draft/in_review | `task` |
| active_prd.status = ready/approved, comms не подготовлены | `comms` |
| Коммуникации готовы, readiness ≥ 80% | `launch` |
| Фича запущена, есть actual_outcome | `post-launch` |

### Переходы между stage

```
goal ──авто──→ epic
epic ──предложение──→ task
epic ⇄ task (цикл по таскам эпика)
task (prd_ready) ──предложение──→ comms
comms (done) ──предложение──→ launch
launch ──авто──→ post-launch
post-launch ──предложение──→ goal (новый цикл)

Короткий путь (path: short):
hypothesis ──авто──→ task
task (prd_ready) ──предложение──→ comms
comms (done) → PRD (финал)

Инструменты (не меняют stage):
generation — callable из любого stage
thinking-in-bets — callable при confidence < 0.7
```

**Автопереходы** (без подтверждения PM): goal→epic, launch→post-launch

**Предложения** (PM подтверждает): epic→task, epic⇄task (цикл), task→comms, comms→launch, post-launch→goal

**Короткий путь** (path: short): hypothesis→task→comms→PRD (финал)

### Условия готовности к переходу

| Переход | Условие готовности | Что проверяется |
|---|---|---|
| → goal | PM начинает работу | goals[] пуст или goals[*].status = draft |
| goal → epic | Цель декомпозирована в эпики | goals[] содержит active + epics[] непуст |
| epic → task | Таска выбрана | goals[].epics[].active_task_id заполнен |
| hypothesis → task | Гипотеза сформулирована | hypotheses[] содержит draft, path = short |
| task → comms | ПРД готов | active_prd.status = ready/approved |
| comms → launch | Коммуникации готовы | артефакт создан, readiness ≥ 80% |
| launch → post-launch | Фича запущена | PM подтвердил запуск |
| post-launch → goal | Оценка завершена | decisions[] содержат actual_outcome |

### Отображение PM

Условия готовности НЕ выполнены: `📍 Этап: [stage]`
Условия готовности выполнены: `📍 Этап: [stage] → Следующий: [next_stage]`
При post-launch (оценка завершена): `📍 Этап: post-launch (завершено)`

При предложении перехода:
```
📍 Переход: [текущий] → [следующий]
Обоснование: [почему]

Перейти? (да/нет/не сейчас)
```

### Обратные переходы

PM может вернуться: `переключись на [stage]`. При этом:
- Не удалять данные — только обновить `stage`
- Если данные для stage в archive — извлечь обратно в активные поля
- Добавить запись в `history` с `trigger: back_transition`
- Не предлагать переход вперёд 3 следующих сообщения (анти-цикл)

### Анти-цикл

Если `stage_transitions_count > 3` за сессию — мягко подсветить паттерн.

## Launch Readiness — Проверка готовности к запуску

> **Ядро v4.18**: Перед переходом comms → launch — автоматическая проверка готовности. Readiness Score, чеклист и Pre-launch Snapshot защищают от преждевременного запуска.

### Launch Readiness Checklist

| # | Пункт | Что проверяется | Автоматически или вручную |
|---|-------|----------------|--------------------------|
| 1 | ПРД approved | `active_prd.status = approved` | Авто |
| 2 | Коммуникации подготовлены | Создан артефакт через pm-copilot-comms | Авто |
| 3 | Ганарды подтверждены | `metrics` содержит ганарды с порогами | PM подтверждает |
| 4 | Откаты определены | `risks[]` содержит mitigation | PM подтверждает |
| 5 | Baseline метрик зафиксирован | `metrics.current` заполнен | Авто + PM |

### Readiness Score

```
Readiness Score = (выполненные пункты / 5) × 100%
```

| Score | Статус | Действие |
|-------|--------|----------|
| 100% | ✅ Готов | Предложить переход |
| 80-99% | ⚠️ Почти готов | Предупредить, предложить исправить |
| 60-79% | 🟡 Не готов | Рекомендовать вернуться |
| <60% | 🔴 Критично | Настоятельно рекомендовать вернуться |

### Pre-launch Snapshot

При подтверждении запуска — сохраняется в `pre_launch_snapshot`:

```yaml
PreLaunchSnapshot:
  timestamp: datetime
  readiness_score: integer
  prd_id: string
  prd_title: string
  goals_summary: string
  metrics_baseline:
    tsar_metric: { name: string, value: string }
    drivers: []
    guards: []
  key_risks: []
  key_decisions: []
  comms_artifacts: []
```

### Правила Launch Readiness

1. Readiness Check не блокирует запуск — PM решает, но Copilot предупреждает при < 80%
2. Snapshot создаётся обязательно при любом Go-решении
3. Readiness обновляется при повторной проверке
4. При post-launch — pre_launch_snapshot загружается автоматически для сравнения
5. Ганарды проверяются дважды: при readiness check и при Go/No-Go


## Autopilot — Проактивные подсказки (v4.05)

Каждый ответ workflow-скилла заканчивается блоком (если autopilot: on):

```
📌 Следующий шаг: [конкретное действие]
   Или: [альтернатива]
```

### Логика предложений

- stage = goal + KR зафиксированы → «Перейти к проработке эпика?»
- stage = epic + таски собраны → «Выбрать таску для проработки?»
- stage = task + prd ready → «Подготовить бриф для PBR?»
- stage = comms + коммуникации готовы → «Подтвердить запуск?»
- stage = post-launch + оценка завершена → «Сформулировать новую цель?»
- Decision confidence < 0.7 → «Провести вероятностный анализ?»
- Нет подходящего условия → не показывать подсказку

Приоритет: одно, самое приоритетное. Настройка: `autopilot on/off` в профиле PM.

## Backward Compatibility — Совместимость с v5.x

При загрузке ProductState без `path` → defaults to `main`.
При загрузке ProductState без `epics[]` → миграция: создать один эпик из существующих данных goal.
При загрузке ProductState со stage `insight` → миграция: установить `stage: goal`, `path: main`.
При загрузке ProductState со stage `generation` → миграция: установить `stage: goal` (или текущий stage цели).
При загрузке ProductState со stage `learning` → миграция: установить `stage: post-launch`.

---

## Deferred Mechanisms

> Механизмы, убранные в Sprint 30 для упрощения. Возвращаем когда станут реально используемыми.
> Полный контент — в git истории (commit до Sprint 30).

- **Archive Search Rules (v4.22)** — алгоритм поиска по архиву с весами relevance (0.3/0.3/0.4). Вернуть когда archive накопит данные.
- **Learning Loop (v4.15)** — замкнутый цикл learning_card → goal bridge → auto-suggest. Вернуть при learning_cycle_count >= 1.
- **Session Resume (v4.10)** — last_context механизм с командой `продолжить`. Вернуть при реальных жалобах на потерю контекста.
- **Multi-Initiative (v4.20)** — параллельные инициативы, shared_memory, cross_insights. Вернуть при >=2 активных PM или по запросу.
- **Obsidian Integration (v4.04)** — сохранение артефактов в vault с frontmatter. Вернуть при активной работе с Obsidian.
- **Compaction Rules (детали)** — правила по полям (goals, hypotheses, decisions, history и т.д.). Вернуть когда ProductState вырастет до размеров требующих compaction.
