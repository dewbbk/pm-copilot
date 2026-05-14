---
name: pm-copilot-tests
description: "QA-сьют для PM Copilot. Отдельный skill, не входящий в runtime-пайплайн. Активируется разработчиком/maintainer'ом: 'запусти автотесты', 'прогон тестов', 'проверь качество'. Содержит тест-кейсы (3 уровня: T1 per-skill, T2 кросс-скилл, T3 регресс-дым), per-skill рубрики (LLM-as-Judge), Coverage Matrix и механику прогона. Тесты читают схемы из pm-copilot/references/ (single source of truth). Возвращает таблицу Pass/Fail с баллами. Версия: v4.18 (Sprint 26: Launch Readiness)."
---

# PM Copilot — QA Suite (pm-copilot-tests)

> **Роль**: QA-инструмент для разработчика/maintainer'а. Не входит в runtime-пайплайн (PM не вызывает этот skill напрямую через фасад).
> **Архитектура**: Тесты проверяют пайплайн извне, читая схемы из `pm-copilot/references/` — single source of truth. Нет циркулярной зависимости.
> **Принцип**: Тест-кейс = диалог PM <-> Copilot с несколькими ходами. Оцениваем не точное совпадение, а соответствие рубрике (LLM-as-Judge).

---

## Связь с пайплайном

```
pm-copilot/              <- Runtime pipeline (PM-facing), 9 sub-skills
  SKILL.md               <- facade v4.18
  references/            <- shared schemas (single source of truth)
    product-state.md
    decision-log.md
    domain-context.md
    thinking-in-bets.md
    metrics.md

pm-copilot-tests/        <- QA suite (developer-facing), этот skill
  SKILL.md               <- test runner + Coverage Matrix + rubrics + test cases
```

**Где читать схемы**: `pm-copilot/references/` — тесты ссылаются на файлы схем, не копируют их содержимое. При изменении схемы — обновляется один файл, тесты автоматически используют новую версию.

---

## Структура тестов: 3 уровня

| Уровень | Название | Кол-во | Назначение | Время прогона |
|---------|----------|--------|------------|---------------|
| T1 | Per-skill | 92 | Тесты конкретных скиллов (включая Obsidian, ProductState, Stage Detection, Decision Log, Autopilot, PM Memory, Product Memory, TIB Auto, Session Resume, Reflection, Router Guard, Anti-Overthinking, Learning Loop, Insight Management, Launch Readiness) | ~46 мин |
| T2 | Кросс-скилл | 16 | Роутинг, handoff, переключение, continuity | ~8 мин |
| T3 | Регресс-дым | 9 | Быстрая проверка перед релизом | ~5 мин |
| **Итого** | | **117** | | **~59 мин** |

---

## Coverage Matrix

Определяет, какие тесты запускать при изменении конкретного скилла.

| Что изменилось | T1 (per-skill) | T2 (кросс-скилл) | T3 (дым) |
|----------------|----------------|-------------------|----------|
| pm-copilot (facade) | T1-state, T1-stage, T1-decision, T1-decision-linking, T1-autopilot, T1-memory, T1-product-memory, T1-session-resume, T1-reflection, T1-router-guard, T1-anti-overthinking, T1-learning-loop, T1-insight, T1-quick-capture, T1-archive-search | T2-routing, T2-handoff, T2-switching, T2-continuity | T3-smoke-routing |
| pm-copilot-onboarding | T1-onboarding, T1-autopilot (003, 004), T1-memory (002, 003) | T2-per-project | T3-smoke-onboarding |
| pm-copilot-goal | T1-goal, T1-decision (006), T1-decision-linking (002), T1-reflection (003 ref) | T2-routing, T2-handoff (goal->gen) | T3-smoke-goal |
| pm-copilot-generation | T1-generation, T1-insight (001, 002) | T2-routing, T2-handoff (goal->gen) | T3-smoke-generation |
| pm-copilot-hypothesis | T1-hypothesis, T1-decision (005), T1-decision-linking (001), T1-memory (001), T1-product-memory (001, 002), T1-reflection (001) | T2-routing, T2-handoff (hyp->task) | T3-smoke-hypothesis |
| pm-copilot-task | T1-task, T1-decision (007), T1-decision-linking (002 ref), T1-reflection (003 ref) | T2-routing, T2-handoff (hyp->task, task->comms) | T3-smoke-task |
| pm-copilot-comms | T1-comms | T2-handoff (task->comms) | T3-smoke-comms |
| pm-copilot-post-launch | T1-post-launch, T1-decision (008, 009), T1-decision-linking (002 ref), T1-memory (004), T1-product-memory (003, 004), T1-learning-loop (003) | -- | T3-smoke-post-launch |
| references/domain-context.md + metrics.md | T1-domain | T2-routing (доменный фокус) | T3-smoke-domain |
| pm-copilot-thinking-in-bets | T1-thinking-in-bets, T1-tib-auto | -- | -- |
| Obsidian-фичи (vault, frontmatter, dataview, шаблоны) | T1-obsidian | T2-handoff (Obsidian-режим) | T3-smoke-obsidian |
| ProductState-фичи (state, create/load, update, history) | T1-state | T2-routing, T2-handoff, T2-continuity | T3-smoke-routing |
| Stage Detection-фичи (detection, display, transitions, back, anti-cycle) | T1-stage | T2-routing, T2-switching | T3-smoke-routing |
| Autopilot-фичи (suggestions, on/off, что дальше?) | T1-autopilot | T2-routing, T2-handoff | T3-smoke-routing |
| PM Memory-фичи (style, auto-analysis, adaptation, команда стиль) | T1-memory | T2-routing | T3-smoke-routing |
| Product Memory-фичи (product_memory, история, past_hypotheses, past_launches, learned_patterns) | T1-product-memory | T2-routing | T3-smoke-routing |
| Decision Linking-фичи (related_decisions, supersedes, цепочка) | T1-decision-linking | T2-routing | T3-smoke-routing |
| TIB Auto-фичи (автоподключение, быстрый/полный режим, цепочки решений в TIB) | T1-tib-auto | T2-routing | T3-smoke-routing |
| Session Resume-фичи (last_context, команда продолжить, автопредложение) | T1-session-resume | T2-continuity | T3-smoke-routing |
| Reflection-фичи (чекпойнты, вопросы, пропуск, контекст из Decision Linking) | T1-reflection | T2-routing | T3-smoke-routing |
| Router Guard-фичи (двойная проверка, last_context vs rule_stage, подтверждение PM при расхождении) | T1-router-guard | T2-routing | T3-smoke-routing |
| Anti-Overthinking-фичи (Phase Limits, Express Mode, Anti-Overthinking Guard, phase_turns) | T1-anti-overthinking | T2-routing | T3-smoke-routing |
| Learning Loop-фичи (Learning Card, learning→generation bridge, auto-suggest, зрелый продукт, команда уроки) | T1-learning-loop | T2-routing, T2-handoff (learning->gen) | T3-smoke-routing |
| Insight Management-фичи (Insight Buffer, команда инсайт, Insight Prioritization, Insight→Goal, Insight↔Decision, Insight→Generation Bridge) | T1-insight | T2-routing, T2-handoff (insight->gen, insight->goal) | T3-smoke-routing |
| Launch Readiness-фичи (Readiness Checklist, Readiness Score, Go/No-Go Frame, Pre-launch Snapshot, команда готовность) | T1-launch-readiness | T2-routing, T2-handoff (comms->launch) | T3-smoke-routing |
| Quick Capture-фичи (конкурент/данные/фидбек/решение руководства, Context Drop при старте сессии, capture_type) | T1-quick-capture | T2-continuity | T3-smoke-routing |
| Archive Search-фичи (auto-search в hypothesis/goal/post-launch, команда поиск, relevance scoring, cross-initiative) | T1-archive-search | T2-routing, T2-handoff | T3-smoke-routing |
| Facade Split-маркеры (LOAD: always/workflow/on-demand, порядок секций) | T1-state, T1-stage, T1-router-guard | T2-routing, T2-continuity | T3-smoke-routing |

**Пример 1**: Изменили pm-copilot-hypothesis -> T1-hypothesis (4) + T2-routing (5) + T2-handoff (1: hyp->task) + T3-smoke-hypothesis (1) = 11 тестов, ~6 мин

**Пример 2**: Изменили Obsidian-секцию в фасаде -> T1-obsidian (4) + T1-onboarding (5, includes Obsidian-setup) + T2-handoff (1: Obsidian-режим) + T3-smoke-obsidian (1) = 11 тестов, ~6 мин

---

## Режимы прогона тестов

### 🔥 Lite-режим (по умолчанию для спринтов)

> **Введено**: v4.15 (Sprint 23). Цель — ускорить цикл спринтов, не теряя базовую безопасность.

**Правило**: После каждого спринта — прогонять **только T1 (per-skill)** тесты, релевантные изменённым скиллам. T2 (кросс-скилл) и T3 (регресс-дым) прогоняются раз в 3 спринта или перед мажорными версиями.

| Что прогонять | Когда | Время |
|---------------|-------|-------|
| T1 (релевантные) | Каждый спринт | ~15-20 мин |
| T1 + T2 | Каждые 3 спринта (Sprint N где N % 3 == 0) | ~30 мин |
| T1 + T2 + T3 | Перед мажорной версией или по команде `тест полный` | ~55 мин |

**Механика Lite-прогона**:
1. Определить, какие скиллы/фичи изменились в спринте
2. По Coverage Matrix выбрать только T1-тесты для этих скиллов
3. Прогнать, составить отчёт
4. T2/T3 отложить до контрольного спринта

**Контрольные спринты** (полный прогон T1+T2): Sprint 30 ✅ (текущий), Sprint 33, Sprint 36, Sprint 39

### 📋 Полный режим (для релизов и аудита)

Все команды ниже работают как раньше — полный прогон:

1. `проверь [скилл]` -> T1 для этого скилла + все T2 из строки Coverage Matrix (~6-12 тестов, ~3-6 мин)
2. `тест дым` / `быстрая проверка` -> все T3 (~9 тестов, ~5 мин)
3. `тест полный` -> все T1 + T2 + T3 (~69 тестов, ~37 мин)
4. `тест перед релизом` -> T3, если pass -> полный T1+T2
5. Автоматически после изменения скилла -> правило 1 (агент видит, какой файл изменён, и запускает по Coverage Matrix)
6. `проверь роутинг` / `проверь handoff` -> конкретная T2-категория
7. `проверь всё кросс-скилловое` -> все T2 (~16 тестов, ~8 мин)
8. `проверь obsidian` -> T1-obsidian (4) + T1-onboarding с Obsidian-setup (2) + T2-handoff-004 (1) + T3-smoke-obsidian (1) = 8 тестов, ~4 мин
9. `проверь state` / `проверь ProductState` -> T1-state (4) + T1-stage (5) + T2-routing (5) + T2-handoff (4) + T2-continuity (2) + T3-smoke-routing (1) = 21 тест, ~10 мин
10. `проверь stage` / `проверь этапы` -> T1-stage (5) + T2-routing (5) + T2-switching (2) + T3-smoke-routing (1) = 13 тестов, ~7 мин
11. `проверь решения` / `проверь Decision Log` -> T1-decision (9) + T1-state (4) + T2-routing (5) + T2-handoff (4) + T3-smoke-routing (1) = 23 теста, ~12 мин
12. `проверь autopilot` / `проверь подсказки` -> T1-autopilot (4) + T1-state (4) + T1-stage (5) + T2-routing (5) + T2-handoff (4) + T3-smoke-routing (1) = 23 теста, ~12 мин
13. `проверь стиль` / `проверь memory` / `проверь PM Memory` -> T1-memory (4) + T1-onboarding (5) + T1-state (4) + T2-routing (5) + T3-smoke-routing (1) = 19 тестов, ~10 мин
14. `проверь историю` / `проверь Product Memory` / `проверь product memory` -> T1-product-memory (4) + T1-state (4) + T1-hypothesis (4) + T1-post-launch (3) + T2-routing (5) + T3-smoke-routing (1) = 21 тест, ~11 мин
15. `проверь связи` / `проверь цепочку` / `проверь Decision Linking` -> T1-decision-linking (3) + T1-decision (12) + T1-state (4) + T2-routing (5) = 24 теста, ~13 мин
16. `проверь TIB` / `проверь thinking-in-bets` / `проверь вероятностный анализ` -> T1-thinking-in-bets (2) + T1-tib-auto (3) + T1-decision (12) + T1-state (4) + T2-routing (5) + T3-smoke-routing (1) = 27 тестов, ~14 мин
17. `проверь resume` / `проверь Session Resume` / `проверь продолжить` -> T1-session-resume (3) + T1-state (4) + T2-continuity (2) + T3-smoke-routing (1) = 10 тестов, ~5 мин
18. `проверь reflection` / `проверь чекпойнты` / `проверь самопроверку` -> T1-reflection (3) + T1-hypothesis (4) + T1-goal (4) + T1-task (4) + T1-decision-linking (3) + T2-routing (5) + T3-smoke-routing (1) = 24 теста, ~12 мин
19. `проверь Router Guard` / `проверь роутинг guard` / `проверь двойную проверку` -> T1-router-guard (3) + T1-stage (5) + T2-routing (5) + T3-smoke-routing (1) = 14 тестов, ~7 мин
20. `проверь Anti-Overthinking` / `проверь Phase Limits` / `проверь экспресс` -> T1-anti-overthinking (3) + T1-stage (5) + T2-routing (5) + T3-smoke-routing (1) = 14 тестов, ~7 мин
21. `проверь Learning Loop` / `проверь уроки` / `проверь обучение` -> T1-learning-loop (3) + T1-product-memory (4) + T1-post-launch (3) + T1-generation (4) + T2-routing (5) + T3-smoke-routing (1) = 20 тестов, ~10 мин
22. `проверь инсайты` / `проверь Insight Management` / `проверь инсайт` -> T1-insight (4) + T1-generation (4) + T1-state (4) + T2-routing (5) + T3-smoke-routing (1) = 18 тестов, ~9 мин
23. `проверь готовность` / `проверь Launch Readiness` / `проверь readiness` -> T1-launch-readiness (4) + T1-state (4) + T1-comms (4) + T2-routing (5) + T3-smoke-routing (1) = 18 тестов, ~9 мин

---

## Механика прогона

### Шаг 1: Выбор тестов

Разработчик может запустить:
- **По уровню** -- `тест дым` / `тест полный` / `тест перед релизом`
- **По скиллу** -- `проверь hypothesis` / `проверь goal`
- **По T2-категории** -- `проверь роутинг` / `проверь handoff`
- **Один тест** -- `прогони тест T1-goal-001`

### Шаг 2: Исполнение

Для каждого тест-кейса:
1. Загрузи профиль PM из теста (если нет -- используй дефолтный)
2. Подставь `pm_message` из первого шага как вход
3. Сгенерируй ответ от имени PM Copilot (загрузи фасад + нужные sub-skills)
4. Сравни ответ с рубрикой, указанной для этого уровня/скилла
5. Если в тесте несколько шагов -- продолжай диалог, подставляя следующий `pm_message`

### Шаг 3: Оценка (LLM-as-Judge)

Для каждого шага оцени по рубрике, соответствующей уровню и скиллу (см. секцию "Рубрики").

Порог:
- **Pass**: >= 7 баллов из 9 (T1, T2) или 3/3 (T3)
- **Weak pass**: 5-6 баллов из 9 (T1, T2)
- **Fail**: < 5 баллов (T1, T2) или < 3/3 (T3)

### Шаг 4: Отчёт

После прогона -- сформируй таблицу:

```markdown
# Отчёт автотестов PM Copilot

> Дата: [дата] | Версия: v4.01
> Уровень: T1+T2 | Прогнано: [N] тестов

## Сводка

| Уровень / Категория | Pass | Weak | Fail | % Pass |
|---------------------|------|------|------|--------|
| T1-onboarding | X | X | X | X% |
| T1-goal | X | X | X | X% |
| ... | | | | |
| T2-routing | X | X | X | X% |
| T2-handoff | X | X | X | X% |
| ... | | | | |
| **Итого** | **X** | **X** | **X** | **X%** |

## Детали

### T1-hypothesis-001: "если A, то B"
- Результат: **Pass** (8/9)
- hypothesis_structure: 2 | experiment_design: 2 | probability_assessment: 1
- decision_framework: 1 | contains_expected: 1 | no_anti_patterns: 0 | no_forbidden: 1
```

---

## Рубрики

### T1 -- Per-skill рубрики (20 шт)

#### T1-onboarding рубрика (0-9)

| Критерий | Баллы | Описание |
|----------|-------|----------|
| `completeness` | 0-2 | Все ли шаги онбординга пройдены? 0=пропущено >1 шага, 1=частично, 2=все |
| `domain_relevance` | 0-2 | Домены соответствуют продукту? 0=чужие, 1=нейтрально, 2=точно |
| `validation_quality` | 0-2 | Валидируются ли царь-метрики? 0=нет, 1=частично, 2=полная валидация |
| `no_forbidden` | 0-1 | Нет ли запрещённых паттернов? |
| `contains_expected` | 0-1 | Содержит ожидаемые ключевые слова? |
| `obsidian_setup` | 0-1 | Правильно ли настроен Obsidian vault (если выбран)? 0=нет/ошибка, 1=корректно или не выбран |
| `user_experience` | 0-1 | Понятен ли PM процесс онбординга? |

#### T1-goal рубрика (0-9)

| Критерий | Баллы | Описание |
|----------|-------|----------|
| `decomposition_quality` | 0-2 | SMART-декомпозиция: 0=нет, 1=частично, 2=полная |
| `smart_compliance` | 0-2 | Все ли 5 букв SMART покрыты? 0=нет, 1=3-4, 2=все 5 |
| `premortem_depth` | 0-1 | Есть ли premortem с >=3 рисками? |
| `metrics_linked` | 0-1 | Привязка к царь-метрике/ганардам? |
| `contains_expected` | 0-1 | Содержит ожидаемые ключевые слова? |
| `no_anti_patterns` | 0-1 | Нет запрещённых паттернов? |
| `no_forbidden` | 0-1 | Нет ли запрещённых паттернов? |

#### T1-generation рубрика (0-9)

| Критерий | Баллы | Описание |
|----------|-------|----------|
| `technique_diversity` | 0-2 | Использовано >=3 из 6 техник? 0=1, 1=2-3, 2=4+ |
| `filtering_quality` | 0-2 | Фильтрация по домену/метрике? 0=нет, 1=частично, 2=полная |
| `prioritization_logic` | 0-1 | Есть ли логика приоритизации? |
| `contains_expected` | 0-1 | Содержит ожидаемые ключевые слова? |
| `no_anti_patterns` | 0-1 | Нет запрещённых паттернов? |
| `no_forbidden` | 0-1 | Нет ли запрещённых паттернов? |
| `checkpoint_present` | 0-1 | Есть ли чекпойнт сохранения? |

#### T1-hypothesis рубрика (0-9)

| Критерий | Баллы | Описание |
|----------|-------|----------|
| `hypothesis_structure` | 0-2 | Формат "если A, то B, потому что C"? 0=нет, 1=частично, 2=полный |
| `experiment_design` | 0-2 | Дизайн эксперимента измерим? 0=нет, 1=частично, 2=полный |
| `probability_assessment` | 0-1 | Есть ли >=3 исхода с вероятностями? |
| `decision_framework` | 0-1 | Есть ли критерии решения (что делать при каждом исходе)? |
| `contains_expected` | 0-1 | Содержит ожидаемые ключевые слова? |
| `no_anti_patterns` | 0-1 | Нет запрещённых паттернов? |
| `no_forbidden` | 0-1 | Нет ли запрещённых паттернов? |

#### T1-task рубрика (0-9)

| Критерий | Баллы | Описание |
|----------|-------|----------|
| `prd_completeness` | 0-2 | Все секции ПРД на месте? 0=пропущено >2, 1=1-2, 2=все |
| `value_effect_link` | 0-2 | Ценность->эффект->царь-метрика связаны? 0=нет, 1=частично, 2=полная цепочка |
| `risk_identification` | 0-1 | Есть ли премортем/риски? |
| `metrics_linked` | 0-1 | Привязка к царь-метрике? |
| `contains_expected` | 0-1 | Содержит ожидаемые ключевые слова? |
| `no_anti_patterns` | 0-1 | Нет запрещённых паттернов? |
| `no_forbidden` | 0-1 | Нет ли запрещённых паттернов? |

#### T1-comms рубрика (0-9)

| Критерий | Баллы | Описание |
|----------|-------|----------|
| `audience_adaptation` | 0-2 | Адаптирован ли для аудитории (PBR vs C-level)? 0=нет, 1=частично, 2=полная |
| `format_compliance` | 0-2 | Соответствует ли формату (бриф <=2 стр, executive)? 0=нет, 1=частично, 2=полный |
| `ask_section` | 0-1 | Есть ли секция Ask (что нужно от аудитории)? |
| `contains_expected` | 0-1 | Содержит ожидаемые ключевые слова? |
| `no_forbidden` | 0-1 | Нет ли запрещённых паттернов? |
| `not_copy_of_prd` | 0-2 | Переработанный контент, а не копия ПРД? 0=копия, 1=частично, 2=полная переработка |

#### T1-post-launch рубрика (0-9)

| Критерий | Баллы | Описание |
|----------|-------|----------|
| `scorecard_quality` | 0-2 | ПРД как baseline + метрики до/после? 0=нет, 1=частично, 2=полный |
| `three_axis_evaluation` | 0-2 | Оценка по 3 осям (метрики, сроки, обучение)? 0=нет, 1=1-2 оси, 2=все 3 |
| `decision_framework` | 0-1 | Есть ли решение (scale/pivot/kill) с обоснованием? |
| `learning_extracted` | 0-1 | Извлечены ли уроки для будущих итераций? |
| `contains_expected` | 0-1 | Содержит ожидаемые ключевые слова? |
| `no_forbidden` | 0-1 | Нет ли запрещённых паттернов? |
| `checkpoint_present` | 0-1 | Есть ли чекпойнт сохранения? |

#### T1-domain рубрика (0-9)

| Критерий | Баллы | Описание |
|----------|-------|----------|
| `domain_focus` | 0-2 | В рамках доменов PM? 0=чужой, 1=нейтральный, 2=точно в домене |
| `metric_relevance` | 0-2 | Метрики релевантны домену? 0=чужие, 1=нейтральные, 2=точно |
| `no_cross_contamination` | 0-2 | Нет ли подмешивания чужих доменов? 0=есть, 1=минорное, 2=чисто |
| `contains_expected` | 0-1 | Содержит ожидаемые ключевые слова? |
| `no_forbidden` | 0-1 | Нет ли запрещённых паттернов? |
| `cache_logic` | 0-1 | При повторном запросе -- проверяет кэш? |

#### T1-thinking-in-bets рубрика (0-9)

| Критерий | Баллы | Описание |
|----------|-------|----------|
| `scenario_coverage` | 0-2 | 4 сценария (лучший/ожидаемый/худший/чёрный лебедь)? 0=1, 1=2-3, 2=4. **Для быстрого режима**: 2 сценария (ожидаемый/худший) = 2 балла |
| `probability_calibration` | 0-2 | Вероятности реалистичны и суммируются ~100%? 0=нет, 1=частично, 2=да |
| `premortem_depth` | 0-2 | Конкретные причины неудачи? 0=общие, 1=частично, 2=конкретные. **Для быстрого режима**: автоматически 1 |
| `contains_expected` | 0-1 | Содержит ожидаемые ключевые слова? |
| `no_forbidden` | 0-1 | Нет ли запрещённых паттернов? |
| `decision_link` | 0-1 | Связь с решением (что делать при каждом сценарии)? |

#### T1-tib-auto рубрика (0-9)

| Критерий | Баллы | Описание |
|----------|-------|----------|
| `auto_trigger_correct` | 0-2 | TIB автоподключение сработало корректно (правильный триггер, правильный режим)? 0=не сработало, 1=частично (не тот режим), 2=корректно |
| `mode_appropriate` | 0-2 | Режим соответствует условию (быстрый для confidence < 0.7 без царь-метрики, полный для царь-метрики/сюрпризов)? 0=неверный, 1=частично, 2=точно |
| `chain_usage` | 0-2 | TIB использует цепочку решений (related_decisions) для обогащения? 0=нет, 1=упомянуто, но не обогащает, 2=конкретно обогащает анализ |
| `contains_expected` | 0-1 | Содержит ожидаемые ключевые слова (вероятностный анализ, сценарий, уверенность, царь-метрик)? |
| `no_forbidden` | 0-1 | Нет запрещённых паттернов (автозапуск TIB без подтверждения PM, быстрый режим при царь-метрике)? |
| `product_memory_used` | 0-1 | TIB проверяет product_memory.learned_patterns? **Если learned_patterns пуст** — автоматически 1 |

#### T1-session-resume рубрика (0-9)

| Критерий | Баллы | Описание |
|----------|-------|----------|
| `last_context_format` | 0-2 | last_context содержит все обязательные поля (skill, phase, last_question, timestamp)? 0=нет>2, 1=частично, 2=полный. **Если тест про команду/поведение, а не формат** — автоматически 2 |
| `command_resume` | 0-2 | Команда `продолжить` возобновляет сессию корректно (показывает skill, phase, last_question)? 0=нет, 1=частично, 2=полный. **Если тест не про эту команду** — автоматически 2 |
| `auto_suggestion` | 0-1 | При загрузке ProductState с непустым last_context — показано автопредложение возобновления? **Если не применяется** — автоматически 1 |
| `contains_expected` | 0-1 | Содержит ожидаемые ключевые слова (продолжить, last_context, фаза, вопрос)? |
| `no_forbidden` | 0-1 | Нет запрещённых паттернов (пустой last_context при активной работе, отсутствие автопредложения при непустом last_context)? |
| `context_accuracy` | 0-2 | last_context.skill и last_context.phase соответствуют реальному состоянию диалога? 0=неверно, 1=частично, 2=точно |
| `update_timing` | 0-1 | last_context обновляется при каждом ответе workflow-скилла, но НЕ при командах просмотра? **Если не применяется** — автоматически 1 |

#### T1-reflection рубрика (0-9)

| Критерий | Баллы | Описание |
|----------|-------|----------|
| `checkpoint_present` | 0-2 | Reflection checkpoint сработал на ожидаемой фазе (между Фазами)? 0=нет, 1=не на той фазе, 2=точно |
| `questions_relevant` | 0-2 | Reflection-вопросы релевантны контексту (допущения, слепые зоны, решения)? 0=нерелевантны, 1=частично, 2=точно |
| `can_skip` | 0-1 | PM может пропустить reflection? Copilot не настаивает? |
| `contains_expected` | 0-1 | Содержит ожидаемые ключевые слова (допущения, проверены, цель, избега)? |
| `no_forbidden` | 0-1 | Нет запрещённых паттернов (более 2 вопросов, обязательный ответ, аудит вместо помощи)? |
| `context_used` | 0-2 | Reflection использует контекст (last_context, Decision Linking, Product Memory)? 0=нет, 1=упомянуто но поверхностно, 2=конкретно используется |
| `not_separate_skill` | 0-1 | Reflection встроен в workflow, не создаёт отдельный шаг? **Если не применяется** — автоматически 1 |

#### T1-obsidian рубрика (0-9)

| Критерий | Баллы | Описание |
|----------|-------|----------|
| `frontmatter_completeness` | 0-2 | YAML frontmatter содержит все обязательные поля (type, status, created, updated, project, tsar-metric, tags)? 0=нет>2, 1=частично, 2=полный |
| `wiki_links_present` | 0-2 | Wiki-links связывают артефакты? 0=нет, 1=частично, 2=полные двусторонние связи |
| `dataview_queries` | 0-2 | Dataview-запросы доступны и корректны? 0=нет, 1=часть, 2=все 5 |
| `template_compliance` | 0-1 | Шаблоны содержат Templater-переменные и Obsidian-структуру? |
| `contains_expected` | 0-1 | Содержит ожидаемые ключевые слова? |
| `no_forbidden` | 0-1 | Нет ли запрещённых паттернов? |

#### T1-state рубрика (0-9)

| Критерий | Баллы | Описание |
|----------|-------|----------|
| `state_format` | 0-2 | ProductState содержит все обязательные поля (id, stage, problem, metrics, history, created, updated)? 0=нет>2, 1=частично, 2=полный |
| `stage_correct` | 0-2 | Stage соответствует текущему пути (hypothesis/goal/task/comms/...)? 0=неверный, 1=частично, 2=точно |
| `state_command` | 0-1 | Команда `state` выводит ProductState в читаемом формате? |
| `history_tracking` | 0-1 | При переходе между stage -- добавляется запись в history? |
| `contains_expected` | 0-1 | Содержит ожидаемые ключевые слова (ProductState, stage, history)? |
| `no_forbidden` | 0-1 | Нет ли запрещённых паттернов (удаление ProductState, потеря данных)? |
| `update_correct` | 0-1 | При ответе скилла -- ProductState обновляется (updated timestamp)? |

#### T1-stage рубрика (0-9)

| Критерий | Баллы | Описание |
|----------|-------|----------|
| `stage_detected` | 0-2 | Stage корректно определён по ProductState? 0=неверный, 1=частично (соседний), 2=точно |
| `stage_displayed` | 0-2 | 📍 Этап показан в ответе? 0=нет, 1=без следующего/неполный, 2=полный (этап + следующий) |
| `transition_appropriate` | 0-1 | Предложение перехода соответствует условиям готовности? |
| `transition_format` | 0-1 | Формат предложения соответствует шаблону (📍 Переход, Обоснование, Перейти?)? |
| `contains_expected` | 0-1 | Содержит ожидаемые ключевые слова (Этап, Переход, stage)? |
| `no_forbidden` | 0-1 | Нет запрещённых паттернов (автопереход без подтверждения на proposal-переходах, потеря данных при back_transition)? |
| `anti_cycle` | 0-1 | При stage_transitions_count > 3 -- подсвечен паттерн? |

#### T1-decision рубрика (0-9 + Decision Linking)

| Критерий | Баллы | Описание |
|----------|-------|----------|
| `decision_format` | 0-2 | Decision содержит все обязательные поля (id, timestamp, stage, decision, rationale, confidence, status, related_decisions, supersedes)? 0=нет>2, 1=частично, 2=полный. **Если тест про команду/поведение, а не запись** -- автоматически 2 |
| `decision_stage_correct` | 0-2 | Stage в Decision соответствует этапу? 0=неверный, 1=частично, 2=точно. **Если не применяется** -- автоматически 2 |
| `command_decisions` | 0-1 | Команда `решения` выводит таблицу всех решений? **Если тест не про эту команду** -- автоматически 1 |
| `command_review` | 0-1 | Команда `ревизия` показывает только open-решения? **Если тест не про эту команду** -- автоматически 1 |
| `contains_expected` | 0-1 | Содержит ожидаемые ключевые слова (Decision, решения, ревизия, rationale, related_decisions, supersedes)? |
| `no_forbidden` | 0-1 | Нет запрещённых паттернов (автозапись без подтверждения PM, actual_outcome до post-launch)? |
| `lifecycle_correct` | 0-1 | Жизненный цикл корректен (open → reviewed / superseded)? **Если не применяется** -- автоматически 1 |

**Decision Linking-специфичные критерии** (для T1-decision-linking тестов):

| Критерий | Баллы | Описание |
|----------|-------|----------|
| `related_decisions_correct` | 0-2 | related_decisions заполнен корректно: hypothesis=[], goal=[hyp ID], task=[goal ID], post-launch=[task ID]? 0=неверно, 1=частично, 2=точно |
| `supersedes_correct` | 0-1 | supersedes = null для новых решений, = ID старого при пересмотре? **Если не применяется** -- автоматически 1 |
| `chain_display` | 0-1 | Команда `цепочка` показывает полный путь решений? **Если тест не про цепочку** -- автоматически 1 |

#### T1-autopilot рубрика (0-9)

| Критерий | Баллы | Описание |
|----------|-------|----------|
| `suggestion_present` | 0-2 | Есть ли блок 📌 Следующий шаг? 0=нет, 1=неполный (без «Или»), 2=полный (шаг + альтернатива) |
| `suggestion_relevant` | 0-2 | Предложение релевантно текущему stage/ProductState? 0=нерелевантно, 1=частично, 2=точно соответствует логике |
| `suggestion_format` | 0-1 | Формат соответствует шаблону (📌 Следующий шаг: ... / Или: ...)? |
| `no_autoswitch` | 0-1 | Нет ли автоматического переключения stage без подтверждения PM? |
| `contains_expected` | 0-1 | Содержит ожидаемые ключевые слова (Следующий шаг, Или,autopilot)? |
| `no_forbidden` | 0-1 | Нет запрещённых паттернов (автопереход, подсказка внутри фазы, подсказка при autopilot: off)? |
| `priority_correct` | 0-1 | При нескольких условиях -- показано самое приоритетное? |

#### T1-memory рубрика (0-9)

| Критерий | Баллы | Описание |
|----------|-------|----------|
| `style_format` | 0-2 | DecisionStyle содержит все обязательные поля (risk_tolerance, decision_speed, preferred_depth, typical_biases, decisions_analysed)? 0=нет>2, 1=частично, 2=полный. **Если тест про команду/поведение, а не формат** -- автоматически 2 |
| `adaptation_present` | 0-2 | Copilot адаптирует вопросы на основе стиля? 0=нет адаптации, 1=частичная (один параметр), 2=полная (несколько параметров). **Если тест не про адаптацию** -- автоматически 2 |
| `command_style` | 0-1 | Команда `стиль` выводит текущий стиль решений? **Если тест не про эту команду** -- автоматически 1 |
| `auto_analysis` | 0-1 | При 5+ решениях -- Copilot предлагает обновить стиль? **Если не применяется** -- автоматически 1 |
| `contains_expected` | 0-1 | Содержит ожидаемые ключевые слова (стиль, risk_tolerance, bias, адаптация)? |
| `no_forbidden` | 0-1 | Нет запрещённых паттернов (автообновление стиля без подтверждения PM, диагноз bias как факт)? |
| `question_driven_preserved` | 0-1 | Question-driven подход сохранён? Copilot адаптирует КАК спрашивает, но не меняет ЧТО? |

#### T1-product-memory рубрика (0-9)

| Критерий | Баллы | Описание |
|----------|-------|----------|
| `memory_format` | 0-2 | product_memory содержит все обязательные подсекции (past_hypotheses, past_launches, active_initiatives, learned_patterns)? 0=нет>2, 1=частично, 2=полный. **Если тест про команду/поведение, а не формат** — автоматически 2 |
| `memory_usage` | 0-2 | Copilot использует Product Memory в диалоге (проверка на повторы, упоминание паттернов, ссылка на прошлый опыт)? 0=нет, 1=частично (одно упоминание), 2=полная интеграция. **Если тест не про использование** — автоматически 2 |
| `command_history` | 0-1 | Команда `история` выводит Product Memory в читаемом формате? **Если тест не про эту команду** — автоматически 1 |
| `pattern_detection` | 0-1 | При выявлении паттерна — Copilot предлагает записать с подтверждением PM? **Если не применяется** — автоматически 1 |
| `contains_expected` | 0-1 | Содержит ожидаемые ключевые слова (история, past_hypotheses, learned_patterns, паттерн, продукт)? |
| `no_forbidden` | 0-1 | Нет запрещённых паттернов (блокировка повторной гипотезы, автозапись learned_patterns без подтверждения, показ confidence < 0.4 без оговорки)? |
| `session_summary` | 0-1 | При загрузке ProductState с непустым product_memory — показана краткая сводка? **Если не применяется** — автоматически 1 |

#### T1-router-guard рубрика (0-9)

| Критерий | Баллы | Описание |
|----------|-------|----------|
| `guard_triggered` | 0-2 | Router Guard сработал при расхождении rule_stage и last_context? 0=не сработал, 1=частично (заметил расхождение, но не предложил выбор), 2=полностью (заметил + предложил PM выбрать) |
| `pm_choice_offered` | 0-2 | PM предложен выбор (переключиться / остаться)? 0=нет выбора, 1=выбор есть но формат не по шаблону, 2=полный (да/нет/не сейчас) |
| `context_consistency` | 0-2 | Copilot корректно определил расхождение (last_context.skill ≠ rule_stage)? 0=не определил, 1=определил но неточно, 2=точно |
| `contains_expected` | 0-1 | Содержит ожидаемые ключевые слова (переключиться, остаться, last_context, stage)? |
| `no_forbidden` | 0-1 | Нет запрещённых паттернов (автопереключение без подтверждения PM, игнорирование last_context при расхождении)? |
| `no_false_positive` | 0-1 | При отсутствии расхождения — Router Guard НЕ срабатывает (нет ложных срабатываний)? **Если расхождение есть** — автоматически 1 |

#### T1-anti-overthinking рубрика (0-9)

| Критерий | Баллы | Описание |
|----------|-------|----------|
| `guard_triggered` | 0-2 | Anti-Overthinking Guard сработал при phase_turns > 3 без фиксации? 0=не сработал, 1=частично (заметил, но не предложил фиксацию), 2=полностью (заметил + предложил зафиксировать) |
| `phase_limit_respected` | 0-2 | Phase Limit соблюдён? При preferred_depth: standard — лимит 5 вопросов. 0=превышен без фиксации, 1=превышен но с фиксацией после, 2=соблюдён или достигнут с фиксацией |
| `express_mode_works` | 0-2 | Команда `экспресс` переключает preferred_depth? 0=не работает, 1=частично (переключил, но не адаптировал вопросы), 2=полностью (переключил + вопросы стали компактнее). **Если тест не про express** — автоматически 2 |
| `contains_expected` | 0-1 | Содержит ожидаемые ключевые слова (зафиксировать, лимит, экспресс, phase_turns)? |
| `no_forbidden` | 0-1 | Нет запрещённых паттернов (игнорирование лимита, продолжение вопросов без фиксации при guard, автопереключение режима без согласия PM)? |
| `fixation_offered` | 0-1 | Copilot предлагает зафиксировать результат при срабатывании guard? |

#### T1-learning-loop рубрика (0-9)

| Критерий | Баллы | Описание |
|----------|-------|----------|
| `learning_card_created` | 0-2 | Learning Card формируется при завершении post-launch? 0=нет, 1=частично (текст без записи в ProductState), 2=полностью (текст + запись в product_memory.learning_cards[]) |
| `bridge_triggered` | 0-2 | При переходе learning → generation — Copilot переносит уроки в контекст генерации? 0=нет, 1=упомянуто но не конкретно, 2=конкретно (what_worked, what_failed, key_learning) |
| `auto_suggest_from_memory` | 0-2 | При начале новой цели/гипотезы — Copilot проверяет learned_patterns и learning_cards? 0=нет, 1=частично (только past_hypotheses), 2=полностью (learned_patterns + learning_cards) |
| `contains_expected` | 0-1 | Содержит ожидаемые ключевые слова (уроки, Learning Card, learning_cards, прошлый опыт, зрелый продукт)? |
| `no_forbidden` | 0-1 | Нет запрещённых паттернов (автопереход learning→generation без подтверждения PM, игнорирование learning_cards при bridge)? |
| `cycle_count_correct` | 0-1 | learning_cycle_count инкрементируется при завершении цикла goal→...→learning? **Если не применяется** — автоматически 1 |

#### T1-insight рубрика (0-9)

| Критерий | Баллы | Описание |
|----------|-------|----------|
| `insight_buffer_used` | 0-2 | Copilot использует инсайты из `insights[]` при генерации/формулировке цели? 0=нет, 1=упомянуто но не конкретно, 2=конкретно (предлагает идеи на основе инсайтов) |
| `insight_command_works` | 0-2 | Команда `инсайт [текст]` создаёт запись в `insights[]` с обязательными полями (id, text, source, date, status)? 0=не работает, 1=частично (нет source/status), 2=полностью |
| `insight_to_goal` | 0-2 | Команда `инсайт → цель` превращает инсайт в цель корректно (linked_goal_id заполнен, status = converted, stage = goal)? 0=не работает, 1=частично, 2=полностью. **Если тест не про конвертацию** — автоматически 2 |
| `prioritization_triggered` | 0-1 | При ≥3 инсайтах — Copilot предлагает приоритизировать? **Если <3 инсайтов** — автоматически 1 |
| `contains_expected` | 0-1 | Содержит ожидаемые ключевые слова (инсайт, Insight Buffer, влияние, царь-метрик, приоритет)? |
| `no_forbidden` | 0-1 | Нет запрещённых паттернов (автоконвертация инсайта без подтверждения PM, потеря инсайта при переходе)? |
| `decision_linkage` | 0-1 | При принятии решения — Copilot проверяет связь с инсайтом? **Если не применяется** — автоматически 1 |

#### T1-launch-readiness рубрика (0-9)

| Критерий | Баллы | Описание |
|----------|-------|----------|
| `checklist_auto_run` | 0-2 | При попытке перехода comms → launch — Readiness Checklist запускается автоматически? 0=не запускается, 1=запускается но неполный, 2=полный чеклист из 5 пунктов |
| `score_calculated` | 0-2 | Readiness Score корректно рассчитан (выполненные/5 × 100%)? 0=не рассчитан, 1=рассчитан но неточен, 2=точный расчёт |
| `go_nogo_frame` | 0-2 | Go/No-Go Frame предложен при readiness ≥ 80%? 0=не предложен, 1=предложен но без TIB-интеграции, 2=полный с TIB-интеграцией и условным Go |
| `snapshot_created` | 0-1 | Pre-launch Snapshot сохранён при подтверждении запуска? |
| `contains_expected` | 0-1 | Содержит ожидаемые ключевые слова (готовность, readiness, Go/No-Go, launch, snapshot)? |
| `no_forbidden` | 0-1 | Нет запрещённых паттернов (блокировка запуска при readiness < 80%, автопереход без подтверждения PM, отсутствие snapshot при Go)? |

---

### T2 -- Кросс-скилл рубрики

#### T2-routing рубрика (0-9)

| Критерий | Баллы | Описание |
|----------|-------|----------|
| `route_correct` | 0-2 | Выбран правильный путь? 0=неверный, 1=предложен альтернативный, 2=точно |
| `tiebreaker_logic` | 0-2 | При конфликте ключевых слов -- контекст решает? 0=нет, 1=частично, 2=да. **Если конфликта нет** -- автоматически 2 (нет необходимости в tiebreaker) |
| `context_used` | 0-2 | Использован ли контекст профиля/домена для роутинга? 0=нет, 1=частично, 2=да |
| `contains_expected` | 0-1 | Содержит ожидаемые ключевые слова? |
| `no_forbidden` | 0-1 | Нет ли запрещённых паттернов? |
| `ambiguity_resolved` | 0-1 | Разрешена ли неоднозначность? **Если неоднозначности нет** -- автоматически 1 |

#### T2-handoff рубрика (0-9)

| Критерий | Баллы | Описание |
|----------|-------|----------|
| `context_transferred` | 0-2 | Ключевой контекст передан между путями? 0=нет, 1=частично, 2=полный |
| `format_compliance` | 0-2 | Формат handoff соответствует спецификации фасада? 0=нет, 1=частично, 2=да |
| `no_data_loss` | 0-1 | Нет ли потери данных при передаче? |
| `contains_expected` | 0-1 | Содержит ожидаемые ключевые слова? |
| `no_forbidden` | 0-1 | Нет ли запрещённых паттернов? |
| `seamless_continuation` | 0-2 | Принимающий скилл подхватывает без повторных вопросов? 0=нет, 1=частично, 2=да |

#### T2-switching рубрика (0-9)

| Критерий | Баллы | Описание |
|----------|-------|----------|
| `switch_appropriate` | 0-2 | Переключение обосновано? 0=нет, 1=частично, 2=да |
| `anti_loop_triggered` | 0-2 | При 3+ переключениях -- Copilot вмешивается? 0=нет, 1=слабо, 2=да |
| `context_preserved` | 0-1 | Контекст не теряется при переключении? |
| `contains_expected` | 0-1 | Содержит ожидаемые ключевые слова? |
| `no_forbidden` | 0-1 | Нет ли запрещённых паттернов? |
| `user_confirmed` | 0-2 | PM подтвердил переключение? 0=нет, 1=неявно, 2=явно |

#### T2-per-project рубрика (0-9)

| Критерий | Баллы | Описание |
|----------|-------|----------|
| `overlay_correct` | 0-2 | Проектные настройки перекрывают глобальные? 0=нет, 1=частично, 2=полный overlay |
| `switch_clean` | 0-2 | При переключении проектов -- контекст обновляется полностью? 0=нет, 1=частично, 2=да |
| `contains_expected` | 0-1 | Содержит ожидаемые ключевые слова? |
| `no_forbidden` | 0-1 | Нет ли запрещённых паттернов? |
| `no_contamination` | 0-2 | Нет ли подмешивания контекста другого проекта? 0=есть, 1=минорное, 2=чисто |
| `conflict_detected` | 0-1 | При расхождении профиля и проекта -- Copilot замечает? |

#### T2-continuity рубрика (0-9)

| Критерий | Баллы | Описание |
|----------|-------|----------|
| `persistence` | 0-2 | Контекст сохраняется в файл? 0=нет, 1=частично, 2=полный |
| `context_preserved` | 0-2 | Не теряются ли данные при операциях? 0=теряются, 1=минорно, 2=без потерь |
| `user_experience` | 0-2 | Понятен ли PM процесс сохранения/возобновления? 0=нет, 1=частично, 2=да |
| `no_data_loss` | 0-1 | Нет ли потери ответов при переключении? |
| `contains_expected` | 0-1 | Содержит ожидаемые ключевые слова? |
| `no_forbidden` | 0-1 | Нет ли запрещённых паттернов? |

---

### T3 -- Регресс-дым рубрика (0-3)

| Критерий | Баллы | Описание |
|----------|-------|----------|
| `pass_fail` | 0/1 | Основной сценарий работает? |
| `critical_check` | 0/1 | Критический критерий выполнен? |
| `no_crash` | 0/1 | Нет ли фатальных ошибок? |

Порог: **Pass** = 3/3, **Fail** = < 3/3

---

## Дефолтный профиль для тестов

```markdown
## Доменные области
- **Выбранные домены**: Кредитные карты, Ориджинейшн/Онбординг, Мобильное приложение
- **Коды доменов**: 1, 17, 21

## Продукт
- **Продукт**: Ритейл -> Кредитные карты
- **Стадия**: Growth

## Метрики
### Царь-метрика
- **Название**: Profit per card
- **Текущее**: 2,400 руб/мес
- **Целевое**: 2,800 руб/мес к Q4 2026

### Драйверные метрики
| Метрика | Текущее | Единица |
|---------|---------|---------|
| Utilization rate | 32 | % |
| Roll rate | 2.1 | % |
| Average balance | 85,000 | руб |
| Activation rate (30 дней) | 68 | % |

### Ганарды
| Ганард | Порог | Единица |
|--------|-------|---------|
| NPL | <= 4.5 | % |
| Fraud rate | <= 0.08 | % |
| NPS продукта | >= 38 | баллов |

## Команда
| Роль | Имя |
|------|-----|
| Tech Lead | Алексей |
| Data-аналитик | Марина |

## Настройки
- **Глубина проработки**: Полный
- **Формат артефактов**: Markdown
- **Sprint cadence**: 2 недели
- **Хранилище**: Обычные папки
- **Obsidian vault путь**: --

### Профиль для Obsidian-тестов

- **Хранилище**: Obsidian
- **Obsidian vault путь**: /Users/pm/MyVault
```

---

## T1 -- Per-skill тест-кейсы (57 тестов)

### T1-onboarding (5 тестов)

#### T1-onboarding-001: Онбординг с нуля

```
PM: "Привет, хочу начать пользоваться PM Copilot"
expected: Copilot начинает шаг 1 онбординга (выбор доменов)
expected_contains: ["домен", "продукт", "выбери"]
forbidden_patterns: ["ПРД", "гипотез", "цель"]
rubric: T1-onboarding
```

#### T1-onboarding-002: Несовместимые домены

```
PM: "Мои домены -- кредитные карты и зарплатные проекты"
expected: Copilot предупреждает о разных контекстах (B2C vs B2B)
expected_contains: ["разн", "контекст", "B2C", "B2B", "вниман"]
forbidden_patterns: ["ок, записал", "отличн"]
rubric: T1-onboarding
```

#### T1-onboarding-003: Обновление настроек

```
Шаг 1: PM: "Хочу обновить свои настройки -- мы сменили царь-метрику"
expected: Copilot загружает текущий профиль и предлагает обновить
expected_contains: ["настройк", "профил", "царь-метрик", "текущ"]
forbidden_patterns: ["создадим нов"]
rubric: T1-onboarding
```

#### T1-onboarding-004: Выбор Obsidian vault при онбординге

```
Шаг 1: PM проходит онбординг до Шага 4.4 (хранилище артефактов)
Шаг 2: PM: "Хочу сохранять в Obsidian vault, путь: /Users/pm/MyVault"
expected: Copilot проверяет .obsidian/ в указанном пути, создаёт структуру PM-Copilot/ (Sessions/, Artifacts/, Templates/, Archive/), подтверждает подключение
expected_contains: ["vault", "Obsidian", "PM-Copilot", "подключ", "структур"]
forbidden_patterns: ["не найден", "ошибка", "ошибк"]
rubric: T1-onboarding
```

#### T1-onboarding-005: Невалидный путь к Obsidian vault

```
Шаг 1: PM проходит онбординг до Шага 4.4 (хранилище артефактов)
Шаг 2: PM: "Obsidian vault, путь: /tmp/nonexistent-path-12345"
expected: Copilot предупреждает, что .obsidian/ не найден, предлагает проверить путь или выбрать другой
expected_contains: ["не найден", ".obsidian", "проверь", "друг"]
forbidden_patterns: ["подключ", "создан"]
rubric: T1-onboarding
```

---

### T1-goal (4 теста)

#### T1-goal-001: SMART-декомпозиция цели

```
PM: "Нужно вырастить Profit per card на 20% к концу года. Как подступиться?"
expected: Copilot начинает декомпозицию по SMART
expected_contains: ["декомпоз", "ключев", "результат", "конкретн"]
forbidden_patterns: ["ПРД", "гипотез", "сделаем"]
rubric: T1-goal
```

#### T1-goal-002: Цель без метрик

```
PM: "Хочу сделать продукт лучше"
expected: Copilot спрашивает про царь-метрику
expected_contains: ["царь-метрик", "какую метрик", "измер", "конкретн"]
forbidden_patterns: ["ок, записал", "понял, лучше"]
rubric: T1-goal
```

#### T1-goal-003: Premortem

```
Шаг 1: PM: "Цель -- увеличить Profit per card на 20% к Q4" -> Copilot декомпозирует
Шаг 2: Copilot доходит до premortem-фазы
expected_contains: ["пойти не так", "риск", "сценар", "премортем"]
expected: >=3 конкретных риска
rubric: T1-goal
```

#### T1-goal-004: Фаза 2.5 -- эпик без инициатив

```
Шаг 1: PM: "Цель -- увеличить Profit per card на 20% к Q4" -> декомпозиция
Шаг 2: PM: "Эпик "Программа лояльности" -- не могу назвать конкретные инициативы"
expected: Copilot предлагает переключение на generation (режим инициатив)
expected_contains: ["генерац", "инициатив", "иде", "Путь 2"]
rubric: T1-goal
```

---

### T1-generation (4 теста)

#### T1-generation-001: Идеи для роста метрики

```
PM: "Мне нужны идеи, как вырастить utilization rate с 32% до 40%"
expected: >=5 вариантов из разных техник (аналогия, инверсия, комбинация и т.д.)
expected_contains: ["вариант", "иде", "техник"]
forbidden_patterns: ["один вариант", "лучший вариант"]
rubric: T1-generation
```

#### T1-generation-002: Команда "ещё"

```
Шаг 1: PM: "Мне нужны идеи для роста utilization" -> Copilot даёт варианты
Шаг 2: PM: "ещё"
expected: новые варианты, без повторов уже предложенных
expected_contains: ["дополнител", "ещё", "нов"]
forbidden_patterns: [повтор предыдущих вариантов]
rubric: T1-generation
```

#### T1-generation-003: Команда "кластеры"

```
Шаг 1: PM: "Мне нужны идеи для роста utilization" -> Copilot даёт варианты
Шаг 2: PM: "кластеры"
expected: группировка вариантов по темам
expected_contains: ["кластер", "групп", "темат", "категор"]
rubric: T1-generation
```

#### T1-generation-004: Команда "выбираю"

```
Шаг 1: PM: "Мне нужны идеи для роста utilization" -> Copilot даёт варианты
Шаг 2: PM: "выбираю вариант 3"
expected: фиксация выбора + следующий шаг
expected_contains: ["выбрал", "фиксир", "следующ", "шаг"]
forbidden_patterns: ["хочешь ещё"]
rubric: T1-generation
```

---

### T1-hypothesis (4 теста)

#### T1-hypothesis-001: "Если A, то B"

```
PM: "Мне кажется, если мы добавим кэшбэк на рестораны, utilization вырастет. Что думаешь?"
expected: Copilot дополняет до полной гипотезы (если A, то B, потому что C)
expected_contains: ["гипотез", "предположени", "провер", "потому что", "почему"]
forbidden_patterns: ["ПРД", "задач", "декомпоз", "сделаем"]
rubric: T1-hypothesis
```

#### T1-hypothesis-002: Дизайн эксперимента

```
Шаг 1: PM: "Если добавим кэшбэк на рестораны, utilization вырастет" -> формулировка
Шаг 2: Copilot переходит к дизайну эксперимента
expected_contains: ["эксперимент", "измер", "тест", "A/B", "контрольн", "пилот"]
expected: измеримый эксперимент с критериями успеха
rubric: T1-hypothesis
```

#### T1-hypothesis-003: Вероятностная оценка

```
Шаг 1: PM формулирует гипотезу -> Шаг 2: Дизайн эксперимента
Шаг 3: Copilot переходит к вероятностной оценке
expected_contains: ["вероятн", "сценар", "исход", "ожидаем", "худш"]
expected: >=3 исхода с вероятностями
rubric: T1-hypothesis
```

#### T1-hypothesis-004: Решение -- Copilot не решает за PM

```
PM: "Ну что, делаем кэшбэк на рестораны?"
expected: Copilot не даёт готовый ответ, а предлагает обоснование
expected_contains: ["зависит", "если", "с другой стороны", "какой вариант ближе", "решен"]
forbidden_patterns: ["да, делаем", "рекомендую сделать", "правильный ответ"]
rubric: T1-hypothesis
```

---

### T1-task (4 теста)

#### T1-task-001: Декомпозиция задачи

```
PM: "Хочу упростить заявку на кредитку, сейчас много шагов отваливаются"
expected: Copilot декомпозирует задачу на подзадачи
expected_contains: ["ценность", "эффект", "метрик", "конверс", "шаг"]
forbidden_patterns: ["гипотез", "предположени", "валидир"]
rubric: T1-task
```

#### T1-task-002: Ценность -> царь-метрика

```
PM: "Хочу увеличить approval rate по кредиткам с 35% до 50%"
expected: Copilot спрашивает про ганарды и связывает с царь-метрикой
expected_contains: ["ганард", "NPL", "риск", "Profit per card", "царь-метрик", "не должен ухудшить"]
rubric: T1-task
```

#### T1-task-003: ПРД-формат

```
Шаг 1: PM проходит через вопросы -> Шаг 2: Copilot генерирует ПРД
expected: все секции ПРД на месте, нет пустых [УТОЧНИТЬ]
expected_contains: ["назначен", "контекст", "User Stor", "метрик", "риск"]
forbidden_patterns: ["[УТОЧНИТЬ]", "[ЗАПОЛНИТЬ]"]
rubric: T1-task
```

#### T1-task-004: Риски -- премортем

```
Шаг 1: PM проходит через вопросы -> Шаг 2: Фаза рисков
expected: Copilot проводит премортем через thinking-in-bets
expected_contains: ["пойти не так", "риск", "премортем", "сценар"]
rubric: T1-task
```

---

### T1-comms (3 теста)

#### T1-comms-001: PBR-бриф

```
PM: "ПРД готов, мне нужен бриф для команды на PBR"
expected: PBR-бриф <= 2 страницы, технический язык, User Stories формат
expected_contains: ["PBR", "бриф", "User Stor", "технич"]
forbidden_patterns: ["бриф длиннее 2 страниц", "копия секций ПРД без переработки"]
rubric: T1-comms
```

#### T1-comms-002: Executive summary

```
PM: "Подготовь экзекьютив саммари для руководства по нашему ПРД"
expected: есть секция Ask, адаптирован для C-level/PO
expected_contains: ["executive", "саммари", "Ask", "нужно от", "решени"]
forbidden_patterns: ["User Stori", "критери приёмк"]
rubric: T1-comms
```

#### T1-comms-003: Бриф != копия ПРД

```
PM: "Подготовь бриф для PBR из этого ПРД" + (ПРД на 5 страниц)
expected: бриф -- переработанный контент, не копия ПРД
expected_contains: ["переработ", "сжат", "ключев"]
forbidden_patterns: [бриф = копия секций ПРД без переработки]
rubric: T1-comms
```

---

### T1-post-launch (3 теста)

#### T1-post-launch-001: Scorecard

```
PM: "Фича запущена, надо оценить результаты"
expected: Copilot начинает с ПРД как baseline, метрики до/после
expected_contains: ["scorecard", "baseline", "до/после", "метрик", "ПРД"]
forbidden_patterns: ["гипотез", "новая задача"]
rubric: T1-post-launch
```

#### T1-post-launch-002: 3-осевая оценка

```
Шаг 1: PM начинает оценку -> Шаг 2: Copilot проводит 3-осевую оценку
expected: оценка по 3 осям (метрики, сроки, обучение)
expected_contains: ["метрик", "срок", "обучен", "ось", "3 ос"]
rubric: T1-post-launch
```

#### T1-post-launch-003: Решение scale/pivot/kill

```
Шаг 1-2: Оценка -> Шаг 3: Copilot формулирует решение
expected: решение (scale/pivot/kill) с обоснованием
expected_contains: ["масштабир", "pivot", "kill", "решен", "обоснован"]
forbidden_patterns: ["ок, записал", "сделаем"]
rubric: T1-post-launch
```

---

### T1-domain (3 теста)

#### T1-domain-001: Фокус на доменах PM

```
profile: домены = [1, 17, 21] (кредитные карты, ориджинейшн, мобильное приложение)
PM: "Расскажи, какие метрики типичны для моего продукта"
expected_contains: ["utilization", "roll rate", "profit per card", "KYC", "MAU"]
forbidden_patterns: ["AUM", "эквайринг", "GPV", "SME", "ипотек", "NPS работодател"]
rubric: T1-domain
```

#### T1-domain-002: CVM-домен без redemption

```
profile: домены = [18, 19] (CVM, Энгейджмент)
PM: "Какие метрики драйверные для меня?"
expected_contains: ["LTV", "share of wallet", "NBA", "retention", "penetration"]
forbidden_patterns: ["NPL", "roll rate", "utilization", "скоринг", "redemption"]
rubric: T1-domain
```

#### T1-domain-003: Кэширование домена

```
Шаг 1: PM: "Покажи метрики для кредитных карт" -> Copilot загружает домен
Шаг 2: PM: "Ещё раз покажи метрики для кредитных карт"
expected: Copilot проверяет кэш и не перезагружает домен
expected_contains: ["уже загруж", "кэш", "ранее"]
rubric: T1-domain
```

---

### T1-thinking-in-bets (2 теста)

#### T1-thinking-in-bets-001: 4 сценария

```
PM: "Давай проведём вероятностный анализ задачи по упрощению заявки"
expected: >=4 сценария (лучший, ожидаемый, худший, чёрный лебедь) с вероятностями
expected_contains: ["сценар", "вероятн", "лучш", "ожидаем", "худш", "лебедь"]
rubric: T1-thinking-in-bets
```

#### T1-thinking-in-bets-002: Премортем

```
PM: "Проведи премортем: задача запущена, но провалилась. Что пошло не так?"
expected: >=3 конкретных причины неудачи
expected_contains: ["пошло не так", "причин", "премортем", "конкретн"]
forbidden_patterns: ["не знаю", "сложно сказать"]
rubric: T1-thinking-in-bets
```

### T1-tib-auto (3 теста)

#### T1-tib-auto-001: Быстрый режим при низком confidence

```
Контекст: ProductState с decisions[] содержащим Decision с confidence=0.55, царь-метрика не затронута
Шаг 1: PM фиксирует решение (confidence: 0.55)
expected: Copilot предлагает быстрый вероятностный анализ (2 сценария: ожидаемый + худший)
expected_contains: ["уверенн", "низк", "вероятностн", "анализ", "сценар", "ожидаем", "худш"]
forbidden_patterns: ["премортем", "четыре сценар", "лебедь", "групповая валидац"]
rubric: T1-tib-auto
```

#### T1-tib-auto-002: Полный режим при затрагивании царь-метрики

```
Контекст: ProductState с царь-метрикой Profit per card, PM фиксирует решение затрагивающее Profit per card
Шаг 1: PM фиксирует решение (затрагивает царь-метрику)
expected: Copilot предлагает полный TIB анализ (4 сценария + премортем + EV)
expected_contains: ["царь-метрик", "сценар", "премортем", "ожидаем", "ценн", "лучш", "худш"]
forbidden_patterns: ["быстрый режим", "2 сценар"]
rubric: T1-tib-auto
```

#### T1-tib-auto-003: Использование цепочки решений в TIB

```
Контекст: ProductState с decisions[] содержащим цепочку: hypothesis Decision (confidence: 0.7) → goal Decision (confidence: 0.65) → текущий task Decision (confidence: 0.55)
Шаг 1: PM фиксирует task Decision (confidence: 0.55)
expected: TIB показывает цепочку решений и предупреждает о падающей уверенности
expected_contains: ["цепочк", "решен", "уверенн", "падает", "снижает", "гипотез", "цель"]
forbidden_patterns: ["автозапуск", "без подтвержд"]
rubric: T1-tib-auto
```

---

### T1-session-resume (3 теста)

#### T1-session-resume-001: Команда «продолжить» с непустым last_context

```
Контекст: ProductState с last_context = {skill: hypothesis, phase: "Фаза 2: Дизайн эксперимента", last_question: "Какой самый быстрый и дешёвый способ проверить эту гипотезу?", timestamp: "2026-05-11T14:30:00"}
Шаг 1: PM: "продолжить"
expected: Copilot показывает контекст прошлого взаимодействия (skill, phase, last_question) и предлагает возобновить
expected_contains: ["гипотез", "Фаза 2", "эксперимент", "быстрый", "дешёвый", "проверить", "продолж"]
forbidden_patterns: ["не найден", "пустой", "начать сначала"]
rubric: T1-session-resume
```

#### T1-session-resume-002: Автопредложение при старте сессии

```
Контекст: Повторная сессия, ProductState с непустым last_context
Шаг 1: PM начинает новую сессию, Copilot загружает ProductState
expected: Copilot показывает автопредложение «В прошлый раз мы работали над...» с last_context данными
expected_contains: ["прошлый раз", "работали", "продолжить", "фаз"]
forbidden_patterns: ["начнём сначала", "новая сессия"]
rubric: T1-session-resume
```

#### T1-session-resume-003: «продолжить» с пустым last_context

```
Контекст: Новый ProductState, last_context пустой
Шаг 1: PM: "продолжить"
expected: Copilot показывает текущий ProductState и предлагает начать работу (нет прошлого контекста для возобновления)
expected_contains: ["нет прошлого", "пуст", "начать", "ProductState", "этап"]
forbidden_patterns: ["В прошлый раз", "работали над"]
rubric: T1-session-resume
```

---

### T1-reflection (3 теста)

#### T1-reflection-001: Reflection checkpoint между Фазами в hypothesis

```
Контекст: PM прошёл Фазу 1 (Формулировка гипотезы) в hypothesis, отвечает на Вопрос 4
Шаг 1: PM: "Может ли это быть просто корреляцией, а не причинно-следственной связью? Допускаю, что может"
expected: Copilot переходит к reflection checkpoint перед Фазой 2, задаёт 1-2 reflection-вопроса (проверяемость гипотезы, непроверенные допущения)
expected_contains: ["reflection", "допущен", "провер", "цель", "гипотез"]
forbidden_patterns: ["обязательн", "должны ответить", "аудит"]
rubric: T1-reflection
```

#### T1-reflection-002: PM пропускает reflection

```
Контекст: Reflection checkpoint сработал, Copilot задал reflection-вопрос
Шаг 1: PM: "пропустить" / "продолжим без остановки"
expected: Copilot принимает пропуск и продолжает работу без давления
expected_contains: ["продолж", "понял", "ок"]
forbidden_patterns: ["обязательн", "надо ответить", "рекомендуем", "не пропуст"]
rubric: T1-reflection
```

#### T1-reflection-003: Reflection использует Decision Linking

```
Контекст: ProductState с decisions[] содержащим цепочку решений с непроверенными assumptions. PM на Фазе 2 в goal (перед Фазой 3)
Шаг 1: Copilot достигает reflection checkpoint
expected: Reflection-вопрос упоминает непроверенные допущения из цепочки решений
expected_contains: ["непроверен", "допущен", "цепочк", "решен"]
forbidden_patterns: ["аудит", "ошибк", "провал"]
rubric: T1-reflection
```

---

### T1-obsidian (4 теста)

#### T1-obsidian-001: YAML frontmatter в артефакте

```
profile: хранилище = Obsidian, vault = /Users/pm/MyVault
Шаг 1: PM проходит путь задачи до генерации ПРД
Шаг 2: Copilot сохраняет ПРД в Obsidian-режиме
expected: артефакт содержит YAML frontmatter с полями type, status, created, updated, project, tsar-metric, tags
expected_contains: ["type:", "status:", "created:", "updated:", "project:", "tsar-metric:", "tags:", "pm-copilot", "prd"]
forbidden_patterns: ["[УТОЧНИТЬ]", "отсутствует frontmatter"]
rubric: T1-obsidian
```

#### T1-obsidian-002: Wiki-links между артефактами

```
profile: хранилище = Obsidian
Шаг 1: PM прошёл гипотезу -> задача -> ПРД (несколько связанных артефактов)
Шаг 2: Copilot сохраняет ПРД с wiki-links на связанные артефакты
expected: ПРД содержит [[wiki-links]] на карточку гипотезы и цель; карточка гипотезы содержит ссылку на ПРД
expected_contains: ["[[Гипотез", "[[Цел", "wiki-links", "связ"]
forbidden_patterns: ["нет связей", "ссылки отсутствуют"]
rubric: T1-obsidian
```

#### T1-obsidian-003: Dataview-запросы

```
profile: хранилище = Obsidian
PM: "dataview"
expected: Copilot показывает список из 5 Dataview-запросов (active-sessions, prd-by-project, hypothesis-pipeline, stale-sessions, project-dashboard) с описаниями
expected_contains: ["active-sessions", "prd-by-project", "hypothesis-pipeline", "stale-sessions", "project-dashboard", "Dataview"]
forbidden_patterns: ["не поддерж", "нет запросов"]
rubric: T1-obsidian
```

#### T1-obsidian-004: Шаблоны Obsidian + Templater

```
profile: хранилище = Obsidian
PM: "Создай шаблон ПРД для новых задач"
expected: Copilot создаёт шаблон prd-template.md в [vault]/PM-Copilot/Templates/ с YAML frontmatter и Templater-переменными (<% tp.date %>, <% tp.file.title %>)
expected_contains: ["prd-template", "tp.date", "tp.file.title", "Назначен", "User Stor", "Метрик", "Риск"]
forbidden_patterns: ["без шаблон", "не поддерж"]
rubric: T1-obsidian
```

---

### T1-state (4 теста)

#### T1-state-001: Создание ProductState при старте

```
profile: новый PM, нет активного ProductState
PM: "давай стартуем, хочу проработать задачу по упрощению заявки на кредитку"
expected: Copilot создаёт ProductState с id, stage=task, problem="упрощение заявки на кредитку", history=[{from: insight, to: task}]
expected_contains: ["ProductState", "stage", "task", "заявк", "history"]
forbidden_patterns: ["нет состояния", "не поддерж"]
rubric: T1-state
```

#### T1-state-002: Команда `state` -- просмотр ProductState

```
Шаг 1: PM начинает сессию -> ProductState создан
Шаг 2: PM: "state"
expected: Copilot показывает ProductState в читаемом формате: id, stage, problem, hypotheses, goals, active_prd, metrics, risks, history
expected_contains: ["ProductState", "stage", "problem", "metrics", "history", "id"]
forbidden_patterns: ["нет состояния", "ошибка", "не найден"]
rubric: T1-state
```

#### T1-state-003: Обновление ProductState при переходе stage

```
Шаг 1: PM начинает по пути 1 (гипотеза) -> ProductState.stage = hypothesis
Шаг 2: PM: "переключись на путь 3"
expected: ProductState.stage обновляется на task, добавляется запись в history: {from: hypothesis, to: task, trigger: "user_command"}
expected_contains: ["task", "history", "переключ", "stage"]
forbidden_patterns: ["stage не обновлён", "потеря данных"]
rubric: T1-state
```

#### T1-state-004: Сохранение ProductState при команде `итого`

```
Шаг 1: PM проходит путь до конца -> Шаг 2: PM: "итого"
expected: Copilot показывает сводку и сохраняет ProductState (обновляет updated timestamp)
expected_contains: ["ProductState", "сохран", "сводк", "updated"]
forbidden_patterns: ["не сохран", "потеря"]
rubric: T1-state
```

---

### T1-stage (5 тестов) — Stage Detection

#### T1-stage-001: Определение stage по ProductState

```
profile: PM с активным ProductState (hypotheses: [{text: "кэшбэк", status: "draft"}], goals: [], active_prd: null)
PM: "хочу продолжить работу"
expected: Copilot определяет stage=hypothesis по ProductState и показывает 📍 Этап: hypothesis | Следующий: goal
expected_contains: ["Этап", "hypothesis", "Следующий", "goal", "📍"]
forbidden_patterns: ["insight", "task", "не определён"]
rubric: T1-stage
```

#### T1-stage-002: Отображение этапа при каждом ответе

```
Шаг 1: PM начинает сессию (path 3, задача) -> ProductState.stage = task
Шаг 2: PM задаёт вопрос по задаче
expected: Copilot отвечает на вопрос И показывает 📍 Этап: task | Следующий: comms
expected_contains: ["📍", "Этап", "task", "Следующ", "comms"]
forbidden_patterns: ["без указания этапа"]
rubric: T1-stage
```

#### T1-stage-003: Предложение перехода (hypothesis → goal)

```
Шаг 1: PM валидировал гипотезу (hypotheses[0].status = validated)
expected: Copilot предлагает переход 📍 Переход: hypothesis → goal с обоснованием
expected_contains: ["Переход", "hypothesis", "goal", "Обоснован", "Перейти"]
forbidden_patterns: ["автоматически перешёл", "переключён без подтверждения"]
rubric: T1-stage
```

#### T1-stage-004: Обратный переход (goal → hypothesis)

```
Шаг 1: ProductState.stage = goal, hypotheses = [{status: validated}]
Шаг 2: PM: "переключись на hypothesis"
expected: Copilot переключает stage на hypothesis, добавляет запись в history с trigger=back_transition, НЕ удаляет данные goals
expected_contains: ["hypothesis", "back_transition", "history", "goal"]
forbidden_patterns: ["удалён", "потеря", "очищен"]
rubric: T1-stage
```

#### T1-stage-005: Анти-цикл при частых переключениях

```
Шаг 1: PM переключается 4-й раз за сессию (stage_transitions_count = 4)
expected: Copilot мягко подсвечивает паттерн частых переключений
expected_contains: ["переключ", "несколько раз", "зафиксир", "этап"]
forbidden_patterns: ["запрещ", "не могу", "блокир"]
rubric: T1-stage
```

---

### T1-decision (12 тестов) — Decision Log + Decision Linking

#### T1-decision-001: Формат Decision при записи

```
Шаг 1: PM валидировал гипотезу -> Copilot предлагает записать решение
Шаг 2: PM: "да, запиши"
expected: Decision содержит id, timestamp, stage=hypothesis, decision, rationale, confidence, status=open, actual_outcome=null
expected_contains: ["Decision", "решен", "rationale", "confidence", "stage", "open"]
forbidden_patterns: ["actual_outcome: не null", "reviewed"]
rubric: T1-decision
```

#### T1-decision-002: Команда `решения`

```
Шаг 1: PM имеет 2+ решений в ProductState.decisions[]
Шаг 2: PM: "решения"
expected: Copilot показывает таблицу всех решений (decision, stage, confidence, status, дата), итоговую строку "Всего: N | Открытых: M | Проверенных: K"
expected_contains: ["решен", "Decision", "stage", "confidence", "Всего", "Открыт"]
forbidden_patterns: ["нет решений", "ошибка"]
rubric: T1-decision
```

#### T1-decision-003: Команда `ревизия`

```
Шаг 1: ProductState.decisions[] содержит 2 решения: одно open, одно reviewed
Шаг 2: PM: "ревизия"
expected: Copilot показывает только open-решение (без actual_outcome), не показывает reviewed
expected_contains: ["ревиз", "open", "допущен", "ожидаем"]
forbidden_patterns: ["reviewed", "actual_outcome: не null"]
rubric: T1-decision
```

#### T1-decision-004: Copilot предлагает записать, не записывает молча

```
Шаг 1: PM выбирает ключевые результаты в goal-пути
expected: Copilot спрашивает "Записать это решение?" (да/нет), НЕ записывает без подтверждения
expected_contains: ["Записать", "решен", "да/нет"]
forbidden_patterns: ["автоматически записал", "решение зафиксировано без запроса"]
rubric: T1-decision
```

#### T1-decision-005: hypothesis — запись при validate/invalidate

```
Шаг 1: PM формулирует гипотезу -> Copilot проводит эксперимент
Шаг 2: PM: "Результаты: конверсия выросла с 5% до 6.2%, NPL не изменился. Гипотеза подтверждена"
expected: Copilot предлагает записать решение в Decision Log с полями decision, rationale, confidence, alternatives
expected_contains: ["Записать", "Decision Log", "решен", "уверенн", "альтернатив"]
forbidden_patterns: ["автоматически записал", "без подтверждения"]
rubric: T1-decision
```

#### T1-decision-006: goal — запись при выборе KR и эпиков

```
Шаг 1: PM формулирует цель -> Copilot проводит декомпозицию
Шаг 2: PM: "Выбираю KR1 Retention 78%, KR2 Cross-sell 1.8, KR3 Frequency 15/мес с этими эпиками"
expected: Copilot предлагает записать выбор KR/эпиков в Decision Log с rationale и alternatives
expected_contains: ["Записать", "KR", "эпик", "Decision Log", "почему", "альтернатив"]
forbidden_patterns: ["автоматически записал"]
rubric: T1-decision
```

#### T1-decision-007: task — запись при фиксации ценности/эффекта

```
Шаг 1: PM описывает задачу -> Copilot проводит анализ ценности
Шаг 2: PM: "Ценность: конверсия +15%. Эффект на царь-метрику: Profit per card +8%"
expected: Copilot предлагает записать фиксацию ценности в Decision Log с assumptions и expected_outcome
expected_contains: ["Записать", "ценност", "эффект", "Decision Log", "допущени", "ожидаем"]
forbidden_patterns: ["автоматически записал"]
rubric: T1-decision
```

#### T1-decision-008: post-launch — заполнение actual_outcome

```
Шаг 1: PM начинает оценку результатов -> Copilot проводит 3-осевую оценку
Шаг 2: Copilot находит open-решение в Decision Log и предлагает заполнить actual_outcome
expected: Copilot сопоставляет прошлые решения с результатами, предлагает заполнить actual_outcome, обновляет статус на reviewed
expected_contains: ["actual_outcome", "заполнить", "решен", "reviewed", "результат"]
forbidden_patterns: ["actual_outcome заполняется в hypothesis", "actual_outcome заполняется в goal"]
rubric: T1-decision
```

#### T1-decision-009: post-launch — новый Decision при scale/pivot/kill

```
Шаг 1: PM оценивает результаты -> Шаг 2: Принимает решение (масштабировать/итерировать/пересмотреть/откатить)
expected: Copilot создаёт НОВЫЙ Decision со stage=post-launch, decision=решение по итогам, rationale=из оценки, status=open
expected_contains: ["Записать", "Decision Log", "масштабир", "решен", "post-launch", "обоснован"]
forbidden_patterns: ["actual_outcome" заполняется здесь для нового Decision"]
rubric: T1-decision
```

### T1-decision-linking (3 теста) — Decision Linking: related_decisions и supersedes

> **v4.08**: Decisions — больше не плоский список. Каждый Decision связан с предыдущим через `related_decisions`, образуя направленный граф.

#### T1-decision-linking-001: hypothesis — related_decisions = [] (начало цепочки)

```
Шаг 1: ProductState: stage=hypothesis, decisions[] непуст (есть прошлый Decision от другого продукта или пуст)
Шаг 2: PM валидирует гипотезу -> Copilot предлагает записать решение
expected: Новый Decision содержит related_decisions = [], supersedes = null
expected_contains: ["related_decisions", "[]", "supersedes", "null", "начало цепочки"]
forbidden_patterns: ["related_decisions: [decision-"]
rubric: T1-decision
```

#### T1-decision-linking-002: goal — related_decisions = [ID от hypothesis Decision]

```
Шаг 1: ProductState: stage=goal, decisions[] содержит Decision с stage=hypothesis (id=decision-2026-05-11-1430)
Шаг 2: PM фиксирует KR и эпики -> Copilot предлагает записать решение
expected: Новый Decision содержит related_decisions = [decision-2026-05-11-1430], supersedes = null
expected_contains: ["related_decisions", "decision-2026-05-11-1430", "supersedes", "null", "гипотез"]
forbidden_patterns: ["related_decisions: []"]
rubric: T1-decision
```

#### T1-decision-linking-003: Команда `цепочка [decision-id]` — показывает полную цепочку решений

```
Шаг 1: ProductState содержит 4 Decision: hypothesis (related=[]), goal (related=[hypothesis]), task (related=[goal]), post-launch (related=[task])
Шаг 2: PM: "цепочка decision-2026-05-11-1700"
expected: Copilot показывает цепочку из 4 решений: hypothesis -> goal -> task -> post-launch, с confidence и status каждого
expected_contains: ["цепочка", "hypothesis", "goal", "task", "post-launch", "confidence", "reviewed|open"]
forbidden_patterns: ["плоский список", "без связей"]
rubric: T1-decision
```

---

### T1-autopilot (4 теста) — Autopilot Suggestions

#### T1-autopilot-001: Подсказка при validated гипотезе

```
Шаг 1: ProductState: stage=hypothesis, hypotheses[].status=validated
Шаг 2: PM: "Что дальше?"
expected: Copilot показывает 📌 Следующий шаг: Декомпозировать цель? + альтернатива
expected_contains: ["Следующий шаг", "цель", "декомпоз", "Или"]
forbidden_patterns: ["автоматически переключ", "перехожу на"]
rubric: T1-autopilot
```

#### T1-autopilot-002: Подсказка при готовом ПРД

```
Шаг 1: ProductState: stage=task, active_prd.status=ready
Шаг 2: PM: "ПРД готов, что теперь?"
expected: Copilot показывает 📌 Следующий шаг: Подготовить бриф для PBR? + альтернатива
expected_contains: ["Следующий шаг", "бриф", "PBR", "Или"]
forbidden_patterns: ["автоматически переключ"]
rubric: T1-autopilot
```

#### T1-autopilot-003: Нет подсказки при autopilot: off

```
Шаг 1: Профиль PM: autopilot=off
Шаг 2: PM: "Гипотеза подтверждена"
expected: NO 📌 Следующий шаг блок — подсказки отключены
forbidden_patterns: ["📌 Следующий шаг", "Следующий шаг"]
rubric: T1-autopilot
```

#### T1-autopilot-004: Команда `что дальше?` при autopilot: off

```
Шаг 1: Профиль PM: autopilot=off
Шаг 2: ProductState: stage=hypothesis, hypotheses[].status=validated
Шаг 3: PM: "что дальше?"
expected: Copilot показывает рекомендацию следующего шага, несмотря на autopilot: off
expected_contains: ["Следующий шаг", "цель", "декомпоз"]
rubric: T1-autopilot
```

---

### T1-memory (4 теста)

#### T1-memory-001: Адаптация вопросов на основе risk_tolerance

```
Шаг 1: Профиль PM: risk_tolerance=low, typical_biases=[]
Шаг 2: PM: "Мне кажется, если мы добавим кэшбэк на рестораны, utilization вырастет"
expected: Copilot задаёт дополнительные вопросы про ганарды и риски (адаптация на основе low risk_tolerance)
expected_contains: ["ганард", "риск", "что может пойти не так", "запасн"]
forbidden_patterns: ["ок, давайте", "отличн", "сделаем"]
rubric: T1-memory
```

#### T1-memory-002: Команда `стиль` — показать стиль решений

```
Шаг 1: Профиль PM: risk_tolerance=medium, decision_speed=deliberate, preferred_depth=deep, typical_biases=[], decisions_analysed=3
Шаг 2: PM: "стиль"
expected: Copilot показывает текущий стиль решений с параметрами и предлагает обновить
expected_contains: ["стиль", "risk_tolerance", "decision_speed", "preferred_depth", "решений"]
rubric: T1-memory
```

#### T1-memory-003: Автоанализ при 5+ решениях

```
Шаг 1: Профиль PM: decisions_analysed=5, risk_tolerance=medium
Шаг 2: Decision Log содержит 5 решений с confidence: [0.3, 0.4, 0.35, 0.45, 0.3]
Шаг 3: PM фиксирует очередное решение
expected: Copilot предлагает обновить стиль решений на основе анализа (большинство confidence < 0.5 → риск-толерантность low)
expected_contains: ["стиль", "проанализировал", "паттерн", "обновить", "risk_tolerance"]
forbidden_patterns: ["автоматически обновл"]
rubric: T1-memory
```

#### T1-memory-004: Адаптация в post-launch при typical_biases

```
Шаг 1: Профиль PM: typical_biases=[confirmation_bias], risk_tolerance=low
Шаг 2: PM: "Результаты хорошие, давайте масштабируем" (при частичном достижении метрик)
expected: Copilot подсвечивает подтверждение-искажение: предлагает отдельно выпишить данные, которые НЕ подтверждают успех, перед масштабированием
expected_contains: ["подтвержда", "не подтвержда", "противореч", "данн"]
forbidden_patterns: ["ок, масштабируем", "отличн", "давайте"]
rubric: T1-memory
```

---

### T1-product-memory (4 теста)

#### T1-product-memory-001: Проверка на повторы при формулировке гипотезы

```
Шаг 1: product_memory.past_hypotheses содержит: {id: h1, text: "Кэшбэк на рестораны увеличивает utilization", outcome: invalidated, key_learning: "Эффект слабее ожидаемого, NPL не вырос"}
Шаг 2: PM: "Мне кажется, если мы добавим кэшбэк на рестораны, utilization вырастет"
expected: Copilot подсвечивает повтор: «Похожая гипотеза уже была... Результат: invalidated. В чём отличие?»
expected_contains: ["похож", "была", " invalidated", "отлич"]
forbidden_patterns: ["нельзя", "запрещ", "не рекомендую"]
rubric: T1-product-memory
```

#### T1-product-memory-002: Команда `история` — показать Product Memory

```
Шаг 1: product_memory содержит: past_hypotheses[2], past_launches[1], learned_patterns[1]
Шаг 2: PM: "история"
expected: Copilot показывает сводку Product Memory с количеством гипотез, запусков и паттернов
expected_contains: ["история", "гипотез", "запуск", "паттерн"]
rubric: T1-product-memory
```

#### T1-product-memory-003: Запись past_launches при завершении post-launch

```
Шаг 1: PM завершил оценку, принято решение "масштабировать"
Шаг 2: Copilot формирует карточку обучения
expected: Copilot добавляет запись в product_memory.past_launches[] с result=scaled, key_metric_change и key_learning
expected_contains: ["past_launches", "scaled", "key_learning", "metric_change"]
forbidden_patterns: ["без подтверждения"]
rubric: T1-product-memory
```

#### T1-product-memory-004: Выявление learned_patterns

```
Шаг 1: product_memory.past_launches содержит 2 запуска с похожим результатом (упрощение флоу → рост конверсии без роста NPL)
Шаг 2: PM завершил третий запуск с аналогичным результатом
expected: Copilot предлагает записать паттерн с подтверждением PM
expected_contains: ["паттерн", "записать", "подтвержд"]
forbidden_patterns: ["автоматически записал"]
rubric: T1-product-memory
```

### T1-router-guard (3 теста)

#### T1-router-guard-001: Расхождение last_context и rule_stage — Copilot предлагает выбор

```
precondition: ProductState.last_context = { skill: "hypothesis", phase: "Фаза 2: Дизайн эксперимента", ... }, но ProductState.goals[] содержит status: active, ProductState.hypotheses[] пуст → rule_stage = goal
Шаг 1: PM: "Хочу продолжить работу"
expected: Router Guard обнаруживает расхождение (last_context.skill = hypothesis, rule_stage = goal), предлагает PM выбор: переключиться на goal или остаться на hypothesis
expected_contains: ["переключ", "остаться", "цель", "гипотез"]
forbidden_patterns: ["автоматически переключ"]
rubric: T1-router-guard
```

#### T1-router-guard-002: PM подтверждает переключение — stage обновляется

```
precondition: Router Guard обнаружил расхождение (last_context.skill = hypothesis, rule_stage = goal)
Шаг 1: PM: "Да, переключаемся на цель"
expected: Copilot обновляет stage на goal, активирует pm-copilot-goal, добавляет запись в history с trigger: router_guard
expected_contains: ["цель", "goal", "перешл"]
forbidden_patterns: ["гипотез"]
rubric: T1-router-guard
```

#### T1-router-guard-003: Нет расхождения — Router Guard не срабатывает

```
precondition: ProductState.last_context = { skill: "goal", phase: "Фаза 2: Декомпозиция", ... }, ProductState.gools[] содержит status: active → rule_stage = goal. Расхождения нет.
Шаг 1: PM: "Продолжим декомпозицию"
expected: Copilot продолжает работу в goal без Router Guard-вопроса, обычный ответ pm-copilot-goal
expected_contains: ["декомпози", "цель"]
forbidden_patterns: ["переключ", "расхожден", "router guard"]
rubric: T1-router-guard
```

### T1-anti-overthinking (3 теста)

#### T1-anti-overthinking-001: Anti-Overthinking Guard срабатывает при >3 вопросов без фиксации

```
precondition: ProductState.stage = goal, preferred_depth = standard, phase_turns = 4 (Copilot задал 4 вопроса без обновления полей ProductState)
Шаг 1: PM: "Не знаю, надо подумать"
expected: Anti-Overthinking Guard срабатывает — Copilot предлагает зафиксировать текущий результат и двигаться дальше
expected_contains: ["зафиксир", "двигаться", "обсудили"]
forbidden_patterns: ["ещё вопрос"]
rubric: T1-anti-overthinking
```

#### T1-anti-overthinking-002: Express Mode — компактные вопросы

```
precondition: ProductState.stage = hypothesis, preferred_depth = standard
Шаг 1: PM: "экспресс"
expected: Copilot переключает preferred_depth на express, подтверждает переключение, следующие вопросы становятся компактнее (1-2 ключевых вопроса вместо 3-5)
expected_contains: ["экспресс", "компактн", "ключев"]
forbidden_patterns: ["глубок", "полный"]
rubric: T1-anti-overthinking
```

#### T1-anti-overthinking-003: Phase Limit — фиксация при достижении лимита

```
precondition: ProductState.stage = goal, preferred_depth = standard, phase_turns = 5 (достигнут лимит стандартного режима)
Шаг 1: PM отвечает на 5-й вопрос
expected: Copilot фиксирует текущий результат и предлагает переход, НЕ задаёт ещё один зондирующий вопрос без фиксации
expected_contains: ["зафиксир", "перейти", "следующ"]
forbidden_patterns: ["как насчёт", "что вы думаете", "расскажите подробнее"]
rubric: T1-anti-overthinking
```

---

## T2 -- Кросс-скилл тест-кейсы (16 тестов)

### T2-routing (5 тестов)

#### T2-routing-001: Чёткий роутинг -- гипотеза

```
PM: "Мне кажется, если мы добавим кэшбэк на рестораны, utilization вырастет"
expected: path=2 (гипотеза)
expected_contains: ["гипотез", "провер", "предположени"]
rubric: T2-routing
```

#### T2-routing-002: Чёткий роутинг -- цель

```
PM: "Нужно увеличить Profit per card на 20% к Q4"
expected: path=1 (цель)
expected_contains: ["цель", "декомпоз", "дорожн"]
rubric: T2-routing
```

#### T2-routing-003: Чёткий роутинг -- задача

```
PM: "Хочу упростить заявку на кредитку, много отваливаются на середине"
expected: path=3 (задача)
expected_contains: ["ценность", "эффект", "ПРД"]
rubric: T2-routing
```

#### T2-routing-004: Конфликт ключевых слов

```
PM: "У меня гипотеза, что если упростить заявку, конверсия вырастет -- нужно это проработать как задачу"
expected: Copilot разрешает конфликт (гипотеза + задача), уточняет у PM приоритет
expected_contains: ["гипотез", "задач", "какой путь", "выбер"]
rubric: T2-routing
```

#### T2-routing-005: Доменный контекст влияет на роутинг

```
profile: домены = [1, 17] (кредитные карты, ориджинейшн)
PM: "Нужно проработать процесс онбординга"
expected: Copilot учитывает доменный контекст и роутит на цель/задачу (не генерацию)
expected_contains: ["ориждинейшн", "онбординг", "домен"]
rubric: T2-routing
```

---

### T2-handoff (4 теста)

#### T2-handoff-001: Гипотеза -> Задача

```
Шаг 1: PM проходит гипотезу (кэшбэк рестораны) -> validated
Шаг 2: PM: "Ок, давай теперь проработаем как задачу"
expected: Copilot передаёт контекст гипотезы в задачу (текст гипотезы, метрики, эксперимент)
expected_contains: ["кэшбэк", "ресторан", "utilization", "гипотез", "задач"]
rubric: T2-handoff
```

#### T2-handoff-002: Цель -> Генерация

```
Шаг 1: PM: "Цель -- увеличить Profit per card на 20%" -> декомпозиция
Шаг 2: PM: "Эпик "Программа лояльности" -- нужны идеи"
expected: Copilot переключается на generation, передавая контекст эпика и цели
expected_contains: ["Программа лояльности", "Profit per card", "генерац", "иде"]
rubric: T2-handoff
```

#### T2-handoff-003: Задача -> Коммуникации

```
Шаг 1: PM проходит задачу до готового ПРД
Шаг 2: PM: "Подготовь бриф для PBR"
expected: Copilot переключается на comms, передавая контекст ПРД
expected_contains: ["ПРД", "бриф", "PBR", "User Stor"]
rubric: T2-handoff
```

#### T2-handoff-004: Obsidian-режим при handoff

```
profile: хранилище = Obsidian
Шаг 1: PM проходит гипотезу -> validated -> handoff на задачу
expected: При handoff в Obsidian-режиме -- wiki-links между артефактами сохраняются, новый артефакт получает frontmatter
expected_contains: ["wiki-links", "frontmatter", "[[Гипотез"]
rubric: T2-handoff
```

---

### T2-switching (2 теста)

#### T2-switching-001: Обоснованное переключение

```
Шаг 1: PM работает по пути 3 (задача)
Шаг 2: PM: "Стоп, это скорее гипотеза, мы ещё не проверили, что это нужно"
expected: Copilot соглашается и предлагает переключение на путь 1, сохраняя контекст
expected_contains: ["гипотез", "переключ", "провер", "контекст"]
rubric: T2-switching
```

#### T2-switching-002: Anti-loop при 3+ переключениях

```
Шаг 1: PM начинает путь 1 -> переключается на 3 -> переключается на 2 -> пытается ещё раз
expected: Copilot замечает множественные переключения и предлагает остановиться
expected_contains: ["переключ", "несколько раз", "определить", "останов"]
rubric: T2-switching
```

---

### T2-per-project (2 теста)

#### T2-per-project-001: Проектные настройки перекрывают глобальные

```
profile: домены = [1, 17], царь-метрика = Profit per card
project-overlay: домены = [18, 19], царь-метрика = LTV
PM: "Хочу проработать задачу в рамках проекта CVM"
expected: Copilot использует проектные настройки (CVM-домены, LTV), не глобальные
expected_contains: ["CVM", "LTV", "share of wallet"]
rubric: T2-per-project
```

#### T2-per-project-002: Переключение проектов -- чистый контекст

```
Шаг 1: PM работает с проектом A (кредитные карты, Profit per card)
Шаг 2: PM: "Переключись на проект B (CVM, LTV)"
expected: Copilot переключает контекст полностью, без подмешивания метрик/доменов проекта A
expected_contains: ["LTV", "CVM"]
forbidden_patterns: ["Profit per card", "utilization", "roll rate"]
rubric: T2-per-project
```

---

### T2-continuity (2 теста)

#### T2-continuity-001: Сохранение и возобновление сессии

```
Шаг 1: PM работает по пути 3 -> собирает ответы
Шаг 2: PM: "итого" -> Copilot сохраняет артефакт
Шаг 3: PM (новая сессия): "Продолжим с того места, где остановились"
expected: Copilot загружает ProductState и продолжает без повторных вопросов
expected_contains: ["продолж", "ранее", "ProductState"]
rubric: T2-continuity
```

#### T2-continuity-002: Переключение без потери данных

```
Шаг 1: PM работает по пути 1 (гипотеза) -> собраны данные
Шаг 2: PM: "переключись на путь 3"
expected: Данные гипотезы сохраняются в ProductState, не теряются
expected_contains: ["гипотез", "сохран", "ProductState"]
rubric: T2-continuity
```

---

## T3 -- Регресс-дым тест-кейсы (9 тестов)

### T3-smoke-routing

```
PM: "Хочу проверить гипотезу про кэшбэк"
expected: path=2, Copilot начинает валидацию
pass: роутинг работает
critical: выбран правильный путь
```

### T3-smoke-onboarding

```
PM: "Хочу настроить PM Copilot"
expected: Copilot начинает онбординг (шаг 1)
pass: онбординг запускается
critical: первый шаг начинается корректно
```

### T3-smoke-goal

```
PM: "Цель -- увеличить Profit per card на 20%"
expected: Copilot начинает декомпозицию
pass: цель принимается
critical: SMART-вопросы задаются
```

### T3-smoke-generation

```
PM: "Мне нужны идеи для роста utilization"
expected: Copilot генерирует >=3 варианта
pass: идеи генерируются
critical: разные техники используются
```

### T3-smoke-hypothesis

```
PM: "Мне кажется, кэшбэк на рестораны вырастит utilization"
expected: Copilot дополняет до гипотезы
pass: гипотеза формулируется
critical: "если A, то B" структура
```

### T3-smoke-task

```
PM: "Хочу упростить заявку на кредитку"
expected: Copilot начинает проработку задачи
pass: задача принимается
critical: спрашивает про ценность/эффект
```

### T3-smoke-comms

```
PM: "ПРД готов, нужен бриф для PBR"
expected: Copilot генерирует PBR-бриф
pass: бриф генерируется
critical: не копия ПРД
```

### T3-smoke-post-launch

```
PM: "Фича запущена, оцени результаты"
expected: Copilot начинает оценку
pass: оценка начинается
critical: ПРД как baseline
```

### T3-smoke-domain

```
PM: "Покажи метрики для кредитных карт"
expected: Copilot загружает домен и показывает релевантные метрики
pass: домен загружается
critical: метрики в рамках домена PM
```

### T3-smoke-obsidian

```
profile: хранилище = Obsidian
PM: "vault"
expected: Copilot показывает статус Obsidian-подключения
pass: команда vault работает
critical: путь к vault отображается
```


---

## T1-learning-loop тест-кейсы (3 шт)

### T1-learning-loop-001: Learning Card создаётся при завершении post-launch

**Рубрика**: T1-learning-loop

**Контекст**: ProductState с stage = post-launch, past_launches содержит 1 запуск с result: iterated, decisions[] содержит 1 decision с actual_outcome. PM завершил Шаг 4 (решение: итерировать) и переходит к Шагу 5.

**Шаг 1**:
PM: "давай подведём итоги"
expected: Copilot начинает Шаг 5 (обучение), задаёт 5 вопросов retrospective
pass: Copilot формирует Learning Card с what_worked, what_failed, key_learning

**Шаг 2**:
PM: "Сработало упрощение заявки, не сработали push-уведомления, ключевой урок - упрощение флоу важнее механик вовлечения"
expected: Copilot формирует Learning Card, записывает в product_memory.learning_cards[], инкрементирует learning_cycle_count, предлагает переход learning -> generation
pass: Learning Card записана в ProductState, learning_cycle_count = 1, предложен переход

**Запрещённые паттерны**: Learning Card без записи в ProductState, автопереход learning -> generation без подтверждения PM

---

### T1-learning-loop-002: Learning -> Generation Bridge переносит уроки

**Рубрика**: T1-learning-loop

**Контекст**: ProductState с stage = learning, product_memory.learning_cards[] содержит 1 карточку (what_worked: "упрощение флоу", what_failed: "push-уведомления", key_learning: "упрощение эффективнее вовлечения"), learning_cycle_count = 1.

**Шаг 1**:
PM: "хочу сгенерировать новые идеи с учётом опыта"
expected: Copilot подтверждает переход learning -> generation, передаёт контекст из Learning Loop Bridge (what_worked, what_failed, key_learning, learned_patterns), загружает generation sub-skill
pass: Bridge сработал, уроки перенесены в контекст генерации, PM подтвердил переход

**Шаг 2** (generation Фаза 0):
expected: Copilot показывает топ-3 урока из Learning Card, спрашивает какие учесть при генерации
pass: Фаза 0 pre-check сработала, PM предложен выбор (все / выборочно / пропустить)

**Запрещённые паттерны**: Переход без переноса уроков, автопереход без подтверждения PM, генерация без Фазы 0 pre-check

---

### T1-learning-loop-003: Команда `уроки` и зрелый продукт

**Рубрика**: T1-learning-loop

**Контекст**: ProductState с stage = goal (новая сессия), product_memory.learning_cards[] содержит 3 карточки, learned_patterns[] содержит 2 паттерна с confidence >= 0.5, learning_cycle_count = 3 (зрелый продукт).

**Шаг 1**:
PM: "уроки"
expected: Copilot показывает все Learning Cards, выявленные паттерны, счётчик циклов, пометку "зрелый продукт"
pass: Команда уроки работает, shows learning_cards + learned_patterns + cycle count + зрелый продукт

**Шаг 2**:
PM: "хочу поставить новую цель - увеличить retention D30"
expected: Copilot начинает работу с целью, но предлагает учесть прошлый опыт (auto-suggest из learned_patterns и learning_cards), адаптирует вопросы для зрелого продукта (фокус на масштабирование и оптимизацию)
pass: Auto-suggest из memory сработал, вопросы адаптированы для зрелого продукта

**Запрещённые паттерны**: Игнорирование learned_patterns/learning_cards при auto-suggest, вопросы как для начального этапа при learning_cycle_count >= 3
