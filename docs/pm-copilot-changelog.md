# PM Copilot — Changelog

> История версий и выполненных работ.

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
