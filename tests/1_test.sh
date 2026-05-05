#!/bin/bash

REPO="ImArcho/to-do-app"
BRANCH="push-model"
PORT=32412

out_1=$(kubectl top pod -l app=todo-app --containers)

git add .
git commit -m "test-$(date +%s)"
git push

out_2=$(kubectl top pod -l app=todo-app --containers)

sleep 5

RUN_ID=$(curl -s -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/$REPO/actions/runs?branch=$BRANCH&per_page=1" \
  | jq -r '.workflow_runs[0].id')

echo "Run ID: $RUN_ID"

out_3=$(kubectl top pod -l app=todo-app --containers)

gh run watch $RUN_ID --exit-status

sleep 5

out_4=$(kubectl top pod -l app=todo-app --containers)

echo "Waiting for pods..."
sleep 30

while [ -z "$(kubectl get pods -l app=todo-app | grep Running)" ]; do
    echo "Waiting for pod..."
    sleep 5
done

sleep 30

out_5=$(kubectl top pod -l app=todo-app --containers)

echo ""
echo "=== RESTARTS ==="
kubectl get pods -l app=todo-app -o custom-columns=NAME:.metadata.name,RESTARTS:.status.containerStatuses[0].restartCount

echo ""
echo "=== HTTP STATUS ==="
curl -s -o /dev/null -w "HTTP %{http_code}" localhost:$PORT

echo ""
echo "=== ВСЕ ЗАМЕРЫ CPU ==="
echo "1 - $out_1"
echo "2 - $out_2"
echo "3 - $out_3"
echo "4 - $out_4"
echo "5 - $out_5"
