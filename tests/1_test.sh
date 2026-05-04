#!/bin/bash

MODEL="push"

# Подготовка
kubectl config use-context ${MODEL}-model
kubectl delete deployment todo-app --ignore-not-found

git add .
git commit -m "Test 1.1"
git push

T0=$(date +%s)

while [ -z "$(kubectl get pods 2>/dev/null | grep Running)" ]; do
    sleep 2
done

while [ "$(curl -s -o /dev/null -w '%{http_code}' localhost:30080)" != "200" ]; do
    sleep 2
done

T2=$(date +%s)

echo "Time: $((T2 - T0)) sec"

sleep 30

for i in 1 2 3; do
    kubectl top pod -l app=todo-app --containers
    sleep 10
done
