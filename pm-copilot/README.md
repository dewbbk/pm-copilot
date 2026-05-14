# PM Copilot — Помощник продакт-менеджера в банке

Интеллектуальный напарник PM на каждом этапе работы — от сырой идеи до валидированного ПРД.

Помогает:
- Из инсайта или проблемы → к обоснованной цели и гипотезам
- Из гипотез → к готовому ПРД с метриками, рисками и ганардами
- Из ПРД → к коммуникациям для команды и C-level
- Помнит контекст между сессиями — не переспрашивает одно и то же

---

## Что нужно для работы

- Claude Code (claude.ai/code) или совместимый клиент с поддержкой skills
- Версия PM Copilot: v4.22

---

## Установка

**1. Скачать архив** последней версии (или получить от автора)

**2. Скопировать папки в `~/.claude/skills/`:**

```bash
cp -r pm-copilot ~/.claude/skills/
cp -r pm-copilot-comms ~/.claude/skills/
cp -r pm-copilot-generation ~/.claude/skills/
cp -r pm-copilot-goal ~/.claude/skills/
cp -r pm-copilot-hypothesis ~/.claude/skills/
cp -r pm-copilot-onboarding ~/.claude/skills/
cp -r pm-copilot-post-launch ~/.claude/skills/
cp -r pm-copilot-task ~/.claude/skills/
cp -r pm-copilot-thinking-in-bets ~/.claude/skills/
```

**3. Перезапустить Claude Code** (или начать новую сессию)

---

## Первый запуск

Напиши в чат Claude любое из:

```
/pm-copilot
```

или просто опиши свою ситуацию:

```
Хочу проработать задачу по [тема]
У меня есть инсайт из аналитики: [текст]
Нужно декомпозировать цель на квартал
```

PM Copilot подхватит и запустит онбординг при первом использовании.

---

## Структура

```
pm-copilot/                ← фасад (оркестратор, запускается первым)
  SKILL.md
  references/              ← общий контекст: метрики, домен, схемы
    product-state.md
    decision-log.md
    domain-context.md
    metrics.md
    thinking-in-bets.md

pm-copilot-onboarding/     ← настройка профиля PM
pm-copilot-goal/           ← Путь 1: декомпозиция цели
pm-copilot-hypothesis/     ← Путь 2: валидация гипотез
pm-copilot-task/           ← Путь 3: проработка задачи → ПРД
pm-copilot-comms/          ← коммуникации из ПРД (PBR Brief, Executive Summary)
pm-copilot-generation/     ← генерация идей
pm-copilot-post-launch/    ← пост-запуск и оценка результатов
pm-copilot-thinking-in-bets/ ← вероятностное мышление (TIB)
```

---

## Версии

- **v4.22** (Sprint 29) — Memory UX: Quick Capture (4 команды, Context Drop) + Archive Search (авто-поиск, `поиск [текст]`)
- **v4.21** (Sprint 28) — Collaboration Lite: Review Request, Feedback Integration
- **v4.20** (Sprint 27) — Multi-Initiative Support: параллельные инициативы, Shared Product Memory
- **v4.18** (Sprint 26) — Launch Readiness: чеклист готовности к запуску, Go/No-Go frame

---

## Вопросы и поддержка

Автор: [имя / контакт]
