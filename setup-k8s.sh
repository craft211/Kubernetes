#!/bin/bash

set -e

echo "[Step 1] Disabling swap..."
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

echo "[Step 2] Updating system..."
apt update && apt upgrade -y

echo "[Step 3] Installing dependencies..."
apt install -y curl apt-transport-https ca-certificates gnupg lsb-release

echo "[Step 4] Installing containerd..."
apt install -y containerd
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd

echo "[Step 5] Adding Kubernetes repo..."
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list

apt update
apt install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

echo "[Done] Base setup complete. Reboot recommended."
