# Kubernetes Cluster on Proxmox

This guide walks you through deploying a Kubernetes cluster on VMs managed by a Proxmox cluster. It covers VM provisioning, Kubernetes setup, and networking.

---

## 🧱 Requirements

- **Proxmox VE cluster**
- **Ubuntu 22.04 LTS VMs**
  - 1 Control Plane Node
  - 1–2 Worker Nodes
- **Static IPs** (or DHCP reservations)
- **Internet access on VMs**

---

## 🖥️ VM Setup in Proxmox

Provision VMs with the following:

- vCPUs: 2+ (4+ for control plane)
- RAM: 2–4 GB
- Disk: 20 GB+

---

## 🛠️ Automated Kubernetes Setup

You will use scripts to simplify and automate the installation process.

### Step 1: Create and upload the scripts

Create two bash scripts on each VM (or use SCP to transfer):

#### `setup-k8s.sh` (run on all nodes)
```bash
#!/bin/bash
set -e

swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

apt update && apt upgrade -y
apt install -y curl apt-transport-https ca-certificates gnupg lsb-release

apt install -y containerd
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list

apt update
apt install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

echo "[Done] Base setup complete. Reboot recommended."
```

#### `init-control-plane.sh` (run only on the control plane)
```bash
#!/bin/bash
set -e

kubeadm init --pod-network-cidr=10.244.0.0/16

mkdir -p $HOME/.kube
cp /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

echo "[Done] Control plane is ready."

echo "Run this on each worker node to join the cluster:"
kubeadm token create --print-join-command
```

Make the scripts executable:
```bash
chmod +x setup-k8s.sh init-control-plane.sh
```

### Step 2: Run the setup

On **all nodes** (control + workers):
```bash
sudo ./setup-k8s.sh
```

Then **reboot** each node:
```bash
sudo reboot
```

After reboot, on the **control plane** node:
```bash
sudo ./init-control-plane.sh
```

Copy the output `kubeadm join ...` command.

On **each worker node**, run the join command:
```bash
sudo kubeadm join <MASTER_IP>:6443 --token <TOKEN> --discovery-token-ca-cert-hash sha256:<HASH>
```

---

## ✅ Verify Cluster

### Check nodes and pods
```bash
kubectl get nodes
kubectl get pods -A
```

All nodes should show as `Ready` and pods should be running normally.

---

## 📘 Optional Enhancements

- Use Ansible or cloud-init for automation
- Install metrics-server and dashboard
- Set up Ingress controllers
- Persistent volume integration (e.g., NFS, Longhorn)

---

## 🔗 References
- [Kubernetes Official Docs](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/)
- [Flannel Network](https://github.com/coreos/flannel)
- [containerd](https://containerd.io/)
