/**
 * OpenTelemetry browser instrumentation.
 * Import this first (before React) so fetch and document load are traced.
 * Traces are sent to OTLP endpoint. Use REACT_APP_OTEL_EXPORTER_OTLP_ENDPOINT or
 * defaults to same-origin /api/otel (proxied to backend -> collector).
 */
import { WebTracerProvider } from '@opentelemetry/sdk-trace-web';
import { BatchSpanProcessor } from '@opentelemetry/sdk-trace-base';
import { OTLPTraceExporter } from '@opentelemetry/exporter-trace-otlp-http';
import { FetchInstrumentation } from '@opentelemetry/instrumentation-fetch';
import { DocumentLoadInstrumentation } from '@opentelemetry/instrumentation-document-load';
import { registerInstrumentations } from '@opentelemetry/instrumentation';
import { Resource } from '@opentelemetry/resources';
import { ATTR_SERVICE_NAME } from '@opentelemetry/semantic-conventions';

const serviceName = process.env.REACT_APP_OTEL_SERVICE_NAME || 'tsp-frontend';

function getOtelEndpoint() {
  if (process.env.REACT_APP_OTEL_EXPORTER_OTLP_ENDPOINT) {
    return process.env.REACT_APP_OTEL_EXPORTER_OTLP_ENDPOINT.replace(/\/$/, '');
  }
  if (typeof window !== 'undefined' && window.location?.origin) {
    return `${window.location.origin}/api/otel`;
  }
  return '';
}

const endpoint = getOtelEndpoint();
if (!endpoint) {
  console.debug('[OTel] No OTLP endpoint; tracing disabled.');
} else {
  const provider = new WebTracerProvider({
    resource: new Resource({ [ATTR_SERVICE_NAME]: serviceName }),
  });

  provider.addSpanProcessor(
    new BatchSpanProcessor(
      new OTLPTraceExporter({
        url: `${endpoint}/v1/traces`,
      })
    )
  );

  provider.register();

  registerInstrumentations({
    instrumentations: [
      new DocumentLoadInstrumentation(),
      new FetchInstrumentation({
        propagateTraceHeaderCorsUrls: [/.*/],
        clearTimingResources: true,
      }),
    ],
  });
}
