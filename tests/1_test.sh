#!/bin/bash

REPO="ImArcho/to-do-app"
BRANCH="push-model"
PORT=32412

echo "=== CPU ЗАМЕР 1 (до пуша) ==="
out_1=$(kubectl top pod -l app=todo-app --containers)

git add .
git commit -m "test-$(date +%s)"
git push

echo "=== CPU ЗАМЕР 2 (после пуша) ==="
out_2=$(kubectl top pod -l app=todo-app --containers)

sleep 5

RUN_ID=$(curl -s -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/$REPO/actions/runs?branch=$BRANCH&per_page=1" \
  | jq -r '.workflow_runs[0].id')

echo "Run ID: $RUN_ID"

echo "=== CPU ЗАМЕР 3 (после получения RUN_ID) ==="
out_3=$(kubectl top pod -l app=todo-app --containers)

gh run watch $RUN_ID --exit-status

echo "=== CPU ЗАМЕР 4 (после завершения CI) ==="
out_4=$(kubectl top pod -l app=todo-app --containers)

echo "Waiting for pods..."
sleep 30

while [ -z "$(kubectl get pods -l app=todo-app | grep Running)" ]; do
    echo "Waiting for pod..."
    sleep 5
done

sleep 30

echo "=== CPU ЗАМЕР 5 (после готовности подов) ==="
out_5=$(kubectl top pod -l app=todo-app --containers)

echo ""
echo "=== RESTARTS ==="
kubectl get pods -l app=todo-app -o custom-columns=NAME:.metadata.name,RESTARTS:.status.containerStatuses[0].restartCount

echo ""
echo "=== HTTP STATUS ==="
curl -s -o /dev/null -w "HTTP %{http_code}" localhost:$PORT
echo ""

echo ""
echo "=== ВСЕ ЗАМЕРЫ CPU ==="
echo "$out_1"
echo "$out_2"
echo "$out_3"
echo "$out_4"
echo "$out_5"
