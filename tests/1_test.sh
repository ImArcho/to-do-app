#!/bin/bash

REPO="ImArcho/to-do-app"
BRANCH="push-model"

git add .
git commit -m "test-$(date +%s)"
git push

sleep 5

RUN_ID=$(curl -s -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/$REPO/actions/runs?branch=$BRANCH&per_page=1" \
  | jq -r '.workflow_runs[0].id')

gh run watch $RUN_ID --exit-status

# Ждём готовности подов
sleep 30
while [ -z "$(kubectl get pods -l app=todo-app 2>/dev/null | grep Running)" ]; do
    sleep 5
done
sleep 30

echo ""
echo "=== ВРЕМЯ РАЗВЁРТЫВАНИЯ ==="
echo "Смотрите в логах выше (от пуша до completion)"
echo ""
echo "=== CPU/RAM (контрольный замер) ==="
kubectl top pod -l app=todo-app --containers
echo ""
echo "=== РУЧНЫХ ВМЕШАТЕЛЬСТВ ==="
echo "0 (всё автоматически)"
