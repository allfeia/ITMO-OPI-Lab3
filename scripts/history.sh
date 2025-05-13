#!/bin/bash

echo "====== HISTORY STARTED ======"

mvn clean compile -q
if [ $? -eq 0 ]; then
    echo "✅ CURRENT VERSION IS CORRECT!"
    echo "====== HISTORY COMPLETED ======"
    exit 0
fi

echo "⚠️ Текущая версия не компилируется. Начинаем откат по истории..."

# Находим первый коммит
FIRST_COMMIT=$(git rev-list --max-parents=0 HEAD)
echo "📌 Первый коммит в истории: $FIRST_COMMIT"

# Получаем список всех коммитов от HEAD до первого
COMMITS=($(git rev-list HEAD))

# Ищем первую рабочую версию
LAST_WORKING=""
for COMMIT in "${COMMITS[@]}"; do
    echo "🔄 Проверяем коммит $COMMIT"
    git checkout -f "$COMMIT" > /dev/null 2>&1
    mvn clean compile -q
    if [ $? -eq 0 ]; then
        echo "✅ Успешная сборка: $COMMIT"
        LAST_WORKING=$COMMIT
        break
    fi
done

if [ -z "$LAST_WORKING" ]; then
    echo "⛔ Не удалось найти рабочую версию. Завершение."
    exit 1
fi

# Находим следующий (сломанный) коммит
REVERSED=($(git rev-list --reverse HEAD))
for ((i=0; i<${#REVERSED[@]}-1; i++)); do
    if [ "${REVERSED[$i]}" == "$LAST_WORKING" ]; then
        BAD_COMMIT=${REVERSED[$i+1]}
        break
    fi
done

if [ -z "$BAD_COMMIT" ]; then
    echo "Рабочая ревизия последняя в истории. Diff не нужен."
    exit 0
fi

echo "📝 Diff между рабочей $LAST_WORKING и сломанной $BAD_COMMIT"
mkdir -p build
git diff "$LAST_WORKING" "$BAD_COMMIT" > build/history-diff.txt
echo "✅ Diff сохранён в build/history-diff.txt"

echo "====== HISTORY COMPLETED ======"
