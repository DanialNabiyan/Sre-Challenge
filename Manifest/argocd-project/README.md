# argocd-project/

ArgoCD `Application` manifests — the "App of Apps" layer. Each subfolder is one platform component, defined as an ArgoCD `Application` that points either at a public Helm chart repo or back at this same Git repo (at `Manifest/gitops/<component>`).

Applying the files in this directory registers the app with ArgoCD; ArgoCD then does the actual syncing/reconciling.

## Components

| Folder | Application | Source | Deploys into |
|---|---|---|---|
| `longhorn/` | `longhorn` | Helm chart `longhorn` @ `charts.longhorn.io`, `v1.12.1` | `longhorn-system` |
| `prometheus/` | `kube-prometheus-stack` | Helm chart @ `prometheus-community.github.io/helm-charts`, `88.3.0` | `prometheus-system` |
| `cnpg/` | `cloudnative-pg-operator` | Helm chart @ `cloudnative-pg.io/charts/`, `0.29.0` | `cnpg-system` |
| `cnpg/` | `cloudnative-pg` | This repo, path `Manifest/gitops/cnpg` | `cnpg-system` |
| `elastic/` | `eck-operator` | Helm chart @ internal repo `repo.mci.dev`, `3.4.0` | `elastic-system` |
| `elastic/` | `eck-stack` | This repo, path `Manifest/gitops/elastic` | `logging` |
| `fluent-bit/` | `fluent-bit` | This repo, path `Manifest/gitops/fluent-bit` | `logging` |

All Applications use `project: default` and `syncOptions: [CreateNamespace=true]`, so target namespaces are created automatically on first sync.

## Usage

Requires ArgoCD already installed (see the top-level README) and applied in dependency order — operators before the resources that need their CRDs:

```bash
# storage + monitoring first (no ordering dependency between them)
kubectl apply -f longhorn/longhorn-application.yaml
kubectl apply -f prometheus/kube-prometheus-stack.yaml

# operator, then the CR that depends on its CRDs
kubectl apply -f cnpg/cnpg-operator.yaml
kubectl apply -f cnpg/cnpg-postgre.yaml

kubectl apply -f elastic/eck-operator.yaml
kubectl apply -f elastic/eck-stack.yaml

# fluent-bit last — its ES output expects logging-es-es-elastic-user secret to exist
kubectl apply -f fluent-bit/fluent-bit.yaml
```

