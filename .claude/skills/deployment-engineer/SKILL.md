---
name: deployment-engineer
type: workflow
description: "Designs and implements CI/CD pipelines, GitOps workflows, and deployment automation. Use when building or improving CI/CD pipelines, containerization, or release automation."
effort: 3
allowed-tools: Read, Glob, Grep, Write, Edit, Bash
argument-hint: "[environment: dev|staging|prod]"
user-invocable: true
when_to_use: "When designing or improving CI/CD pipelines, implementing GitOps workflows, or automating deployments"
---

# Deployment Engineer

Designs and implements CI/CD pipelines, GitOps workflows, container build strategies, and release automation with progressive delivery.

## When to Use

- Designing or improving CI/CD pipelines and release workflows
- Implementing GitOps or progressive delivery patterns
- Automating deployments with zero-downtime requirements
- Integrating security scanning into deployment flows

## When NOT to Use

- Executing a deployment (use deployment-procedures instead)
- Simple dev setup without pipeline changes
- Infrastructure architecture decisions (use backend-architect or cloud-architect)

---

## Workflow

### 1. Gather Requirements

Ask before designing:
- Target environments (dev/staging/prod)?
- Current CI/CD platform (GitHub Actions, GitLab CI, Azure DevOps, Jenkins)?
- Container strategy (Docker, Podman, buildpacks)?
- Zero-downtime requirement? Database migrations involved?
- Compliance requirements (SOX, PCI-DSS, HIPAA)?
- Team prefers GitOps (declarative) or imperative deployment?

### 2. Design Pipeline Stages

Standard pipeline structure:

\`\`\`
[Build] -> [Test] -> [Security Scan] -> [Package] -> [Deploy Staging] -> [Integration Test] -> [Approval] -> [Deploy Prod] -> [Verify]
\`\`\`

Design each stage:

| Stage | Actions | Failure Policy |
|-------|---------|----------------|
| Build | Compile, lint, type-check | Block |
| Test | Unit + integration tests | Block |
| Security | SAST, dependency scan, container scan | Block on Critical/High |
| Package | Docker build, push to registry, sign image | Block |
| Deploy Staging | Apply manifests/Helm, run smoke tests | Block |
| Integration Test | E2E tests, performance baseline | Block |
| Approval | Manual gate for production | Require approval |
| Deploy Prod | Progressive rollout | Auto-rollback on failure |
| Verify | Health checks, metrics validation | Auto-rollback |

### 3. Implement Container Strategy

Dockerfile best practices:
\`\`\`dockerfile
# Multi-stage build
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM gcr.io/distroless/nodejs20-debian12
COPY --from=builder /app /app
USER nonroot
CMD ["app/index.js"]
\`\`\`

Checklist:
- Multi-stage build to minimize image size
- Distroless or minimal base image
- Non-root user
- No secrets in image layers
- .dockerignore excludes unnecessary files
- Image scanning in pipeline (Trivy, Grype)
- Image signing (Cosign/Sigstore)

### 4. Configure Deployment Strategy

Choose based on requirements:

| Strategy | Zero-downtime | Rollback Speed | Resource Cost | Use When |
|----------|---------------|----------------|---------------|----------|
| Rolling Update | Yes | Slow (redeploy) | Low | Default for most services |
| Blue/Green | Yes | Instant (switch) | 2x | Critical services, DB-independent |
| Canary | Yes | Fast (shift) | 1.1x | High-traffic, need real-user validation |
| A/B Testing | Yes | Fast | 1.1x | Feature experiments |

For Kubernetes, implement with:
- Rolling: native Deployment strategy
- Canary: Argo Rollouts or Flagger
- Blue/Green: Argo Rollouts with previewService

### 5. Implement GitOps (if applicable)

Repository structure:
\`\`\`
app-repo/           # Application source code + Dockerfile
env-repo/           # Environment configs (Kustomize overlays / Helm values)
  base/             # Base manifests
  overlays/
    dev/            # Dev-specific values
    staging/        # Staging-specific values
    prod/           # Production-specific values
\`\`\`

Tools:
- ArgoCD or Flux v2 for continuous deployment
- Kustomize or Helm for environment-specific configuration
- External Secrets Operator for secret management
- Sealed Secrets as alternative

### 6. Integrate Security

Pipeline security stages:
- SAST: CodeQL, Semgrep, SonarQube
- Dependency scanning: Snyk, Dependabot, npm audit
- Container scanning: Trivy, Grype
- Secret scanning: GitLeaks, TruffleHog
- SBOM generation: Syft
- Image signing: Cosign

Policy enforcement:
- OPA/Gatekeeper for admission control
- Only signed images in production
- No Critical/High vulnerabilities pass gates

### 7. Add Observability

Deployment metrics to track (DORA):
- Deployment frequency
- Lead time for changes
- Change failure rate
- Mean time to recovery (MTTR)

Implementation:
- Pipeline notifications (Slack, Teams, email)
- Deployment markers in APM (Datadog, New Relic)
- Health check endpoints for readiness/liveness
- Synthetic monitoring post-deployment

### 8. Create Rollback Plan

Automated rollback triggers:
- Health check failures after deployment
- Error rate spike above threshold
- Latency regression beyond SLO
- Manual rollback command

Rollback procedure:
\`\`\`bash
# Kubernetes rollback
kubectl rollout undo deployment/<app> -n <namespace>

# ArgoCD rollback
argocd app rollback <app-name> <revision>
\`\`\`

---

## Output

Deliver:
- Pipeline configuration file (GitHub Actions / GitLab CI / etc.)
- Dockerfile with multi-stage build and security hardening
- Deployment strategy selection with justification
- GitOps repository structure (if applicable)
- Security scanning configuration
- Rollback runbook
- Monitoring dashboard requirements

---

## Quality Gates

Before marking pipeline as complete:
- All pipeline stages pass on a test commit
- Security scan catches intentional vulnerability in test
- Rollback tested successfully
- Pipeline runs under 10 minutes for CI (excluding deploy)
- Secrets properly managed (not in code, not in logs)
- Documentation covers troubleshooting common failures
