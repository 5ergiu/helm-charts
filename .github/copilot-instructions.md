# 🧑‍💻 Copilot Instructions for helm-charts

This repository provides production-grade Helm charts for deploying Laravel and Next.js applications to Kubernetes. AI coding agents should follow these project-specific guidelines for effective contributions.

## 🏗️ Architecture Overview
- **charts/** contains Helm charts for each app (e.g., `laravel`, `nextjs`). Each chart has its own `values.yaml`, templates, and tests.
- **examples/** provides Dockerfiles for demo Laravel/Next.js apps. These build fresh projects for immediate chart testing.
- **scripts/** includes helper scripts (e.g., `test.sh`).
- **COSIGN.md** and `cosign.pub` document and provide keys for chart signature verification.

## 🚀 Developer Workflows
- **Install charts:**
  - From OCI registry: `helm install my-app oci://ghcr.io/5ergiu/helm-charts/<chart> --version <ver> --namespace <ns> --create-namespace --values values.yaml`
  - From local: `helm install my-app ./charts/<chart> --namespace <ns> --create-namespace --values values.yaml`
- **Build demo images:**
  - Laravel: `docker build --target development -t ghcr.io/5ergiu/laravel:dev examples/laravel-app`
  - Next.js: `docker build --target development -t ghcr.io/5ergiu/nextjs:dev examples/nextjs-app`
- **Test charts:**
  - Use `charts/<chart>/tests/` for Helm test manifests. Run with `helm test <release> -n <namespace>`.
  - Use `scripts/test.sh` for custom test automation.
- **Verify chart signatures:**
  - Install Cosign (`brew install cosign` on macOS).
  - Verify: `cosign verify --key cosign.pub ghcr.io/5ergiu/helm-charts/<chart>:<tag>`

## 📦 Project Conventions
- **values.yaml**: All configuration is driven by values files. Use `values.schema.json` for validation and discoverable options.
- **Environment separation:**
  - Use `values.dev.yaml`, `values.prod.yaml` for local vs. production settings.
  - Local dev values often disable probes, autoscaling, and use relaxed security/middleware.
- **Image tags:**
  - Development images use `:dev` tag, production uses versioned tags (e.g., `:v0.1.0`).
- **Ingress:**
  - Traefik is the default ingress controller for local dev (`className: traefik`).
  - TLS is disabled for dev, enabled for prod.
- **Persistence:**
  - PVCs are not auto-deleted on uninstall; must be deleted manually if needed.
- **Secrets:**
  - Dev secrets are in values files for convenience; do NOT use in production.

## 🧩 Integration Points
- **External services:**
  - PostgreSQL and Redis are optional dependencies, installable via Bitnami charts.
  - Email (Mailpit), S3 (MinIO), and other services are configurable via values.
- **Cosign:**
  - All charts are signed; see `COSIGN.md` and use `cosign.pub` for verification.

## 📝 Examples
- See `charts/nextjs/values.dev.yaml` for a full-featured local dev config.
- See `examples/laravel-app/Dockerfile` for multi-stage build patterns.

## ⚡ Patterns & Anti-Patterns
- **Pattern:** Use schema-driven values for all config. Validate with `values.schema.json`.
- **Pattern:** Separate dev/prod configs. Never commit secrets for production.
- **Anti-pattern:** Hardcoding values in templates. Always use values files.

---
For more details, see the main [README.md](../README.md), chart READMEs, and schema files. If any section is unclear or missing, please provide feedback for improvement.
