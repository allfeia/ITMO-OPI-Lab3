#!/bin/bash
set -e

echo "---------------Запуск поиска последнего рабочего коммита---------------"

BAD_COMMIT=$(git rev-parse HEAD)
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

# Ищем последний рабочий коммит
while true; do
  if [ "$(git rev-parse HEAD)" = "$FIRST_COMMIT" ]; then
    echo "---------------Не найдено ни одного рабочего коммита---------------"
    git checkout -f master
    exit 1
  fi

  git checkout -f HEAD~1 > /dev/null

  if try_compile "$(git rev-parse HEAD)"; then
    GOOD_COMMIT=$(git rev-parse HEAD)
    # Получаем коммит, следующий за рабочим
    BAD_COMMIT=$(git rev-list --reverse master | grep -A1 "$GOOD_COMMIT" | tail -n1)
    echo "---------------Последний рабочий коммит: $GOOD_COMMIT---------------"
    echo "---------------Следующий коммит, который сломался: $BAD_COMMIT---------------"
    break
  fi
done

# Формируем diff между рабочим и сломанным коммитом
echo "---------------Формируем diff между $GOOD_COMMIT и $BAD_COMMIT---------------"
git diff "$GOOD_COMMIT" "$BAD_COMMIT" > last_good_diff.patch

if [ -s last_good_diff.patch ]; then
    echo "---------------Diff сохранён в: last_good_diff.patch---------------"
else
    echo "---------------Diff пуст — возможно, изменений не было---------------"
fi

# Возврат на ветку master
git checkout -f master
echo "---------------Возвращение на ветку: master---------------"
