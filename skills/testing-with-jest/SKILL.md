---
name: nextjs:testing-with-jest
description: Configure and write tests with Jest and React Testing Library for Next.js applications
---

# Testing with Jest

Complete Jest setup for Next.js projects with React Testing Library, covering unit tests, component tests, and integration tests.

## Installation

```bash
npm install --save-dev jest @testing-library/react @testing-library/jest-dom jest-environment-jsdom
# or
yarn add --dev jest @testing-library/react @testing-library/jest-dom jest-environment-jsdom
```

## Configuration

### jest.config.js

```javascript
const nextJest = require('next/jest')

const createJestConfig = nextJest({
  // Provide the path to your Next.js app to load next.config.js and .env files in your test environment
  dir: './',
})

// Add any custom config to be passed to Jest
const customJestConfig = {
  setupFilesAfterEnv: ['<rootDir>/jest.setup.js'],
  testEnvironment: 'jest-environment-jsdom',
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
    '^@/components/(.*)$': '<rootDir>/src/components/$1',
    '^@/lib/(.*)$': '<rootDir>/src/lib/$1',
  },
  testMatch: [
    '**/__tests__/**/*.test.ts',
    '**/__tests__/**/*.test.tsx',
    '**/*.test.ts',
    '**/*.test.tsx',
  ],
  collectCoverageFrom: [
    'src/**/*.{js,jsx,ts,tsx}',
    '!src/**/*.d.ts',
    '!src/**/*.stories.{js,jsx,ts,tsx}',
    '!src/**/__tests__/**',
  ],
}

// createJestConfig is exported this way to ensure that next/jest can load the Next.js config which is async
module.exports = createJestConfig(customJestConfig)
```

### jest.setup.js

```javascript
import '@testing-library/jest-dom'

// Mock next/router
jest.mock('next/router', () => ({
  useRouter() {
    return {
      route: '/',
      pathname: '/',
      query: {},
      asPath: '/',
      push: jest.fn(),
      replace: jest.fn(),
      reload: jest.fn(),
      back: jest.fn(),
      prefetch: jest.fn(),
      beforePopState: jest.fn(),
      events: {
        on: jest.fn(),
        off: jest.fn(),
        emit: jest.fn(),
      },
      isFallback: false,
    }
  },
}))

// Mock next/image
jest.mock('next/image', () => ({
  __esModule: true,
  default: (props) => {
    // eslint-disable-next-line jsx-a11y/alt-text
    return <img {...props} />
  },
}))
```

### package.json

```json
{
  "scripts": {
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage"
  }
}
```

## Unit Testing Examples

### Basic Component Test

```typescript
// src/components/Button.tsx
import React from 'react'

type ButtonProps = {
  onClick?: () => void
  children: React.ReactNode
  disabled?: boolean
};

export const Button: React.FC<ButtonProps> = ({
  onClick,
  children,
  disabled = false
}) => (
  <button onClick={onClick} disabled={disabled}>
    {children}
  </button>
)
```

```typescript
// src/components/__tests__/Button.test.tsx
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { Button } from '../Button'

describe('Button Component', () => {
  it('renders button with text', () => {
    render(<Button>Click me</Button>)
    expect(screen.getByRole('button', { name: /click me/i })).toBeInTheDocument()
  })

  it('calls onClick handler when clicked', async () => {
    const handleClick = jest.fn()
    render(<Button onClick={handleClick}>Click me</Button>)

    const button = screen.getByRole('button')
    await userEvent.click(button)

    expect(handleClick).toHaveBeenCalledTimes(1)
  })

  it('disables button when disabled prop is true', () => {
    render(<Button disabled>Click me</Button>)
    expect(screen.getByRole('button')).toBeDisabled()
  })

  it('renders children correctly', () => {
    render(
      <Button>
        <span>Custom content</span>
      </Button>
    )
    expect(screen.getByText('Custom content')).toBeInTheDocument()
  })
})
```

## Form Testing

```typescript
// src/components/LoginForm.tsx
import React, { useState } from 'react'

type LoginFormProps = {
  onSubmit: (email: string, password: string) => Promise<void>
};

export const LoginForm: React.FC<LoginFormProps> = ({ onSubmit }) => {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setError('')

    try {
      await onSubmit(email, password)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'An error occurred')
    } finally {
      setLoading(false)
    }
  }

  return (
    <form onSubmit={handleSubmit}>
      <input
        type="email"
        placeholder="Email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        required
      />
      <input
        type="password"
        placeholder="Password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
        required
      />
      {error && <p role="alert">{error}</p>}
      <button type="submit" disabled={loading}>
        {loading ? 'Loading...' : 'Login'}
      </button>
    </form>
  )
}
```

```typescript
// src/components/__tests__/LoginForm.test.tsx
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { LoginForm } from '../LoginForm'

describe('LoginForm', () => {
  it('renders form inputs', () => {
    const mockSubmit = jest.fn()
    render(<LoginForm onSubmit={mockSubmit} />)

    expect(screen.getByPlaceholderText('Email')).toBeInTheDocument()
    expect(screen.getByPlaceholderText('Password')).toBeInTheDocument()
  })

  it('submits form with correct values', async () => {
    const user = userEvent.setup()
    const mockSubmit = jest.fn().mockResolvedValue(undefined)
    render(<LoginForm onSubmit={mockSubmit} />)

    await user.type(screen.getByPlaceholderText('Email'), 'test@example.com')
    await user.type(screen.getByPlaceholderText('Password'), 'password123')
    await user.click(screen.getByRole('button', { name: /login/i }))

    expect(mockSubmit).toHaveBeenCalledWith('test@example.com', 'password123')
  })

  it('displays error message on submit failure', async () => {
    const user = userEvent.setup()
    const mockSubmit = jest.fn().mockRejectedValue(new Error('Invalid credentials'))
    render(<LoginForm onSubmit={mockSubmit} />)

    await user.type(screen.getByPlaceholderText('Email'), 'test@example.com')
    await user.type(screen.getByPlaceholderText('Password'), 'wrong')
    await user.click(screen.getByRole('button', { name: /login/i }))

    await waitFor(() => {
      expect(screen.getByRole('alert')).toHaveTextContent('Invalid credentials')
    })
  })

  it('disables button while loading', async () => {
    const user = userEvent.setup()
    const mockSubmit = jest.fn(() => new Promise(resolve => setTimeout(resolve, 100)))
    render(<LoginForm onSubmit={mockSubmit} />)

    await user.type(screen.getByPlaceholderText('Email'), 'test@example.com')
    await user.type(screen.getByPlaceholderText('Password'), 'password123')

    const button = screen.getByRole('button', { name: /login/i })
    await user.click(button)

    expect(button).toBeDisabled()

    await waitFor(() => {
      expect(button).not.toBeDisabled()
    })
  })
})
```

## API Testing with Mocks

```typescript
// src/lib/api.ts
export const fetchUser = async (userId: string) => {
  const response = await fetch(`/api/users/${userId}`)
  if (!response.ok) throw new Error('Failed to fetch user')
  return response.json()
}

export const createUser = async (userData: { name: string; email: string }) => {
  const response = await fetch('/api/users', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(userData),
  })
  if (!response.ok) throw new Error('Failed to create user')
  return response.json()
}
```

```typescript
// src/lib/__tests__/api.test.ts
import { fetchUser, createUser } from '../api'

describe('API functions', () => {
  beforeEach(() => {
    global.fetch = jest.fn()
  })

  afterEach(() => {
    jest.resetAllMocks()
  })

  describe('fetchUser', () => {
    it('fetches user data successfully', async () => {
      const mockUser = { id: '1', name: 'John', email: 'john@example.com' }
      ;(global.fetch as jest.Mock).mockResolvedValueOnce({
        ok: true,
        json: async () => mockUser,
      })

      const result = await fetchUser('1')

      expect(global.fetch).toHaveBeenCalledWith('/api/users/1')
      expect(result).toEqual(mockUser)
    })

    it('throws error on fetch failure', async () => {
      ;(global.fetch as jest.Mock).mockResolvedValueOnce({
        ok: false,
      })

      await expect(fetchUser('1')).rejects.toThrow('Failed to fetch user')
    })
  })

  describe('createUser', () => {
    it('creates user with correct payload', async () => {
      const userData = { name: 'Jane', email: 'jane@example.com' }
      const mockResponse = { id: '2', ...userData }
      ;(global.fetch as jest.Mock).mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse,
      })

      const result = await createUser(userData)

      expect(global.fetch).toHaveBeenCalledWith(
        '/api/users',
        expect.objectContaining({
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(userData),
        })
      )
      expect(result).toEqual(mockResponse)
    })
  })
})
```

## Hook Testing

```typescript
// src/hooks/useCounter.ts
import { useState, useCallback } from 'react'

export const useCounter = (initialValue = 0) => {
  const [count, setCount] = useState(initialValue)

  const increment = useCallback(() => setCount(c => c + 1), [])
  const decrement = useCallback(() => setCount(c => c - 1), [])
  const reset = useCallback(() => setCount(initialValue), [initialValue])

  return { count, increment, decrement, reset }
}
```

```typescript
// src/hooks/__tests__/useCounter.test.ts
import { renderHook, act } from '@testing-library/react'
import { useCounter } from '../useCounter'

describe('useCounter', () => {
  it('initializes with default value', () => {
    const { result } = renderHook(() => useCounter())
    expect(result.current.count).toBe(0)
  })

  it('initializes with custom value', () => {
    const { result } = renderHook(() => useCounter(10))
    expect(result.current.count).toBe(10)
  })

  it('increments count', () => {
    const { result } = renderHook(() => useCounter())

    act(() => {
      result.current.increment()
    })

    expect(result.current.count).toBe(1)
  })

  it('decrements count', () => {
    const { result } = renderHook(() => useCounter(5))

    act(() => {
      result.current.decrement()
    })

    expect(result.current.count).toBe(4)
  })

  it('resets count to initial value', () => {
    const { result } = renderHook(() => useCounter(10))

    act(() => {
      result.current.increment()
      result.current.increment()
    })

    expect(result.current.count).toBe(12)

    act(() => {
      result.current.reset()
    })

    expect(result.current.count).toBe(10)
  })
})
```

## Running Tests

```bash
# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Run tests with coverage
npm run test:coverage

# Run specific test file
npm test Button.test.tsx

# Run tests matching pattern
npm test --testNamePattern="LoginForm"
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Tests

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
```

## Best Practices

1. **Test user behavior, not implementation** - Use Testing Library queries that match how users interact with your app
2. **Mock external dependencies** - Mock API calls, external libraries, and Next.js modules
3. **Use descriptive test names** - Test names should clearly describe what is being tested
4. **Keep tests focused** - Each test should verify one specific behavior
5. **Use beforeEach/afterEach** - Clean up mocks and state between tests
6. **Test async operations** - Use waitFor and userEvent.setup() for async interactions
7. **Aim for meaningful coverage** - Focus on critical user paths, not just line coverage
