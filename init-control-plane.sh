#!/bin/bash

set -e

echo "[Step] Initializing control plane..."
kubeadm init --pod-network-cidr=10.244.0.0/16

echo "[Step] Setting up kubeconfig..."
mkdir -p $HOME/.kube
cp /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

echo "[Step] Installing Flannel network..."
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

echo "[Done] Control plane is ready."

echo "Run this on each worker node to join the cluster:"
kubeadm token create --print-join-command
