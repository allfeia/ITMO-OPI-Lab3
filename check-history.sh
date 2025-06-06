#!/bin/bash
set -e

echo "-------------Запуск автоматического поиска рабочего коммита-------------"

CURRENT_COMMIT=$(git rev-parse HEAD)
FIRST_COMMIT=$(git rev-list --max-parents=0 HEAD)
TEMP_BRANCH="_temp_compile_check_branch_$$"

# Создаём временную ветку для безопасного перехода по коммитам
git checkout -b "$TEMP_BRANCH" > /dev/null

function try_compile() {
  local commit=$1
  echo "-------------Пробуем собрать коммит: $commit-------------"
  git checkout -f "$commit" > /dev/null

  if mvn clean compile -DskipTests=true > /dev/null; then
    echo "-------------Успешная сборка коммита: $commit-------------"
    return 0
  else
    echo "-------------Неудача при сборке коммита: $commit-------------"
    return 1
  fi
}

LAST_GOOD_COMMIT=""
NEXT_COMMIT=""

# Проверяем текущий HEAD
if try_compile "$CURRENT_COMMIT"; then
  echo "-------------Текущий коммит рабочий-------------"
  git checkout -f "$CURRENT_COMMIT"
  git branch -D "$TEMP_BRANCH" > /dev/null
  exit 0
fi

# Переходим по истории
while true; do
  CURRENT=$(git rev-parse HEAD)

  if [ "$CURRENT" = "$FIRST_COMMIT" ]; then
    echo "-------------Не найдено ни одного рабочего коммита-------------"
    git checkout -f "$CURRENT_COMMIT"
    git branch -D "$TEMP_BRANCH" > /dev/null
    exit 1
  fi

  git checkout -f HEAD~1 > /dev/null

  if try_compile "$(git rev-parse HEAD)"; then
    LAST_GOOD_COMMIT=$(git rev-parse HEAD)
    NEXT_COMMIT=$(git rev-parse "$LAST_GOOD_COMMIT^@")  # обычно HEAD^1
    echo "-------------Найден последний рабочий коммит: $LAST_GOOD_COMMIT-------------"
    break
  fi
done

# Создаём diff между "рабочим" и следующим
echo "-------------Формируем diff между $LAST_GOOD_COMMIT и $NEXT_COMMIT-------------"

git diff "$LAST_GOOD_COMMIT" "$NEXT_COMMIT" > last_good_diff.patch
echo "-------------Diff сохранён в: last_good_diff.patch-------------"

# Возвращаемся на изначальный коммит
git checkout -f master > /dev/null
git branch -D "$TEMP_BRANCH" > /dev/null

echo "-------------Возвращение на ветку: master-------------"
