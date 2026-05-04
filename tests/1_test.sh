#!/bin/bash

git add .
git commit -m "test-$(date +%s)"
git push

echo "Waiting for CI to complete..."
gh run watch --branch push-model --repo ImArcho/to-do-app --exit-status

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
