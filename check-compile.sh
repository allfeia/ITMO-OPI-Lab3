#!/bin/bash

echo "-------------compile-------------"
if mvn clean compile -DskipTests=true; then
    echo "-------------Сборка успешна-------------"
else
    echo "-------------Ошибка компиляции! Запускаем поиск последнего рабочего коммита-------------"
    ./check-history.sh
fi
