# Reference

# Error Handling for Next.js Applications

Robust error handling is essential for creating reliable user experiences. Next.js provides multiple mechanisms for handling errors at different levels: file-based error boundaries, API routes, and client-side error management.

## File-Based Error Boundaries

### error.tsx (Segment Error Boundary)

The `error.tsx` file catches errors in a route segment and its nested children.

```tsx
// app/dashboard/error.tsx
'use client';

import { useEffect } from 'react';
import Button from '@/components/Button';

type ErrorProps = {
  error: Error & { digest?: string };
  reset: () => void;
};

export default function DashboardError({ error, reset }: ErrorProps) {
  useEffect(() => {
    // Log error to monitoring service
    console.error('Dashboard error:', error);
    // Example: Sentry.captureException(error);
  }, [error]);

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50">
      <div className="max-w-md w-full text-center">
        <h2 className="text-2xl font-bold text-gray-900 mb-2">
          Something went wrong!
        </h2>
        <p className="text-gray-600 mb-4">
          We encountered an error while loading the dashboard.
        </p>
        {process.env.NODE_ENV === 'development' && (
          <details className="text-left bg-red-50 p-3 rounded-lg mb-4 text-sm">
            <summary className="font-mono text-red-600 cursor-pointer">
              Error Details
            </summary>
            <pre className="mt-2 text-xs overflow-auto">
              {error.message}
              {error.digest && `\nDigest: ${error.digest}`}
            </pre>
          </details>
        )}
        <Button onClick={() => reset()}>
          Try Again
        </Button>
      </div>
    </div>
  );
}
```

### global-error.tsx (Root Error Boundary)

The `global-error.tsx` file catches errors in the root layout and replaces the entire application.

```tsx
// app/global-error.tsx
'use client';

type GlobalErrorProps = {
  error: Error & { digest?: string };
  reset: () => void;
};

export default function GlobalError({ error, reset }: GlobalErrorProps) {
  return (
    <html>
      <body>
        <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-red-50 to-red-100">
          <div className="max-w-md w-full text-center">
            <div className="text-6xl mb-4">⚠️</div>
            <h1 className="text-3xl font-bold text-red-900 mb-2">
              Critical Error
            </h1>
            <p className="text-red-700 mb-4">
              The application encountered a critical error. Our team has been
              notified.
            </p>
            {process.env.NODE_ENV === 'development' && (
              <details className="text-left bg-red-100 p-4 rounded-lg mb-4">
                <summary className="font-mono text-red-900 cursor-pointer font-semibold">
                  Error Details (Development Only)
                </summary>
                <pre className="mt-2 text-xs overflow-auto text-red-800">
                  {error.message}
                  {error.stack}
                </pre>
              </details>
            )}
            <button
              onClick={() => reset()}
              className="px-6 py-2 bg-red-600 text-white rounded-lg font-semibold hover:bg-red-700 transition-colors"
            >
              Restart Application
            </button>
          </div>
        </div>
      </body>
    </html>
  );
}
```

### not-found.tsx (404 Handling)

```tsx
// app/not-found.tsx
import Link from 'next/link';

export default function NotFound() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50">
      <div className="max-w-md w-full text-center">
        <h1 className="text-6xl font-bold text-gray-900 mb-2">404</h1>
        <h2 className="text-2xl font-semibold text-gray-700 mb-4">
          Page Not Found
        </h2>
        <p className="text-gray-600 mb-6">
          The page you're looking for doesn't exist or has been moved.
        </p>
        <Link
          href="/"
          className="inline-block px-6 py-2 bg-blue-600 text-white rounded-lg font-semibold hover:bg-blue-700 transition-colors"
        >
          Return Home
        </Link>
      </div>
    </div>
  );
}

// app/products/[id]/not-found.tsx
import Link from 'next/link';

export default function ProductNotFound() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50">
      <div className="max-w-md w-full text-center">
        <h1 className="text-2xl font-bold text-gray-900 mb-2">
          Product Not Found
        </h1>
        <p className="text-gray-600 mb-4">
          The product you're looking for doesn't exist.
        </p>
        <Link
          href="/products"
          className="inline-block px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
        >
          View All Products
        </Link>
      </div>
    </div>
  );
}
```

## Client-Side Error Boundaries

### React Error Boundary Component

```tsx
// components/ErrorBoundary.tsx
'use client';

import React, { ReactNode, ReactElement } from 'react';

type Props = {
  children: ReactNode;
  fallback?: (error: Error, reset: () => void) => ReactElement;
};

type State = {
  hasError: boolean;
  error: Error | null;
};

export class ErrorBoundary extends React.Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    // Log to error reporting service
    console.error('Error caught by boundary:', error);
    console.error('Error info:', errorInfo);
    // Example: Sentry.captureException(error);
  }

  resetError = () => {
    this.setState({ hasError: false, error: null });
  };

  render() {
    if (this.state.hasError && this.state.error) {
      return this.props.fallback ? (
        this.props.fallback(this.state.error, this.resetError)
      ) : (
        <div className="p-4 bg-red-50 border border-red-200 rounded-lg">
          <h3 className="font-semibold text-red-900 mb-2">
            Something went wrong
          </h3>
          <p className="text-red-700 mb-4">{this.state.error.message}</p>
          <button
            onClick={this.resetError}
            className="px-4 py-2 bg-red-600 text-white rounded hover:bg-red-700"
          >
            Try Again
          </button>
        </div>
      );
    }

    return this.props.children;
  }
}

// Usage
<ErrorBoundary
  fallback={(error, reset) => (
    <div className="p-4 bg-red-50 rounded-lg">
      <h3 className="font-semibold text-red-900">Error occurred</h3>
      <button onClick={reset}>Retry</button>
    </div>
  )}
>
  <ComplexComponent />
</ErrorBoundary>
```

## Server-Side Error Handling

### Handling Errors in API Routes

```typescript
// app/api/users/route.ts
import { NextRequest, NextResponse } from 'next/server';

class ValidationError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'ValidationError';
  }
}

class DatabaseError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'DatabaseError';
  }
}

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const page = searchParams.get('page');

    // Validate input
    if (!page) {
      throw new ValidationError('Page parameter is required');
    }

    const pageNum = parseInt(page);
    if (isNaN(pageNum) || pageNum < 1) {
      throw new ValidationError('Page must be a positive number');
    }

    // Fetch data
    const users = await fetchUsers(pageNum);

    return NextResponse.json(
      {
        success: true,
        data: users,
        page: pageNum,
      },
      { status: 200 }
    );
  } catch (error) {
    return handleApiError(error);
  }
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();

    // Validate request body
    if (!body.name || !body.email) {
      throw new ValidationError('Name and email are required');
    }

    if (!isValidEmail(body.email)) {
      throw new ValidationError('Invalid email format');
    }

    // Create user
    const user = await createUser(body);

    return NextResponse.json(
      {
        success: true,
        data: user,
      },
      { status: 201 }
    );
  } catch (error) {
    return handleApiError(error);
  }
}

// Error handling utility
function handleApiError(error: unknown) {
  console.error('API error:', error);

  if (error instanceof ValidationError) {
    return NextResponse.json(
      {
        success: false,
        error: error.message,
        code: 'VALIDATION_ERROR',
      },
      { status: 400 }
    );
  }

  if (error instanceof DatabaseError) {
    return NextResponse.json(
      {
        success: false,
        error: 'Database operation failed',
        code: 'DATABASE_ERROR',
      },
      { status: 500 }
    );
  }

  // Generic error
  return NextResponse.json(
    {
      success: false,
      error: 'Internal server error',
      code: 'INTERNAL_ERROR',
    },
    { status: 500 }
  );
}

// Validation helpers
function isValidEmail(email: string): boolean {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}

async function fetchUsers(page: number) {
  try {
    // Simulate database query
    return [{ id: 1, name: 'John', email: 'john@example.com' }];
  } catch (error) {
    throw new DatabaseError('Failed to fetch users');
  }
}

async function createUser(data: any) {
  try {
    // Simulate database insert
    return { id: 1, ...data };
  } catch (error) {
    throw new DatabaseError('Failed to create user');
  }
}
```

### Route Handlers with Error Handling

```typescript
// app/api/products/[id]/route.ts
import { NextRequest, NextResponse } from 'next/server';

export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const id = params.id;

    // Validate ID format
    if (!isValidProductId(id)) {
      return NextResponse.json(
        { error: 'Invalid product ID format' },
        { status: 400 }
      );
    }

    // Fetch product
    const product = await fetchProductFromDatabase(id);

    if (!product) {
      return NextResponse.json(
        { error: 'Product not found' },
        { status: 404 }
      );
    }

    return NextResponse.json(product);
  } catch (error) {
    console.error('Error fetching product:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}

export async function PATCH(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const id = params.id;
    const body = await request.json();

    // Validate permissions
    const user = await getCurrentUser(request);
    if (!user) {
      return NextResponse.json(
        { error: 'Unauthorized' },
        { status: 401 }
      );
    }

    const product = await updateProduct(id, body);

    return NextResponse.json(product);
  } catch (error) {
    return NextResponse.json(
      { error: 'Failed to update product' },
      { status: 500 }
    );
  }
}

function isValidProductId(id: string): boolean {
  return /^[a-zA-Z0-9]+$/.test(id);
}

async function fetchProductFromDatabase(id: string) {
  // Simulated database query
  return null;
}

async function updateProduct(id: string, updates: any) {
  // Simulated database update
  return {};
}

async function getCurrentUser(request: NextRequest) {
  // Simulated user check
  return null;
}
```

## Graceful Degradation

### Handling Data Fetching Errors

```tsx
// components/ProductList.tsx
'use client';

import { useState, useEffect } from 'react';
import { fallbackProducts } from '@/data/fallback';

type Product = {
  id: string;
  name: string;
  price: number;
};

export default function ProductList() {
  const [products, setProducts] = useState<Product[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [useFallback, setUseFallback] = useState(false);

  useEffect(() => {
    const fetchProducts = async () => {
      try {
        const response = await fetch('/api/products', {
          signal: AbortSignal.timeout(5000), // 5 second timeout
        });

        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }

        const data = await response.json();
        setProducts(data);
      } catch (error) {
        console.error('Failed to fetch products:', error);
        setError('Failed to load products. Showing cached data.');
        setUseFallback(true);
        setProducts(fallbackProducts);
      } finally {
        setLoading(false);
      }
    };

    fetchProducts();
  }, []);

  if (loading) {
    return <div className="text-center py-8">Loading products...</div>;
  }

  return (
    <div>
      {error && (
        <div className="mb-4 p-4 bg-yellow-50 border border-yellow-200 rounded-lg">
          <p className="text-yellow-800">{error}</p>
          <button
            onClick={() => window.location.reload()}
            className="mt-2 px-4 py-2 bg-yellow-600 text-white rounded hover:bg-yellow-700"
          >
            Retry
          </button>
        </div>
      )}

      {useFallback && (
        <div className="mb-2 text-sm text-gray-600">
          Showing cached products (last updated: {new Date().toLocaleString()})
        </div>
      )}

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {products.map((product) => (
          <div key={product.id} className="p-4 border rounded-lg">
            <h3 className="font-semibold">{product.name}</h3>
            <p className="text-gray-600">${product.price}</p>
          </div>
        ))}
      </div>
    </div>
  );
}
```

### Retry Logic with Exponential Backoff

```typescript
// lib/retry.ts
type RetryOptions = {
  maxAttempts?: number;
  initialDelay?: number;
  maxDelay?: number;
  backoffMultiplier?: number;
};

export async function retryWithBackoff<T>(
  fn: () => Promise<T>,
  options: RetryOptions = {}
): Promise<T> {
  const {
    maxAttempts = 3,
    initialDelay = 1000,
    maxDelay = 10000,
    backoffMultiplier = 2,
  } = options;

  let lastError: Error | null = null;

  for (let attempt = 0; attempt < maxAttempts; attempt++) {
    try {
      return await fn();
    } catch (error) {
      lastError = error instanceof Error ? error : new Error(String(error));

      if (attempt < maxAttempts - 1) {
        const delay = Math.min(
          initialDelay * Math.pow(backoffMultiplier, attempt),
          maxDelay
        );
        await new Promise((resolve) => setTimeout(resolve, delay));
      }
    }
  }

  throw lastError;
}

// Usage
const data = await retryWithBackoff(
  () => fetch('/api/users').then((r) => r.json()),
  {
    maxAttempts: 3,
    initialDelay: 1000,
  }
);
```

## Error Logging and Monitoring

### Error Reporting Service Integration

```typescript
// lib/errorReporting.ts
import * as Sentry from '@sentry/nextjs';

type ErrorContext = {
  userId?: string;
  route?: string;
  component?: string;
  [key: string]: any;
};

export function reportError(
  error: Error,
  context?: ErrorContext
) {
  if (process.env.NODE_ENV === 'production') {
    Sentry.captureException(error, {
      contexts: {
        app: context,
      },
    });
  } else {
    console.error('Error:', error);
    console.error('Context:', context);
  }
}

export function captureMessage(
  message: string,
  level: 'info' | 'warning' | 'error' = 'info'
) {
  if (process.env.NODE_ENV === 'production') {
    Sentry.captureMessage(message, level);
  } else {
    console[level]('Message:', message);
  }
}
```

```tsx
// app/dashboard/error.tsx
'use client';

import { useEffect } from 'react';
import { reportError } from '@/lib/errorReporting';

type ErrorProps = {
  error: Error & { digest?: string };
  reset: () => void;
};

export default function DashboardError({ error, reset }: ErrorProps) {
  useEffect(() => {
    reportError(error, {
      component: 'DashboardPage',
      digest: error.digest,
    });
  }, [error]);

  return (
    <div className="p-4 bg-red-50 rounded-lg">
      <h2 className="font-semibold text-red-900">Error</h2>
      <button onClick={() => reset()}>Try Again</button>
    </div>
  );
}
```

## Error Recovery Strategies

### Form Submission Errors

```tsx
// components/ContactForm.tsx
'use client';

import { useState } from 'react';
import { FormData, submitContactForm } from '@/actions/contact';

export default function ContactForm() {
  const [state, setState] = useState<{
    status: 'idle' | 'pending' | 'success' | 'error';
    message?: string;
    fieldErrors?: Record<string, string>;
  }>({ status: 'idle' });

  const handleSubmit = async (formData: FormData) => {
    setState({ status: 'pending' });

    try {
      const result = await submitContactForm(formData);

      if (result.success) {
        setState({
          status: 'success',
          message: 'Message sent successfully!',
        });
      } else {
        setState({
          status: 'error',
          message: result.error || 'Failed to send message',
          fieldErrors: result.fieldErrors,
        });
      }
    } catch (error) {
      setState({
        status: 'error',
        message: 'An unexpected error occurred. Please try again.',
      });
    }
  };

  return (
    <form action={handleSubmit} className="space-y-4">
      {state.status === 'success' && (
        <div className="p-4 bg-green-50 border border-green-200 rounded-lg text-green-700">
          {state.message}
        </div>
      )}

      {state.status === 'error' && (
        <div className="p-4 bg-red-50 border border-red-200 rounded-lg text-red-700">
          {state.message}
        </div>
      )}

      <input
        type="text"
        name="name"
        placeholder="Your name"
        className="w-full px-4 py-2 border rounded-lg"
      />
      {state.fieldErrors?.name && (
        <p className="text-red-600 text-sm">{state.fieldErrors.name}</p>
      )}

      <textarea
        name="message"
        placeholder="Your message"
        className="w-full px-4 py-2 border rounded-lg"
      />
      {state.fieldErrors?.message && (
        <p className="text-red-600 text-sm">{state.fieldErrors.message}</p>
      )}

      <button
        type="submit"
        disabled={state.status === 'pending'}
        className="px-6 py-2 bg-blue-600 text-white rounded-lg disabled:opacity-50"
      >
        {state.status === 'pending' ? 'Sending...' : 'Send'}
      </button>
    </form>
  );
}
```

## Summary

Comprehensive error handling includes:
- File-based error boundaries (`error.tsx`, `global-error.tsx`)
- Client-side error boundaries for component isolation
- Server-side error handling in API routes
- Graceful degradation with fallback data
- Retry logic with exponential backoff
- Error reporting and monitoring
- User-friendly error messages
- Form validation and error recovery
