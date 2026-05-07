#!/bin/bash

REPO="ImArcho/to-do-app"
BRANCH="pull-model"
PORT=30080

kubectl config use-context pull-model
out_1=$(kubectl top pod -l app=todo-app --containers || echo "Поды не найдены")

OLD_TAG=$(grep "image: imarcho/myapp:" manifests/deployment.yaml | head -1 | cut -d: -f3)
NEW_TAG="v$(date +%Y%m%d%H%M%S)"
sed -i "s|image: imarcho/myapp:.*|image: imarcho/myapp:${NEW_TAG}|" manifests/deployment.yaml

git add manifests/deployment.yaml
git commit -m "test-pull-$(date +%s)"
git push

out_2=$(kubectl top pod -l app=todo-app --containers || echo "Поды не найдены")

sleep 60

out_3=$(kubectl top pod -l app=todo-app --containers || echo "Поды не найдены")

sleep 30

while [ -z "$(kubectl get pods -l app=todo-app | grep Running)" ]; do
    echo "Waiting for pod..."
    kubectl get pods -l app=todo-app
done

sleep 30

out_4=$(kubectl top pod -l app=todo-app --containers)

echo ""
echo "CPU"
echo "$out_1"
echo "$out_2"
echo "$out_3"
echo "$out_4"

echo ""
kubectl get pods -l app=todo-app -o custom-columns=NAME:.metadata.name,RESTARTS:.status.containerStatuses[0].restartCount

echo ""
curl -s -o /dev/null -w "HTTP %{http_code}" localhost:$PORT
echo ""
echo "${NEW_TAG}"
