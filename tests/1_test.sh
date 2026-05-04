#!/bin/bash

MODEL=$1

kubectl config use-context ${MODEL}-model
kubectl delete deployment to-do-app --ignore-not-found

echo "Сделайте: git add . && git commit -m \"Test\" && git push"
echo "Затем нажмите ENTER (GitHub Actions сам сделает деплой)"
read

T0=$(date +%s)

while [ -z "$(kubectl get pods 2>/dev/null | grep Running)" ]; do
    sleep 2
done

while [ "$(curl -s -o /dev/null -w '%{http_code}' localhost:30080)" != "200" ]; do
    sleep 2
done

T2=$(date +%s)

echo ""
echo "Время развёртывания: $((T2 - T0)) секунд"

sleep 30

echo "=== CPU/RAM (3 замера) ==="
for i in 1 2 3; do
    kubectl top pod -l app=todo-app --containers
    sleep 10
done

echo ""
echo "=== КАЧЕСТВЕННЫЕ ХАРАКТЕРИСТИКИ ==="
echo "Прозрачность (1-5): ______"
echo "Простота отката (1-5): ______"
echo "Безопасность доступа (1-5): ______"
echo "Человеческий фактор (1-5): ______"
echo "Понятность для новичка (1-5): ______"
