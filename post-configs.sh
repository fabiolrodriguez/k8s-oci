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
  
  kubectl create ingress demo --class=nginx \
  --rule="apps.fabio.monster/*=demo:80"