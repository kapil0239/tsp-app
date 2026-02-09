# Frontend Application

React-based frontend for the task management application. Instrumented with OpenTelemetry (browser); traces are sent to OTLP (same-origin `/api/otel` by default, proxied to backend → collector → Tempo).

## Local Development

1. Install dependencies: `npm install`
2. Copy `.env.example` to `.env` and configure API URL
3. Run: `npm start`
4. Open http://localhost:3000

## Build for Production

```bash
npm run build
```

## Deploy to Azure Web App

1. Build and deploy the app. If you use the Node server (`server.js`) to serve the build and proxy `/api` to the backend, deploy with a startup command that runs `node server.js` (so `/api/otel` is also proxied and browser traces reach the backend → collector).
2. Optional: set **Application settings** in Azure Web App:
   - `REACT_APP_OTEL_EXPORTER_OTLP_ENDPOINT`: leave unset to use same-origin `/api/otel`, or set to your backend URL + `/api/otel` (e.g. `https://your-backend.azurewebsites.net/api/otel`) if the frontend is served as static files without the proxy.
   - `REACT_APP_OTEL_SERVICE_NAME`: service name for traces (default: `tsp-frontend`). Rebuild after changing.

```bash
npm run build
cd build
zip -r ../frontend.zip .
az webapp deployment source config-zip \
  --resource-group <resource-group> \
  --name <webapp-name> \
  --src frontend.zip
```
