# Reference

# Testing with Vitest

High-performance testing framework for Next.js projects with native ESM, TypeScript, and instant feedback loop.

## Installation

```bash
npm install --save-dev vitest @vitest/ui @vitest/coverage-v8 jsdom @testing-library/react @testing-library/jest-dom
# or
yarn add --dev vitest @vitest/ui @vitest/coverage-v8 jsdom @testing-library/react @testing-library/jest-dom
```

## Configuration

### vitest.config.ts

```typescript
import { defineConfig } from 'vitest/config'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig({
  plugins: [react()],
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: ['./vitest.setup.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html', 'lcov'],
      exclude: [
        'node_modules/',
        'dist/',
        '.next/',
        '**/*.d.ts',
        '**/*.config.*',
        '**/mockData',
        '**/__tests__/**',
      ],
    },
    include: ['**/*.test.ts', '**/*.test.tsx'],
    exclude: ['node_modules', 'dist', '.idea', '.git', '.cache'],
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
      '@/components': path.resolve(__dirname, './src/components'),
      '@/lib': path.resolve(__dirname, './src/lib'),
    },
  },
})
```

### vitest.setup.ts

```typescript
import '@testing-library/jest-dom'
import { expect, afterEach, vi } from 'vitest'
import { cleanup } from '@testing-library/react'

// Cleanup after each test
afterEach(() => {
  cleanup()
})

// Mock next/router
vi.mock('next/router', () => ({
  useRouter: vi.fn(() => ({
    route: '/',
    pathname: '/',
    query: {},
    asPath: '/',
    push: vi.fn(),
    replace: vi.fn(),
    reload: vi.fn(),
    back: vi.fn(),
    prefetch: vi.fn(),
    beforePopState: vi.fn(),
    events: {
      on: vi.fn(),
      off: vi.fn(),
      emit: vi.fn(),
    },
    isFallback: false,
  })),
}))

// Mock next/image
vi.mock('next/image', () => ({
  default: (props: any) => ({
    __esModule: true,
    default: (props: any) => <img {...props} />,
  }),
}))

// Global test utilities
declare global {
  namespace Vi {
    interface Matchers<R> {
      toBeInTheDocument(): R
      toBeVisible(): R
      toBeDisabled(): R
      toHaveTextContent(text: string | RegExp): R
    }
  }
}
```

### package.json

```json
{
  "scripts": {
    "test": "vitest",
    "test:ui": "vitest --ui",
    "test:coverage": "vitest --coverage",
    "test:watch": "vitest --watch"
  }
}
```

## Unit Testing Examples

### Basic Component Test

```typescript
// src/components/Card.tsx
import React from 'react'

type CardProps = {
  title: string
  description?: string
  children?: React.ReactNode
};

export const Card: React.FC<CardProps> = ({ title, description, children }) => (
  <div className="card">
    <h2>{title}</h2>
    {description && <p>{description}</p>}
    {children && <div className="card-content">{children}</div>}
  </div>
)
```

```typescript
// src/components/__tests__/Card.test.tsx
import { describe, it, expect } from 'vitest'
import { render, screen } from '@testing-library/react'
import { Card } from '../Card'

describe('Card Component', () => {
  it('renders title', () => {
    render(<Card title="Test Card" />)
    expect(screen.getByRole('heading', { name: /test card/i })).toBeInTheDocument()
  })

  it('renders description when provided', () => {
    render(<Card title="Test" description="Test description" />)
    expect(screen.getByText('Test description')).toBeInTheDocument()
  })

  it('does not render description when not provided', () => {
    const { container } = render(<Card title="Test" />)
    const description = container.querySelector('p')
    expect(description).toBeNull()
  })

  it('renders children correctly', () => {
    render(
      <Card title="Test">
        <span>Child content</span>
      </Card>
    )
    expect(screen.getByText('Child content')).toBeInTheDocument()
  })

  it('applies card class', () => {
    const { container } = render(<Card title="Test" />)
    const cardElement = container.querySelector('.card')
    expect(cardElement).toBeInTheDocument()
  })
})
```

## Integration Testing

```typescript
// src/components/UserProfile.tsx
import React, { useState, useEffect } from 'react'

type User = {
  id: string
  name: string
  email: string
};

type UserProfileProps = {
  userId: string
};

export const UserProfile: React.FC<UserProfileProps> = ({ userId }) => {
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    const fetchUser = async () => {
      try {
        const response = await fetch(`/api/users/${userId}`)
        if (!response.ok) throw new Error('Failed to fetch')
        const data = await response.json()
        setUser(data)
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Error')
      } finally {
        setLoading(false)
      }
    }

    fetchUser()
  }, [userId])

  if (loading) return <div>Loading...</div>
  if (error) return <div>Error: {error}</div>
  if (!user) return <div>No user found</div>

  return (
    <div>
      <h1>{user.name}</h1>
      <p>{user.email}</p>
    </div>
  )
}
```

```typescript
// src/components/__tests__/UserProfile.test.tsx
import { describe, it, expect, beforeEach, vi } from 'vitest'
import { render, screen, waitFor } from '@testing-library/react'
import { UserProfile } from '../UserProfile'

describe('UserProfile Component', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  it('displays loading state initially', () => {
    vi.stubGlobal('fetch', vi.fn(() => new Promise(() => {})))

    render(<UserProfile userId="1" />)
    expect(screen.getByText('Loading...')).toBeInTheDocument()
  })

  it('displays user data after loading', async () => {
    const mockUser = { id: '1', name: 'John Doe', email: 'john@example.com' }

    global.fetch = vi.fn(() =>
      Promise.resolve({
        ok: true,
        json: () => Promise.resolve(mockUser),
      } as Response)
    )

    render(<UserProfile userId="1" />)

    await waitFor(() => {
      expect(screen.getByText('John Doe')).toBeInTheDocument()
    })

    expect(screen.getByText('john@example.com')).toBeInTheDocument()
  })

  it('displays error message on fetch failure', async () => {
    global.fetch = vi.fn(() =>
      Promise.resolve({
        ok: false,
        json: () => Promise.reject(new Error('Server error')),
      } as Response)
    )

    render(<UserProfile userId="1" />)

    await waitFor(() => {
      expect(screen.getByText(/error:/i)).toBeInTheDocument()
    })
  })

  it('refetches when userId changes', async () => {
    const mockUser1 = { id: '1', name: 'John', email: 'john@example.com' }
    const mockUser2 = { id: '2', name: 'Jane', email: 'jane@example.com' }

    global.fetch = vi.fn()
      .mockResolvedValueOnce({
        ok: true,
        json: () => Promise.resolve(mockUser1),
      } as Response)
      .mockResolvedValueOnce({
        ok: true,
        json: () => Promise.resolve(mockUser2),
      } as Response)

    const { rerender } = render(<UserProfile userId="1" />)

    await waitFor(() => {
      expect(screen.getByText('John')).toBeInTheDocument()
    })

    rerender(<UserProfile userId="2" />)

    await waitFor(() => {
      expect(screen.getByText('Jane')).toBeInTheDocument()
    })
  })
})
```

## Async Testing

```typescript
// src/lib/asyncUtils.ts
export const fetchWithRetry = async (
  url: string,
  maxRetries = 3
): Promise<Response> => {
  let lastError: Error | null = null

  for (let i = 0; i < maxRetries; i++) {
    try {
      const response = await fetch(url)
      if (response.ok) return response
      throw new Error(`HTTP ${response.status}`)
    } catch (error) {
      lastError = error as Error
      if (i < maxRetries - 1) {
        await new Promise(resolve => setTimeout(resolve, Math.pow(2, i) * 1000))
      }
    }
  }

  throw lastError
}

export const debounce = <T extends (...args: any[]) => any>(
  fn: T,
  delay: number
): ((...args: Parameters<T>) => void) => {
  let timeoutId: NodeJS.Timeout

  return (...args: Parameters<T>) => {
    clearTimeout(timeoutId)
    timeoutId = setTimeout(() => fn(...args), delay)
  }
}
```

```typescript
// src/lib/__tests__/asyncUtils.test.ts
import { describe, it, expect, vi, beforeEach } from 'vitest'
import { fetchWithRetry, debounce } from '../asyncUtils'

describe('asyncUtils', () => {
  beforeEach(() => {
    vi.useFakeTimers()
    vi.clearAllMocks()
  })

  describe('fetchWithRetry', () => {
    it('returns response on first success', async () => {
      const mockResponse = { ok: true, status: 200 } as Response
      global.fetch = vi.fn(() => Promise.resolve(mockResponse))

      const result = await fetchWithRetry('https://api.example.com')

      expect(result).toEqual(mockResponse)
      expect(global.fetch).toHaveBeenCalledTimes(1)
    })

    it('retries on failure', async () => {
      global.fetch = vi.fn()
        .mockRejectedValueOnce(new Error('Network error'))
        .mockResolvedValueOnce({ ok: true } as Response)

      const promise = fetchWithRetry('https://api.example.com', 2)

      await vi.advanceTimersByTimeAsync(1000)
      const result = await promise

      expect(result).toEqual({ ok: true })
      expect(global.fetch).toHaveBeenCalledTimes(2)
    })

    it('throws after max retries', async () => {
      global.fetch = vi.fn().mockRejectedValue(new Error('Network error'))

      const promise = fetchWithRetry('https://api.example.com', 2)

      await vi.advanceTimersByTimeAsync(3000)

      await expect(promise).rejects.toThrow('Network error')
      expect(global.fetch).toHaveBeenCalledTimes(2)
    })
  })

  describe('debounce', () => {
    it('debounces function calls', async () => {
      const mockFn = vi.fn()
      const debouncedFn = debounce(mockFn, 500)

      debouncedFn('call1')
      debouncedFn('call2')
      debouncedFn('call3')

      expect(mockFn).not.toHaveBeenCalled()

      vi.advanceTimersByTime(500)

      expect(mockFn).toHaveBeenCalledTimes(1)
      expect(mockFn).toHaveBeenCalledWith('call3')
    })

    it('resets timer on new call', async () => {
      const mockFn = vi.fn()
      const debouncedFn = debounce(mockFn, 500)

      debouncedFn('call1')
      vi.advanceTimersByTime(300)
      debouncedFn('call2')
      vi.advanceTimersByTime(300)

      expect(mockFn).not.toHaveBeenCalled()

      vi.advanceTimersByTime(200)

      expect(mockFn).toHaveBeenCalledTimes(1)
      expect(mockFn).toHaveBeenCalledWith('call2')
    })
  })
})
```

## Snapshot Testing

```typescript
// src/components/__tests__/Layout.test.tsx
import { describe, it, expect } from 'vitest'
import { render } from '@testing-library/react'
import { Layout } from '../Layout'

describe('Layout Component', () => {
  it('matches snapshot', () => {
    const { container } = render(
      <Layout>
        <div>Page content</div>
      </Layout>
    )
    expect(container.firstChild).toMatchSnapshot()
  })
})
```

## Mocking Modules

```typescript
// src/api/client.ts
export const apiClient = {
  get: async (url: string) => {
    const response = await fetch(url)
    return response.json()
  },
  post: async (url: string, data: any) => {
    const response = await fetch(url, {
      method: 'POST',
      body: JSON.stringify(data),
    })
    return response.json()
  },
}
```

```typescript
// src/api/__tests__/client.test.ts
import { describe, it, expect, vi, beforeEach } from 'vitest'
import { apiClient } from '../client'

vi.mock('../client', () => ({
  apiClient: {
    get: vi.fn(),
    post: vi.fn(),
  },
}))

describe('API Client', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  it('calls get method', async () => {
    const mockData = { id: 1, name: 'Test' }
    ;(apiClient.get as any).mockResolvedValue(mockData)

    const result = await apiClient.get('/api/data')

    expect(result).toEqual(mockData)
    expect(apiClient.get).toHaveBeenCalledWith('/api/data')
  })
})
```

## Running Tests

```bash
# Run all tests
npm test

# Run in watch mode with UI
npm run test:ui

# Generate coverage report
npm run test:coverage

# Run specific test file
npm test Card.test.tsx

# Run tests matching pattern
npm test --reporter=verbose UserProfile
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Vitest

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      - run: npm ci
      - run: npm run test:coverage
      - uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info
          flags: vitest
```

## Performance Tips

1. **Use Vitest UI** - `npm run test:ui` provides instant visual feedback
2. **Isolate tests** - Use `describe.only()` to focus on specific test suites
3. **Mock heavy operations** - Mock database calls, external APIs, file I/O
4. **Parallel execution** - Vitest runs tests in parallel by default for speed
5. **Use fake timers** - For time-dependent tests, use `vi.useFakeTimers()`
6. **Snapshot testing** - Use snapshots for component structure verification

## Best Practices

1. **Test behavior, not implementation** - Focus on what components do, not how
2. **Clear test names** - Describe exactly what is being tested
3. **Arrange-Act-Assert** - Structure tests in this order
4. **One assertion per test** - Keep tests focused and specific
5. **Use descriptive mocks** - Mock names should indicate what they replace
6. **Clean up after tests** - Use `beforeEach` and `afterEach` hooks
7. **Test edge cases** - Cover error states, empty states, and boundaries
