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

### Step 1: Prepare a Working Directory and Download the Scripts

On each VM, create a working folder and download the scripts inside it:
```bash
mkdir -p ~/k8s-setup
cd ~/k8s-setup
```
```bash
wget https://raw.githubusercontent.com/craft211/Kubernetes/cb47be911628cabf99ed17480f16a60741e6d7e3/setup-k8s.sh
wget https://raw.githubusercontent.com/craft211/Kubernetes/cb47be911628cabf99ed17480f16a60741e6d7e3/init-control-plane.sh

chmod +x setup-k8s.sh init-control-plane.sh
```

### Step 2: Run the Base Setup Script

Run the following on **all nodes** (control + workers):
```bash
sudo ./setup-k8s.sh
```

Then **reboot** each node:
```bash
sudo reboot
```

### Step 3: Initialize the Control Plane

After reboot, on the **control plane** node:
```bash
cd ~/k8s-setup
sudo ./init-control-plane.sh
```

Copy the output `kubeadm join ...` command.

### Step 4: Join Worker Nodes to the Cluster

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
- [GitHub Scripts Repo](https://github.com/craft211/Kubernetes)
