# PM Copilot

Интеллектуальный напарник продакт-менеджера в банке.  
Работает внутри Claude Code — помогает на каждом этапе: от сырой идеи до валидированного ПРД и коммуникаций.

**Что умеет:**
- Из инсайта или проблемы → к обоснованной цели и гипотезам
- Из гипотез → к готовому ПРД с метриками, рисками и гардами
- Из ПРД → к коммуникациям для команды и C-level
- Помнит контекст между сессиями — не переспрашивает одно и то же

**Версия:** v4.18 (Sprint 26)

---

## Требования

- [Claude Code](https://claude.ai/code)

---

## Установка

```bash
curl -fsSL https://raw.githubusercontent.com/dewbbk/pm-copilot/main/install.sh | bash
```

Скрипт скачает скиллы и установит их в `~/.claude/skills/`.

---

## Обновление

Та же команда — скрипт сам подтянет изменения:

```bash
curl -fsSL https://raw.githubusercontent.com/dewbbk/pm-copilot/main/install.sh | bash
```

---

## Запуск

В Claude Code напиши:

```
/pm-copilot
```

При первом запуске пройдёт онбординг (3-4 вопроса о твоём продукте).

---

## Roadmap

См. [docs/pm-copilot-backlog.md](docs/pm-copilot-backlog.md)
