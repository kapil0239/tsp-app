```
helm repo add grafana https://grafana.github.io/helm-charts

helm search repo grafana

helm fetch grafana/loki

tar -xzvf .\loki-6.52.0.tgz

cd loki

helm -n monitoring install loki . --values single-binary-values.yaml
```

```
cd ..

helm fetch grafana/tempo

tar -xzvf .\tempo-1.24.4.tgz

cd tempo

helm -n monitoring install tempo .
```

```
cd ../otel

helm -n monitoring install otel .
```
