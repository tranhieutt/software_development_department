---
paths:
  - "src/ai/**"
  - "src/ml/**"
  - "src/recommendations/**"
---

# AI/ML Code Rules

- AI/ML inference budget: profile with realistic data to verify acceptable latency — never guess
- All model parameters and thresholds must be configurable from environment or config files (not hardcoded)
- AI systems must be debuggable: implement logging for model inputs, outputs, and confidence scores
- Recommendation and ranking systems must expose why scores were assigned (explainability)
- Prefer well-tested libraries over custom ML implementations for standard tasks
- All AI pipelines must support A/B testing and shadow mode evaluation before full rollout
- All ML model state machines and transitions must emit events for monitoring
- Never trust AI-generated content without validation against safety and business rules
