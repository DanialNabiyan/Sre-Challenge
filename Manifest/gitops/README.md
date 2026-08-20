# gitops/

The actual Kubernetes manifests that ArgoCD syncs — referenced as the `source.path` in the matching `Application` under [`../argocd-project`](../argocd-project). This is the layer you edit when you want to change what's actually running; `argocd-project/` only ever changes when you add/remove a whole component.

## Components

### `cnpg/` → namespace `cnpg-system`
`test-postgre.yaml` defines:
- A CloudNativePG `Cluster` (`cluster-postgre`), 3 instances, `max_connections=200`, `shared_buffers=512MB`, requests 500m/1Gi–2/4Gi, **2Gi storage**.
- A `PodMonitor` wiring it into `kube-prometheus-stack` (matches `release: kube-prometheus-stack` label — must match your Prometheus Helm release name).

⚠️ 2Gi of storage against a 512MB `shared_buffers` config is enough for a quick smoke test only — WAL and base data will fill it fast under any real load. Size storage relative to expected data volume before using this for anything but validation.

### `elastic/` → namespace `logging`
`logging.yaml` defines:
- An ECK `Elasticsearch` cluster (`logging-es`), single node (`master+data+ingest+ml`), 30Gi PVC, TLS disabled on the HTTP layer (`selfSignedCertificate.disabled: true`).
- A `Kibana` instance pointed at it, also with TLS disabled.

⚠️ Single-node ES has no HA — I use single node because of resource limitation for my nodes

### `fluent-bit/` → namespace `logging`
DaemonSet-based log shipper, deployed as raw manifests (not the upstream Helm chart, though labeled as if from `fluent-bit-0.58.1`):
- `configmap.yaml` — tails `/var/log/containers/*.log`, enriches with the `kubernetes` filter, ships to `logging-es-es-http.logging.svc:9200`

## Apply order

If applying these directly (bypassing ArgoCD) rather than letting Applications sync them:

```bash
kubectl apply -f cnpg/           # after the cnpg operator's CRDs exist
kubectl apply -f elastic/        # after the eck-operator is running
kubectl apply -f fluent-bit/     # after elastic/, so its ES secret exists
```
