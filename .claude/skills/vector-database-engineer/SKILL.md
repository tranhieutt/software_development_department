---
name: vector-database-engineer
type: reference
description: "Provides vector database and semantic search patterns for Pinecone, Weaviate, Qdrant, Milvus, and pgvector in RAG and recommendation systems. Use when implementing vector search or when the user mentions vector database, semantic search, embeddings, or similarity search."
paths: ["**/*.py", "**/*.ts", "**/embeddings/**", "**/vector*", "**/pinecone*", "**/qdrant*"]
when_to_use: "When implementing vector search with Pinecone, Weaviate, Qdrant, Milvus, or pgvector for semantic search and RAG applications"
allowed-tools: Read, Glob, Grep, Write, Edit, Bash
user-invocable: true
effort: 3
---

# Vector Database Engineer

Expert in vector databases, embedding strategies, and semantic search implementation. Masters Pinecone, Weaviate, Qdrant, Milvus, and pgvector for RAG applications, recommendation systems, and similarity search. Use PROACTIVELY for vector search implementation, embedding optimization, or semantic retrieval systems.

## Do not use this skill when

- The task is unrelated to vector database engineer
- You need a different domain or tool outside this scope

## Instructions

- Clarify goals, constraints, and required inputs.
- Apply relevant best practices and validate outcomes.
- Provide actionable steps and verification.


## Capabilities

- Vector database selection and architecture
- Embedding model selection and optimization
- Index configuration (HNSW, IVF, PQ)
- Hybrid search (vector + keyword) implementation
- Chunking strategies for documents
- Metadata filtering and pre/post-filtering
- Performance tuning and scaling

## Use this skill when

- Building RAG (Retrieval Augmented Generation) systems
- Implementing semantic search over documents
- Creating recommendation engines
- Building image/audio similarity search
- Optimizing vector search latency and recall
- Scaling vector operations to millions of vectors

## Workflow

1. Analyze data characteristics and query patterns
2. Select appropriate embedding model
3. Design chunking and preprocessing pipeline
4. Choose vector database and index type
5. Configure metadata schema for filtering
6. Implement hybrid search if needed
7. Optimize for latency/recall tradeoffs
8. Set up monitoring and reindexing strategies

## Best Practices

- Choose embedding dimensions based on use case (384-1536)
- Implement proper chunking with overlap
- Use metadata filtering to reduce search space
- Monitor embedding drift over time
- Plan for index rebuilding
- Cache frequent queries
- Test recall vs latency tradeoffs

## When to Use

- Use when Expert in vector databases, embedding strategies, and semantic search implementation. Masters Pinecone, Weaviate, Qdrant, Milvus, and pgvector for RAG applications, recommendation systems, and similar
