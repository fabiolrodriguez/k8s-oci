#!/bin/bash

echo "Installing Metallb"

kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl apply -f - -n kube-system

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/manifests/metallb-native.yaml

kubectl apply -f pool.yaml

echo "Installing nginx-ingress"

helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace

kubectl create deployment demo --image=httpd --port=80

kubectl expose deployment demo

kubectl port-forward --namespace=ingress-nginx service/ingress-nginx-controller 8080:80

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install [RELEASE_NAME] prometheus-community/prometheus-node-exporter

kubectl patch ds prometheus-prometheus-node-exporter --type "json" -p '[{"op": "remove", "path" : "/spec/template/spec/containers/0/volumeMounts/2/mountPropagation"}]'
  
kubectl create ingress prometheus-grafana --class=nginx --rule="grafana.fabio.monster/*=prometheus-grafana:80"

kubectl create ingress prometheus-kube-prometheus-prometheus --class=nginx --rule="prom.fabio.monster/*=prometheus-kube-prometheus-prometheus:80"

kubectl create ingress magic-app --class=nginx --rule="magic.fabio.monster/*=magic-pod:8080"

echo "Instaling Cert Manager"

 kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.10.1/cert-manager.yaml