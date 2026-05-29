# Obsidian Vault — Настройка интеграции

> Если PM использует Obsidian для управления знаниями — артефакты Copilot сохраняются прямо в vault с frontmatter, тегами и wiki-links.

## Подключение

1. Запроси путь к vault: «Укажи путь к твоему Obsidian vault (папка с файлом `.obsidian/`):»
2. Проверь наличие `.obsidian/` в указанном пути
3. Если не найден: «В указанной папке не найдена конфигурация Obsidian. Уверен, что это vault? Можем создать структуру — или выбери другую папку.»
4. Создай структуру внутри vault: `PM-Copilot/` → `Sessions/`, `Artifacts/`, `Templates/`, `Archive/`
5. Подтверди: «Vault подключён. Артефакты будут сохраняться в [путь]/PM-Copilot/.»

## Пути сохранения

- Профиль: `[vault]/PM-Copilot/profile.md`
- Инициативы: `[vault]/PM-Copilot/state/[initiative-id].md`
- Общая память: `[vault]/PM-Copilot/shared-[product_id].md`
