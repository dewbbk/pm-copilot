#!/bin/bash

set -e

REPO_URL="https://github.com/dewbbk/pm-copilot.git"
INSTALL_DIR="$HOME/.claude/skills"
REPO_DIR="$HOME/pm-copilot-repo"

echo "PM Copilot — установка/обновление"
echo "=================================="

# Клонируем или обновляем репо
if [ -d "$REPO_DIR/.git" ]; then
  echo "Обновляем до последней версии..."
  cd "$REPO_DIR" && git pull
else
  echo "Скачиваем PM Copilot..."
  git clone "$REPO_URL" "$REPO_DIR"
fi

# Создаём папку skills если нет
mkdir -p "$INSTALL_DIR"

# Копируем все pm-copilot скиллы (dev-инструменты не устанавливаем)
echo "Устанавливаем скиллы в $INSTALL_DIR..."
for dir in "$REPO_DIR"/pm-copilot*/; do
  name=$(basename "$dir")
  # Пропускаем dev-инструменты — они не нужны пользователям
  [[ "$name" == "pm-copilot-tests" ]] && continue
  [[ "$name" == "pm-copilot-dev" ]] && continue
  # Удаляем старую версию целиком (cp -r не удаляет файлы, удалённые в репо)
  rm -rf "$INSTALL_DIR/$name"
  cp -r "$dir" "$INSTALL_DIR/$name"
  echo "  ✓ $name"
done

echo ""
echo "Готово! PM Copilot установлен."
echo "Запусти /pm-copilot в Claude Code чтобы начать."
