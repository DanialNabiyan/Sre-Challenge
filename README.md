# SRE Challenge

Provisions a vSphere-based Kubernetes cluster and bootstraps it with a GitOps-managed platform stack.

**Flow:** Terraform (VMs on vSphere) → Kubespray (Kubernetes, CRI-O + Cilium) → ArgoCD (Longhorn, kube-prometheus-stack, CloudNativePG, ECK, Fluent Bit).

## Structure

| Path | What it is |
|---|---|
| `Terraform/` | vSphere VM provisioning. See [Terraform/README.md](Terraform/README.md). |
| `Ansible/kubespray/` | Vendored Kubespray + custom inventory for cluster deployment. See its [README](Ansible/kubespray/README.md). |
| `Manifest/argocd.yaml` | ArgoCD install manifest. |
| `Manifest/argocd-project/` | ArgoCD `Application` definitions (App of Apps). See [README](Manifest/argocd-project/README.md). |
| `Manifest/gitops/` | Manifests those Applications sync. See [README](Manifest/gitops/README.md). |
