---
name: nextjs:project-structure
description: Organize Next.js projects with feature-based or layer-based folder structures
---

# Project Structure for Next.js Applications

Proper project organization is crucial for scalability, maintainability, and team collaboration. Next.js projects can follow feature-based or layer-based architectures depending on project complexity and team size.

## Core Principles

### Why Structure Matters

1. **Scalability**: Easy to add new features without affecting existing code
2. **Maintainability**: Clear relationships between files and modules
3. **Team Collaboration**: New developers quickly understand the codebase
4. **Performance**: Optimized module loading and code splitting
5. **Testing**: Isolated modules are easier to test
6. **Code Reusability**: Clear dependencies reduce duplication

## Feature-Based Architecture

Feature-based structure organizes code around business features. Each feature is self-contained with its own components, services, hooks, and styles.

### Structure Example

```
project/
├── app/
│   ├── layout.tsx
│   ├── page.tsx
│   ├── error.tsx
│   ├── loading.tsx
│   │
│   ├── (auth)/
│   │   ├── login/
│   │   │   ├── page.tsx
│   │   │   ├── error.tsx
│   │   │   └── layout.tsx
│   │   ├── register/
│   │   │   ├── page.tsx
│   │   │   └── layout.tsx
│   │   └── forgot-password/
│   │       └── page.tsx
│   │
│   ├── dashboard/
│   │   ├── layout.tsx
│   │   ├── page.tsx
│   │   ├── error.tsx
│   │   ├── (analytics)/
│   │   │   ├── page.tsx
│   │   │   ├── reports/
│   │   │   │   └── page.tsx
│   │   │   └── insights/
│   │   │       └── page.tsx
│   │   └── (settings)/
│   │       ├── profile/
│   │       │   └── page.tsx
│   │       ├── security/
│   │       │   └── page.tsx
│   │       └── preferences/
│   │           └── page.tsx
│   │
│   ├── products/
│   │   ├── page.tsx
│   │   ├── [id]/
│   │   │   ├── page.tsx
│   │   │   └── layout.tsx
│   │   └── create/
│   │       └── page.tsx
│   │
│   └── api/
│       ├── auth/
│       │   ├── login/route.ts
│       │   ├── logout/route.ts
│       │   └── refresh/route.ts
│       ├── products/
│       │   ├── route.ts
│       │   └── [id]/route.ts
│       └── users/
│           └── [id]/route.ts
│
├── features/
│   ├── auth/
│   │   ├── components/
│   │   │   ├── LoginForm.tsx
│   │   │   ├── RegisterForm.tsx
│   │   │   └── PasswordReset.tsx
│   │   ├── hooks/
│   │   │   ├── useLogin.ts
│   │   │   ├── useRegister.ts
│   │   │   └── useAuth.ts
│   │   ├── services/
│   │   │   └── authService.ts
│   │   ├── context/
│   │   │   └── AuthContext.tsx
│   │   ├── types/
│   │   │   └── auth.types.ts
│   │   └── index.ts
│   │
│   ├── products/
│   │   ├── components/
│   │   │   ├── ProductList.tsx
│   │   │   ├── ProductCard.tsx
│   │   │   ├── ProductForm.tsx
│   │   │   └── ProductDetail.tsx
│   │   ├── hooks/
│   │   │   ├── useProducts.ts
│   │   │   ├── useProduct.ts
│   │   │   └── useProductForm.ts
│   │   ├── services/
│   │   │   └── productService.ts
│   │   ├── types/
│   │   │   └── product.types.ts
│   │   ├── utils/
│   │   │   ├── productHelpers.ts
│   │   │   └── productValidation.ts
│   │   └── index.ts
│   │
│   └── dashboard/
│       ├── components/
│       │   ├── Analytics.tsx
│       │   ├── ReportGenerator.tsx
│       │   ├── ChartContainer.tsx
│       │   └── Sidebar.tsx
│       ├── hooks/
│       │   ├── useAnalytics.ts
│       │   └── useReports.ts
│       ├── services/
│       │   └── dashboardService.ts
│       ├── types/
│       │   └── dashboard.types.ts
│       └── index.ts
│
├── shared/
│   ├── components/
│   │   ├── Button/
│   │   │   ├── Button.tsx
│   │   │   ├── Button.module.css
│   │   │   └── index.ts
│   │   ├── Card/
│   │   │   ├── Card.tsx
│   │   │   ├── Card.module.css
│   │   │   └── index.ts
│   │   ├── Modal/
│   │   │   ├── Modal.tsx
│   │   │   ├── Modal.module.css
│   │   │   └── index.ts
│   │   ├── Input/
│   │   │   ├── Input.tsx
│   │   │   ├── Input.module.css
│   │   │   └── index.ts
│   │   ├── Layout/
│   │   │   ├── Header.tsx
│   │   │   ├── Footer.tsx
│   │   │   ├── Sidebar.tsx
│   │   │   └── index.ts
│   │   └── index.ts
│   ├── hooks/
│   │   ├── useLocalStorage.ts
│   │   ├── useDebounce.ts
│   │   ├── useFetch.ts
│   │   ├── useAsync.ts
│   │   └── index.ts
│   ├── utils/
│   │   ├── api.ts
│   │   ├── validators.ts
│   │   ├── formatters.ts
│   │   ├── classNames.ts
│   │   ├── storage.ts
│   │   └── index.ts
│   ├── types/
│   │   ├── common.types.ts
│   │   ├── api.types.ts
│   │   └── index.ts
│   ├── constants/
│   │   ├── config.ts
│   │   ├── endpoints.ts
│   │   ├── messages.ts
│   │   └── index.ts
│   └── styles/
│       ├── globals.css
│       ├── variables.css
│       └── reset.css
│
├── lib/
│   ├── db.ts
│   ├── cache.ts
│   ├── auth.ts
│   ├── logger.ts
│   └── storage.ts
│
├── config/
│   ├── env.ts
│   ├── site.config.ts
│   └── constants.ts
│
├── public/
│   ├── images/
│   ├── icons/
│   └── fonts/
│
├── .env.local
├── .env.example
├── tsconfig.json
├── next.config.js
└── package.json
```

## Layer-Based Architecture

Layer-based structure organizes code by technical layers: presentation, domain, data, and infrastructure.

### Structure Example

```
project/
├── app/                    # Next.js App Router
│   ├── layout.tsx
│   ├── page.tsx
│   ├── error.tsx
│   ├── not-found.tsx
│   │
│   ├── (auth)/
│   │   ├── login/page.tsx
│   │   ├── register/page.tsx
│   │   └── layout.tsx
│   │
│   ├── (main)/
│   │   ├── layout.tsx
│   │   ├── dashboard/page.tsx
│   │   ├── products/[id]/page.tsx
│   │   └── settings/page.tsx
│   │
│   └── api/                # API Layer
│       ├── auth/
│       ├── products/
│       └── middleware.ts
│
├── presentation/           # UI/Presentation Layer
│   ├── components/
│   │   ├── common/
│   │   │   ├── Button.tsx
│   │   │   ├── Card.tsx
│   │   │   ├── Modal.tsx
│   │   │   └── Input.tsx
│   │   ├── layout/
│   │   │   ├── Header.tsx
│   │   │   ├── Sidebar.tsx
│   │   │   ├── Footer.tsx
│   │   │   └── Navigation.tsx
│   │   ├── features/
│   │   │   ├── Auth/
│   │   │   │   ├── LoginForm.tsx
│   │   │   │   └── RegisterForm.tsx
│   │   │   ├── Products/
│   │   │   │   ├── ProductList.tsx
│   │   │   │   └── ProductCard.tsx
│   │   │   └── Dashboard/
│   │   │       ├── DashboardStats.tsx
│   │   │       └── Charts.tsx
│   │   └── index.ts
│   ├── pages/              # Page-specific components
│   │   ├── HomePage.tsx
│   │   ├── DashboardPage.tsx
│   │   ├── ProductsPage.tsx
│   │   └── NotFoundPage.tsx
│   └── hooks/              # UI-specific hooks
│       ├── useForm.ts
│       ├── useModal.ts
│       ├── usePagination.ts
│       └── useFilter.ts
│
├── domain/                 # Business Logic Layer
│   ├── models/             # Domain models
│   │   ├── User.ts
│   │   ├── Product.ts
│   │   ├── Order.ts
│   │   └── Review.ts
│   ├── services/           # Business logic
│   │   ├── AuthService.ts
│   │   ├── ProductService.ts
│   │   ├── OrderService.ts
│   │   └── UserService.ts
│   ├── repositories/       # Data access abstractions
│   │   ├── IUserRepository.ts
│   │   ├── IProductRepository.ts
│   │   └── IOrderRepository.ts
│   └── types/              # Domain types
│       ├── auth.types.ts
│       ├── product.types.ts
│       ├── order.types.ts
│       └── user.types.ts
│
├── infrastructure/         # Infrastructure Layer
│   ├── api/                # External API clients
│   │   ├── httpClient.ts
│   │   ├── userApi.ts
│   │   ├── productApi.ts
│   │   └── orderApi.ts
│   ├── database/           # Database implementations
│   │   ├── prisma.ts
│   │   ├── userRepository.ts
│   │   ├── productRepository.ts
│   │   └── orderRepository.ts
│   ├── cache/              # Caching layer
│   │   ├── cacheService.ts
│   │   └── redis.ts
│   └── storage/            # File storage
│       ├── uploadService.ts
│       └── s3Client.ts
│
├── shared/                 # Shared utilities
│   ├── utils/
│   │   ├── validators.ts
│   │   ├── formatters.ts
│   │   ├── helpers.ts
│   │   └── constants.ts
│   ├── types/
│   │   ├── common.types.ts
│   │   └── api.types.ts
│   ├── styles/
│   │   ├── globals.css
│   │   ├── variables.css
│   │   └── reset.css
│   └── config/
│       ├── env.ts
│       └── constants.ts
│
├── tests/                  # Test files
│   ├── unit/
│   ├── integration/
│   ├── e2e/
│   └── __mocks__/
│
└── config files...
```

## Hybrid Approach (Recommended)

Combine features and layers for flexibility:

```
project/
├── app/                    # Next.js App Router
├── features/               # Feature modules
│   ├── auth/
│   │   ├── components/
│   │   ├── hooks/
│   │   ├── services/
│   │   ├── types/
│   │   └── index.ts
│   ├── products/
│   ├── dashboard/
│   └── ...
├── shared/                 # Shared across features
│   ├── components/
│   ├── hooks/
│   ├── utils/
│   ├── types/
│   └── styles/
├── infrastructure/         # External integrations
│   ├── api/
│   ├── database/
│   └── cache/
├── lib/                    # Utilities
├── config/
└── public/
```

## Module Index Files

Use index files to control public APIs:

```typescript
// features/products/index.ts
export { useProducts } from './hooks/useProducts';
export { useProduct } from './hooks/useProduct';
export { ProductList } from './components/ProductList';
export { ProductCard } from './components/ProductCard';
export type { Product, ProductFilters } from './types/product.types';

// Not exported (internal only)
// - ProductForm
// - productService
```

```typescript
// shared/components/index.ts
export { Button } from './Button/Button';
export { Card } from './Card/Card';
export { Modal } from './Modal/Modal';
export { Input } from './Input/Input';
export { Header } from './Layout/Header';
export { Footer } from './Layout/Footer';
export { Sidebar } from './Layout/Sidebar';
```

## File Naming Conventions

```
components/
├── Button.tsx              # Component
├── Button.module.css       # Component styles
├── Button.test.tsx         # Component tests
├── index.ts                # Barrel export

hooks/
├── useAuth.ts              # Hook
├── useAuth.test.ts         # Hook tests

services/
├── authService.ts          # Service
├── authService.test.ts     # Service tests

types/
├── auth.types.ts           # Types only
├── product.types.ts        # Types only

utils/
├── validators.ts
├── formatters.ts
├── helpers.ts
```

## Directory with Clear Responsibilities

```typescript
// Feature structure - clear ownership
features/auth/
  ├── README.md             # Feature documentation
  ├── components/           # Auth UI components
  ├── hooks/                # Auth-specific hooks
  ├── services/             # Business logic
  ├── context/              # Auth context
  ├── types/                # Auth types
  ├── utils/                # Auth utilities
  └── index.ts              # Public API

// Use case: Adding new auth feature
// Developer only needs to modify features/auth/
// No touching other features
```

## Monorepo Structure (Optional)

For larger projects:

```
monorepo/
├── packages/
│   ├── web/                # Next.js app
│   │   ├── app/
│   │   ├── features/
│   │   ├── shared/
│   │   └── package.json
│   ├── api/                # Node API
│   │   ├── src/
│   │   └── package.json
│   ├── ui-library/         # Shared UI components
│   │   ├── components/
│   │   └── package.json
│   ├── types/              # Shared types
│   │   └── package.json
│   └── config/             # Shared configuration
│       └── package.json
│
├── tsconfig.json           # Root TypeScript config
├── package.json            # Root package config
└── turbo.json              # Turbo monorepo config
```

## Scalability Guidelines

### When to Add New Directories

1. **Feature has >5 components**: Create feature folder
2. **Shared utility used by 3+ features**: Move to shared
3. **Business logic needed by API**: Create service
4. **Type used by multiple features**: Create types folder
5. **Complex data fetching**: Create hooks folder

### When to Refactor

1. **Feature folder exceeds 1500 lines total**: Split into sub-features
2. **Components folder has >15 files**: Group by purpose
3. **Shared has unused code**: Archive or remove
4. **API becomes a bottleneck**: Extract to separate layer
5. **Tests are slow**: Move to separate test directory

## Configuration Organization

```typescript
// config/env.ts
export const config = {
  api: {
    baseUrl: process.env.NEXT_PUBLIC_API_URL,
    timeout: parseInt(process.env.API_TIMEOUT || '30000'),
  },
  auth: {
    tokenKey: 'auth_token',
    refreshTokenKey: 'refresh_token',
  },
  features: {
    analytics: process.env.NEXT_PUBLIC_ANALYTICS_ENABLED === 'true',
    beta: process.env.NEXT_PUBLIC_BETA_FEATURES === 'true',
  },
} as const;

// Usage
import { config } from '@/config/env';
const baseUrl = config.api.baseUrl;
```

## Best Practices

1. **Keep features independent**: Features shouldn't import from other features
2. **Use barrel exports**: `index.ts` files for clean imports
3. **Clear separation of concerns**: UI, logic, and data access
4. **Consistent naming**: Follow conventions across the project
5. **Document structure**: README files explain module purpose
6. **Type safety**: Centralized types with proper exports
7. **One reason to change**: Single responsibility principle
8. **Minimize nesting**: Max 4 levels deep

## Migration Strategy

Moving from flat to structured:

1. Create feature folders gradually
2. Move related components together
3. Extract shared utilities progressively
4. Update imports as you go
5. Use barrel exports for compatibility
6. Test thoroughly after each change

## Summary

Well-organized Next.js projects:
- Scale with team size
- Enable rapid feature development
- Reduce onboarding time
- Support code reusability
- Improve testing and debugging
- Facilitate long-term maintenance
