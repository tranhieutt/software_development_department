---
name: nestjs-expert
type: reference
description: "Provides NestJS patterns for modules, controllers, providers, guards, interceptors, and microservices. Use when working with NestJS TypeScript files (*.module.ts, *.controller.ts, *.service.ts) or when the user mentions NestJS, Nest.js, or NestJS modules."
paths: ["**/*.module.ts", "**/*.controller.ts", "**/*.service.ts", "**/*.guard.ts", "**/nest-cli.json"]
effort: 3
allowed-tools: Read, Glob, Grep, Write, Edit, Bash
user-invocable: true
when_to_use: "When building NestJS backend APIs, microservices, or guards/interceptors"
---

# NestJS Expert

## Critical rules (non-obvious)

- **Circular dependencies**: use `forwardRef(() => ServiceB)` in both modules; better — restructure to avoid
- **Global modules**: use `@Global()` sparingly; prefer explicit imports to keep modules testable
- **`APP_GUARD` / `APP_INTERCEPTOR`**: registered in AppModule providers, not in individual modules
- **Lifecycle hooks order**: `onModuleInit` → `onApplicationBootstrap` → ready; `onModuleDestroy` → `beforeApplicationShutdown` → `onApplicationShutdown`
- **Never use `req.user` without type assertion** — it's `any` from Passport; extend `Express.Request`

## Module structure

```typescript
@Module({
  imports: [TypeOrmModule.forFeature([User]), JwtModule],
  controllers: [UserController],
  providers: [UserService, UserRepository],
  exports: [UserService],   // export what other modules need
})
export class UserModule {}
```

## Controller with validation

```typescript
@Controller("users")
@UseGuards(JwtAuthGuard)
export class UserController {
  constructor(private readonly userService: UserService) {}

  @Get(":id")
  @HttpCode(HttpStatus.OK)
  async findOne(@Param("id", ParseUUIDPipe) id: string, @CurrentUser() user: User) {
    return this.userService.findOneOrFail(id);
  }

  @Post()
  @Roles(Role.ADMIN)
  async create(@Body() dto: CreateUserDto) {
    return this.userService.create(dto);
  }
}
```

## Service with repository pattern

```typescript
@Injectable()
export class UserService {
  constructor(
    @InjectRepository(User) private readonly repo: Repository<User>,
    private readonly eventEmitter: EventEmitter2,
  ) {}

  async findOneOrFail(id: string): Promise<User> {
    const user = await this.repo.findOne({ where: { id } });
    if (!user) throw new NotFoundException(`User ${id} not found`);
    return user;
  }

  async create(dto: CreateUserDto): Promise<User> {
    const user = this.repo.create(dto);
    const saved = await this.repo.save(user);
    this.eventEmitter.emit("user.created", new UserCreatedEvent(saved));
    return saved;
  }
}
```

## JWT auth guard pattern

```typescript
@Injectable()
export class JwtAuthGuard extends AuthGuard("jwt") {
  canActivate(context: ExecutionContext) {
    return super.canActivate(context);
  }
  handleRequest(err: any, user: any) {
    if (err || !user) throw err ?? new UnauthorizedException();
    return user;
  }
}

// Custom decorator for current user
export const CurrentUser = createParamDecorator(
  (_, ctx: ExecutionContext) => ctx.switchToHttp().getRequest().user,
);
```

## Global exception filter

```typescript
@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const status = exception instanceof HttpException
      ? exception.getStatus()
      : HttpStatus.INTERNAL_SERVER_ERROR;
    ctx.getResponse().status(status).json({
      statusCode: status,
      message: exception instanceof HttpException ? exception.message : "Internal server error",
      timestamp: new Date().toISOString(),
    });
  }
}
// Register: app.useGlobalFilters(new AllExceptionsFilter())
```

## Interceptor: response transform + timing

```typescript
@Injectable()
export class TransformInterceptor implements NestInterceptor {
  intercept(ctx: ExecutionContext, next: CallHandler): Observable<any> {
    const start = Date.now();
    return next.handle().pipe(
      map(data => ({ data, duration: Date.now() - start, timestamp: new Date() })),
    );
  }
}
```

## Validation DTO

```typescript
export class CreateUserDto {
  @IsEmail()
  email: string;

  @IsString()
  @MinLength(8)
  @Matches(/^(?=.*[A-Z])(?=.*\d)/, { message: "Must contain uppercase and digit" })
  password: string;

  @IsEnum(Role)
  @IsOptional()
  role?: Role = Role.USER;
}
// Global: app.useGlobalPipes(new ValidationPipe({ transform: true, whitelist: true }))
```

## Config with validation

```typescript
// app.module.ts
ConfigModule.forRoot({
  isGlobal: true,
  validationSchema: Joi.object({
    NODE_ENV: Joi.string().valid("development", "production", "test").required(),
    PORT: Joi.number().default(3000),
    DATABASE_URL: Joi.string().required(),
    JWT_SECRET: Joi.string().min(32).required(),
  }),
})
```

## Common pitfalls

| Pitfall | Fix |
|---|---|
| Injecting service into wrong module | Export service from its module; import module |
| Missing `async` on lifecycle hooks | `async onModuleInit()` if doing DB work on startup |
| `ValidationPipe` without `whitelist: true` | Strips extra fields; prevents mass assignment |
| Blocking the event loop in provider | Use `async/await`; never synchronous I/O |
| Missing `enableShutdownHooks()` | Required for `onModuleDestroy` to fire in Docker |
