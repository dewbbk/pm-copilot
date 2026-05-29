---
name: pm-copilot-tests
description: "QA-сьют для PM Copilot v7.0 (Memory Refactor). Запускается pm-copilot-dev после каждого спринта. Содержит 15 бинарных тест-кейсов трёх категорий: R (Routing, 6), F (Files, 5), H (Handoff, 4). Проверяет корректность роутинга и файловых операций. Версия: v7.0."
---

# PM Copilot — QA Suite (pm-copilot-tests)

> **Роль**: QA-инструмент для pm-copilot-dev. Не входит в runtime-пайплайн.
> **Принцип**: Тест = файловое состояние + сообщение PM + бинарный критерий Pass/Fail.
> **Что проверяем**: роутинг, CRUD файлов, хендоф между скиллами.

---

## Механика прогона

### Как запускать

1. Определить, какие файлы изменились в спринте
2. По Coverage Matrix выбрать релевантные тесты
3. Для каждого теста: подготовить файлы, подставить pm_message, получить ответ
4. Проверить pass_condition — да/нет
5. Сформировать отчёт

### Команды

- `тест полный` → все 15 тестов (~8 мин)
- `тест дым` → R-001, R-002, F-001, F-003, H-001 (5 тестов, ~3 мин)
- `проверь routing` → только R-тесты (6 тестов)
- `проверь files` → только F-тесты (5 тестов)
- `проверь handoff` → только H-тесты (4 теста)
- `прогони тест [ID]` → один конкретный тест

---

## Coverage Matrix

При изменении файла → запускать следующие тесты:

- `pm-copilot/SKILL.md` (facade/роутер) → R-001..R-006, H-001..H-004
- `pm-copilot/references/product-state.md` → F-001..F-005, H-001..H-004
- `pm-copilot-onboarding/SKILL.md` → R-001, F-001
- `pm-copilot-goal/SKILL.md` → R-003, F-002, H-001
- `pm-copilot-epic/SKILL.md` → R-004, F-003, H-003
- `pm-copilot-hypothesis/SKILL.md` → R-005, F-002, H-002
- `pm-copilot-task/SKILL.md` → R-004, F-004, H-003
- `pm-copilot-comms/SKILL.md` → R-006, F-005, H-004
- `pm-copilot-post-launch/SKILL.md` → R-006, F-004
- `pm-copilot-thinking-in-bets/SKILL.md` → H-003

---

## R — Routing Tests (6)

Проверяют: правильный ли sub-skill активируется при данных файлах.

### R-001: Нет профиля → onboarding

```
Состояние: ~/pm-copilot/ не существует
PM говорит: "Привет"
pass_condition: Активирован pm-copilot-onboarding, предложен онбординг
```

### R-002: Есть профиль, нет целей → goal

```
Состояние: ~/pm-copilot/profile.md существует, goals/ пустая
PM говорит: "Хочу заняться LTV"
pass_condition: Активирован pm-copilot-goal, предложено создать цель
```

### R-003: Goal с status=draft → goal

```
Состояние:
  goals/ltv-growth-q4.md: frontmatter {status: draft}
PM говорит: "Надо доработать цель"
pass_condition: Активирован pm-copilot-goal, загружен goal file
```

### R-004: Epic active, есть draft story → task

```
Состояние:
  goals/ltv-growth-q4.md: frontmatter {status: active, epics: [{id: onboarding, status: active}]}
  epics/onboarding.md: frontmatter {status: active, stories: [{id: s1, status: draft}]}
PM говорит: "Давай проработаем первую стори"
pass_condition: Активирован pm-copilot-task, загружен epic file
```

### R-005: Hypotheses непуст → hypothesis

```
Состояние:
  goals/ltv-growth-q4.md: frontmatter {status: active, hypotheses: [{id: h1, text: "...", status: draft}]}
  epics/ — пустая
PM говорит: "/гипотеза"
pass_condition: Активирован pm-copilot-hypothesis, короткий путь
```

### R-006: Story prd_approved → comms

```
Состояние:
  epics/onboarding.md: frontmatter {stories: [{id: s1, status: prd_approved}]}
PM говорит: "Что дальше?"
pass_condition: Предложен переход к comms, активирован pm-copilot-comms
```

---

## F — File Tests (5)

Проверяют: правильно ли создаются и обновляются файлы.

### F-001: Onboarding создаёт profile.md

```
Действие: Пройти онбординг (mock-ответы PM)
pass_condition:
  - Файл ~/pm-copilot/profile.md создан
  - Frontmatter содержит: product.slug, metrics.tsar, settings.depth
  - Body содержит секции: Продукт, Метрики, Команда
  - Директории goals/ и epics/ созданы
```

### F-002: Goal skill создаёт goal file

```
Действие: Создать цель "LTV +20% к Q4"
pass_condition:
  - Файл ~/pm-copilot/goals/[slug].md создан
  - Frontmatter: id, title, status=draft, tsar_metric, deadline
  - Body: заголовок, контекст, пустые секции эпиков/гипотез
  - Slug человекочитаемый (не initiative-YYYY-MM-DD)
```

### F-003: Epic skill создаёт epic file + обновляет goal

```
Действие: Создать эпик "Онбординг" в рамках цели
pass_condition:
  - Файл ~/pm-copilot/epics/[slug].md создан
  - Frontmatter: id, goal_id, title, status=planned, stories=[]
  - Body: контекст с wiki-link на goal
  - В goal file: epics[] обновлён (добавлен {id, title, status})
```

### F-004: Task skill обновляет story в epic file

```
Действие: Проработать стори s1, зафиксировать ценность
pass_condition:
  - В epic file frontmatter: stories[0].status = in_progress
  - В epic file frontmatter: stories[0].value заполнен
  - В epic file body: секция стори обновлена
```

### F-005: Frontmatter и body синхронизированы

```
Действие: Обновить статус стори на prd_approved
pass_condition:
  - Frontmatter: stories[0].status = prd_approved
  - Body: статус стори обновлён (✅ ПРД утверждён)
  - Поле updated обновлено
```

---

## H — Handoff Tests (4)

Проверяют: передаётся ли контекст между скиллами.

### H-001: Goal → Epic хендоф

```
Действие: Завершить goal skill, перейти к epic
pass_condition:
  - Царь-метрика из profile.md передана в epic skill
  - Goal slug передан для связи (goal_id в epic file)
  - ПРД не создаётся (это этап декомпозиции)
```

### H-002: Hypothesis → Task хендоф

```
Действие: Валидировать гипотезу h1, перейти к task
pass_condition:
  - Статус гипотезы обновлён в goal file (h1.status = validated)
  - Текст гипотезы доступен в task skill
  - Царь-метрика из profile.md передана
```

### H-003: Task → TIB при low confidence

```
Действие: PM говорит confidence = 0.4 при фиксации ценности
pass_condition:
  - Copilot предлагает вероятностный анализ (thinking-in-bets)
  - TIB не пишет в файлы — только помогает оценить
  - После TIB — возврат к task skill
```

### H-004: Comms → артефакт

```
Действие: Подготовить коммуникации для prd_approved стори
pass_condition:
  - Epic file прочитан (story + value + effect)
  - Артефакт коммуникации создан
  - Epic file не изменён (comms не пишет в state)
```

---

## Отчёт о прогоне

```
QA Suite v7.0 — Результаты
Дата: [дата]

R (Routing): X/6 passed
  R-001: PASS/FAIL
  R-002: PASS/FAIL
  ...

F (Files): X/5 passed
  F-001: PASS/FAIL
  ...

H (Handoff): X/4 passed
  H-001: PASS/FAIL
  ...

Итого: X/15 passed
```
