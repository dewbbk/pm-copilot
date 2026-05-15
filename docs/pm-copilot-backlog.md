# PM Copilot — Бэклог развития

> Текущая версия: v5.2 (Product Scope)
> Последнее обновление: 2026-05-15
> Режим тестирования: Lite (T1 каждый спринт, T2/T3 каждые 3 спринта)
> Changelog: [pm-copilot-changelog.md](pm-copilot-changelog.md)

---

**Структура**: 3 эпика + Icebox. Каждая задача оценивается по вижну: «Помогает ли PM быстрее принять решение от инсайта до ПРД?» Приоритет внутри эпика: P1 (критический) → P2 (важный) → P3 (желательный).

---

## Эпик 1: Продуктовая ценность — «Copilot, который принимает решения»

> Фичи, которые напрямую помогают PM быстрее дойти от инсайта до ПРД. Критерий вижна: ускоряет цикл «инсайт → решение → ПРД».

---

### ~~Product Scope~~ — Границы продукта в Working Memory ✅ РЕШЕНО в v5.2

---

### Obsidian-Read-Before-Ask — Сначала ищи в Obsidian

**Приоритет**: P2
**Источник**: Обратная связь от коллег (2026-05-15)

**Проблема**: Для активных Obsidian-юзеров — Copilot задаёт вопросы, ответы на которые уже лежат в vault. При явном запросе «поищи в Obsidian» находит, но на следующем вопросе снова спрашивает PM вместо автопоиска. Нет инструкции «сначала проверь vault, потом спрашивай».

**Что делаем**:
1. **Pre-Ask Vault Scan** — перед каждым вопросом к PM, grep по vault по ключевым терминам
2. **Found-in-Vault Response** — если ответ найден, использовать его, не спрашивать
3. **Stage-limited** — применять только на `generation`/`goal` стадиях (где вероятность наличия данных в vault выше)
4. **Token Budget** — ограничить +500 in-токенов на проверку

**Метрики успеха**: Доля вопросов с ответом в vault ≤10%
**Риск**: +[DEPARTMENT_7806] in-токенов на каждый ход при сканировании
**Затронутые файлы**: `pm-copilot/SKILL.md`, workflow sub-skills (`pm-copilot-goal`, `pm-copilot-hypothesis`, `pm-copilot-generation`)

---

### Stakeholder Lens — Ранний взгляд стейкхолдеров

**Приоритет**: P2
**Источник**: Обратная связь от коллег (2026-05-15)

**Проблема**: Стейкхолдеры появляются только в `/pm-copilot-comms`, когда ПРД готов. PM хочет подключать их раньше — на этапе идеи: подумать над задачей как стейкхолдер/аналитик/разработчик, подготовиться к встрече (какие вопросы зададут, какие возражения возникнут), отсечь идеи, которые не пройдут юристов/финансов.

**Что делаем**:
1. **Stakeholder Perspectives** — типовые перспективы: юрист, финансист, аналитик, разработчик, C-level, compliance
2. **Lens Activation** — команда `взгляд [перспектива]` или авто-предложение в goal/hypothesis
3. **Output per perspective**: (1) вопросы стейкхолдера, (2) возражения, (3) красные флаги, (4) что подготовить
4. **Idea Filter** — суммарная оценка «пройдёт / не пройдёт» по всем перспективам

**Отличие от Icebox «Stakeholder Profiles»**: Stakeholder Profiles — командная работа / plugin-фаза. Stakeholder Lens — индивидуальный thinking tool для one-on-one copilot.

**Метрики успеха**: PM использует Stakeholder Lens ≥30% сессий с goal/hypothesis
**Затронутые файлы**: `pm-copilot-goal/SKILL.md`, `pm-copilot-hypothesis/SKILL.md`, новый reference `stakeholder-lenses.md` или блок в существующий reference

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

### ~~ProductState Compaction~~ — Сжатие состояния продукта ✅ РЕШЕНО в v5.0

**Статус**: Решено архитектурно. Compaction rules — SSoT в `references/product-state.md`, фасад ссылается на reference.

### ~~Conditional Reference Loading~~ — Ленивая загрузка references ✅ РЕШЕНО в v5.0

**Статус**: Решено архитектурно. Фасад 152 строки — загрузка reference по ссылке, не inline.

### ~~Reference Dedup~~ — Устранение дублирования references ✅ РЕШЕНО в v5.0

**Статус**: Решено. `pm-copilot-task/references/thinking-in-bets.md` удалён, task ссылается на `pm-copilot/references/thinking-in-bets.md`.

### ~~TIB-lite Inline~~ — Компактный TIB для быстрого режима ✅ РЕШЕНО в v5.0

**Статус**: Решено. TIB reference на месте, дубль из task удалён. Потребность в inline-lite отпала — фасад не содержит TIB описания.

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

### Достигнутая экономия от v5.0 (Lean Facade)

- **Фасад**: 1,837 → 152 строк (-92%)
- **In-token на старте**: ~21,700 → ~12,000-15,000 (30-45%)
- **In-token глубокие сессии**: ~38,000 → ~15,000-18,000 (56-63%)
- **Стоимость/мес (100 PM)**: ~$1,800 → ~$600-700 (~$1,100 экономии)

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
