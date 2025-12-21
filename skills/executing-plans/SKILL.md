---
name: nextjs:executing-plans
description: Test-driven development execution for Next.js - implementing features through tests, TDD workflows, and quality assurance
---

# Executing Plans - TDD Workflow for Next.js

This skill provides a test-driven development (TDD) workflow for implementing Next.js features, ensuring quality through tests while building features.

## Overview

TDD Execution Workflow:

- **Red Phase**: Write failing tests that define behavior
- **Green Phase**: Write minimum code to pass tests
- **Refactor Phase**: Improve code while keeping tests passing
- **Document Phase**: Add comments and documentation
- **Integrate Phase**: Merge and verify in context

## TDD Workflow

### Phase 1: Red - Write Failing Tests

Start by writing tests that define desired behavior:

```typescript
// tests/api/products.test.ts
import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { createMocks } from 'node-mocks-http';
import handler from '@/app/api/products/route';

describe('GET /api/products', () => {
  it('should return a list of products', async () => {
    const { req, res } = createMocks({
      method: 'GET',
    });

    await handler(req, res);

    expect(res._getStatusCode()).toBe(200);
    const data = JSON.parse(res._getData());
    expect(Array.isArray(data.products)).toBe(true);
  });

  it('should filter products by category', async () => {
    const { req, res } = createMocks({
      method: 'GET',
      query: { category: 'electronics' },
    });

    await handler(req, res);

    expect(res._getStatusCode()).toBe(200);
    const data = JSON.parse(res._getData());
    expect(data.products.every(p => p.category === 'electronics')).toBe(true);
  });

  it('should return 400 for invalid category', async () => {
    const { req, res } = createMocks({
      method: 'GET',
      query: { category: '' },
    });

    await handler(req, res);

    expect(res._getStatusCode()).toBe(400);
  });

  it('should paginate results', async () => {
    const { req, res } = createMocks({
      method: 'GET',
      query: { page: '2', limit: '10' },
    });

    await handler(req, res);

    expect(res._getStatusCode()).toBe(200);
    const data = JSON.parse(res._getData());
    expect(data.page).toBe(2);
    expect(data.products.length).toBeLessThanOrEqual(10);
  });
});

// Run tests - they should FAIL
// npm test -- products.test.ts
```

### Phase 2: Green - Write Minimum Code

Implement minimum code to pass tests:

```typescript
// app/api/products/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/db';

export async function GET(request: NextRequest) {
  try {
    // Parse query parameters
    const searchParams = request.nextUrl.searchParams;
    const category = searchParams.get('category');
    const page = parseInt(searchParams.get('page') || '1');
    const limit = parseInt(searchParams.get('limit') || '20');

    // Validation
    if (category !== null && category === '') {
      return NextResponse.json(
        { error: 'Category cannot be empty' },
        { status: 400 }
      );
    }

    // Build query
    let query = {};
    if (category) {
      query = { category };
    }

    // Execute query with pagination
    const products = await db.product.findMany({
      where: query,
      skip: (page - 1) * limit,
      take: limit,
    });

    // Return response
    return NextResponse.json({
      products,
      page,
      limit,
      total: await db.product.count({ where: query }),
    });
  } catch (error) {
    console.error('Error fetching products:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}

// Run tests - they should PASS
// npm test -- products.test.ts
```

### Phase 3: Refactor - Improve Code

Improve code while keeping tests passing:

```typescript
// app/api/products/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/db';
import { validatePaginationParams } from '@/lib/validators';

// Extract to helper
async function fetchProducts(
  category: string | null,
  page: number,
  limit: number
) {
  const query = category ? { category } : {};

  const [products, total] = await Promise.all([
    db.product.findMany({
      where: query,
      skip: (page - 1) * limit,
      take: limit,
      select: {
        id: true,
        name: true,
        category: true,
        price: true,
        image: true,
      },
    }),
    db.product.count({ where: query }),
  ]);

  return { products, total };
}

// Validate inputs
function validateInputs(category: string | null, page: number, limit: number) {
  if (category === '') {
    throw new Error('Category cannot be empty');
  }

  if (page < 1 || limit < 1) {
    throw new Error('Page and limit must be positive numbers');
  }

  if (limit > 100) {
    throw new Error('Limit cannot exceed 100');
  }
}

// Main handler
export async function GET(request: NextRequest) {
  try {
    const searchParams = request.nextUrl.searchParams;
    const category = searchParams.get('category');
    const page = parseInt(searchParams.get('page') || '1');
    const limit = parseInt(searchParams.get('limit') || '20');

    validateInputs(category, page, limit);

    const { products, total } = await fetchProducts(category, page, limit);

    return NextResponse.json({
      products,
      page,
      limit,
      total,
      hasMore: (page * limit) < total,
    });
  } catch (error) {
    console.error('Error fetching products:', error);
    return NextResponse.json(
      { error: error instanceof Error ? error.message : 'Internal server error' },
      { status: error instanceof Error ? 400 : 500 }
    );
  }
}

// Tests still PASS
```

## TDD Best Practices

### Test Organization

```typescript
// Organize tests by feature/layer
describe('Products API', () => {
  describe('GET /api/products', () => {
    describe('filtering', () => {
      it('should filter by category', () => {});
      it('should filter by price range', () => {});
      it('should filter by search term', () => {});
    });

    describe('pagination', () => {
      it('should paginate results', () => {});
      it('should handle invalid page number', () => {});
    });

    describe('error handling', () => {
      it('should return 400 for invalid input', () => {});
      it('should return 500 for server errors', () => {});
    });
  });

  describe('POST /api/products', () => {
    it('should create a new product', () => {});
    it('should validate required fields', () => {});
  });
});
```

### Test Fixtures & Helpers

```typescript
// tests/fixtures/products.ts
export const mockProduct = {
  id: '1',
  name: 'Test Product',
  category: 'electronics',
  price: 99.99,
  description: 'A test product',
  image: 'https://example.com/image.jpg',
};

export const mockProducts = [
  mockProduct,
  { ...mockProduct, id: '2', name: 'Product 2' },
  { ...mockProduct, id: '3', name: 'Product 3' },
];

// tests/helpers/db.ts
export async function seedDatabase() {
  await db.product.deleteMany({});
  await db.product.createMany({ data: mockProducts });
}

export async function clearDatabase() {
  await db.product.deleteMany({});
}

// Usage in tests
describe('Products', () => {
  beforeEach(async () => {
    await seedDatabase();
  });

  afterEach(async () => {
    await clearDatabase();
  });
});
```

### Assertion Examples

```typescript
describe('API Tests', () => {
  it('should handle various assertions', async () => {
    const response = await fetch('/api/products');
    const data = await response.json();

    // Basic assertions
    expect(response.status).toBe(200);
    expect(data).toBeDefined();
    expect(data.products).toHaveLength(3);

    // Array assertions
    expect(data.products).toContainEqual(expect.objectContaining({
      id: '1',
      name: 'Test Product',
    }));

    // Object assertions
    expect(data).toEqual({
      products: expect.any(Array),
      total: expect.any(Number),
      page: expect.any(Number),
    });

    // String assertions
    expect(data.products[0].name).toMatch(/product/i);
    expect(data.products[0].name).toHaveLength(12);

    // Error assertions
    const invalidResponse = await fetch('/api/products?category=');
    expect(invalidResponse.status).toBe(400);
  });
});
```

## Component Testing

### Server Component Testing

```typescript
// components/ProductList.test.tsx
import { render, screen } from '@testing-library/react';
import { ProductList } from '@/components/ProductList';
import { mockProducts } from '@/tests/fixtures';

// Mock data fetching
jest.mock('@/lib/db', () => ({
  getProducts: jest.fn(async () => mockProducts),
}));

describe('ProductList Component', () => {
  it('should render products', async () => {
    const { container } = render(await ProductList());

    expect(screen.getByText('Test Product')).toBeInTheDocument();
  });

  it('should show loading state', async () => {
    render(<Suspense fallback={<div>Loading...</div>}><ProductList /></Suspense>);
    expect(screen.getByText('Loading...')).toBeInTheDocument();
  });
});
```

### Client Component Testing

```typescript
// components/ProductFilter.test.tsx
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { ProductFilter } from '@/components/ProductFilter';

describe('ProductFilter Component', () => {
  it('should filter products on category change', async () => {
    const mockOnFilter = jest.fn();
    render(<ProductFilter onFilter={mockOnFilter} />);

    const select = screen.getByRole('combobox');
    fireEvent.change(select, { target: { value: 'electronics' } });

    await waitFor(() => {
      expect(mockOnFilter).toHaveBeenCalledWith({
        category: 'electronics',
      });
    });
  });

  it('should debounce search input', async () => {
    const mockOnFilter = jest.fn();
    render(<ProductFilter onFilter={mockOnFilter} debounceMs={300} />);

    const input = screen.getByPlaceholderText('Search...');

    fireEvent.change(input, { target: { value: 'test' } });
    expect(mockOnFilter).not.toHaveBeenCalled();

    await waitFor(() => {
      expect(mockOnFilter).toHaveBeenCalled();
    }, { timeout: 400 });
  });
});
```

## Integration Testing

### API + Component Integration

```typescript
// tests/integration/products.integration.test.ts
describe('Products Feature Integration', () => {
  beforeAll(async () => {
    await seedDatabase();
  });

  it('should fetch and display products', async () => {
    // Call API
    const response = await fetch('/api/products');
    const { products } = await response.json();

    expect(products).toHaveLength(3);

    // Render component with data
    const { getByText } = render(
      <ProductList initialProducts={products} />
    );

    // Verify rendering
    expect(getByText('Test Product')).toBeInTheDocument();
  });

  it('should filter and display results', async () => {
    // API call with filter
    const response = await fetch('/api/products?category=electronics');
    const { products } = await response.json();

    // All should be electronics
    expect(products.every(p => p.category === 'electronics')).toBe(true);
  });
});
```

## E2E Testing

### Playwright Example

```typescript
// tests/e2e/products.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Products Page', () => {
  test('should load products', async ({ page }) => {
    await page.goto('/products');

    // Wait for products to load
    await page.waitForSelector('[data-testid="product-card"]');

    // Verify content
    const cards = await page.locator('[data-testid="product-card"]').count();
    expect(cards).toBeGreaterThan(0);
  });

  test('should filter by category', async ({ page }) => {
    await page.goto('/products');

    // Select category filter
    await page.selectOption('select[name="category"]', 'electronics');

    // Wait for filtered results
    await page.waitForNavigation({ url: /category=electronics/ });

    // Verify filtering
    const products = await page.locator('[data-testid="product-card"]');
    const count = await products.count();
    expect(count).toBeGreaterThan(0);
  });

  test('should paginate', async ({ page }) => {
    await page.goto('/products');

    // Go to next page
    await page.click('button:has-text("Next")');

    // Verify pagination
    await expect(page).toHaveURL(/page=2/);
  });
});
```

## Continuous Testing

### Test Execution Workflow

```bash
# Run all tests
npm test

# Run specific test file
npm test -- products.test.ts

# Run with coverage
npm test -- --coverage

# Run in watch mode
npm test -- --watch

# Run E2E tests
npm run test:e2e

# Run performance tests
npm run test:performance

# Run accessibility tests
npm run test:a11y
```

### CI/CD Integration

```yaml
# .github/workflows/test.yml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Node
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run unit tests
        run: npm test -- --coverage

      - name: Run E2E tests
        run: npm run test:e2e

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/coverage-final.json
```

## Test Coverage

### Coverage Goals

```markdown
## Coverage Targets

| Type | Target | Reason |
|------|--------|--------|
| Statements | 80%+ | Comprehensive logic coverage |
| Branches | 75%+ | Edge case handling |
| Functions | 80%+ | All code paths tested |
| Lines | 80%+ | Overall code coverage |

## Critical Areas (100%)
- Authentication & authorization
- Data validation
- Error handling
- Security-sensitive code
```

### Coverage Report

```bash
# Generate coverage report
npm test -- --coverage

# HTML coverage report
npm test -- --coverage --reporters=default --reporters=html

# Open report
open coverage/index.html
```

## Testing Patterns

### Mocking Patterns

```typescript
// Mock external API
jest.mock('@/lib/api', () => ({
  fetchUser: jest.fn().mockResolvedValue({ id: '1', name: 'Test' }),
}));

// Mock database
jest.mock('@/lib/db', () => ({
  product: {
    findMany: jest.fn().mockResolvedValue(mockProducts),
    findById: jest.fn((id) => mockProducts.find(p => p.id === id)),
  },
}));

// Mock Next.js functions
jest.mock('next/navigation', () => ({
  useRouter: () => ({
    push: jest.fn(),
    query: { id: '1' },
  }),
  useSearchParams: () => new URLSearchParams('id=1'),
}));
```

### Error Testing

```typescript
describe('Error Handling', () => {
  it('should handle API errors gracefully', async () => {
    jest.spyOn(global, 'fetch').mockRejectedValueOnce(
      new Error('Network error')
    );

    await expect(fetchProducts()).rejects.toThrow('Network error');
  });

  it('should handle validation errors', async () => {
    const response = await fetch('/api/products', {
      method: 'POST',
      body: JSON.stringify({ name: '' }), // Invalid
    });

    expect(response.status).toBe(400);
    const { error } = await response.json();
    expect(error).toContain('name is required');
  });
});
```

## Performance Testing

```typescript
// tests/performance/products.perf.test.ts
import { performance } from 'perf_hooks';

describe('Performance', () => {
  it('should fetch products in < 100ms', async () => {
    const start = performance.now();
    await fetchProducts();
    const duration = performance.now() - start;

    expect(duration).toBeLessThan(100);
  });

  it('should render component in < 50ms', async () => {
    const start = performance.now();
    render(<ProductList products={mockProducts} />);
    const duration = performance.now() - start;

    expect(duration).toBeLessThan(50);
  });
});
```

## Resources

- [Vitest Documentation](https://vitest.dev)
- [React Testing Library](https://testing-library.com)
- [Playwright Documentation](https://playwright.dev)
- [Testing Best Practices](https://kentcdodds.com/blog/common-mistakes-with-react-testing-library)
