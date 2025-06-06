#!/bin/bash
set -e

echo "---------------Запуск поиска последнего рабочего коммита---------------"

FIRST_COMMIT=$(git rev-list --max-parents=0 HEAD)

function try_compile() {
  local commit=$1
  git checkout -f "$commit" > /dev/null
  echo "---------------Пробуем собрать коммит: $commit---------------"

  if mvn clean compile -DskipTests=true > /dev/null; then
    echo "---------------Успешная сборка коммита: $commit---------------"
    return 0
  else
    echo "---------------Неудача при сборке коммита: $commit---------------"
    return 1
  fi
}

# Сохраняем текущие изменения в стэш
git stash push -u -m "temp-uncommitted-changes" > /dev/null

GOOD_COMMIT=""
for commit in $(git rev-list HEAD); do
  if try_compile "$commit"; then
    GOOD_COMMIT="$commit"
    break
  fi

  if [ "$commit" = "$FIRST_COMMIT" ]; then
    echo "---------------Не найдено ни одного рабочего коммита---------------"
    git checkout -f master
    git stash pop --index > /dev/null
    exit 1
  fi
done

# Получаем BAD_COMMIT — следующий за GOOD_COMMIT
BAD_COMMIT=$(git rev-list --reverse master | grep -A1 "$GOOD_COMMIT" | tail -n1)

# Восстанавливаем рабочее состояние
git checkout -f master
git stash pop --index > /dev/null

echo "---------------Последний рабочий коммит: $GOOD_COMMIT---------------"
echo "---------------Следующий коммит, который сломался: $BAD_COMMIT---------------"

# Специальная обработка: ошибка в незакоммиченных изменениях
if [ "$GOOD_COMMIT" = "$BAD_COMMIT" ]; then
  echo "---------------Ошибка была в незакоммиченных изменениях---------------"
  git diff > last_good_diff.patch
else
  echo "---------------Формируем diff между $GOOD_COMMIT и $BAD_COMMIT---------------"
  git diff "$GOOD_COMMIT" "$BAD_COMMIT" > last_good_diff.patch
fi

if [ -s last_good_diff.patch ]; then
  echo "---------------Diff сохранён в: last_good_diff.patch---------------"
else
  echo "---------------Diff пуст — возможно, изменений не было---------------"
fi

echo "---------------Готово---------------"
