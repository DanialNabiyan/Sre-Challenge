# Kubernetes Cluster Deployment with Kubespray v2.30.0

This document describes the Kubernetes cluster deployment using **Kubespray v2.30.0** with the following customizations:

* Kubernetes version configured explicitly
* CRI-O configured as the container runtime
* Cilium configured as the CNI
* Cilium version configured explicitly
* HTTP/HTTPS proxy configured
* `no_proxy` configured for Kubernetes and cluster networks
* CRI-O image mirror configured
* Helm enabled
* Kubernetes Metrics Server enabled
* Vault used to store the cluster root password
* Cluster deployment performed with Ansible

---

## 1. Prerequisites

The deployment host must have:

* Ansible
* Git
* Python 3
* SSH access to all Kubernetes nodes
* Privileged access (`sudo`) on all nodes

Example:

Install the Kubespray Python requirements:

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

---

## 2. Create the Inventory

Copy the sample inventory:

```bash
cp -rfp inventory/sample inventory/mycluster
```

Define the Kubernetes nodes in:

```text
inventory/mycluster/inventory.ini
```

Example:

```ini
[all]
k8s-test-01 ansible_user=manage ansible_host=10.19.5.185 ansible_port=5566
k8s-test-02 ansible_user=manage ansible_host=10.19.5.186 ansible_port=5566
k8s-test-03 ansible_user=manage ansible_host=10.19.5.187 ansible_port=5566

[kube_control_plane]
k8s-test-01

[etcd:children]
kube_control_plane

[kube_node]
k8s-test-02
k8s-test-03
```

Adjust the inventory according to the actual cluster topology.

---

## 3. Kubespray Configuration Changes

The main configuration changes are stored under:

```text
inventory/mycluster/group_vars/
```

The important configuration files are:

```text
inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml
inventory/mycluster/group_vars/k8s_cluster/addons.yml
inventory/mycluster/group_vars/k8s_cluster/k8s-net-cilium.yml
inventory/mycluster/group_vars/all/cri-o.yml
inventory/mycluster/group_vars/all/all.yml
```

---

## 4. Kubernetes Version

Set the required Kubernetes version in the Kubespray configuration.

Example:

```yaml
kube_version: "1.XX.Y"
```

Replace `1.XX.Y` with the Kubernetes version selected for the cluster.

Verify the configured version before deployment:

```bash
grep kube_version inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml
```

---

## 5. Configure CRI-O as Container Runtime

CRI-O is used as the container runtime instead of containerd.

Configure in file:

```yaml
container_manager: crio
```

Example:

```yaml
# inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml

container_manager: crio
```

After deployment, verify:

```bash
kubectl get nodes -o wide
```

And on a Kubernetes node:

```bash
crictl info
```

The CRI endpoint should point to CRI-O.

---

## 6. Configure Cilium as CNI

Cilium is configured as the Kubernetes Container Network Interface.

Example:

```yaml
kube_network_plugin: cilium
```

Configuration:

```yaml
# inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml

kube_network_plugin: cilium
```

Do not configure another CNI simultaneously.

---

## 7. Configure Cilium Version

The Cilium version is explicitly pinned to the required version.

Example:

```yaml
cilium_version: "X.Y.Z"
```

Replace `X.Y.Z` with the approved Cilium version.

Example:

```yaml
#inventory/mycluster/group_vars/k8s_cluster/k8s-net-cilium.yml

cilium_version: "1.XX.X"
```

Keeping the Cilium version pinned makes deployments reproducible and avoids automatically deploying a newer version.

---

## 8. HTTP/HTTPS Proxy

Set proxy for download some packages that have restriction for Iran(403).

Example:

```yaml
#inventory/mycluster/group_vars/all/all.yml

http_proxy: "http://proxy.example.com:8080"
https_proxy: "http://proxy.example.com:8080"
```

If authentication is required:

```yaml
#inventory/mycluster/group_vars/all/all.yml

http_proxy: "http://USERNAME:PASSWORD@proxy.example.local:8080"
https_proxy: "http://USERNAME:PASSWORD@proxy.example.local:8080"
```

---

## 9. Configure `no_proxy`

The `no_proxy` configuration must contain addresses that should bypass the proxy.


Example:

```yaml
#inventory/mycluster/group_vars/all/all.yml

no_proxy: test.com
```

---

## 10. CRI-O Image Mirror

CRI-O is configured to use the internal container image mirror/registry.

Example:

```yaml
#inventory/mycluster/group_vars/all/cri-o.yml

crio_registries:
  - prefix: quay.io
    location: registry.example.com/quay.io
```

Verify image pulls from a Kubernetes node:

```bash
crictl pull <image>
```

---

## 11. Enable Helm

Helm is enabled through the Kubespray addons configuration.

Example:

```yaml
helm_enabled: true
```

Configuration file:

```text
inventory/mycluster/group_vars/k8s_cluster/addons.yml
```

Example:

```yaml
helm_enabled: true
```

---

## 12. Enable Metrics Server

Enable the Kubernetes Metrics Server:

```yaml
metrics_server_enabled: true
```

Configuration:

```text
inventory/mycluster/group_vars/k8s_cluster/addons.yml
```

Example:

```yaml
metrics_server_enabled: true
```

Verify after deployment:

```bash
kubectl get pods -n kube-system | grep metrics
```

Then:

```bash
kubectl top nodes
```

And:

```bash
kubectl top pods -A
```

---

## 13. Store Root Password in Ansible Vault

The root/administrative password is stored using **Ansible Vault** instead of storing it in plaintext.

Create a Vault file:

```bash
ansible-vault create inventory/mycluster/group_vars/all/vault-root.yml
```

Add the required secret:

```yaml
ansible_become_password: "<ROOT_PASSWORD>"
```

Do **not** commit the Vault password or plaintext credentials to Git.

---

## 14. Verify Ansible Connectivity

Before deploying Kubernetes, test connectivity:

```bash
ansible -i inventory/mycluster/inventory.ini all -b --become-user=root --ask-vault-pass -m ping
```

All nodes should return:

```text
pong
```

---

## 15. Deploy the Kubernetes Cluster

Run the Kubespray cluster playbook:

```bash
ansible-playbook \
  -i inventory/mycluster/inventory.ini \
  -b \
  --become-user=root \
  --ask-vault-pass \
  cluster.yml
```

Run the command from the Kubespray root directory.

---