#!/bin/bash

MODEL=$1

kubectl config use-context ${MODEL}-model
kubectl delete deployment todo-app --ignore-not-found

echo "Сделайте git push (и kubectl apply для push-модели) затем нажмите ENTER"
read

T0=$(date +%s)

while [ -z "$(kubectl get pods 2>/dev/null | grep Running)" ]; do
    sleep 2
done

T1=$(date +%s)

while [ "$(curl -s -o /dev/null -w '%{http_code}' localhost:30080)" != "200" ]; do
    sleep 2
done

T2=$(date +%s)

echo ""
echo "=== ВРЕМЕННЫЕ МЕТРИКИ ==="
echo "t0 (начало): $(date -d @$T0 '+%H:%M:%S')"
echo "t1 (поды Running): $(date -d @$T1 '+%H:%M:%S')"
echo "t2 (HTTP 200): $(date -d @$T2 '+%H:%M:%S')"
echo "Время развёртывания: $((T2 - T0)) секунд"
echo ""

sleep 30

echo "=== ПОТРЕБЛЕНИЕ РЕСУРСОВ (3 замера) ==="
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
echo "Комментарий: _________________________________"
