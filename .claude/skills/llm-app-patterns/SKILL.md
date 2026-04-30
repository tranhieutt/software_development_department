---
name: llm-app-patterns
type: reference
description: "Provides architectural patterns for LLM-powered applications and AI assistants, including prompt engineering, RAG, agent loops, conversation management, and evaluation. Use when building AI-based features, chatbots, or complex AI system architectures."
paths: ["**/*.py", "**/*.ts", "**/openai*", "**/anthropic*", "**/langchain*", "**/chatbot*", "**/assistant*"]
effort: 3
allowed-tools: Read, Glob, Grep, Write, Edit, Bash
user-invocable: true
when_to_use: "When designing LLM applications, building AI assistants/chatbots, implementing RAG pipelines, or setting up agent architectures."
---

# LLM Application & AI Assistant Patterns

## Resources

- `resources/implementation-playbook.md` for detailed patterns and examples.

## Architecture decision matrix

| Pattern | Use when | Cost |
|---|---|---|
| Simple RAG | FAQ, docs Q&A | Low |
| Hybrid RAG (semantic + BM25) | Mixed query types | Medium |
| Function calling | Structured tool use | Low |
| ReAct agent | Multi-step reasoning | Medium |
| Plan-and-execute | Complex decomposable tasks | High |
| Multi-agent | Research, critique-refine | Very High |

## RAG: critical config numbers

```python
CHUNK_CONFIG = {
    "chunk_size": 512,       # tokens — sweet spot for most docs
    "chunk_overlap": 50,     # prevents context loss at boundaries
    "separators": ["\n\n", "\n", ". ", " "],
}
# Hybrid search alpha: 1.0=semantic only, 0.0=BM25 only, 0.5=balanced
```

## RAG: retrieval strategies

```python
# Basic: semantic search
results = vector_db.similarity_search(embed(query), top_k=5)

# Better: hybrid (semantic + keyword via RRF)
def hybrid_search(query, alpha=0.5):
    return rrf_merge(vector_db.search(query), bm25_search(query), alpha)

# Best for recall: multi-query (3 variations, deduplicate)
queries = llm.generate_variations(query, n=3)
results = deduplicate([semantic_search(q) for q in queries])
```

## RAG: generation prompt template

```python
RAG_PROMPT = """Answer based ONLY on the context below.
If insufficient, say "I don't have enough information."

Context: {context}
Question: {question}
Answer:"""
```

## Agent: function calling loop

```python
messages = [{"role": "user", "content": question}]
while True:
    response = llm.chat(messages=messages, tools=TOOLS, tool_choice="auto")
    if not response.tool_calls:
        return response.content
    for call in response.tool_calls:
        result = execute_tool(call.name, call.arguments)
        messages.append({"role": "tool", "tool_call_id": call.id, "content": str(result)})
```

## Production: caching (only temperature=0 responses)

```python
def get_or_generate(prompt, model, **kwargs):
    deterministic = kwargs.get("temperature", 1.0) == 0
    if deterministic:
        key = sha256(f"{model}:{prompt}:{json.dumps(kwargs, sort_keys=True)}")
        if cached := redis.get(key): return cached
    response = llm.generate(prompt, model=model, **kwargs)
    if deterministic: redis.setex(key, 3600, response)
    return response
```

## Production: retry + fallback

```python
from tenacity import retry, wait_exponential, stop_after_attempt

@retry(wait=wait_exponential(multiplier=1, min=4, max=60), stop=stop_after_attempt(5))
def call_llm(prompt): return llm.generate(prompt)

# Fallback chain
for model in [primary] + fallbacks:
    try: return llm.generate(prompt, model=model)
    except (RateLimitError, APIError): continue
```

## LLMOps: key metrics

```
Latency : p50, p99 response time
Quality : satisfaction (thumbs), task completion %, hallucination rate
Cost    : cost_per_request, tokens_per_request, cache_hit_rate
Health  : error_rate, timeout_rate, retry_rate
```

## Embedding model selection

| Model | Dims | Cost | Use |
|---|---|---|---|
| text-embedding-3-small | 1536 | $0.02/1M | Most cases |
| text-embedding-3-large | 3072 | $0.13/1M | High accuracy |
| bge-large (local) | 1024 | Free | Self-hosted |
