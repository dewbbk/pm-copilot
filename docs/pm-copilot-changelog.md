# PM Copilot — Changelog

> История версий и выполненных работ.

---

## v7.0 — Memory Refactor (2026-05-29)

**Что сделали:**
- **Архитектура**: монолитный ProductState заменён на file-per-entity (1 цель = 1 файл, 1 эпик = 1 файл)
- **Формат**: MD + YAML frontmatter — LLM парсит frontmatter, PM читает body (Obsidian-совместимо)
- **ID**: slug-based (onboarding-activation) вместо timestamp (initiative-2026-05-11-1430)
- **Dual-write**: при обновлении меняются frontmatter и body одновременно
- **Router**: определение этапа по файлам и статусам, не по отдельному полю stage
- **Удалено**: Decision Log, History, Archive, Product Memory, Compaction, timestamp IDs, 4-слойная загрузка памяти
- **Файлы**: `~/pm-copilot/profile.md`, `goals/[slug].md`, `epics/[slug].md`
- **Тесты**: переписаны под новую архитектуру (15 тестов: R6 + F5 + H4)

**Изменённые файлы:** pm-copilot/SKILL.md, pm-copilot-onboarding/SKILL.md, pm-copilot-goal/SKILL.md, pm-copilot-epic/SKILL.md, pm-copilot-task/SKILL.md, pm-copilot-hypothesis/SKILL.md, pm-copilot-comms/SKILL.md, pm-copilot-post-launch/SKILL.md, pm-copilot-thinking-in-bets/SKILL.md, pm-copilot-tests/SKILL.md, pm-copilot/references/product-state.md, pm-copilot-comms/references/review-request.md, pm-copilot-comms/references/feedback-integration.md, README.md, docs/pm-copilot-backlog.md, docs/pm-copilot-changelog.md

**Удалённые файлы:** pm-copilot/references/decision-log.md

---

## v6.2 — PERF Cleanup (2026-05-27)

**Что сделали:**
- **PERF-1**: Сжат metrics.md (109 → 34 строки) — убраны ASCII-таблицы и шаблоны, оставлены правила и банковские примеры
- **PERF-2**: Сокращён product-state.md (921 → 397 строк) — в Deferred: Multi-Initiative, Obsidian, Archive Search Rules (с весами), Learning Loop, Session Resume, детали Compaction Rules и Memory Layers
- Убраны команды `vault`, `dataview`, `инициативы`, `переключись`, `новая инициатива` из фасада (deferred)
- Упрощены Archive Search триггеры в goal/hypothesis/post-launch/comms (без ссылки на алгоритм с весами)

**Изменённые файлы:** pm-copilot/references/metrics.md, pm-copilot/references/product-state.md, pm-copilot/SKILL.md, pm-copilot-goal/SKILL.md, pm-copilot-hypothesis/SKILL.md, pm-copilot-post-launch/SKILL.md, pm-copilot-comms/SKILL.md, README.md

---

## v6.1 — Audit Cleanup (2026-05-24)

**Что сделали:**
- **ONBOARDING-1**: Удалён Quick Capture — 4 команды, которыми никто не пользовался. Убраны из фасада, product-state.md (схема + секция + Context Drop), онбординга
- **ONBOARDING-8**: Decision Log оставлен — core-механизм, интегрирован в 10 файлов
- **ONBOARDING-9**: Удалён Domain Context — domain-context.md (25 строк) удалён, ссылки убраны из goal, hypothesis, epic, comms, onboarding, facade
- **preferred_depth**: Упрощён с 4 уровней (express/surface/standard/deep) до 2 (quick/full). Обновлены task, goal, hypothesis, post-launch, onboarding, decision-log. Команды: `быстро` / `полностью`
- **Version bump**: все затронутые SKILL.md → v6.1

**Изменённые файлы:** pm-copilot/SKILL.md, pm-copilot-goal/SKILL.md, pm-copilot-hypothesis/SKILL.md, pm-copilot-task/SKILL.md, pm-copilot-post-launch/SKILL.md, pm-copilot-epic/SKILL.md, pm-copilot-comms/SKILL.md, pm-copilot-onboarding/SKILL.md, pm-copilot/references/product-state.md, pm-copilot/references/decision-log.md, README.md, docs/pm-copilot-backlog.md, docs/pm-copilot-changelog.md

**Удалённые файлы:** pm-copilot/references/domain-context.md

---

## v6.0 — Goal-First Architecture (2026-05-19)

**Что сделали:**
- **Архитектурный переход**: goal-first подход — цель всегда первый шаг основного пути
- **Новый слой epic**: pm-copilot-epic — контейнер юзер стори/тасок между goal и task
- **Generation как инструмент**: не stage, а callable tool из любого stage через `/идея`
- **Короткий путь**: `/гипотеза` → hypothesis → task → comms → PRD (без goal/epic)
- **path field**: `main` (основной) и `short` (короткий) в ProductState
- **Nested goals**: `goals[].epics[].tasks[]` вместо плоской структуры
- **State Machine**: 9 правил (было 10) — убраны insight, generation, learning
- **Backward compatibility**: автоколебание старых состояний при загрузке
- **Все sub-skills**: version bump v5.0/v5.2 → v6.0

**Изменённые файлы:**
- pm-copilot/SKILL.md (facade — новая state machine, activation matrix)
- pm-copilot/references/product-state.md (schema v6.0)
- pm-copilot-epic/SKILL.md (новый sub-skill)
- pm-copilot-goal/SKILL.md (handoff в epic)
- pm-copilot-hypothesis/SKILL.md (короткий путь, path: short)
- pm-copilot-generation/SKILL.md (инструмент, не stage)
- pm-copilot-task/SKILL.md (два входа: main + short)
- pm-copilot-comms/SKILL.md (version bump)
- pm-copilot-onboarding/SKILL.md (version bump)
- pm-copilot-post-launch/SKILL.md (version bump, updated cycle)
- README.md, docs/pm-copilot-backlog.md, docs/pm-copilot-changelog.md

---

## v5.2 — Product Scope (2026-05-15)

**Что сделали:**
- **product_scope** — новое поле в Working Memory: краткое описание границ продукта (загружается каждый ход, держит контекст)
- **Заполнение** — на insight stage Copilot выводит product_scope из описания проблемы PM → спрашивает подтверждение
- **Антипаттерн** — добавлена строка «Не выходить за рамки product_scope из Working Memory»
- **Version bump:** pm-copilot/SKILL.md, references/product-state.md → v5.2
- **Бэклог cleanup** — удалены 4 дубля resolved-задач (TIB-lite, Reference Dedup, Conditional Reference Loading, ProductState Compaction)

**Изменённые файлы:** pm-copilot/SKILL.md, pm-copilot/references/product-state.md, README.md, docs/pm-copilot-backlog.md, docs/pm-copilot-changelog.md

---

## v5.1 — Fix Sprint (2026-05-14)

**Что сделали:**
- **BUG-01 [HIGH]:** Rule 3 State Machine — добавлено условие `active_prd пуст`. Без этого при hypotheses[] nonempty + active_prd=draft роутинг перехватывался в goal вместо task.
- **BUG-02 [MEDIUM]:** `generation` stage добавлен в stage enum (product-state.md) и State Machine Rule 2. Ранее generation был в Activation Matrix, но отсутствовал в enum и detection rules — pm-copilot-generation никогда не активировался через роутер.
- **WARN-01:** Удалён Rule 5 (unreachable dead code — полностью покрывался Rule 4). Перенумерованы правила 1-10.
- **WARN-02:** Анти-цикл механизм — уточнена формулировка (конкретный вопрос вместо «мягко подсветить»).
- **ISSUE-01:** Reflection Checkpoints в task — исправлено описание (было «Между Фазой 3→4 и 5→6», стало «Перед Фазой 3 и перед Фазой 5»).
- **install.sh:** добавлен `rm -rf` перед `cp -r` — удалённые в репо файлы теперь корректно удаляются из installed.
- **Version bump:** references/product-state.md, references/thinking-in-bets.md — обновлены до v5.1.

**Изменённые файлы:** pm-copilot/SKILL.md, pm-copilot/references/product-state.md, pm-copilot/references/thinking-in-bets.md, pm-copilot-task/SKILL.md, install.sh, README.md, docs/pm-copilot-backlog.md, docs/pm-copilot-changelog.md

---

## v5.0 — Lean Facade (2026-05-14)

**Что сделали:**
- **Фасад обрезан**: pm-copilot/SKILL.md с 1,837 → 152 строк (-92%). Роутер + State Machine + Activation Matrix + Router Guard + команды + антипаттерны
- **Устранено дублирование**: ProductState schema, Memory Layers, Compaction, Decision Log, TIB description — убраны из фасада, SSoT остался в `references/product-state.md`
- **references/product-state.md обогащён**: добавлены Quick Capture, Autopilot, Multi-Initiative, Obsidian Integration (773 → 918 строк)
- **Workflow skills обновлены**: встроены Reflection Checkpoints (goal, hypothesis, task), обновлены ссылки на `references/product-state.md`
- **Удалён дубль**: `pm-copilot-task/references/thinking-in-bets.md` — теперь task ссылается на `pm-copilot/references/thinking-in-bets.md`
- **Frontmatter обновлён**: все SKILL.md → version v5.0 (Lean Facade)
- **Архитектура**: Lean Facade — 0 новых skills, 0 новых директорий, 0 перемещённых references. Фасад = чистый роутер

**Изменённые файлы:** pm-copilot/SKILL.md, pm-copilot/references/product-state.md, pm-copilot-goal/SKILL.md, pm-copilot-hypothesis/SKILL.md, pm-copilot-task/SKILL.md, pm-copilot-generation/SKILL.md, pm-copilot-comms/SKILL.md, pm-copilot-post-launch/SKILL.md, pm-copilot-onboarding/SKILL.md, pm-copilot-thinking-in-bets/SKILL.md, README.md

**Удалённые файлы:** pm-copilot-task/references/thinking-in-bets.md

---

## v4.23 — Facade Split: LOAD Markers (2026-05-14)

**Что сделали:**
- **LOAD-маркеры** — все секции фасада `pm-copilot/SKILL.md` размечены комментариями загрузки:
  - `<!-- LOAD: always -->` — Core (~400 строк): State Machine, Activation Matrix, Router Guard, Autopilot, Insight Management, Старт сессии, Reference Map, Orchestration Principles, Artifacts Structure, Commands Table, Anti-Patterns
  - `<!-- LOAD: workflow -->` — Workflow Reference (~350 строк): Learning Loop, Launch Readiness, Session Resume, Reflection Checkpoints, Anti-Overthinking, TIB автоподключение, Multi-Initiative Support
  - `<!-- LOAD: on-demand -->` — Domain Reference (~300 строк): PM Memory, Product Memory, Decision Log, Obsidian Integration
- **Заголовок-комментарий** — добавлен блок с описанием стратегии Facade Split и правилами загрузки
- **Coverage Matrix** — обновлена в `pm-copilot-tests`: добавлены строки для Quick Capture, Archive Search, Facade Split-маркеров; обновлены контрольные спринты

**Изменённые файлы:** pm-copilot/SKILL.md, pm-copilot-tests/SKILL.md, README.md

---

## v4.22 — Memory UX: Quick Capture + Archive Search (2026-05-14)

**Что сделали:**
- **Quick Capture** — 4 команды для мгновенной записи контекста без уточняющих вопросов: `конкурент [текст]`, `данные [текст]`, `фидбек [текст]`, `решение руководства [текст]`
- **Context Drop** — при старте сессии Copilot показывает captures, добавленные после последнего визита, с предложением учесть или отложить
- **Archive Search** — авто-поиск по archive при активации hypothesis (→ гипотезы + решения), goal (→ цели + запуски), post-launch (→ решения + запуски). Блок «Из архива» перед первым вопросом если relevance ≥ 0.4
- **Команда `поиск [текст]`** — явный поиск по всему archive + shared_memory с результатами по типам
- **Archive Search Rules** — алгоритм relevance scoring (match_stage 0.3 + match_problem 0.3 + match_text 0.4), cross-initiative поиск
- **Executive Summary** — новый раздел «Из прошлого опыта» из archive (если релевантно)
- **ProductState** — расширена schema `insights[]`: добавлены поля `capture_type` (quick/manual) и `related_prd_id`
- **Онбординг** — информационный блок про Quick Capture в Шаг 4

**Изменённые файлы:** pm-copilot/SKILL.md, pm-copilot/references/product-state.md, pm-copilot-hypothesis/SKILL.md, pm-copilot-goal/SKILL.md, pm-copilot-post-launch/SKILL.md, pm-copilot-comms/SKILL.md, pm-copilot-onboarding/SKILL.md, README.md

---

## v4.21 — Collaboration Lite (2026-05-13)

**Что сделали:**
- **Review Request** — Copilot формирует запрос ревью стейкхолдеру (Tech Lead, Аналитик, Дизайнер, C-level) с адаптированным контекстом из ПРД. Вопросы генерируются под аудиторию.
- **Feedback Integration** — при получении фидбека Copilot категоризирует замечания (риск / допущение / правка ПРД / отклонение) и структурированно интегрирует в ProductState (risks[], decisions[]).
- **ProductState** — добавлено поле `active_prd.review_requests[]` для трекинга запросов ревью.
- **Фасад** — новые команды `запросить ревью` и `интегрировать фидбек`.

**Изменённые файлы:** pm-copilot-comms/SKILL.md, pm-copilot/SKILL.md, README.md

---

## v4.20 — Multi-Initiative Support (2026-05-12)

**Что сделали:**
- Параллельные инициативы — каждая инициатива в отдельном ProductState файле
- Shared Product Memory — общая память для всех инициатив одного продукта
- Команды `инициативы`, `переключись на [номер/id]`, `новая инициатива`
- Cross-Initiative Insights — инсайты релевантные нескольким инициативам

---

## v4.18 — Launch Readiness (2026-05-xx)

**Что сделали:**
- Авточеклист готовности к запуску (5 пунктов)
- Readiness Score (0-100%)
- Go/No-Go Frame
- Pre-launch Snapshot — срез ProductState перед launch

---

## v4.17 — ProductState Lifecycle + Memory Layers (2026-05-xx)

**Что сделали:**
- ProductState разделён на 5 слоёв: Working, Initiative, Product, Archive, Company (placeholder)
- Compaction Rules — автоматическое сжатие при завершении этапов
- Команды `детали [поле]` и `компактизация`
- product_memory.summary — авто-сводка истории продукта

---

## v4.16 — Insight Management (2026-05-xx)

**Что сделали:**
- Insight Buffer — накопление инсайтов с impact_score и связями (goal/hypothesis/decision)
- Команды `инсайт [текст]`, `инсайты`, `инсайт приоритет [id]`
- Insight → Goal/Hypothesis/Decision Bridge

---

## v4.15 — Reflection Checkpoints + Learning Loop (2026-05-xx)

**Что сделали:**
- Learning Loop — замкнутый цикл: post-launch → learning → generation
- Learning Cards — карточки обучения из post-launch
- Зрелый продукт (learning_cycle_count >= 3)

---

## v4.14 — Anti-Overthinking + Phase Limits + Express Mode (2026-05-xx)

**Что сделали:**
- Phase Limits — лимиты вопросов на фазу
- Express Mode — быстрый режим для опытных PM
- Anti-Overthinking Guard — защита от затягивания

---

## v4.13 — Orchestrator Logic + State Machine Rules (2026-05-xx)

**Что сделали:**
- State Machine — явная логика переходов между stage
- Router Guard — двойная проверка роутинга
- Activation Matrix — однозначное определение активного sub-skill
- Domain consolidation — pm-copilot-domain → references

---

## v4.10 — Session Resume (2026-05-xx)

**Что сделали:**
- last_context — контекст последнего взаимодействия
- Команда `продолжить` — возобновление сессии
- Автопредложение при старте сессии

---

## v4.09 — Thinking in Bets (2026-05-xx)

**Что сделали:**
- Вероятностное мышление — quick/full режим
- TIB sub-skill с 2 сценариями
- Автоподключение при confidence < 0.7

---

## v4.08 — Decision Linking (2026-05-xx)

**Что сделали:**
- Цепочки решений — related_decisions
- Связи между гипотезами, целями и решениями

---

## v4.07 — Product Memory (2026-05-xx)

**Что сделали:**
- past_hypotheses, past_launches, learned_patterns
- Команда `история`
- Auto-suggest из Product Memory

---

## v4.06 — PM Memory (2026-05-xx)

**Что сделали:**
- DecisionStyle: risk_tolerance, decision_speed, preferred_depth, typical_biases
- Автоанализ паттернов из Decision Log
- Адаптация вопросов на основе стиля

---

## v4.05 — Autopilot Suggestions (2026-05-xx)

**Что сделали:**
- Проактивные подсказки следующего шага
- Настройка autopilot on/off

---

## v4.04 — Obsidian Integration (2026-05-xx)

**Что сделали:**
- Obsidian vault — артефакты сессии в Obsidian
- Frontmatter для Dataview-запросов
- Автосохранение ProductState в vault

---

## v4.03 — Decision Log (2026-05-xx)

**Что сделали:**
- История решений с confidence, rationale, assumptions
- Команда `решения`, `ревизия`, `цепочка`

---

## v4.02 — Stage Detection (2026-05-xx)

**Что сделали:**
- Явное определение этапа (stage)
- Отображение `📍 Этап: [stage]`

---

## v4.01 — Facade + Роутинг (2026-05-xx)

**Что сделали:**
- Единый фасад — точка входа
- Роутинг на sub-skills

---

## v4.00 — ProductState (2026-05-xx)

**Что сделали:**
- ProductState — ядро системы
- Сохранение и загрузка между сессиями
