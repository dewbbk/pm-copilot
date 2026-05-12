# ProductState — Схема состояния продукта

> Single source of truth. Тесты (pm-copilot-tests) и скиллы ссылаются на этот файл.
> Версия: v4.18 (Sprint 26: Launch Readiness)

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
  initiative_title: string            # Краткое название инициативы для дашборда (макс. 50 символов)
  stage: enum                         # insight | goal | hypothesis | task | comms | launch | post-launch | learning
  problem: string                     # формулировка проблемы PM
  goals:                              # список целей (ПУТЬ 1 — первична)
    - id: string
      text: string
      smart: boolean                  # пройдена ли SMART-проверка
      status: draft | active | completed | archived
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
      source: string                  # интервью | аналитика | отзыв | пост-запуск | CustDev | конкурент
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
  history: []                         # лог переходов между stage. При compaction — последние 5
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
    active_initiatives:               # текущие инициативы и их статус
      - id: string
        title: string
        status: in_progress | blocked | at_risk
        related_goal_id: string
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
  learning_cycle_count: integer       # количество полных циклов goal→...→learning (v4.15)

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

  # =============================================
  # LAYER: SHARED PRODUCT MEMORY (v4.20)
  # Хранится отдельно: ~/pm-copilot-shared-[product_id].md
  # Загружается при старте сессии если product_id совпадает с другой инициативой
  # =============================================
  shared_memory:                      # общая память продукта, доступна всем инициативам (v4.20)
    product_id: string                # дублирует product_id из корня для удобства
    past_launches: []                 # запуски из ВСЕХ инициатив продукта (копируется из product_memory при compaction)
    learned_patterns: []              # паттерны с confidence >= 0.5 из всех инициатив
    cross_insights: []                # инсайты, помеченные как релевантные нескольким инициативам
      - id: string                    # формат: ci-YYYY-MM-DD-HHMM
        text: string
        source_initiative_id: string  # откуда пришёл
        relevant_to: []               # список initiative_id которым релевантен
        date: datetime
```

## Жизненный цикл ProductState

1. **Создание**: При первой сессии с новым продуктом — создать ProductState с `stage: insight`, `problem` из первого сообщения PM. `archive` пустой. `company_memory: null`.
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

### Правила загрузки

1. **Working Memory — всегда**: На каждом ходу Copilot имеет доступ к Working Memory. Это минимум для осмысленного ответа
2. **Initiative Memory — при старте сессии**: При загрузке ProductState — загрузить Initiative Memory целиком. Внутри сессии — не перезагружать (уже загружено)
3. **Product Memory — сводка при старте**: При загрузке ProductState — показать `product_memory.summary` если он непуст. Детали past_hypotheses, past_launches, learning_cards — загружать при первом обращении к соответствующему sub-skill (goal, post-launch, learning)
4. **Archive — по запросу**: Никогда не загружается автоматически. Только по команде `детали [поле]`. Примеры: `детали решения`, `детали гипотезы`, `детали история`
5. **Company Memory — placeholder**: Не загружается. Архитектурное место зарезервировано для будущей реализации

### Формат сводки при загрузке ProductState

При загрузке существующего ProductState (повторная сессия) Copilot показывает:

```
📦 ProductState: [id]
📍 Stage: [stage]
📋 Проблема: [problem]

🎯 Цель: [goals[0].text если active]
📊 Метрика: [tsar_metric] — текущее: [current] → цель: [target]

📚 Product Memory: [summary если непуст, иначе «пока нет истории»]
📂 Archive: [N] записей (команда `детали [поле]` для доступа)
```

### Что попадает в какой слой

| Поле | Слой | Примечание |
|------|------|------------|
| id, stage, problem | Working | Ядро, нужно каждый ход |
| goals[] | Working | Все цели (при compaction — completed/archived → archive) |
| hypotheses[] | Working | Все гипотезы (при compaction — finalized → archive) |
| active_prd | Working | Текущий ПРД |
| metrics | Working | Царь-метрика, нужна каждый ход |
| risks[] | Working | При compaction — последние 5, остальные → archive |
| insights[] | Working | При compaction — new/prioritized, остальные → archive |
| last_context | Working | Для Session Resume |
| stage_transitions_count, phase_turns | Working | Счётчики для Anti-Overthinking и анти-цикла |
| launch_readiness | Working | Launch Readiness проверка готовности (v4.18) |
| pre_launch_snapshot | Working | Pre-launch Snapshot для post-launch сравнения (v4.18) |
| decisions[] | Initiative | Не нужны каждый ход, но важны при принятии решений |
| history[] | Initiative | Лог переходов, при compaction — последние 5 |
| product_memory.* | Product | Исторический контекст, загружается как сводка |
| archive.* | Archive | Не загружается по умолчанию |
| company_memory | Company | Placeholder |

## Compaction Rules — Правила компактизации

> **Ядро v4.17**: Compaction сжимает детальные данные в сводку, перемещая избыточные записи в archive. Данные не теряются — доступны по команде `детали`.

### Когда срабатывает compaction

| Триггер | Условие | Что компактится |
|---------|---------|-----------------|
| **Авто-compaction** | `history.length > 5` | history → archive.history (оставить последние 5) |
| **Завершение этапа** | Переход stage (кроме back_transition) | Данные завершённого этапа → archive |
| **Ручная команда** | `компактизация` | Полная компактизация всех полей |
| **Завершение сессии** | `итого` | Полная компактизация + генерация summary |

### Правила компактизации по полям

#### goals[]
- **Условие**: goals[] содержит completed/archived
- **Действие**: Переместить completed/archived цели в `archive.goals[]`
- **Оставить**: Только draft/active в Working Memory
- **Без потерь**: Все данные цели сохранены в archive, доступны по `детали цели`

#### hypotheses[]
- **Условие**: hypotheses[] содержит validated/invalidated/abandoned
- **Действие**: Переместить finalized гипотезы в `archive.hypotheses[]`
- **Оставить**: Только draft в Working Memory
- **Связь**: Если hypothesis связана с goal (через related_decisions) — связь сохраняется

#### decisions[]
- **Условие**: decisions[] содержит >3 reviewed/superseded
- **Действие**: Оставить open + последние 3 reviewed, остальные → `archive.decisions[]`
- **Цепочки**: related_decisions ссылки работают и через archive

#### history[]
- **Условие**: history.length > 5
- **Действие**: Оставить последние 5 переходов, остальные → `archive.history[]`
- **Сводка**: Добавить summary старых переходов: «С [date] по [date]: [N] переходов, основные stages: [list]»

#### insights[]
- **Условие**: insights[] содержит converted/archived
- **Действие**: Переместить converted/archived → `archive.insights[]`
- **Оставить**: Только new/prioritized в Working Memory
- **Связи**: linked_goal_id, linked_decision_id сохраняются

#### risks[]
- **Условие**: risks.length > 5
- **Действие**: Оставить последние 5, остальные → `archive.risks[]`

#### product_memory.past_hypotheses[]
- **Условие**: past_hypotheses.length > 3
- **Действие**: Оставить последние 3, остальные → `archive.past_hypotheses[]`
- **Сводка**: Добавить summary: «[N] гипотез за [период]: [X] validated, [Y] invalidated, [Z] abandoned. Ключевой паттерн: [pattern]»

#### product_memory.past_launches[]
- **Условие**: past_launches.length > 3
- **Действие**: Оставить последние 3, остальные → `archive.past_launches[]`
- **Сводка**: Добавить summary: «[N] запусков за [период]: [X] scaled, [Y] iterated, [Z] rolled_back. Средний эффект: [summary]»

#### product_memory.learning_cards[]
- **Условие**: learning_cards.length > 3
- **Действие**: Оставить последние 3, остальные → `archive.learning_cards[]`

#### product_memory.learned_patterns[]
- **Условие**: learned_patterns содержит confidence < 0.5
- **Действие**: Оставить patterns с confidence >= 0.5, остальные → `archive.learned_patterns[]`
- **Оговорка**: При запросе `история` —_patterns с confidence < 0.4 показывать с пометкой «предварительный вывод»

### Генерация product_memory.summary

При первой компактизации (или по команде `итого`) Copilot генерирует `product_memory.summary` — компактную сводку всей истории продукта:

```yaml
product_memory:
  summary: "Продукт прошёл [N] циклов. Ключевой опыт: [1-2 предложения]. Основной паттерн: [pattern]. Рекомендация для будущих итераций: [recommendation]"
```

**Правила summary**:
- Не более 2-3 предложений (~100-150 токенов)
- Содержит: количество циклов, ключевой опыт, основной паттерн, рекомендацию
- Обновляется при каждой компактизации
- Если `learning_cycle_count >= 3` — добавить «Зрелый продукт: фокус на масштабировании»

### Команда `детали`

PM может запросить полные данные из archive:

```
🔍 Детали: [поле]

[полные данные из archive.[поле]]

Вернуться к сводке? (да)
```

**Доступные поля**:
- `детали цели` → archive.goals (completed/archived цели)
- `детали гипотезы` → archive.hypotheses (finalized гипотезы)
- `детали решения` → archive.decisions (reviewed/superseded решения)
- `детали история` → archive.history (старые переходы)
- `детали инсайты` → archive.insights (converted/archived инсайты)
- `детали риски` → archive.risks (архивные риски)
- `детали запуски` → archive.past_launches (старые запуски)

**При отсутствии данных**: «В archive нет данных по полю [поле]. Все данные активны.»

### Команда `компактизация`

PM может запустить компактизацию вручную:

```
📦 Компактизация ProductState

Было: [N] записей в активных полях
Стало: [M] записей в активных полях, [K] перемещено в archive

Перемещено:
  goals: [X] → archive
  hypotheses: [Y] → archive
  decisions: [Z] → archive
  ...

Summary обновлён: [да/нет]

Данные доступны по команде `детали [поле]`
```

### Правила Compaction

1. **Данные не теряются**: Каждая запись, перемещённая в archive, сохраняется полностью. Compaction = перемещение, не удаление
2. **Связи сохраняются**: related_decisions, linked_goal_id, linked_decision_id — все ссылки работают и через archive
3. **Archive не загружается по умолчанию**: Это ключевая экономия. Archive доступен только по команде `детали`
4. **Summary генерируется один раз**: При первой компактизации, обновляется при последующих
5. **Обратная распаковка**: Если PM возвращается к архивной цели/гипотезе (команда `переключись на [stage]`) — Copilot извлекает данные из archive обратно в активные поля
6. **Compaction при каждом переходе stage**: При переходе (кроме back_transition) — автоматически компактить данные завершённого этапа

---

## Stage Detection — Определение этапа

### Определение текущего stage по ProductState

| Условие в ProductState | Stage |
|---|---|
| Создан, нет goals/hypotheses/active_prd | `insight` |
| goals[] непуст, goals[*].status = draft/active, active_prd пуст | `goal` |
| goals[] содержит active, hypotheses[] непуст (для неопределённых эпиков) | `goal` (гипотезы обслуживают цель) |
| hypotheses[] непуст, goals[] пуст (PM вошёл через Путь 2) | `hypothesis` |
| hypotheses[] содержит validated гипотезу, goals[] пуст | `hypothesis` (ждём решение PM о переходе) |
| active_prd.status = draft/in_review, goals содержат active | `task` |
| active_prd.status = ready/approved, comms не подготовлены | `comms` |
| Коммуникации готовы, запуск подтверждён | `launch` |
| Фича запущена, есть actual_outcome для проверки | `post-launch` |
| post-launch завершён, уроки извлечены | `learning` |

### Переходы между stage

```
insight ──авто──→ generation
goal (decomposed) ──предложение──→ task
goal (uncertain epics) ──предложение──→ hypothesis
hypothesis (validated) ──предложение──→ goal
task (prd_ready) ──предложение──→ comms
comms (done) ──предложение──→ launch
launch ──авто──→ post-launch
post-launch ──авто──→ learning
learning ──предложение──→ generation  (Learning Loop, v4.15)
learning ──предложение──→ goal       (если PM хочет новую цель из уроков)
```

**Автопереходы** (без подтверждения PM): insight→generation, launch→post-launch, post-launch→learning

**Предложения** (PM подтверждает): goal→task, goal→hypothesis, hypothesis→goal, task→comms, comms→launch, learning→generation, learning→goal

**Learning Loop** (v4.15): При stage = learning — Copilot автоматически предлагает начать новый цикл из уроков. Если learning_cycle_count >= 3 — Copilot отмечает «зрелый продукт» и адаптирует вопросы (больше фокуса на масштабирование и оптимизацию, меньше на поиск product-market fit).

### Условия готовности к переходу

| Переход | Условие готовности | Что проверяется в ProductState |
|---|---|---|
| insight → generation | PM описал проблему | `problem` заполнен, `stage = insight` |
| insight → goal | PM хочет превратить инсайт в цель напрямую | `insights[]` содержит `impact_score >= 2`, PM подтвердил |
| goal → task | Цель декомпозирована | `goals[]` содержит `status: active` + есть KR/эпики |
| goal → hypothesis | Есть неопределённые эпики | `goals[]` содержит `status: active` + эпики с высокой неопределённостью |
| hypothesis → goal | Гипотеза валидирована | `hypotheses[]` содержит `status: validated` |
| task → comms | ПРД готов | `active_prd.status = ready/approved` |
| comms → launch | Коммуникации готовы | артефакт коммуникаций создан |
| launch → post-launch | Фича запущена | PM подтвердил запуск |
| post-launch → learning | Оценка завершена | `decisions[]` содержат `actual_outcome` |
| learning → generation | PM хочет начать новый цикл из уроков | `product_memory.learning_cards[]` непуст |
| learning → goal | PM хочет сформулировать новую цель из уроков | `product_memory.learning_cards[]` непуст |

### Отображение PM

Условия готовности НЕ выполнены: `📍 Этап: [stage]`
Условия готовности выполнены: `📍 Этап: [stage] → Следующий: [next_stage]`
При learning: `📍 Этап: learning (завершено)`

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

## Learning Loop — Замкнутый цикл обучения

> **Ядро v4.15**: После post-launch уроки извлекаются и автоматически влияют на будущие сессии. Learning Loop замыкает пайплайн: запустили → оценили → извлекли уроки → следующий запуск лучше.

### Механизм Learning Loop

1. **Post-launch → Learning Card**: При завершении post-launch — Copilot формирует Learning Card (фиксированный формат) и записывает в `product_memory.learning_cards[]`
2. **Learning → Generation Bridge**: При stage = learning — Copilot автоматически переносит уроки в контекст для следующей генерации: «В прошлый раз [pattern]. Учесть при генерации?»
3. **Auto-suggest из Product Memory**: При начале новой цели/гипотезы — Copilot проверяет `learned_patterns` и `learning_cards`, предлагает учесть прошлый опыт
4. **Счётчик циклов**: `learning_cycle_count` инкрементируется при каждом завершённом цикле (goal → ... → learning). При >=3 — «зрелый продукт»

### Формат Learning Card

```yaml
LearningCard:
  id: lc-YYYY-MM-DD-HHMM
  title: string                      # название задачи/запуска
  what_worked: string                # что сработало (1-3 пункта)
  what_failed: string                # что НЕ сработало (1-3 пункта)
  surprises: string                  # сюрпризы — что произошло неожиданно
  tib_scenario: string               # какой сценарий TIB реализовался
  key_learning: string               # 1-2 предложения, которые изменят будущие решения
  process_change: string             # что меняем в процессе
  source_ids: []                     # ссылки на past_launches/decisions
  created: datetime
```

### Правила Learning Loop

1. **Learning Card формируется обязательно** при завершении post-launch (Шаг 5). Если PM торопится — Copilot создаёт минимальную карточку (what_worked + what_failed + key_learning) и предлагает дополнить позже
2. **Bridge срабатывает автоматически**: При переходе learning → generation — Copilot показывает топ-3 урока из последней Learning Card и спрашивает, какие учесть
3. **Auto-suggest на старте**: При начале новой цели/гипотезы — Copilot проверяет `learned_patterns` с confidence >= 0.5 и предлагает: «Из прошлого опыта: [pattern]. Учесть?»
4. **Зрелый продукт**: При learning_cycle_count >= 3 — Copilot отмечает «зрелый продукт» и адаптирует вопросы: больше фокуса на масштабирование и оптимизацию, меньше на поиск PMF
5. **Learning Card ≠ learned_pattern**: Learning Card — конкретный кейс. learned_pattern — обобщённый вывод на основе нескольких кейсов. Одна Learning Card может породить learned_pattern при обнаружении повторения

### Команда `уроки`

PM может запросить все Learning Cards командой `уроки`:

```
📚 Уроки продукта: [название]

Циклов пройдено: [N] [зрелый продукт / начальный этап]

Карточки обучения:
  1. [title] — [key_learning]
  2. [title] — [key_learning]
  ...

Выявленные паттерны:
  - [pattern] (confidence: [X])
  ...
```

---

### Insight Management (v4.16)

**insights[]**: Заполняется при добавлении инсайта командой `инсайт [текст]` или автоматически при обнаружении наблюдения/данных в диалоге. Каждый инсайт имеет `source` (источник), `impact_score` (влияние на царь-метрику, заполняется при приоритизации) и `status` (new → prioritized → converted → archived).

При конвертации инсайта в цель: `linked_goal_id` = ID цели, `status` = converted.
При конвертации в гипотезу: `linked_hypothesis_id` = ID гипотезы, `status` = converted.
При связи с решением: `linked_decision_id` = ID решения, `status` = converted.

При compaction: converted/archived инсайты перемещаются в `archive.insights[]`.

**Команды для PM**:
- `инсайт [текст]` — добавить инсайт
- `инсайты` — просмотреть все инсайты с приоритизацией
- `инсайты все` — включая архивные
- `инсайт → цель [id]` — превратить инсайт в цель напрямую
- `инсайт → гипотеза [id]` — превратить инсайт в гипотезу
- `инсайт приоритет [id]` — переприоритизировать инсайт

---

## Product Memory — История продукта

> **Ядро v4.07**: Product Memory накапливает опыт продукта — прошлые гипотезы, запуски, инициативы и автоматические выводы. Copilot использует этот контекст при новых сессиях, чтобы избежать повторения ошибок и предложить более точные рекомендации.

### Жизненный цикл Product Memory

1. **Создание**: При первом ProductState — `product_memory` пустой (нет прошлого опыта)
2. **Накопление**: При каждом ключевом событии — hypothesis с outcome, launch с результатом, выявленный паттерн — соответствующий список пополняется
3. **Загрузка**: При новой сессии — Copilot загружает Product Memory как сводку (summary), детали — по запросу
4. **Compaction**: При превышении лимитов — старые данные перемещаются в archive, генерируется summary
5. **Обновление**: При post-launch — `learned_patterns` обновляется на основе оценки результатов

### Правила заполнения

**past_hypotheses**: Заполняется при изменении `hypotheses[].status` на validated/invalidated/abandoned. Copilot переносит завершённую гипотезу в `past_hypotheses` с `key_learning` — 1-2 предложения главного вывода.

**past_launches**: Заполняется при завершении post-launch (Шаг 4 — Решение). Copilot добавляет запись с результатом (scaled/iterated/pivoted/rolled_back), изменением ключевой метрики и главным выводом.

**active_initiatives**: Обновляется при создании/изменении целей и задач. Инициатива = эпик или задача в работе. Статус определяется по ProductState: есть ли блокеры, риски, зависимость.

**learned_patterns**: Заполняется автоматически при post-launch, когда Copilot выявляет повторяющийся паттерн. Каждый паттерн имеет `evidence` (на чём основан) и `confidence` (насколько подтверждён). Паттерны с confidence < 0.4 — предварительные, не показываются PM без оговорки.

**summary** (v4.17): Генерируется при первой компактизации. Содержит 2-3 предложения ключевого опыта продукта. Обновляется при каждой компактизации.

### Как Copilot использует Product Memory

| Контекст | Что Copilot делает с Product Memory |
|----------|--------------------------------------|
| При формулировке гипотезы | Проверяет `past_hypotheses` на повторы — «Похожая гипотеза уже была: [text]. Результат: [outcome]. Учесть прошлый опыт?» |
| При планировании эксперимента | Проверяет `learned_patterns` — «Раньше кэшбэк-кампании давали +5% utilization, но рос roll rate. Учтём это в ганардах?» |
| При post-launch | Добавляет в `past_launches`, обновляет `learned_patterns` если выявлен новый паттерн, создаёт Learning Card в `learning_cards[]` |
| При оценке рисков | Проверяет `past_launches` с result = rolled_back — «Похожий запуск откатили: [title]. Причина: [key_learning]. Учтём?» |
| При начале новой цели/гипотезы | Проверяет `learned_patterns` и `learning_cards` — «Из прошлого опыта: [pattern]. Учесть?» (Learning Loop, v4.15) |
| При переходе learning → generation | Переносит топ-3 урока из Learning Cards в контекст генерации (Learning Loop Bridge, v4.15) |
| При старте новой сессии | Показывает `product_memory.summary` если непуст, иначе краткую сводку Product Memory |
| При learning_cycle_count >= 3 | Отмечает «зрелый продукт», адаптирует вопросы — больше фокуса на масштабирование, меньше на PMF (v4.15) |
| При добавлении инсайта | Проверяет `insights[]` на повторы — «Похожий инсайт уже есть: [text]. Объединить?» (v4.16) |
| При приоритизации инсайтов | Оценивает влияние каждого инсайта на `tsar_metric` через `impact_score` (v4.16) |
| При конвертации инсайта | Заполняет `linked_*_id` и обновляет `status` на converted (v4.16) |
| При compaction | Перемещает старые данные в archive, генерирует/обновляет summary (v4.17) |

### Команда `история`

PM может запросить Product Memory командой `история`:

```
📖 История продукта: [название]

Прошлые гипотезы: [N]
  ✅ Валидировано: [X] | ❌ Опровергнуто: [Y] | ⛔ Брошено: [Z]

Прошлые запуски: [N]
  📈 Масштабировано: [X] | 🔄 Итерировано: [Y] | 🔀 Pivoted: [Z] | ⏪ Откачено: [W]

Активные инициативы: [N]
  [список с статусами]

Выявленные паттерны: [N]
  [список pattern + confidence]

Циклов обучения: [N] [зрелый продукт / начальный этап]
Уроки: [N] карточек — команда `уроки` для деталей

📦 Archive: [N] записей — команда `детали [поле]` для доступа
```

## Session Resume — Возобновление сессии

> **Ядро v4.10**: PM возвращается в сессию и сразу видит, где остановился. last_context сохраняется автоматически при каждом взаимодействии и используется для бесшовного возобновления.

### Жизненный цикл last_context

1. **Создание**: При первом ProductState — `last_context` пустой (нет прошлого взаимодействия)
2. **Обновление**: При каждом ответе workflow-скилла — обновить `skill`, `phase`, `last_question`, `timestamp`
3. **Загрузка**: При возобновлении сессии — если `last_context` непустой, показать PM: «В прошлый раз мы работали над [skill/phase]. Последний вопрос: [last_question]. Продолжим?»
4. **Сохранение**: При завершении сессии или по команде `итого` — `last_context` сохраняется вместе с ProductState

### Команда `продолжить`

PM может возобновить работу с последнего контекста командой `продолжить`:

```
🔄 Возобновление сессии

Скилл: [skill]
Фаза: [phase]
Последний вопрос: [last_question]
Последняя активность: [timestamp]

Продолжим? (да/начать сначала/переключиться на [другой скилл])
```

Если PM вводит `продолжить` а `last_context` пустой — показать текущий ProductState и предложить начать работу.

### Автопредложение при старте сессии

При загрузке существующего ProductState (повторная сессия) — если `last_context` непустой:

```
👋 С возвращением! В прошлый раз ([last_context.timestamp]) мы работали над:
   📂 [skill] → [phase]
   ❓ Последний вопрос: «[last_context.last_question]»

   Команда `продолжить` — возобновить с того места
   Или начните новый этап
```

### Правила обновления last_context

1. **Обновляют только workflow-скиллы**: hypothesis, goal, task, comms, post-launch. Остальные скиллы (domain, onboarding, thinking-in-bets, generation) не обновляют last_context — они вспомогательные.
2. **Обновление при каждом ответе**: После каждого ответа workflow-скилла — записать skill, phase (из фазовой структуры скилла), last_question (последний заданный вопрос), timestamp.
3. **Не обновлять при командах просмотра**: `state`, `решения`, `ревизия`, `история`, `диагностика`, `стиль`, `детали`, `компактизация` — это команды просмотра, не работа внутри фазы.
4. **phase = название фазы из скилла**: «Фаза 1: Формулировка гипотезы», «Фаза 2: Дизайн эксперимента», «Фаза 3: Фиксация и решение» и т.д.

## Правила обновления

- Каждый sub-skill после своего ответа явно указывает, какие поля ProductState он обновил
- Поле `updated` обновляется при каждом изменении
- Поле `history` получает запись при каждом переходе `stage`
- Поле `stage_transitions_count` инкрементируется при каждом переходе
- Поле `product_memory` обновляется при ключевых событиях (hypothesis outcome, post-launch result, pattern detection, learning card creation)
- Поле `learning_cycle_count` инкрементируется при завершении цикла goal→...→learning (v4.15)
- Поле `insights[]` обновляется при добавлении/конвертации инсайтов (v4.16 Insight Management)
- Поле `last_context` обновляется при каждом ответе workflow-скилла (skill, phase, last_question, timestamp)
- Поле `archive` пополняется при compaction (v4.17)
- Поле `product_memory.summary` генерируется/обновляется при compaction (v4.17)
- При обратном переходе (`переключись на [stage]`) — если данные в archive, извлечь обратно в активные поля
- Если PM меняет тему (другой продукт/инициатива) — предложить создать новый ProductState или переключиться на существующий
- ProductState не удаляется — только архивируется через compaction
- Поле `launch_readiness` обновляется при команде `готовность` или автоматически при попытке перехода comms → launch (v4.18)
- Поле `pre_launch_snapshot` заполняется при подтверждении запуска (Go) и используется при post-launch (v4.18)
