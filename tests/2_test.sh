#!/bin/bash

REPO="ImArcho/to-do-app"
BRANCH="push-model"
PORT=32412

out_1=$(kubectl top pod -l app=todo-app --containers)

CURRENT_IMAGE=$(kubectl get deployment todo-app -o jsonpath='{.spec.template.spec.containers[0].image}')
CURRENT_TAG=$(echo $CURRENT_IMAGE | cut -d: -f2)
echo "Текущий образ: $CURRENT_IMAGE"

PREVIOUS_COMMIT="eb202ff"
echo "Предыдущий коммит: $PREVIOUS_COMMIT"

git revert $PREVIOUS_COMMIT --no-edit
git push

sleep 5

RUN_ID=$(curl -s -H "Accept: application/vnd.github.v3+json" "https://api.github.com/repos/$REPO/actions/runs?branch=$BRANCH&per_page=1" | jq -r '.workflow_runs[0].id')

echo "Run ID: $RUN_ID"
gh run watch $RUN_ID --exit-status

sleep 15

out_2=$(kubectl top pod -l app=todo-app --containers 2>/dev/null || echo "Поды не найдены")

sleep 30

while [ -z "$(kubectl get pods -l app=todo-app 2>/dev/null | grep Running)" ]; do
    echo "Waiting for pod..."
    sleep 5
done

sleep 30

NEW_IMAGE=$(kubectl get deployment todo-app -o jsonpath='{.spec.template.spec.containers[0].image}')
echo "Новый образ после отката: $NEW_IMAGE"

out_3=$(kubectl top pod -l app=todo-app --containers)

echo "=== ВСЕ ЗАМЕРЫ CPU ==="
echo "1 (до отката): $out_1"
echo "2 (после CI): $out_2"
echo "3 (поды готовы): $out_3"

echo ""
kubectl get pods -l app=todo-app -o custom-columns=NAME:.metadata.name,RESTARTS:.status.containerStatuses[0].restartCount

echo ""
curl -s -o /dev/null -w "HTTP %{http_code}" localhost:$PORT
