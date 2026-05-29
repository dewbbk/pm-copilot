# Схема файлов состояния pm-copilot

> Single source of truth. Тесты и скиллы ссылаются на этот файл.
> Версия: v7.0 (Memory Refactor)

## Принципы

1. **Только текущий стейт** — нет истории, нет лога решений, нет архива
2. **1 цель = 1 файл, 1 эпик = 1 файл** — файл = единица навигации
3. **MD + YAML frontmatter** — LLM парсит frontmatter, PM читает body
4. **Обе части синхронизированы** — при обновлении меняются frontmatter и body

## Структура директории

```
~/pm-copilot/
  profile.md                                ← профиль PM
  goals/
    [slug].md                               ← файл цели
  epics/
    [slug].md                               ← файл эпика
```

---

## Profile — profile.md

### Frontmatter-поля

```yaml
version: "2.0"
updated: YYYY-MM-DD
product:
  direction: string          # Ритейл / МСБ / КБ / Private / Диджитал
  name: string               # название продукта
  stage: string              # Launch / Growth / Maturity / Turnaround
  slug: string               # короткий идентификатор (dc-ntb, cc-origination)
metrics:
  tsar: {name: string, current: string, target: string}
  drivers:
    - {name: string, current: string}
  guards:
    - {name: string, threshold: string}
team:
  - {role: string, name: string}
process:
  cap_process: string        # название процесса в CAP
settings:
  depth: string              # express / standard / deep
  format: string             # obsidian / markdown / confluence / jira
  sprint_cadence: string     # 2 недели / 1 неделя
  storage_path: string       # путь к хранилищу артефактов
  autopilot: boolean         # on / off
decision_style:
  risk_tolerance: string     # low / medium / high
  typical_biases: []         # автоматически выявленные
```

### Body-шаблон

```markdown
# PM Profile

## Продукт
[direction] → [name] ([stage])

## Метрики
- **Царь-метрика**: [name] = [current] → [target]
- **Драйверные**: [список]
- **Ганарды**: [список]

## Команда
- [role]: [name]
```

---

## Goal — goals/[slug].md

### Frontmatter-поля

```yaml
id: string                   # slug (совпадает с именем файла без .md)
title: string                # название цели
status: string               # draft / active / completed / archived
tsar_metric: string          # привязка к царь-метрике
current: string              # текущее значение
target: string               # целевое значение
deadline: date               # срок
ambition: string             # амбиция (x% к Y дате)
epics:
  - {id: string, title: string, status: string}
hypotheses:
  - {id: string, text: string, status: string}
created: date
updated: date
```

### Body-шаблон

```markdown
# [title]

## Контекст
[problem / обоснование цели]

## Эпики
- [[epic-slug|Название]] — статус
- ...

## Гипотезы
- [статус] id: текст
```

### Статусы goal

- `draft` — цель сформулирована, но не утверждена
- `active` — цель утверждена, работа идёт
- `completed` — цель достигнута
- `archived` — цель отменена/отложена

---

## Epic — epics/[slug].md

### Frontmatter-поля

```yaml
id: string                   # slug (совпадает с именем файла без .md)
goal_id: string              # ссылка на goal (FK)
title: string                # название эпика
status: string               # planned / active / completed
stories:
  - id: string
    title: string
    status: string            # draft / in_progress / prd_approved / done
    value: string             # ценность стори (влияние на метрику)
    effect: string            # что конкретно делаем
    prd_path: string          # путь к файлу ПРД (пустая строка если нет)
insights:
  - string                    # текст инсайта
updated: date
```

### Body-шаблон

```markdown
# [title]

## Контекст
Эпик в рамках цели [[goal-slug|Название цели]].

## Стори
- **id** title — статус, ценность: value

## Зависимости
- [зависимости эпика]
```

### Статусы epic

- `planned` — эпик запланирован, но не начат
- `active` — эпик в работе
- `completed` — все стори эпика выполнены

### Статусы story

- `draft` — стори сформулирована, но не проработана
- `in_progress` — идёт проработка (вопросы, анализ)
- `prd_approved` — ПРД готов и утверждён
- `done` — реализовано, запущено

---

## Правила обновления файлов

### Принцип dual-write

При каждом изменении обновляются **обе части** файла:

1. **Frontmatter** — структурированные данные (статусы, массивы, ссылки). LLM читает/пишет через парсинг YAML.
2. **Body** — человекочитаемый Markdown. Синхронизирован с frontmatter. Содержит wiki-links для Obsidian.

### Slug-генерация

ИД файлов (slug) генерируется из названия:
- Транслитерация + kebab-case: «Улучшение онбординга» → `onboarding-activation`
- PM подтверждает slug при создании
- Slug уникален в рамках типа (goals/ и epics/ — разные пространства)

### Обновление статусов

При изменении статуса goal/epic/story:
1. Обновить frontmatter (статус + updated)
2. Обновить body (статус в списке)
3. Если epic создан/удалён → обновить epics[] в goal file
4. Если story создана/удалена → обновить stories[] в epic file

---

## Router — определение текущего этапа

Определяется по файлам и статусам (не по отдельному полю stage):

```
1. Нет ~/pm-copilot/profile.md → onboarding
2. Есть profile, нет файлов в goals/ → goal (создать)
3. Goal с status=draft → goal (доработать)
4. Goal active, есть эпики → epic (выбрать/создать)
5. Epic active, есть draft/in_progress story → task (проработать)
6. Story с status=prd_approved → comms (подготовить)
7. Все stories done → следующий epic или новая цель
```

---

## Связь со скиллами

| Скилл | Читает | Пишет |
|-------|--------|-------|
| **facade** | profile.md, glob goals/*.md | — |
| **onboarding** | — | profile.md |
| **goal** | profile.md | goals/[slug].md |
| **epic** | goals/[slug].md | epics/[slug].md, обновляет epics[] в goal |
| **hypothesis** | goals/[slug].md | hypotheses[] в goal file |
| **task** | epics/[slug].md, profile.md | stories[] в epic file |
| **comms** | epics/[slug].md | артефакт по story.prd_path |
| **post-launch** | epics/[slug].md | stories[].status в epic file |
| **generation** | profile.md | — (инструмент) |
| **thinking-in-bets** | — | — (фреймворк, не пишет) |
