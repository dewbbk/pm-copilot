# PM Copilot — Бэклог развития

> Текущая версия: v4.21
> Последнее обновление: 2026-05-14
> Режим тестирования: Lite (T1 каждый спринт, T2/T3 каждые 3 спринта)
> Changelog: [pm-copilot-changelog.md](pm-copilot-changelog.md)

---

**Структура**: 3 эпика + Icebox. Каждая задача оценивается по вижну: «Помогает ли PM быстрее принять решение от инсайта до ПРД?» Приоритет внутри эпика: P1 (критический) → P2 (важный) → P3 (желательный).

---

## Эпик 1: Продуктовая ценность — «Copilot, который принимает решения»

> Фичи, которые напрямую помогают PM быстрее дойти от инсайта до ПРД. Критерий вижна: ускоряет цикл «инсайт → решение → ПРД».

---

### PRD Tiers / Output Budget — Управление глубиной артефактов

**Приоритет**: P3
**Проблема**: При генерации ПРД и коммуникаций — Copilot может выдавать 3,000-5,000 out-токенов. Нет контроля за объёмом. PM не может выбрать глубину ПРД под задачу.

**Что делаем**:
1. **PRD Size Tiers**: 3 уровня — Brief (~800 токенов), Standard (~1,500), Full (~2,500)
2. **Comms Size Tiers**: Brief (~400), Standard (~800), Full (~1,200)
3. **Auto-tier Selection**: Copilot выбирает tier на основе preferred_depth из профиля PM
4. **Explicit Tier Override**: PM может запросить: `ПРД brief`, `коммуникация full`

**Метрики успеха**: Средний out-token для PRD standard ≤1,500; comms standard ≤800
**Экономия**: -500-1,500 out-токенов за генерацию

**Детальный план реализации**:
- `pm-copilot-task/SKILL.md` — добавить PRD tiers (3 шаблона), auto-tier selection, explicit override
- `pm-copilot-comms/SKILL.md` — добавить comms tiers (3 шаблона), аналогичный механизм
- `pm-copilot-onboarding/SKILL.md` — добавить default tier в профиль PM (Шаг 4 «Предпочтения»)

---

### Quick Capture — Быстрая запись контекста между сессиями

**Приоритет**: P3
**Проблема**: PM постоянно получает информацию вне сессии — competitor intel, данные от аналитика, обратная связь от клиентов. Сейчас записать можно только через `инсайт [текст]` — неочевидный путь. Контекст теряется.

**Что делаем**:
1. **Quick Capture Commands** — 4 команды: `конкурент [текст]`, `данные [текст]`, `фидбек [текст]`, `решение руководства [текст]`
2. **Type-specific обработка**: каждый тип — свой source, auto-link к ProductState, follow-up вопрос
3. **Context Drop** — при старте сессии Copilot показывает накопленные captures
4. **Расширение Insight Buffer**: новые source-типы, поле capture_type (quick/manual)

**Метрики успеха**: Доля сессий с pre-session captures ≥30%; время от capture до использования ≤2 сессии

**Детальный план реализации**:
1. **`pm-copilot/references/product-state.md`** — расширить `insights[]` schema:
   - Добавить source-типы: `конкурент`, `аналитика`, `стейкхолдер`
   - Добавить поле `capture_type`: `quick | manual`
   - Добавить поле `related_prd_id` (для auto-link при `данные [текст]`)
2. **`pm-copilot/SKILL.md`** — фасад:
   - «Быстрые команды» — добавить 4 команды
   - «Insight Management» — добавить триггеры auto-detect при вводе quick capture форматов
   - «Session Resume» — добавить Context Drop: при загрузке ProductState проверять `insights[]` с `capture_type: quick` после `last_context.timestamp`
   - ProductState формат — обновить `insights[]` schema
3. **`pm-copilot-onboarding/SKILL.md`** — онбординг:
   - Шаг 4 «Предпочтения» — блок про Quick Capture: 4 типа команд

---

### Archive Search — Память для принятия решений

**Приоритет**: P3
**Проблема**: Archive содержит сотни записей, но Copilot не использует их при принятии решений. PM не может спросить «что мы уже пробовали в этом направлении?» — archive доступен только точечно через `детали [поле]`.

**Что делаем**:
1. **Auto-search по archive** — при работе в hypothesis/goal/post-launch Copilot автоматически ищет релевантные записи
2. **Cross-initiative search** — поиск в Shared Memory + других инициативах
3. **Search Result Format** — компактный блок с top-5 релевантных записей
4. **Команда `поиск [текст]`** — явный поиск по archive + Shared Memory
5. **Relevance scoring** — оценка релевантности к текущему контексту (stage, problem, active_prd)

**Метрики успеха**: Доля решений с учётом archive ≥50%; команда `поиск` ≥2 раз/неделю

**Детальный план реализации**:
1. **`pm-copilot/SKILL.md`** — фасад:
   - «Быстрые команды» — добавить `поиск [текст]`
   - Новая секция **«Archive Search»**: правила auto-search, Search Result Format, Relevance scoring, Cross-initiative
   - Activation Matrix — при активации hypothesis/goal/post-launch дополнительно искать по archive
2. **`pm-copilot/references/product-state.md`** — reference:
   - Новая секция **«Archive Search Rules»**: алгоритм, scoring (match_stage 0.3 + match_problem 0.3 + match_text 0.4), cross-initiative, формат вывода
3. **`pm-copilot-hypothesis/SKILL.md`** — «Формулировка гипотезы» → auto-search по archive.hypotheses + archive.decisions
4. **`pm-copilot-goal/SKILL.md`** — «Декомпозиция цели» → auto-search по archive.past_launches
5. **`pm-copilot-post-launch/SKILL.md`** — «Оценка результатов» → auto-search по archive.decisions
6. **`pm-copilot-comms/SKILL.md`** — archive.search для «из прошлого опыта» секции в Executive Summary

---

## Эпик 2: Техдолг — «Надёжный и быстрый пайплайн»

> Не создаёт новую продуктовую ценность напрямую, но без этого продукт деградирует — тормозит, ломается, теряет контекст. Критерий: ускоряет pipeline или устраняет риск потери данных.

> **Контекст PERF**: Pipeline загружает ~97,600 токенов суммарно, ~54% фасада загружается напрасно на каждом ходу. Ожидаемая экономия: 30-49% in-токенов, ~$900/мес при 100 PM.

---

### QA-AUDIT — Аудит и актуализация тестирования

**Приоритет**: P2
**Зависимость**: Перед началом PERF-задач

**Проблема**: pm-copilot-tests содержит 100 тестов (75 T1 + 16 T2 + 9 T3), написанных под v4.11. После v4.13-v4.21 в пайплайн добавлены: State Machine, Anti-Overthinking, Learning Loop, Insight Management, Memory Layers, Launch Readiness, Multi-Initiative, Collaboration Lite. Тесты устарели.

**Что делаем**:
1. Актуализировать Coverage Matrix — связи «что изменилось → какие тесты запускать»
2. Добавить тесты на новые фичи (8 фич)
3. Пересмотреть T1-рубрики с учётом новых критериев
4. Актуализировать дефолтный профиль (express mode, experienced PM)

**Детальный план реализации**:
- `pm-copilot-tests/SKILL.md` — обновить Coverage Matrix, добавить тест-кейсы, обновить профиль

---

### Facade Split — Разделение фасада на слои загрузки

**Приоритет**: P1 (критический для скорости)

**Проблема**: Facade = 1,003 строки / ~12,000 токенов, загружается КАЖДЫЙ ход. ~54% — описания подсистем, не нужных на текущем этапе.

**Что делаем**:
1. Split Facade на 3 слоя:
   - **Core** (~400 строк): Stage Detection, Activation Matrix, Router Guard, команды — загружается ВСЕГДА
   - **Workflow Reference** (~300 строк): Autopilot, Session Resume, Reflection, Transitions, Memory — при активации workflow-скилла
   - **Domain Reference** (~300 строк): PM Memory, Product Memory, Decision Log, Obsidian — по запросу
2. Loading Strategy: Core всегда, Workflow при активации, Domain по запросу
3. Обновить Coverage Matrix для нового split

**Экономия**: -6,500 in-токенов/ход
**Метрики успеха**: Средний in-token budget на старте ≤15,000; Facade Core ≤5,000 токенов

**Детальный план реализации**:
1. **`pm-copilot/SKILL.md`** — реорганизовать в 3 секции с пометками загрузки (<!-- LOAD: always/workflow/on-demand -->)
2. **`pm-copilot-tests/SKILL.md`** — обновить Coverage Matrix

---

### ProductState Compaction — Сжатие состояния продукта

**Приоритет**: P1
**Зависимость**: После Facade Split

**Проблема**: ProductState растёт от ~300 токенов (новый) до 8,000+ (зрелый). Весь подаётся на вход каждого хода. Нет механизма сжатия.

**Что делаем**:
1. Compaction Rules — явные правила сжатия для каждого поля
2. Auto-Compaction Trigger — при >5 переходов от created
3. Detail-on-Demand — команда `детали [поле]`

**Экономия**: -2,000-5,000 in-токенов/ход (для зрелых продуктов)
**Метрики успеха**: ProductState средний ≤2,500 токенов; данные доступны по запросу 100%

**Детальный план реализации**:
1. **`pm-copilot/references/product-state.md`** — добавить compaction rules, триггеры, формат summary
2. **`pm-copilot/SKILL.md`** — секция Compaction, обновить Lifecycle

---

### Conversation Summarization — Сжатие истории диалога

**Приоритет**: P1
**Зависимость**: После ProductState Compaction

**Проблема**: Conversation history подаётся полностью. В глубоких сессиях (20+ ходов) занимает 10,000-20,000 токенов.

**Что делаем**:
1. Rolling Summary — каждые 5 ходов сводка (~200 токенов)
2. Summary Window — последние 5 полных ходов + rolling summary
3. Key Decisions Preservation — Decision Log не сжимается
4. Phase-boundary Summary — при переходе между фазами

**Экономия**: -10,000-20,000 in-токенов для глубоких сессий
**Метрики успеха**: In-token на 20-м ходу ≤25,000; потеря контекста ≤5%

**Детальный план реализации**:
1. **`pm-copilot/SKILL.md`** — новая секция «Conversation Summarization» с правилами
2. **Workflow sub-skills** — phase-boundary summary при переходе между фазами

---

### TIB-lite Inline — Компактный TIB для быстрого режима

**Приоритет**: P2

**Проблема**: При автовызове TIB загружается весь sub-skill (~3,000 токенов). Для быстрого режима избыточно.

**Что делаем**:
1. TIB-lite Template (~400 токенов) встроить в фасад
2. Inline для быстрого режима, Full для полного
3. Full → Lite Fallback при пропуске TIB

**Экономия**: -2,500 in-токенов при автовызове быстрого режима
**Метрики успеха**: In-token при TIB quick ≤+500; доля quick ≥60%

**Детальный план реализации**:
1. **`pm-copilot/SKILL.md`** — TIB-lite inline секция
2. **`pm-copilot-thinking-in-bets/SKILL.md`** — уточнение режимов quick/full

---

### Reference Dedup — Устранение дублирования references

**Приоритет**: P2

**Проблема**: `task/references/thinking-in-bets.md` дублирует `facade/references/thinking-in-bets.md`. TIB загружается дважды при task + TIB.

**Что делаем**:
1. Удалить дубликат из task/references
2. Audit всех references на дублирование
3. Reference Index — единый индекс

**Экономия**: -1,800 in-токенов
**Метрики успеха**: Дублирование 0%; общий размер references снижение ≥15%

**Детальный план реализации**:
1. **`pm-copilot-task/references/thinking-in-bets.md`** — удалить
2. **`pm-copilot-task/SKILL.md`** — обновить ссылку на facade reference
3. **Audit** — проверить все 5 reference файлов

---

### Turn Budget per Phase — Бюджет токенов на ход

**Приоритет**: P2

**Проблема**: Нет явного бюджета. Copilot генерирует слишком длинные ответы, потребляя лишние out-токены.

**Что делаем**:
1. Turn Budget Table — лимиты in/out по phase
2. Budget Check — Copilot проверяет перед ответом
3. Команда `бюджет` — показать потребление за сессию

**Метрики успеха**: Средний out-token per turn ≤1,200; доля out >2,000 ≤10%

**Детальный план реализации**:
1. **`pm-copilot/SKILL.md`** — Turn Budget секция + Budget Table

---

### Conditional Reference Loading — Ленивая загрузка references

**Приоритет**: P2

**Проблема**: Все references загружаются при старте, даже если не нужны. Domain-context (~3,800 токенов) нужен только при онбординге.

**Что делаем**:
1. Lazy Loading — references по запросу (domain → при онбординге, metrics → при goal, TIB → при автовызове)
2. Reference Trigger Map — таблица «команда → reference»
3. Cache Loaded References

**Экономия**: -2,000-4,000 in-токенов (domain + metrics не нужны на ~60% ходов)
**Метрики успеха**: In-token при простых ходах ≤12,000; cache hit rate ≥70%

**Детальный план реализации**:
1. **`pm-copilot/SKILL.md`** — Conditional Reference Loading секция + Reference Trigger Map

---

### Ожидаемая экономия от Эпика 2

- **In-token на старте**: ~21,700 → ~12,000-15,000 (30-45%)
- **In-token глубокие сессии**: ~55,000 → ~25,000-30,000 (45-55%)
- **Стоимость/мес (100 PM)**: ~$1,800 → ~$900-1,100 (~$700-900 экономии)

---

## Icebox — «Вне вижна»

> Идеи, не противоречащие вижну, но сейчас не приоритет. Вернёмся когда контекст изменится.

---

### Autopilot Shortcut

**Почему в Icebox**: Ускоряет опытных PM (-300-500 out-токенов/ход), но PM пока один — marginal gain. Вернётся когда ≥3 активных PM.

---

### Stakeholder Profiles

**Почему в Icebox**: Профили стейкхолдеров нужны для командной работы. Текущий вижн — one-on-one copilot. Вернётся при plugin-фазе.

---

### Team Sync

**Почему в Icebox**: Синхронизация для команды — та же причина. Нужен plugin или multi-seat режим.

---

### DEV-SKILLS: Development-скиллы (Analyst, Architect, QA)

**Почему в Icebox**: Development-tooling, ускоряет разработку пайпа, но не продукт. Вернётся после стабилизации runtime.

**Предложение**: 3 скилла — `pm-copilot-analyst` (аудит), `pm-copilot-architect` (проектирование), `pm-copilot-qa` (тестирование).

---

### Decision Quality Metrics

**Почему в Icebox**: Требует накопленного Decision Log с actual_outcome. На этапе первичного adoption у PM нет данных.

**Что делаем**: Decision Quality Score (3 оси), Assumption Tracker, Decision Dashboard.
**Когда**: Когда реальные PM накопят Decision Log с actual_outcome.
