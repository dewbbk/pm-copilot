# PM Copilot — Мастер-план развития

> Версия: v4.21 (Sprint 29: Collaboration Lite)
> Последнее обновление: 2026-05-13
> Текущий статус: Sprint 29 завершён, Sprint 30 — следующий
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
| Sprint 28 | v4.20 | Multi-Initiative Support — параллельные инициативы | ✅ |
| Sprint 29 | v4.21 | Collaboration Lite — Review Request + Feedback Integration | ✅ |

---

---

## Запланированные спринты (29-37)

> **Структура бэклога**: 3 эпика + Icebox. Каждая фича оценивается по вижну: «Помогает ли PM быстрее принять решение от инсайта до ПРД?»

---

## Эпик 1: Продуктовая ценность — «Copilot, который принимает решения»

> Фичи, которые напрямую помогают PM быстрее дойти от инсайта до ПРД. Критерий вижна: ускоряет цикл «инсайт → решение → ПРД».

---

### Sprint 29: Collaboration Lite [v4.21] ✅ ЗАВЕРШЁН

**Приоритет**: P3

**Что сделали:**
1. **Review Request** — Copilot формирует запрос ревью стейкхолдеру (Tech Lead, Аналитик, Дизайнер, C-level) с адаптированным контекстом из ПРД. Вопросы генерируются под аудиторию.
2. **Feedback Integration** — при получении фидбека Copilot категоризирует замечания (риск / допущение / правка ПРД / отклонение) и структурированно интегрирует в ProductState (risks[], decisions[]).
3. **ProductState** — добавлено поле `active_prd.review_requests[]` для трекинга запросов ревью.
4. **Фасад** — новые команды `запросить ревью` и `интегрировать фидбек`.

---
**Проблема**: Copilot работает один-на-один с PM. Нет интеграции с командой — Tech Lead, аналитик, дизайнер не видят контекст. Коммуникации (comms sub-skill) — односторонние.

**Что делаем**:
1. **Review Request**: Команда `запросить ревью` — Copilot формирует запрос стейкхолдеру с нужным контекстом (для Tech Lead — техническая часть ПРД, для C-level — executive summary).
2. **Feedback Integration**: При получении фидбека — Copilot помогает PM интегрировать его в ProductState (обновить risks, assumptions, decisions).

> **Вырезано в Icebox**: Stakeholder Profiles (вернётся при plugin-фазе), Team Sync (там же).

**Метрики успеха**:
- Доля ПРД с external feedback: ≥40% (сейчас ~10%)
- Время от фидбека до интеграции: ≤1 час

**Артефакты**:
- Обновлённый comms sub-skill (review request, feedback integration)
- Обновлённый фасад (Review Request секция)

---

### Sprint 39: Output Budget / PRD Tiers [v4.30]

**Приоритет**: P3
**Проблема**: При генерации ПРД и коммуникаций — Copilot может выдавать 3,000-5,000 out-токенов. Это дорого и долго. Нет контроля за объёмом выходных артефактов. PM не может выбрать глубину ПРД под задачу.

**Что делаем**:
1. **PRD Size Tiers**: 3 уровня по объёму:
   - **Brief** (~800 токенов): Ключевые секции, минимум текста
   - **Standard** (~1,500 токенов): Все секции, умеренная детализация
   - **Full** (~2,500 токенов): Полный ПРД с деталями
2. **Comms Size Tiers**: Аналогично:
   - **Brief** (~400 токенов): Executive summary
   - **Standard** (~800 токенов): Бриф для PBR
   - **Full** (~1,200 токенов): Полная коммуникация
3. **Auto-tier Selection**: Copilot выбирает tier на основе preferred_depth из профиля PM.
4. **Explicit Tier Override**: PM может запросить конкретный tier: `ПРД brief`, `коммуникация full`.

> **Почему в бизнес-ценности**: PM выбирает глубину ПРД → быстрее от инсайта до артефакта. Это не только экономия токенов, а продуктовое решение.

**Экономия**: -500-1,500 out-токенов за генерацию (для стандартных)

**Метрики успеха**:
- Средний out-token для PRD standard: ≤1,500
- Средний out-token для comms standard: ≤800

**Артефакты**:
- Обновлённый task sub-skill (PRD tiers)
- Обновлённый comms sub-skill (comms tiers)
- Обновлённый onboarding (default tier в профиле)

---

### Sprint 40: Quick Capture — Быстрая запись контекста между сессиями [v4.31]

**Приоритет**: P3
**Проблема**: PM постоянно получает информацию вне сессии — competitor intel, данные от аналитика, обратная связь от клиентов, решение руководства. Сейчас записать это можно только через `инсайт [текст]` — неочевидный путь, требует начала сессии. Контекст теряется до следующего формального взаимодействия.

**Что делаем**:
1. **Quick Capture Commands** — 4 компактные команды для быстрой записи:
   - `конкурент [текст]` → source: конкурент, auto-prioritize через вопрос «Угроза или возможность?»
   - `данные [текст]` → source: аналитика, auto-link к tsar_metric если упоминается
   - `фидбек [текст]` → source: отзыв/клиент, auto-check на связь с текущей гипотезой
   - `решение руководства [текст]` → source: стейкхолдер, auto-create Decision Log entry (open)
2. **Type-specific обработка**: Каждый тип capture имеет свой формат записи, автоматическую связь с релевантными полями ProductState и follow-up вопрос для обогащения
3. **Context Drop** — при старте сессии Copilot показывает накопленные captures: «С момента последней сессии: [N] записей. Показать? (да/нет)». Позволяет PM быстро войти в контекст
4. **Расширение Insight Buffer**: Новые source-типы в `insights[]`: конкурент, аналитика, стейкхолдер. Существующий `инсайт [текст]` продолжает работать как generic capture

**Метрики успеха**:
- Доля сессий с pre-session captures: ≥30%
- Время от capture до использования в решении: ≤2 сессии

**Артефакты**:
- Обновлённый фасад (новые команды: конкурент, данные, фидбек, решение руководства)
- Обновлённый product-state reference (расширенный Insight Buffer, новые source-типы)
- Обновлённый onboarding (объяснение Quick Capture при онбординге)

**Детальный план реализации**:

1. **`pm-copilot/references/product-state.md`** — расширить `insights[]` schema:
   - Добавить source-типы: `конкурент`, `аналитика`, `стейкхолдер` (сейчас есть: интервью, аналитика, отзыв, пост-запуск, CustDev, конкурент — дополнить)
   - Добавить поле `capture_type`: `quick | manual` (для различия как инсайт попал — через quick capture или через `инсайт [текст]`)
   - Добавить поле `related_prd_id` (для auto-link при `данные [текст]`)

2. **`pm-copilot/SKILL.md`** — фасад:
   - Секция «Быстрые команды» — добавить 4 команды: `конкурент [текст]`, `данные [текст]`, `фидбек [текст]`, `решение руководства [текст]`
   - Секция «Insight Management» — добавить триггеры: auto-detect при вводе quick capture форматов
   - Секция «Session Resume» — добавить Context Drop: при загрузке ProductState проверять `insights[]` с `capture_type: quick` после `last_context.timestamp`, показывать счётчик
   - ProductState формат — обновить `insights[]` schema (добавить capture_type, related_prd_id)

3. **`pm-copilot-onboarding/SKILL.md`** — онбординг:
   - Шаг 4 «Предпочтения» — добавить блок про Quick Capture: объяснить 4 типа команд, спросить хочет ли PM чтобы Copilot активно предлагал записывать наблюдения

---

### Sprint 41: Archive Search — Память для принятия решений [v4.32]

**Приоритет**: P3
**Проблема**: Archive содержит сотни записей (completed goals, finalized hypotheses, reviewed decisions, past_launches), но Copilot не использует их при принятии решений. PM не может спросить «что мы уже пробовали в этом направлении?» — archive доступен только точечно через `детали [поле]`. Опыт теряется.

**Что делаем**:
1. **Auto-search по archive** — при работе в hypothesis, goal, post-launch Copilot автоматически ищет релевантные записи:
   - При формулировке гипотезы → «Что мы уже пробовали?» → archive.hypotheses + archive.decisions
   - При оценке рисков → «Был ли похожий запуск?» → archive.past_launches
   - При post-launch → «Почему мы приняли похожее решение?» → archive.decisions
2. **Cross-initiative search** — поиск не только в текущем initiative, но и в Shared Memory + других инициативах того же product_id
3. **Search Result Format** — компактный блок при автоматическом срабатывании:
   ```
   🔍 Найдено в истории (3 записи):
   1. [2025-11] Гипотеза «X» — invalidated. Причина: ...
   2. [2025-09] Запуск «Y» — rolled_back. Урок: ...
   3. [2025-06] Решение «Z» — reviewed. Outcome: ...
   Учесть при работе? (да/нет)
   ```
4. **Команда `поиск [текст]`** — явный поиск по archive + Shared Memory. PM задаёт вопрос — Copilot ищет релевантные записи
5. **Relevance scoring** — Copilot оценивает релевантность каждой записи к текущему контексту (stage, problem, active_prd), показывает только top-5

**Метрики успеха**:
- Доля решений с учётом archive: ≥50% (сейчас ~0%)
- Команда `поиск` используется ≥2 раз/неделю при активной работе

**Артефакты**:
- Обновлённый фасад (команда `поиск`, auto-search триггеры)
- Обновлённый product-state reference (search rules, relevance scoring)
- Обновлённые sub-skills (hypothesis, goal, post-launch — auto-search при работе)

**Детальный план реализации**:

1. **`pm-copilot/SKILL.md`** — фасад:
   - Секция «Быстрые команды» — добавить `поиск [текст]`
   - Новая секция **«Archive Search»** (после Insight Management):
     - Правила auto-search: какие триггеры → какие источники archive
     - Search Result Format (шаблон вывода)
     - Relevance scoring: критерии релевантности (совпадение по stage/problem/active_prd тексту)
     - Cross-initiative: порядок поиска (текущий archive → shared_memory → другие initiative files)
   - Activation Matrix: при активации hypothesis/goal/post-launch — дополнительно искать по archive

2. **`pm-copilot/references/product-state.md`** — reference:
   - Новая секция **«Archive Search Rules»**:
     - Алгоритм поиска: парсинг запроса → scan archive.* → score relevance → sort → top-5
     - Relevance scoring: weighted score = match_stage(0.3) + match_problem(0.3) + match_text(0.4)
     - Cross-initiative правила: какие поля из shared_memory участвуют в поиске
     - Формат Search Result (шаблон для LLM-вывода)

3. **`pm-copilot-hypothesis/SKILL.md`** — sub-skill:
   - Шаг «Формулировка гипотезы» — добавить auto-search: перед показом гипотезы PM → Copilot ищет в archive.hypotheses похожие (по тексту + проблеме)
   - Шаблон: «🔍 В истории найдено [N] похожих гипотез: ... Учесть при формулировке?»

4. **`pm-copilot-goal/SKILL.md`** — sub-skill:
   - Шаг «Декомпозиция цели» — добавить auto-search: при определении эпиков с неопределённостью → Copilot ищет в archive.past_launches похожие запуски
   - Шаблон: «🔍 Похожий запуск уже был: [title], результат: [result]. Учесть в план?»

5. **`pm-copilot-post-launch/SKILL.md`** — sub-skill:
   - Шаг «Оценка результатов» — добавить auto-search: при заполнении actual_outcome → Copilot ищет archive.decisions с похожей проблемой для сравнения
   - Шаблон: «🔍 Похожее решение [date]: [text]. Outcome: [actual_outcome]. Сравнить?»

6. **`pm-copilot-comms/SKILL.md`** — sub-skill:
   - Команда `поиск` доступна на любом stage через фасад, но comms может использовать archive.search при подготовке Executive Summary (показать «из прошлого опыта» секцию)

---

## Эпик 2: Техдолг — «Надёжный и быстрый пайплайн»

> Не создаёт новую продуктовую ценность напрямую, но без этого продукт деградирует — тормозит, ломается, теряет контекст. Критерий: ускоряет pipeline или устраняет риск потери данных.

> **Контекст PERF**: Pipeline загружает ~97,600 токенов суммарно, ~54% фасада загружается напрасно на каждом ходу. ProductState растёт бесконтрольно. Ожидаемая экономия: 30-49% in-токенов, ~$900/мес при 100 PM.

---

### Sprint 30: QA-AUDIT — Аудит и актуализация тестирования

**Статус**: 📋 Задача-заметка (отдельный спринт перед PERF-блоком)
**Приоритет**: P2

**Контекст**: pm-copilot-tests содержит 100 тестов (75 T1 + 16 T2 + 9 T3), написанных под v4.11. После Sprint 21-28 в пайплайн добавлены: State Machine, Anti-Overthinking, Learning Loop, Insight Management, Memory Layers, Launch Readiness, Multi-Initiative. Тесты устарели.

**Что нужно сделать**:
1. **Актуализировать Coverage Matrix**: Пересмотреть связи «что изменилось → какие тесты запускать»
2. **Добавить тесты на новые фичи**: State Machine, Anti-Overthinking, Express Mode, Learning Loop, Insight Management, Memory Layers, Launch Readiness, Multi-Initiative
3. **Пересмотреть рубрики**: Обновить T1-рубрики с учётом новых критериев
4. **Актуализировать дефолтный профиль**: Добавить express mode, experienced PM settings

**Когда**: Перед началом PERF-спринтов

---

### Sprint 31: PERF-1 — Facade Split [v4.22]

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

### Sprint 32: PERF-2 — ProductState Compaction [v4.23]

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

### Sprint 33: PERF-3 — Conversation Summarization [v4.24]

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

### Sprint 34: PERF-4 — TIB-lite Inline [v4.25]

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

### Sprint 35: PERF-5 — Reference Dedup [v4.26]

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

### Sprint 36: PERF-6 — Turn Budget per Phase [v4.27]

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

### Sprint 37: PERF-7 — Conditional Reference Loading [v4.28]

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

## Icebox — «Вне вижна»

> Идеи, которые не противоречат вижну, но сейчас не приоритет — нет ресурса, нет спроса, или нужен plugin-этап. Вернёмся когда контекст изменится.

---

### Autopilot Shortcut [бывш. Sprint 38]

**Почему в Icebox**: Ускоряет опытных PM (-300-500 out-токенов/ход), но PM пока один и это marginal gain. Вернётся когда ≥3 активных PM.

---

### Stakeholder Profiles [вырезано из Sprint 29]

**Почему в Icebox**: Профили стейкхолдеров нужны для командной работы. Текущий вижн — one-on-one copilot. Вернётся при plugin-фазе.

---

### Team Sync [вырезано из Sprint 29]

**Почему в Icebox**: Синхронизация для команды — та же причина. Нужен plugin или multi-seat режим.

---

### DEV-SKILLS: Выделение development-скиллов (Analyst, Architect, QA)

**Статус**: 📋 Задача-заметка
**Почему в Icebox**: Development-tooling, ускоряет разработку пайпа, но не продукт (не помогает PM принимать решения). Вернётся после стабилизации runtime.

**Предложение — 3 development-скилла**:
- `pm-copilot-analyst` — аудит, анализ, рекомендации
- `pm-copilot-architect` — проектирование и изменение пайпа
- `pm-copilot-qa` — тестирование, покрытие, актуализация

**Когда анализировать**: После стабилизации Эпика 2 (PERF-блок завершён)

---

### Decision Quality Metrics 📦 Icebox

**Статус**: 📦 Icebox — перенесён 2026-05-12
**Почему в Icebox**: Требует накопленного Decision Log с `actual_outcome`. На этапе первичного adoption у PM нет данных — Quality Score будет пустым.

**Что делаем (когда дойдём)**:
1. **Decision Quality Score**: Оценка по 3 осям: обоснованность, проверенность допущений, калибровка
2. **Assumption Tracker**: Трекер допущений со статусами
3. **Decision Dashboard**: Команда `дашборд решений`

**Когда**: Когда реальные PM накопят Decision Log с `actual_outcome`

---

## Сводная дорожная карта

```
═══════════════════════════════════════════════════════════
ЭПИК 1: ПРОДУКТОВАЯ ЦЕННОСТЬ
═══════════════════════════════════════════════════════════
Sprint 29 ─── Collaboration Lite [v4.21] ─────────────── ✅ ЗАВЕРШЁН
Sprint 39 ─── PRD Tiers / Output Budget [v4.30] ──────── P3
Sprint 40 ─── Quick Capture [v4.31] ──────────────────── P3
Sprint 41 ─── Archive Search [v4.32] ─────────────────── P3

═══════════════════════════════════════════════════════════
ЭПИК 2: ТЕХДОЛГ
═══════════════════════════════════════════════════════════
Sprint 30 ─── QA-AUDIT ──────────────────────────────── P2
Sprint 31 ─── PERF-1: Facade Split [v4.22] ────────────── P1
Sprint 32 ─── PERF-2: ProductState Compaction [v4.23] ─── P1
Sprint 33 ─── PERF-3: Conversation Summarization [v4.24] ── P1
Sprint 34 ─── PERF-4: TIB-lite Inline [v4.25] ────────── P2
Sprint 35 ─── PERF-5: Reference Dedup [v4.26] ────────── P2
Sprint 36 ─── PERF-6: Turn Budget per Phase [v4.27] ──── P2
Sprint 37 ─── PERF-7: Conditional Reference Loading [v4.28] ── P2

═══════════════════════════════════════════════════════════
ICEBOX
═══════════════════════════════════════════════════════════
📦 Autopilot Shortcut ───────────────────────────────── marginal gain (1 PM)
📦 Stakeholder Profiles ─────────────────────────────── нужна plugin-фаза
📦 Team Sync ─────────────────────────────────────────── нужна plugin-фаза
📦 DEV-SKILLS ─────────────────────────────────────────── development-tooling
📦 Decision Quality Metrics ──────────────────────────── нет данных
```

### Ожидаемая экономия от PERF-спринтов (Эпик 2)

- **In-token на старте**: ~21,700 → ~12,000-15,000 (30-45%)
- **In-token глубокие сессии**: ~55,000 → ~25,000-30,000 (45-55%)
- **Стоимость/мес (100 PM)**: ~$1,800 → ~$900-1,100 (~$700-900 экономии)