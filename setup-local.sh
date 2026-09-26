#!/usr/bin/env bash
# Cria o cluster Kind e faz deploy de todos os serviços do zero.
# Pré-requisitos: docker, kind, kubectl
set -euo pipefail

CLUSTER_NAME="kind"
M2_CACHE="/tmp/vmetrix-m2"

echo "==> Verificando pré-requisitos..."
for cmd in docker kind kubectl; do
  command -v "$cmd" >/dev/null || { echo "ERRO: $cmd não encontrado"; exit 1; }
done

echo "==> Criando cluster Kind (se não existir)..."
if ! kind get clusters 2>/dev/null | grep -q "^${CLUSTER_NAME}$"; then
  kind create cluster --name "$CLUSTER_NAME"
fi
kubectl config use-context "kind-${CLUSTER_NAME}"

echo "==> Buildando bibliotecas..."
mkdir -p "$M2_CACHE"
docker run --rm -v "$M2_CACHE":/root/.m2 -v "$(pwd)/calc-lib":/app -w /app \
  maven:3.9-eclipse-temurin-17 mvn clean install -B -q
docker run --rm -v "$M2_CACHE":/root/.m2 -v "$(pwd)/misc-utils":/app -w /app \
  maven:3.9-eclipse-temurin-17 mvn clean install -B -q

echo "==> Preparando .m2 para os serviços..."
mkdir -p svc-calc/.m2/repository/com/vmetrix/calc-lib/1.0.0
mkdir -p svc-misc/.m2/repository/com/vmetrix/misc-utils/1.0.0
mkdir -p web-app/.m2/repository/com/vmetrix/calc-lib/1.0.0
mkdir -p web-app/.m2/repository/com/vmetrix/misc-utils/1.0.0
cp "$M2_CACHE"/repository/com/vmetrix/calc-lib/1.0.0/*  svc-calc/.m2/repository/com/vmetrix/calc-lib/1.0.0/
cp "$M2_CACHE"/repository/com/vmetrix/misc-utils/1.0.0/* svc-misc/.m2/repository/com/vmetrix/misc-utils/1.0.0/
cp "$M2_CACHE"/repository/com/vmetrix/calc-lib/1.0.0/*  web-app/.m2/repository/com/vmetrix/calc-lib/1.0.0/
cp "$M2_CACHE"/repository/com/vmetrix/misc-utils/1.0.0/* web-app/.m2/repository/com/vmetrix/misc-utils/1.0.0/

echo "==> Buildando imagens Docker..."
docker build -t vmetrix/svc-calc:local svc-calc/
docker build -t vmetrix/svc-misc:local svc-misc/
docker build -t vmetrix/web-app:local  web-app/

echo "==> Carregando imagens no Kind..."
kind load docker-image vmetrix/svc-calc:local vmetrix/svc-misc:local vmetrix/web-app:local --name "$CLUSTER_NAME"

echo "==> Aplicando manifests Kubernetes..."
kubectl apply -f k8s/svc-calc/ -f k8s/svc-misc/ -f k8s/web-app/

echo "==> Aguardando deployments ficarem prontos..."
kubectl wait deployment svc-calc svc-misc web-app --for=condition=available --timeout=120s

echo ""
echo "✅ Ambiente pronto!"
echo "   kubectl port-forward svc/web-app 8080:8080"
echo "   kubectl port-forward svc/svc-calc 8082:8082"
echo "   kubectl port-forward svc/svc-misc 8081:8081"
