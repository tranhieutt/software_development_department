---
name: django-patterns
type: reference
description: "Provides expert-level Django development patterns covering App Router (indirectly via REST/GraphQL), async views, DRF, Celery, signals, middleware, and performance optimization. Use when building complex Django 5.x applications or identifying N+1 query issues."
paths: ["**/*.py", "**/manage.py", "**/settings.py", "**/urls.py", "**/serializers.py"]
effort: 3
allowed-tools: Read, Glob, Grep, Write, Edit, Bash
user-invocable: true
when_to_use: "When building Django 5.x applications requiring async support, background tasks (Celery), real-time features (Channels), or advanced ORM optimization."
---

# Django & DRF Professional Patterns

## Core Expertise
- **Modern Django:** 5.x features, async views/middleware, ASGI deployment.
- **Background & Real-time:** Celery integration, Django Channels.
- **ORM Optimization:** select_related, prefetch_related, custom managers.
- **Security:** JWT auth, OAuth2, RBAC, protection against SQLi/XSS/CSRF.

## Critical rules (non-obvious)

- **N+1 queries**: always use `select_related` (FK) / `prefetch_related` (M2M) â€” never iterate and query inside loops
- **`get_or_create` race condition**: wrap in `transaction.atomic()` in concurrent environments
- **Never call `save()` inside `pre_save` signal** â€” causes infinite recursion; use `update_fields`
- **`bulk_create` skips signals and `save()`** â€” don't use when signal logic is required
- **Migrations on large tables**: use `RunSQL` with `CONCURRENTLY` index creation to avoid locks

## ORM: select_related vs prefetch_related

```python
# FK / OneToOne â†’ select_related (JOIN)
books = Book.objects.select_related("author", "author__publisher").all()

# M2M / reverse FK â†’ prefetch_related (separate query)
authors = Author.objects.prefetch_related("books", "books__tags").all()

# Custom prefetch with queryset
from django.db.models import Prefetch
Author.objects.prefetch_related(
    Prefetch("books", queryset=Book.objects.filter(published=True), to_attr="active_books")
)
```

## ORM: annotations and aggregations

```python
from django.db.models import Count, Avg, Q, F, Value
from django.db.models.functions import Coalesce

Author.objects.annotate(
    book_count=Count("books"),
    avg_rating=Coalesce(Avg("books__rating"), Value(0.0)),
    high_rated=Count("books", filter=Q(books__rating__gte=4)),
).filter(book_count__gt=0).order_by("-book_count")
```

## ORM: F expressions (avoid race conditions)

```python
# BAD â€” race condition
product = Product.objects.get(pk=pk)
product.stock -= quantity
product.save()

# GOOD â€” atomic at DB level
Product.objects.filter(pk=pk).update(stock=F("stock") - quantity)
```

## Views: class-based view pattern

```python
from django.views import View
from django.contrib.auth.mixins import LoginRequiredMixin

class OrderDetailView(LoginRequiredMixin, View):
    def get(self, request, pk):
        order = get_object_or_404(Order.objects.select_related("user"), pk=pk, user=request.user)
        return JsonResponse(OrderSerializer(order).data)
```

## DRF: serializer with validation

```python
class ProductSerializer(serializers.ModelSerializer):
    class Meta:
        model = Product
        fields = ["id", "name", "price", "stock"]
        read_only_fields = ["id"]

    def validate_price(self, value):
        if value <= 0:
            raise serializers.ValidationError("Price must be positive.")
        return value

    def validate(self, data):  # cross-field
        if data["stock"] == 0 and data.get("is_featured"):
            raise serializers.ValidationError("Out-of-stock products cannot be featured.")
        return data
```

## DRF: ViewSet with custom actions

```python
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response

class ProductViewSet(viewsets.ModelViewSet):
    queryset = Product.objects.select_related("category")
    serializer_class = ProductSerializer
    permission_classes = [IsAuthenticated]

    @action(detail=True, methods=["post"], url_path="archive")
    def archive(self, request, pk=None):
        product = self.get_object()
        product.is_archived = True
        product.save(update_fields=["is_archived"])
        return Response(status=status.HTTP_204_NO_CONTENT)
```

## DRF: filtering + pagination

```python
# settings.py
REST_FRAMEWORK = {
    "DEFAULT_FILTER_BACKENDS": ["django_filters.rest_framework.DjangoFilterBackend"],
    "DEFAULT_PAGINATION_CLASS": "rest_framework.pagination.CursorPagination",
    "PAGE_SIZE": 20,
}

# viewset
class ProductViewSet(viewsets.ReadOnlyModelViewSet):
    filterset_fields = {"price": ["gte", "lte"], "category": ["exact"]}
    ordering_fields = ["price", "created_at"]
    search_fields = ["name", "description"]
```

## Celery task pattern

```python
from celery import shared_task
from django.db import transaction

@shared_task(bind=True, max_retries=3, default_retry_delay=60)
def send_order_email(self, order_id: int):
    try:
        order = Order.objects.select_related("user").get(pk=order_id)
        send_email(order.user.email, order)
    except Order.DoesNotExist:
        return  # don't retry if deleted
    except Exception as exc:
        raise self.retry(exc=exc)

# Dispatch after DB commit â€” avoids race condition
def create_order(data):
    with transaction.atomic():
        order = Order.objects.create(**data)
        transaction.on_commit(lambda: send_order_email.delay(order.pk))
```

## Common pitfalls

| Pitfall | Fix |
|---|---|
| N+1 queries in serializer | `select_related` / `prefetch_related` on queryset |
| `objects.all()` in views | Always filter + limit; never expose unbounded querysets |
| Storing secrets in settings.py | Use `django-environ` or environment variables |
| `DateTimeField(auto_now_add=True)` not testable | Use `default=timezone.now` for overridable defaults |
| Sync ORM in async views | Use `sync_to_async` or Django 4.1+ async ORM |
