# System Architecture Document

**System**: [System or product name]
**Author**: [Your name]
**Status**: Draft | In Review | Approved
**Date**: [YYYY-MM-DD]

---

## 1. Executive Summary

[2-3 sentences: What system is this? What problem does it solve? Who uses it?]

## 2. Context (C4 Level 1 — System Context)

[Describe the system in relation to its users and external dependencies]

**Users**:
- [User type 1]: [How they interact with the system]
- [User type 2]: [How they interact with the system]

**External Systems**:
- [External system 1]: [How this system integrates with it]
- [External system 2]: [How this system integrates with it]

## 3. Container View (C4 Level 2)

[Describe the major containers/services that make up the system]

| Container | Technology | Responsibility |
|-----------|------------|----------------|
| Web Frontend | React + TypeScript | User interface |
| API Server | Node.js / FastAPI / etc. | Business logic, REST API |
| Database | PostgreSQL | Data persistence |
| [Other] | [Tech] | [Purpose] |

**Communication**:
- Frontend → API: HTTPS REST
- API → Database: Connection pool (pg)
- [Other communication]

## 4. Key Architectural Decisions

| Decision | Choice | Rationale | ADR |
|----------|--------|-----------|-----|
| [Decision area] | [Choice made] | [Why] | [ADR link] |

## 5. Data Flow

[Describe the key data flows in the system]

### [Flow Name]
1. User submits [action] via frontend
2. Frontend calls `POST /api/v1/[endpoint]`
3. API validates input and calls [service]
4. [Service] writes to database
5. API returns 201 Created

## 6. Security

- **Authentication**: [JWT / OAuth2 / SAML]
- **Authorization**: [RBAC / ABAC / etc.]
- **Data Encryption**: [At rest and in transit]
- **Secrets Management**: [How secrets are stored]

## 7. Scalability & Reliability

| Concern | Strategy |
|---------|----------|
| Horizontal scaling | [Stateless services, load balancer] |
| Database scaling | [Read replicas, connection pooling] |
| Caching | [Redis for sessions/hot data] |
| Failure handling | [Retry policies, circuit breakers] |

## 8. Non-Functional Requirements

| Requirement | Target |
|-------------|--------|
| API response time (p99) | < 500ms |
| Uptime | 99.9% |
| [Other] | [Target] |

## 9. Open Questions & Future Work

- [ ] [Decision that needs to be made]
- [ ] [Planned future enhancement]
