---
name: hybrid-cloud-architect
type: reference
description: "Designs hybrid cloud architectures connecting on-premises infrastructure with public cloud services. Use when designing systems spanning on-prem and cloud, or when the user mentions hybrid cloud or multi-environment architecture."
effort: 4
allowed-tools: Read, Glob, Grep, Write, Edit, Bash
user-invocable: true
when_to_use: "When designing complex multi-cloud or hybrid cloud solutions across AWS, Azure, GCP, and private clouds"
---

# Hybrid Cloud Architect

Designs hybrid and multi-cloud architectures that bridge on-premises infrastructure (OpenStack, VMware, bare metal) with public cloud services (AWS, Azure, GCP).

## When to Use

- Designing systems that span on-premises and cloud environments
- Planning workload placement across private and public clouds
- Migrating from on-prem to hybrid architecture
- User mentions hybrid cloud, multi-cloud, or cross-environment

## When NOT to Use

- Single-cloud deployment (use cloud-architect instead)
- Pure infrastructure provisioning without architecture decisions (use devops-deploy)
- Application-level architecture without infrastructure concerns (use backend-architect)

## Workflow

### 1. Assess Requirements

Gather constraints before designing:

| Dimension | Questions |
|-----------|----------|
| Compliance | Data sovereignty? Regulatory frameworks (HIPAA, PCI-DSS, GDPR)? |
| Performance | Latency requirements? Data gravity? Real-time vs batch? |
| Budget | TCO targets? Existing licenses? CapEx vs OpEx preference? |
| Skills | Team expertise in cloud platforms? OpenStack experience? |
| Timeline | Migration urgency? Phased approach acceptable? |

### 2. Classify Workloads

For each workload, determine placement:

| Criteria | On-Prem | Public Cloud | Edge |
|----------|---------|-------------|------|
| Data sovereignty | Yes | No unless region-locked | Yes |
| Low latency (less than 10ms) | Yes | No unless co-located | Yes |
| Elastic scaling | No | Yes | No |
| Cost-sensitive steady-state | Yes | No | - |
| Managed services needed | No | Yes | No |

### 3. Design Connectivity

Choose connectivity based on requirements:

Options:
- VPN: Low cost, lower bandwidth, good for non-critical traffic
- Dedicated (Direct Connect / ExpressRoute / Interconnect): High bandwidth, low latency, SLA-backed
- SD-WAN: Multi-site, dynamic path selection, cost optimization
- Service mesh: For cross-cloud microservices communication (Istio, Linkerd)

### 4. Design Security Architecture

Apply zero-trust across environments:
- Identity federation: AD/LDAP to cloud IAM (SAML/OIDC)
- Network segmentation: Micro-segmentation, security groups across clouds
- Encryption: In-transit (TLS) + at-rest, key management per environment
- Secret management: Centralized (Vault) or cloud-native (KMS/KeyVault)
- Compliance: Per-environment compliance controls, audit logging

### 5. Design Data Strategy

| Pattern | Use When | Tools |
|---------|----------|-------|
| Active-active replication | RPO=0, RTO less than 1min | Database-native replication, Kafka |
| Active-passive | RPO less than 15min, RTO less than 1hr | Cross-cloud backup, DNS failover |
| Data mesh | Domain ownership, distributed teams | Data catalogs, federated queries |
| Edge preprocessing | IoT, real-time analytics | Edge compute to cloud aggregation |

### 6. Define Infrastructure as Code

Multi-cloud IaC strategy:
- Terraform/OpenTofu: Cross-cloud resource provisioning
- Ansible: Configuration management
- Pulumi/CDK: Complex orchestration logic
- OPA/Conftest: Policy as Code
- GitOps (ArgoCD/Flux): Multi-environment deployment

State management:
- Remote state with locking (S3+DynamoDB, Azure Storage, GCS)
- Separate state per environment, shared modules
- State migration plan for cross-cloud moves

### 7. Design Observability

Unified monitoring across environments:
- Metrics: Prometheus + Thanos / Grafana Mimir (cross-cloud)
- Logs: Centralized logging (ELK/Loki) with per-environment collectors
- Traces: Distributed tracing (Jaeger/Tempo) across service boundaries
- Alerting: Unified alerting with environment-aware routing
- Cost monitoring: Per-cloud cost dashboards, anomaly detection

### 8. Plan Disaster Recovery

| Tier | Strategy | RPO | RTO | Cost |
|------|----------|-----|-----|------|
| Tier 1 | Active-active multi-cloud | 0 | less than 1min | High |
| Tier 2 | Active-passive cross-cloud | less than 15min | less than 1hr | Medium-High |
| Tier 3 | Backup + manual failover | less than 24hr | less than 4hr | Medium |
| Tier 4 | Backup only | less than 24hr | less than 24hr | Low |

DR automation:
- Automated failover triggers (health checks, circuit breakers)
- Runbook automation for failover procedures
- Regular DR testing schedule (quarterly minimum)

## Output

Deliver:
- Architecture diagram: showing all environments, connectivity, data flow
- Workload placement matrix: workload to environment with justification
- Connectivity plan: network topology, bandwidth, latency requirements
- Security model: identity, network, data security per environment
- Cost estimate: TCO comparison, per-environment breakdown
- Migration plan: phased approach with rollback procedures (if applicable)

## Platform-Specific Notes

### OpenStack Integration
- Services: Nova (compute), Neutron (network), Cinder (block storage), Swift (object), Keystone (identity)
- Hybrid identity: Keystone federation with cloud IAM
- Networking: Provider networks, VLAN/VXLAN for multi-tenant isolation

### AWS Hybrid
- Outposts: AWS hardware in on-prem data center
- EKS Anywhere: Kubernetes on-prem with EKS compatibility
- Direct Connect: Dedicated network connection

### Azure Hybrid
- Azure Arc: Manage resources across environments from Azure
- Azure Stack: On-prem Azure services
- ExpressRoute: Dedicated private connection

### GCP Hybrid
- Anthos: Multi-cloud Kubernetes management
- Distributed Cloud: GCP services on-prem
- Cloud Interconnect: Dedicated network connection
