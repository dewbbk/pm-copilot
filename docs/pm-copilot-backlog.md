# PM Copilot — Мастер-план развития

> Версия: v4.18 (Sprint 26: Launch Readiness)
> Последнее обновление: 2026-05-12
> Текущий статус: Sprint 26 завершён
> Режим тестирования: Lite (T1 каждый спринт, T2/T3 каждые 3 спринта)

---

## Завершённые спринты (1-17)

| Спринт | Версия | Содержание | Статус |
|--------|--------|------------|--------|
| Sprint 1 | v4.00 | ProductState — ядро системы | ✅ |
| Sprint 2 | v4.01 | Facade + роутинг | ✅ |
| Sprint 3 | v4.02 | Stage Detection — явное определение этапа | ✅ |
| Sprint 4 | v4.03 | Decision Log — история решений | ✅ |
| Sprint 5-6 | v4.04 | Obsidian Integration — vault, frontmatter, dataview | ✅ |
| Sprint 7 | v4.05 | Autopilot Suggestions — проактивные подсказки | ✅ |
| Sprint 8 | v4.06 | PM Memory — стиль решений | ✅ |
| Sprint 9 | v4.07 | Product Memory — история продукта | ✅ |
| Sprint 10-11 | v4.08 | Decision Linking — цепочки решений | ✅ |
| Sprint 12-13 | v4.09 | Thinking in Bets — вероятностное мышление | ✅ |
| Sprint 14-15 | v4.10 | Session Resume — возобновление сессии | ✅ |
| Sprint 16-17 | v4.11-4.12 | Reflection Checkpoints + Goal-first restructure | ✅ |
| Sprint 21-pre | v4.13 | Domain consolidation: pm-copilot-domain → references | ✅ |
| Sprint 21 | v4.13 | Orchestrator Logic + State Machine Rules | ✅ |
| Sprint 22 | v4.14 | Anti-Overthinking + Phase Limits + Express Mode | ✅ |
| Sprint 24 | v4.16 | Insight Management — управление инсайтами | ✅ |
| Sprint 25 | v4.17 | ProductState Lifecycle + Memory Layers | ✅ |
| Sprint 26 | v4.18 | Launch Readiness — проверка готовности к запуску | ✅ |

---

## Запланированные спринты (27-38)

### Sprint 26: Launch Readiness [v4.18] ✅ ЗАВЕРШЁН

**Приоритет**: P2
**Проблема**: Нет явной проверки готовности к запуску. PM может перейти к launch, не проверив критерии — коммуникации не отправлены, ганарды не подтверждены, риски не оценены.

**Что сделали**:
1. **Launch Readiness Checklist**: Автоматический чеклист перед переходом comms → launch. Проверяет: ПРД approved, коммуникации отправлены, ганарды подтверждены, откаты определены, метрики baseline зафиксированы.
2. **Readiness Score**: 0-100% на основе чеклиста. <80% — Copilot предупреждает, <60% — рекомендует вернуться.
3. **Go/No-Go Frame**: Явный фреймворк принятия решения о запуске на основе readiness score + вероятностной оценки (интеграция с TIB).
4. **Pre-launch Snapshot**: Автоматическое сохранение среза ProductState перед launch для сравнения в post-launch.

**Артефакты**:
- Обновлённый фасад (Launch Readiness секция) ✅
- Обновлённый comms sub-skill (интеграция с readiness) ✅
- Обновлённый product-state reference (launch_readiness, pre_launch_snapshot поля) ✅
- Обновлённые тесты (T1-launch-readiness рубрика, 4 теста) ✅

---

### Sprint 27: ~~Decision Quality Metrics [v4.19]~~ ⏭️ SKIPPED

**Статус**: Пропущен 2026-05-12. Задача перенесена в Sprint 39.
**Причина**: Фича требует накопленного Decision Log. На этапе первичного adoption у PM нет решений с `actual_outcome` — Quality Score будет пустым. Возвращаемся после Sprint 38 когда PM накопят реальные данные.

---

### Sprint 28: Multi-Initiative Support [v4.20] ✅ ЗАВЕРШЁН

**Приоритет**: P2
**Проблема**: Один ProductState = одна инициатива. PM в банке ведёт 3-5 инициатив параллельно. Приходится создавать отдельные сессии, контекст не переносится.

**Что делаем**:
1. **Initiative Switcher**: Команда `инициативы` — список всех инициатив с статусами. Команда `переключись на [id]` — загрузить другой ProductState.
2. **Cross-Initiative Insights**: При добавлении инсайта — Copilot проверяет, не релевантен ли он другим инициативам.
3. **Shared Product Memory**: Product Memory на уровне продукта (не инициативы) — past_launches и learned_patterns доступны для всех инициатив.
4. **Initiative Dashboard**: Сводка по всем инициативам — stage, readiness, blockers.

**Метрики успеха**:
- Доля PM с ≥2 параллельными инициативами: ≥60%
- Время переключения между инициативами: ≤30 сек

**Артефакты**:
- Обновлённый фасад (Multi-Initiative секция)
- Обновлённый product-state reference (initiative_id, shared_memory)
- Initiative Switcher логика

---

### Sprint 29: Collaboration & Stakeholder Integration [v4.21]

**Приоритет**: P3
**Проблема**: Copilot работает один-на-один с PM. Нет интеграции с командой — Tech Lead, аналитик, дизайнер не видят контекст. Коммуникации (comms sub-skill) — односторонние.

**Что делаем**:
1. **Stakeholder Profiles**: В онбординге — добавить профили ключевых стейкхолдеров (роль, имя, коммуникационные предпочтения).
2. **Review Request**: Команда `запросить ревью` — Copilot формирует запрос стейкхолдеру с нужным контекстом (для Tech Lead — техническая часть ПРД, для C-level — executive summary).
3. **Feedback Integration**: При получении фидбека — Copilot помогает PM интегрировать его в ProductState (обновить risks, assumptions, decisions).
4. **Team Sync**: Команда `синхронизация` — краткая сводка текущего состояния для команды.

**Метрики успеха**:
- Доля ПРД с external feedback: ≥40% (сейчас ~10%)
- Время от фидбека до интеграции: ≤1 час

**Артефакты**:
- Обновлённый onboarding (stakeholder profiles)
- Обновлённый comms sub-skill (review request, feedback integration)
- Обновлённый фасад (Team Sync секция)

---

## PERF-спринты: Оптимизация скорости и потребления токенов

> **Контекст**: Анализ потребления показал — pipeline загружает ~97,600 токенов суммарно, при этом ~54% фасада загружается напрасно на каждом ходу. ProductState растёт бесконтрольно. Ожидаемая экономия: 30-49% in-токенов, ~$900/мес при 100 PM.

---

### Sprint 30: PERF-1 — Facade Split [v4.22]

**Приоритет**: P1 (критический для скорости)
**Проблема**: Facade = 1,003 строки / ~12,000 токенов, загружается КАЖДЫЙ ход. Из них ~540 строк (54%) — описания подсистем, которые не нужны на текущем этапе. Это крупнейший потребитель токенов.

**Что делаем**:
1. **Split Facade на 3 слоя**:
   - **Core** (~400 строк / ~4,800 токенов): Stage Detection, Activation Matrix, Router Guard, команды (state, решения, ревизия, продолжить, стиль, история). Загружается ВСЕГДА.
   - **Workflow Reference** (~300 строк / ~3,600 токенов): Описания workflow (Autopilot, Session Resume, Reflection, Transitions, Memory). Загружается при активации workflow-скилла.
   - **Domain Reference** (~300 строк / ~3,600 токенов): PM Memory, Product Memory, Decision Log, Obsidian. Загружается по запросу (команды стиль, история, решения) или при автовызове.
2. **Loading Strategy**: Core — всегда. Workflow — при активации sub-skill. Domain — по запросу.
3. **Обновить тесты**: Coverage Matrix для нового split.

**Экономия**: -6,500 in-токенов/ход (Workflow + Domain не загружаются на ~60% ходов)

**Метрики успеха**:
- Средний in-token budget на старте: ≤15,000 (сейчас ~21,700)
- Facade Core: ≤5,000 токенов

**Артефакты**:
- `pm-copilot/SKILL.md` → реорганизован в 3 секции с пометками загрузки
- Обновлённый `pm-copilot-tests/SKILL.md`

---

### Sprint 31: PERF-2 — ProductState Compaction [v4.23]

**Приоритет**: P1
**Проблема**: ProductState растёт от ~300 токенов (новый продукт) до 8,000+ (зрелый). При каждом ходе весь ProductState подаётся на вход. Нет механизма сжатия.

**Что делаем**:
1. **Compaction Rules**: Явные правила сжатия для каждого поля:
   - `history[]` — хранить только последние 5 переходов, старшие в summary
   - `decisions[]` — хранить только open + последние 3 reviewed, остальные по ссылке
   - `product_memory.past_hypotheses` — хранить последние 5, старшие в pattern summary
   - `product_memory.past_launches` — хранить последние 3, старшие в pattern summary
   - `product_memory.learned_patterns` — хранить patterns с confidence ≥0.5, остальные по запросу
2. **Auto-Compaction Trigger**: При `updated` > 5 переходов от `created` — автоматически компактить. Или по команде `компактизация`.
3. **Detail-on-Demand**: Команда `детали [поле]` — загрузить полные данные из архива.

**Экономия**: -2,000-5,000 in-токенов/ход (для зрелых продуктов)

**Метрики успеха**:
- ProductState средний размер: ≤2,500 токенов (сейчас до 8,000)
- Данные доступны по запросу: 100%

**Артефакты**:
- Обновлённый product-state reference (compaction rules)
- Обновлённый фасад (compaction секция)

---

### Sprint 32: PERF-3 — Conversation Summarization [v4.24]

**Приоритет**: P1
**Проблема**: Conversation history подаётся на вход полностью. В глубоких сессиях (20+ ходов) история занимает 10,000-20,000 токенов. Нет summarization — всё копится.

**Что делаем**:
1. **Rolling Summary**: Каждые 5 ходов — Copilot создаёт краткую сводку предыдущего диалога (1-2 абзаца, ~200 токенов). Сводка заменяет полные сообщения.
2. **Summary Window**: Хранить последние 5 полных ходов + rolling summary всего предыдущего. При команде `контекст` — показать summary + текущий ProductState.
3. **Key Decisions Preservation**: Решения из Decision Log всегда доступны полностью (не сжимаются). Summary содержит ссылки на Decision ID.
4. **Phase-boundary Summary**: При переходе между фазами — создавать summary фазы (~150 токенов), содержащее ключевые выводы и незавершённые вопросы.

**Экономия**: -10,000-20,000 in-токенов для глубоких сессий

**Метрики успеха**:
- In-token budget на 20-м ходу: ≤25,000 (сейчас ~35,000-55,000)
- Потеря контекста при summarization: ≤5%

**Артефакты**:
- Обновлённый фасад (Conversation Summarization секция)
- Обновлённые sub-skills (phase-boundary summary)

---

### Sprint 33: PERF-4 — TIB-lite Inline [v4.25]

**Приоритет**: P2
**Проблема**: При автовызове TIB (confidence < 0.7, царь-метрика, сюрпризы) — загружается весь TIB sub-skill (254 строки / ~3,000 токенов). Для быстрого режима (2 сценария) это избыточно — нужна только половина.

**Что делаем**:
1. **TIB-lite Template**: Компактный шаблон быстрого режима (~30 строк / ~400 токенов) встроить в фасад. Содержит: 2 сценария (ожидаемый/худший), вероятности, решение.
2. **Inline для быстрого, Full для полного**: При автотриггере быстрого режима — использовать inline шаблон, не загружать sub-skill. При полном режиме — загружать полный TIB sub-skill.
3. **Full → Lite Fallback**: Если PM пропускает TIB после 1 вопроса — автоматический fallback на lite (краткий ответ с 2 сценариями).

**Экономия**: -2,500 in-токенов при автовызове быстрого режима

**Метрики успеха**:
- In-token budget при TIB quick: ≤ +500 (сейчас +3,000)
- Доля TIB quick vs full: ≥60% quick

**Артефакты**:
- Обновлённый фасад (TIB-lite inline секция)
- Обновлённый thinking-in-bets sub-skill (уточнение режимов)

---

### Sprint 34: PERF-5 — Reference Dedup [v4.26]

**Приоритет**: P2
**Проблема**: `task/references/thinking-in-bets.md` (151 строка) дублирует `facade/references/thinking-in-bets.md` (115 строк). При активации task + TIB — TIB-контент загружается дважды.

**Что делаем**:
1. **Удалить дубликат**: `task/references/thinking-in-bets.md` → удалить. Task sub-skill ссылается на `facade/references/thinking-in-bets.md`.
2. **Audit всех references**: Проверить все 5 reference файлов на дублирование между sub-skills. Устранить все дубликаты.
3. **Reference Index**: Создать единый индекс всех references с указанием, какие sub-skills их используют.

**Экономия**: -1,800 in-токенов (устранение дублирования)

**Метрики успеха**:
- Дублирование references: 0%
- Общий размер references: снижение на ≥15%

**Артефакты**:
- Удалён `task/references/thinking-in-bets.md`
- Создан reference index
- Обновлённые sub-skills (ссылки на единые references)

---

### Sprint 35: PERF-6 — Turn Budget per Phase [v4.27]

**Приоритет**: P2
**Проблема**: Нет явного бюджета токенов на ход. Copilot может генерировать слишком длинные ответы (особенно при генерации ПРД или коммуникаций), потребляя лишние out-токены и время.

**Что делаем**:
1. **Turn Budget Table**: Явные лимиты на in/out токены по phase:
   | Phase | Max in (target) | Max out (target) |
   |-------|-----------------|------------------|
   | insight | 15,000 | 800 |
   | generation | 20,000 | 1,500 |
   | goal | 18,000 | 1,200 |
   | hypothesis | 18,000 | 1,000 |
   | task | 22,000 | 2,000 |
   | comms | 20,000 | 1,500 |
   | launch | 15,000 | 600 |
   | post-launch | 20,000 | 1,200 |
2. **Budget Check**: Copilot проверяет бюджет перед ответом. Если близок к лимиту — сжимает ответ.
3. **Budget Report**: Команда `бюджет` — показать текущее потребление токенов за сессию.

**Экономия**: Косвенная — предотвращает перерасход out-токенов, ускоряет ответы

**Метрики успеха**:
- Средний out-token per turn: ≤1,200 (сейчас не трекается)
- Доля ходов с out > 2,000: ≤10%

**Артефакты**:
- Обновлённый фасад (Turn Budget секция)
- Budget table

---

### Sprint 36: PERF-7 — Conditional Reference Loading [v4.28]

**Приоритет**: P2
**Проблема**: Все references (domain-context, metrics, thinking-in-bets) загружаются при старте, даже если не нужны. Domain-context (318 строк / ~3,800 токенов) нужен только при первом онбординге или запросе домена.

**Что делаем**:
1. **Lazy Loading Strategy**: References загружаются по запросу:
   - `domain-context.md` — при команде `домен` или первом онбординге
   - `metrics.md` — при работе с царь-метриками (goal, post-launch)
   - `thinking-in-bets.md` — при автовызове TIB или команде `сценарии`
   - `decision-log.md` — при командах `решения`, `ревизия`, `цепочка`
   - `product-state.md` — всегда (Core reference)
2. **Reference Trigger Map**: Явная таблица «какая команда/событие → какой reference загрузить».
3. **Cache Loaded References**: Если reference уже загружен в сессии — не загружать повторно.

**Экономия**: -2,000-4,000 in-токенов (domain-context + metrics не нужны на ~60% ходов)

**Метрики успеха**:
- In-token budget при простых ходах (внутри фазы): ≤12,000
- Reference cache hit rate: ≥70%

**Артефакты**:
- Обновлённый фасад (Conditional Reference Loading секция)
- Reference Trigger Map

---

### Sprint 37: PERF-8 — Autopilot Shortcut [v4.29]

**Приоритет**: P3
**Проблема**: При autopilot on — Copilot генерирует подсказку на каждом ответе. Это добавляет ~300-500 токенов out + время генерации. Для опытных PM — ненужные задержки.

**Что делаем**:
1. **Smart Autopilot**: Подсказки показываются только при переходах между stage, не на каждом ходу внутри фазы.
2. **Experienced PM Detection**: Если PM ≥3 полных цикла (goal → learning) — автоматически переключить autopilot на minimal (только переходы).
3. **Skip Autopilot Command**: Команда `дальше` — PM пропускает подсказку и идёт к следующему шагу без лишних токенов.
4. **Pre-computed Suggestions**: Частые подсказки (goal→task, hypothesis→goal) — шаблонизировать, не генерировать заново.

**Экономия**: -0.3-0.5 сек/ход, -300-500 out-токенов/ход для опытных PM

**Метрики успеха**:
- Время генерации ответа: ≤3 сек для простых ходов
- Out-token per turn с autopilot: ≤1,000

**Артефакты**:
- Обновлённый фасад (Smart Autopilot секция)
- Обновлённый onboarding (experienced PM detection)

---

### Sprint 38: PERF-9 — Output Budget для PRD/comms [v4.30]

**Приоритет**: P3
**Проблема**: При генерации ПРД и коммуникаций — Copilot может выдавать 3,000-5,000 out-токенов. Это дорого и долго. Нет контроля за объёмом выходных артефактов.

**Что делаем**:
1. **PRD Size Tiers**: 3 уровня ПРД по объёму:
   - **Brief** (~800 токенов): Ключевые секции, минимум текста
   - **Standard** (~1,500 токенов): Все секции, умеренная детализация
   - **Full** (~2,500 токенов): Полный ПРД с деталями
2. **Comms Size Tiers**: Аналогично:
   - **Brief** (~400 токенов): Executive summary
   - **Standard** (~800 токенов): Бриф для PBR
   - **Full** (~1,200 токенов): Полная коммуникация
3. **Auto-tier Selection**: Copilot выбирает tier на основе preferred_depth из профиля PM.
4. **Explicit Tier Override**: PM может запросить конкретный tier: `ПРД brief`, `коммуникация full`.

**Экономия**: -500-1,500 out-токенов за генерацию (для стандартных сессий)

**Метрики успеха**:
- Средний out-token для PRD standard: ≤1,500
- Средний out-token для comms standard: ≤800

**Артефакты**:
- Обновлённый task sub-skill (PRD tiers)
- Обновлённый comms sub-skill (comms tiers)
- Обновлённый onboarding (default tier в профиле)

---

## Отложенные задачи (после Sprint 38)

### DEV-SKILLS: Выделение development-скиллов (Analyst, Architect, QA)

**Статус**: 📋 Задача-заметка (после Sprint 38, проанализируем и примем решение)
**Приоритет**: P2

**Контекст**: Сейчас вся development-работа (анализ, проектирование, тестирование пайплайна) делается вручную или ad-hoc. Нет специализированных скиллов для этих ролей. Фасад одновременно является и роутером, и аналитиком, и создателем — это создаёт путаницу и раздувает токены.

**Предложение — 3 development-скилла**:

| Скилл | Роль | Триггеры | Что делает |
|-------|------|----------|------------|
| `pm-copilot-analyst` | Аналитик | «проанализируй пайплайн», «найди слабые места», «аудит токенов», «оцени архитектуру» | Анализ точек отказа, аудит architecture/CJM, рекомендации по развитию, оценка потребления токенов |
| `pm-copilot-architect` | Создатель пайпа | «добавь фичу X», «рефакторинг фасада», «создай новый sub-skill», «спроектируй изменения» | Проектирование изменений, написание/обновление SKILL.md и references, обеспечение консистентности, миграция данных |
| `pm-copilot-qa` | Тестировщик | «проверь покрытие», «сгенерируй тесты для Sprint N», «актуализируй рубрики», «аудит тестов» | Расширенный pm-copilot-tests: прогоны + аудит покрытия + генерация новых тестов + актуализация рубрик + PERF-специфичные тесты |

**Архитектура**:
```
pm-copilot/              ← Runtime (PM-facing) — без изменений
pm-copilot-analyst/      ← Development: аудит, анализ, рекомендации
pm-copilot-architect/    ← Development: проектирование и изменение пайпа
pm-copilot-qa/           ← Development: тестирование, покрытие, актуализация
                         ← pm-copilot-qa наследует/заменяет pm-copilot-tests
```

**Общие references**: analyst, architect и qa читают те же references (product-state.md, decision-log.md, domain-context.md, metrics.md, thinking-in-bets.md) — single source of truth с runtime.

**Риски**:
- Triple maintenance: при изменении runtime — нужно обновить все три development-скилла
- Нужен чёткий контракт: какие файлы каждый скилл читает/пишет, чтобы не было конфликтов
- Token overhead: +3 description в available_skills, +маршрутизация

**Когда анализировать**: После завершения Sprint 38 (полный опыт 18 спринтов → понятны повторяющиеся паттерны)

**Что нужно сделать (когда дойдём)**:
1. Проанализировать опыт Sprint 21-38: какие задачи повторялись, какие роли были нужны чаще всего
2. Оценить, действительно ли нужны 3 отдельных скилла или достаточно 1-2
3. Спроектировать контракты (read/write для каждого скилла)
4. Решить: pm-copilot-qa заменяет pm-copilot-tests или расширяет его
5. Прототипировать минимальный скилл (скорее всего analyst — самый простой и полезный)

---

### Sprint 39: Decision Quality Metrics [v4.19] (перенесён из Sprint 27)

**Статус**: 📋 Перенесён 2026-05-12 (был Sprint 27, пропущен до накопления данных)
**Приоритет**: P2

**Проблема**: Decision Log фиксирует решения, но не оценивает их качество. Нет метрик: насколько обосновано решение, сколько допущений не проверено, какова дистанция между expected и actual.

**Что делаем**:
1. **Decision Quality Score**: Автоматическая оценка каждого решения по 3 осям: обоснованность (rationale depth), проверенность допущений (assumptions validated / total), калибровка (expected vs actual).
2. **Assumption Tracker**: Отдельный трекер допущений с статусами (untested / testing / validated / invalidated). При каждом TIB-автовызове — проверять assumptions.
3. **Decision Dashboard**: Команда `дашборд решений` — сводка по всем решениям с quality scores, непроверенными assumptions, калибровкой.
4. **Link с Learning Loop**: При post-launch — Decision Quality Score обновляется с actual_outcome.

**Метрики успеха**:
- Доля решений с quality score ≥6/10: ≥70%
- Доля assumptions с статусом tested: ≥50%

**Артефакты**:
- Обновлённый decision-log reference (quality_score, assumption_tracker)
- Обновлённый фасад (Decision Dashboard секция)
- Обновлённый post-launch sub-skill (калибровка)

**Когда делать**: После Sprint 38, когда реальные PM накопят Decision Log с `actual_outcome`.

---

### QA-AUDIT: Аудит и актуализация тестирования

**Статус**: 📋 Задача-заметка (без привязки к спринту)
**Приоритет**: P2 (когда дойдём — проанализируем и уточним)

**Контекст**: pm-copilot-tests содержит 100 тестов (75 T1 + 16 T2 + 9 T3), написанных под v4.11. После Sprint 21-38 в пайплайн добавятся: State Machine, Anti-Overthinking, Learning Loop, Insight Management, Memory Layers, Launch Readiness, Decision Quality, Multi-Initiative, Collaboration, Facade Split, Compaction, Summarization, TIB-lite, Reference Dedup, Turn Budget, Conditional Loading, Autopilot Shortcut, Output Budget. Каждый спринт меняет архитектуру → тесты могут устареть.

**Что нужно сделать (когда дойдём)**:
1. **Актуализировать Coverage Matrix**: Пересмотреть связи «что изменилось → какие тесты запускать» с учётом новых фич
2. **Добавить тесты на новые фичи**: State Machine, Anti-Overthinking, Express Mode, Learning Loop, Insight Management, Memory Layers, Launch Readiness, Decision Quality, Multi-Initiative, Collaboration, Facade Split, Compaction, Summarization, TIB-lite, Reference Dedup, Turn Budget, Conditional Loading, Autopilot Shortcut, Output Budget
3. **Пересмотреть рубрики**: Обновить T1-рубрики с учётом новых критериев (phase limits, compaction quality, budget compliance)
4. **Добавить PERF-специфичные тесты**: Token budget compliance, Compaction без потери данных, Lazy loading корректность
5. **Актуализировать дефолтный профиль**: Добавить express mode, PRD tier, experienced PM settings

**Когда анализировать**: После завершения Sprint 29 (перед PERF-спринтами) или после Sprint 38 (полная актуализация)

---

## Сводная дорожная карта

```
Sprint 21 ─── Orchestrator Logic + State Machine [v4.13] ──── ✅
Sprint 22 ─── Anti-Overthinking + Express Mode [v4.14] ──── ✅
Sprint 23 ─── Learning Loop [v4.15] ──────────────────── ✅
Sprint 24 ─── Insight Management [v4.16] ──────────────── ✅
Sprint 25 ─── ProductState Lifecycle + Memory Layers [v4.17] ── ✅
Sprint 26 ─── Launch Readiness [v4.18] ────────────────── ✅
Sprint 27 ─── ~~Decision Quality Metrics [v4.19]~~ ──────── ⏭️ SKIPPED → Sprint 39
Sprint 28 ─── Multi-Initiative Support [v4.20] ────────── ✅
Sprint 29 ─── Collaboration & Stakeholders [v4.21] ────── P3
───────────────────────────────────────────────────────────────
Sprint 30 ─── PERF-1: Facade Split [v4.22] ────────────── P1
Sprint 31 ─── PERF-2: ProductState Compaction [v4.23] ─── P1
Sprint 32 ─── PERF-3: Conversation Summarization [v4.24] ── P1
Sprint 33 ─── PERF-4: TIB-lite Inline [v4.25] ────────── P2
Sprint 34 ─── PERF-5: Reference Dedup [v4.26] ────────── P2
Sprint 35 ─── PERF-6: Turn Budget per Phase [v4.27] ──── P2
Sprint 36 ─── PERF-7: Conditional Reference Loading [v4.28] ── P2
Sprint 37 ─── PERF-8: Autopilot Shortcut [v4.29] ─────── P3
Sprint 38 ─── PERF-9: Output Budget [v4.30] ──────────── P3
───────────────────────────────────────────────────────────────
DEV-SKILLS ─ Выделение development-скиллов ────────────── 📋 Заметка
QA-AUDIT  ─── Аудит тестирования ──────────────────────── 📋 Заметка
```

### Ожидаемая экономия от PERF-спринтов

| Метрика | До | После (оценка) | Экономия |
|---------|-----|----------------|----------|
| In-token на старте | ~21,700 | ~12,000-15,000 | 30-45% |
| In-token глубокие | ~55,000 | ~25,000-30,000 | 45-55% |
| Out-token ПРД | ~3,000-5,000 | ~1,500-2,500 | 40-50% |
| Стоимость/мес (100 PM) | ~$1,800 | ~$900-1,100 | ~$700-900 |
