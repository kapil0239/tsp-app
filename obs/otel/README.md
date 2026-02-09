# OpenTelemetry Collector (Helm Chart)

Deploys the OpenTelemetry Collector. It receives OTLP traces and forwards them to Tempo.

## Prerequisites

- Tempo installed (e.g. in `monitoring` namespace).
- Helm 3.

## Install

```bash
cd otel
helm -n monitoring install otel-collector .
```

With custom Tempo endpoint:

```bash
helm -n monitoring install otel-collector . \
  --set tempo.host=tempo-default.monitoring.svc.cluster.local \
  --set tempo.port=4317
```

## Upgrade

```bash
helm -n monitoring upgrade otel-collector . -f values.yaml
```

## Uninstall

```bash
helm -n monitoring uninstall otel-collector
```

## Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `nameOverride` | Override chart name | `""` |
| `fullnameOverride` | Override full name | `""` |
| `replicas` | Number of collector replicas | `1` |
| `image.repository` | Collector image repo | `otel/opentelemetry-collector-contrib` |
| `image.tag` | Image tag | `0.112.0` |
| `image.pullPolicy` | Pull policy | `IfNotPresent` |
| `tempo.host` | Tempo OTLP gRPC host | `tempo.monitoring.svc.cluster.local` |
| `tempo.port` | Tempo OTLP gRPC port | `4317` |
| `tempo.tlsInsecure` | Use insecure TLS to Tempo | `true` |
| `config.override` | Replace entire collector config (YAML string) | `""` |
| `resources` | CPU/memory requests and limits | see `values.yaml` |
| `serviceAccount.create` | Create ServiceAccount | `true` |
| `service.type` | Service type | `ClusterIP` |

## Endpoints

After install, send OTLP traces to the collector:

| Protocol   | Port |
|-----------|------|
| OTLP gRPC | 4317 |
| OTLP HTTP | 4318 |

Example (same namespace): `otel-collector:4317`. From another namespace: `otel-collector.monitoring.svc.cluster.local:4317`.
