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

## ⚙️ Prepare the VMs

### Update and install dependencies
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl apt-transport-https ca-certificates gnupg lsb-release
```

### Disable swap (required by Kubernetes)
```bash
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab
```

---

## 📦 Install Container Runtime (containerd)

```bash
sudo apt install -y containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd
```

---

## 🔧 Install Kubernetes Components

### Add Kubernetes APT repository
```bash
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

### Install kubelet, kubeadm, and kubectl
```bash
sudo apt update
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

---

## 🚀 Initialize the Control Plane Node

### Run on the control plane node:
```bash
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
```

### Configure kubectl access
```bash
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

---

## 🌐 Install Pod Network (Flannel)

```bash
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

---

## 🧩 Join Worker Nodes

From the control plane node, copy the output `kubeadm join ...` command and run it on each worker node:
```bash
kubeadm join <MASTER_IP>:6443 --token <TOKEN> --discovery-token-ca-cert-hash sha256:<HASH>
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
