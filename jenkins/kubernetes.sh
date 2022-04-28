#!/bin/bash
aws eks update-kubeconfig --name project-cluster
kubectl apply -f kubernetes/frontend.yaml
kubectl delete pod backend
kubectl apply -f kubernetes/backend.yaml
kubectl apply -f kubernetes/mysql-deployment.yaml