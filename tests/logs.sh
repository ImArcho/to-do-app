#!/bin/bash

FILE="1.5.txt"

echo "Начало сбора метрик"

for i in {1..100}
do
	echo "$(date +%H:%M:%S)" >> $FILE
	kubectl top pod -l app=todo-app --containers --no-headers >> $FILE
	sleep 3
done

echo "Сбор завершён"
