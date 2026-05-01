---
name: dotnet-backend-patterns
type: reference
description: "Provides .NET and ASP.NET Core patterns for REST APIs, Entity Framework, dependency injection, and middleware. Use when working with C# files (*.cs, *.csproj) or when the user mentions .NET, ASP.NET Core, C#, or Entity Framework."
paths: ["**/*.cs", "**/*.csproj", "**/*.sln", "**/appsettings*.json"]
effort: 3
allowed-tools: Read, Glob, Grep
user-invocable: true
when_to_use: "When building C#/.NET backend APIs, MCP servers, or enterprise applications with Entity Framework or Dapper"
---

# .NET Backend Development Patterns

C#/.NET patterns for production-grade APIs, MCP servers, and enterprise backends.

## API Structure (Minimal API + Controllers)

\`\`\`csharp
// Program.cs - Minimal API
var builder = WebApplication.CreateBuilder(args);
builder.Services.AddDbContext<AppDbContext>(o => o.UseNpgsql(connStr));
builder.Services.AddScoped<IOrderService, OrderService>();

var app = builder.Build();
app.MapGet("/orders/{id}", async (int id, IOrderService svc) =>
    await svc.GetByIdAsync(id) is { } order ? Results.Ok(order) : Results.NotFound());
\`\`\`

## Dependency Injection Patterns

\`\`\`csharp
// Register services
builder.Services.AddScoped<IPaymentService, StripePaymentService>();
builder.Services.AddSingleton<ICacheService, RedisCacheService>();
builder.Services.AddHttpClient<IApiClient, ExternalApiClient>(client => {
    client.BaseAddress = new Uri("https://api.external.com");
});
\`\`\`

Lifetime guide: Singleton (stateless/cache), Scoped (per-request), Transient (stateless utility).

## Entity Framework Core

\`\`\`csharp
// DbContext with conventions
public class AppDbContext : DbContext {
    public DbSet<Order> Orders => Set<Order>();
    protected override void OnModelCreating(ModelBuilder builder) {
        builder.Entity<Order>().HasIndex(o => o.UserId);
        builder.Entity<Order>().Property(o => o.Total).HasPrecision(18, 2);
    }
}
\`\`\`

Performance tips:
- Use `.AsNoTracking()` for read-only queries
- Avoid N+1 with `.Include()` or projection
- Use compiled queries for hot paths

## Middleware Pipeline

\`\`\`csharp
app.UseMiddleware<RequestLoggingMiddleware>();
app.UseAuthentication();
app.UseAuthorization();
app.UseRateLimiter();
app.MapControllers();
\`\`\`

## Error Handling

\`\`\`csharp
// Global exception handler
app.UseExceptionHandler(err => err.Run(async context => {
    var exception = context.Features.Get<IExceptionHandlerFeature>()?.Error;
    var (status, message) = exception switch {
        NotFoundException => (404, exception.Message),
        UnauthorizedAccessException => (403, "Forbidden"),
        _ => (500, "Internal server error")
    };
    context.Response.StatusCode = status;
    await context.Response.WriteAsJsonAsync(new { error = message });
}));
\`\`\`

## Configuration (IOptions pattern)

\`\`\`csharp
builder.Services.Configure<StripeSettings>(
    builder.Configuration.GetSection("Stripe"));

// Usage
public class PaymentService(IOptions<StripeSettings> opts) {
    private readonly string _key = opts.Value.SecretKey;
}
\`\`\`

## Testing

\`\`\`csharp
// Integration test with WebApplicationFactory
public class OrderApiTests : IClassFixture<WebApplicationFactory<Program>> {
    private readonly HttpClient _client;
    [Fact]
    public async Task GetOrder_ReturnsOk() {
        var response = await _client.GetAsync("/orders/1");
        response.StatusCode.Should().Be(HttpStatusCode.OK);
    }
}
\`\`\`

## Related Skills

- `backend-architect` — architecture decisions
- `database-architect` — schema design
- `drizzle-orm-expert` — Node.js ORM alternative
