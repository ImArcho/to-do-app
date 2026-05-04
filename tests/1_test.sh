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

echo "Run ID: $RUN_ID"

gh run watch $RUN_ID --exit-status

echo ""
echo "=== CPU/RAM ==="
kubectl top pod -l app=todo-app --containers

echo ""
echo "=== RESTARTS ==="
kubectl get pods -l app=todo-app -o custom-columns=NAME:.metadata.name,RESTARTS:.status.containerStatuses[0].restartCount

echo ""
echo "=== HTTP STATUS ==="
curl -s -o /dev/null -w "HTTP %{http_code}" localhost:32412
echo ""
