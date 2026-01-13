# Reference

# React Testing Library

Best practices for testing React components with Testing Library, focusing on user-centric testing patterns.

## Core Concepts

React Testing Library encourages testing components from the user's perspective rather than implementation details. It provides queries that match how users interact with elements.

## Query Types

### Priority Order for Queries

```typescript
// 1. Queries that reflect how users interact with components
screen.getByRole('button', { name: /submit/i })
screen.getByLabelText('Username')
screen.getByPlaceholderText('Enter name')
screen.getByText('Welcome')
screen.getByDisplayValue('selected value')

// 2. Semantic queries
screen.getByAltText('Decorative image')
screen.getByTitle('Help')

// 3. Test IDs (last resort)
screen.getByTestId('special-component')
```

## Basic Component Testing

```typescript
// src/components/Badge.tsx
import React from 'react'

type BadgeProps = {
  color?: 'red' | 'blue' | 'green'
  children: React.ReactNode
};

export const Badge: React.FC<BadgeProps> = ({ color = 'blue', children }) => (
  <span className={`badge badge-${color}`}>{children}</span>
)
```

```typescript
// src/components/__tests__/Badge.test.tsx
import { render, screen } from '@testing-library/react'
import { Badge } from '../Badge'

describe('Badge Component', () => {
  it('renders badge with text', () => {
    render(<Badge>New</Badge>)
    expect(screen.getByText('New')).toBeInTheDocument()
  })

  it('applies correct color class', () => {
    const { container } = render(<Badge color="red">Alert</Badge>)
    const badge = container.querySelector('.badge-red')
    expect(badge).toBeInTheDocument()
  })

  it('defaults to blue color', () => {
    const { container } = render(<Badge>Info</Badge>)
    const badge = container.querySelector('.badge-blue')
    expect(badge).toBeInTheDocument()
  })
})
```

## User Event Testing

```typescript
// src/components/Toggle.tsx
import React, { useState } from 'react'

type ToggleProps = {
  onToggle?: (value: boolean) => void
  defaultValue?: boolean
};

export const Toggle: React.FC<ToggleProps> = ({ onToggle, defaultValue = false }) => {
  const [enabled, setEnabled] = useState(defaultValue)

  const handleToggle = () => {
    const newValue = !enabled
    setEnabled(newValue)
    onToggle?.(newValue)
  }

  return (
    <button
      onClick={handleToggle}
      role="switch"
      aria-checked={enabled}
      aria-label="Feature toggle"
    >
      {enabled ? 'Enabled' : 'Disabled'}
    </button>
  )
}
```

```typescript
// src/components/__tests__/Toggle.test.tsx
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { Toggle } from '../Toggle'

describe('Toggle Component', () => {
  it('renders toggle button', () => {
    render(<Toggle />)
    expect(screen.getByRole('switch')).toBeInTheDocument()
  })

  it('starts in disabled state', () => {
    render(<Toggle />)
    const toggle = screen.getByRole('switch')
    expect(toggle).toHaveAttribute('aria-checked', 'false')
  })

  it('toggles when clicked', async () => {
    const user = userEvent.setup()
    render(<Toggle />)

    const toggle = screen.getByRole('switch')

    expect(toggle).toHaveAttribute('aria-checked', 'false')
    expect(toggle).toHaveTextContent('Disabled')

    await user.click(toggle)

    expect(toggle).toHaveAttribute('aria-checked', 'true')
    expect(toggle).toHaveTextContent('Enabled')
  })

  it('calls onToggle callback when clicked', async () => {
    const user = userEvent.setup()
    const handleToggle = jest.fn()
    render(<Toggle onToggle={handleToggle} />)

    await user.click(screen.getByRole('switch'))

    expect(handleToggle).toHaveBeenCalledWith(true)
  })

  it('respects defaultValue prop', () => {
    render(<Toggle defaultValue={true} />)
    expect(screen.getByRole('switch')).toHaveAttribute('aria-checked', 'true')
  })

  it('supports keyboard interaction', async () => {
    const user = userEvent.setup()
    render(<Toggle />)

    const toggle = screen.getByRole('switch')
    toggle.focus()

    await user.keyboard(' ')

    expect(toggle).toHaveAttribute('aria-checked', 'true')
  })
})
```

## Form Input Testing

```typescript
// src/components/SearchInput.tsx
import React, { useState } from 'react'

type SearchInputProps = {
  onSearch: (query: string) => void
  placeholder?: string
};

export const SearchInput: React.FC<SearchInputProps> = ({
  onSearch,
  placeholder = 'Search...',
}) => {
  const [value, setValue] = useState('')

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const newValue = e.target.value
    setValue(newValue)
  }

  const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Enter') {
      onSearch(value)
      setValue('')
    }
  }

  return (
    <input
      type="text"
      value={value}
      onChange={handleChange}
      onKeyDown={handleKeyDown}
      placeholder={placeholder}
      aria-label="Search"
    />
  )
}
```

```typescript
// src/components/__tests__/SearchInput.test.tsx
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { SearchInput } from '../SearchInput'

describe('SearchInput Component', () => {
  it('renders input with placeholder', () => {
    const handleSearch = jest.fn()
    render(<SearchInput onSearch={handleSearch} placeholder="Find..." />)
    expect(screen.getByPlaceholderText('Find...')).toBeInTheDocument()
  })

  it('updates input value on type', async () => {
    const user = userEvent.setup()
    const handleSearch = jest.fn()
    render(<SearchInput onSearch={handleSearch} />)

    const input = screen.getByLabelText('Search')
    await user.type(input, 'react')

    expect(input).toHaveValue('react')
  })

  it('calls onSearch when Enter is pressed', async () => {
    const user = userEvent.setup()
    const handleSearch = jest.fn()
    render(<SearchInput onSearch={handleSearch} />)

    const input = screen.getByLabelText('Search')
    await user.type(input, 'testing')
    await user.keyboard('{Enter}')

    expect(handleSearch).toHaveBeenCalledWith('testing')
  })

  it('clears input after search', async () => {
    const user = userEvent.setup()
    const handleSearch = jest.fn()
    render(<SearchInput onSearch={handleSearch} />)

    const input = screen.getByLabelText('Search') as HTMLInputElement
    await user.type(input, 'query')
    await user.keyboard('{Enter}')

    expect(input.value).toBe('')
  })

  it('handles special characters', async () => {
    const user = userEvent.setup()
    const handleSearch = jest.fn()
    render(<SearchInput onSearch={handleSearch} />)

    const input = screen.getByLabelText('Search')
    await user.type(input, '@#$%&*()')
    await user.keyboard('{Enter}')

    expect(handleSearch).toHaveBeenCalledWith('@#$%&*()')
  })
})
```

## Async Testing Patterns

```typescript
// src/components/DataTable.tsx
import React, { useState, useEffect } from 'react'

type Row = {
  id: string
  name: string
  email: string
};

type DataTableProps = {
  url: string
};

export const DataTable: React.FC<DataTableProps> = ({ url }) => {
  const [rows, setRows] = useState<Row[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    const fetchData = async () => {
      try {
        const response = await fetch(url)
        if (!response.ok) throw new Error('Failed to load data')
        const data = await response.json()
        setRows(data)
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Error')
      } finally {
        setLoading(false)
      }
    }

    fetchData()
  }, [url])

  if (loading) return <div role="status">Loading data...</div>
  if (error) return <div role="alert">Error: {error}</div>
  if (rows.length === 0) return <div>No data available</div>

  return (
    <table>
      <thead>
        <tr>
          <th>Name</th>
          <th>Email</th>
        </tr>
      </thead>
      <tbody>
        {rows.map(row => (
          <tr key={row.id}>
            <td>{row.name}</td>
            <td>{row.email}</td>
          </tr>
        ))}
      </tbody>
    </table>
  )
}
```

```typescript
// src/components/__tests__/DataTable.test.tsx
import { render, screen, waitFor } from '@testing-library/react'
import { DataTable } from '../DataTable'

describe('DataTable Component', () => {
  beforeEach(() => {
    global.fetch = jest.fn()
  })

  afterEach(() => {
    jest.resetAllMocks()
  })

  it('displays loading state', () => {
    ;(global.fetch as jest.Mock).mockImplementation(() => new Promise(() => {}))

    render(<DataTable url="/api/data" />)
    expect(screen.getByRole('status')).toHaveTextContent('Loading data...')
  })

  it('displays data after loading', async () => {
    const mockData = [
      { id: '1', name: 'John', email: 'john@example.com' },
      { id: '2', name: 'Jane', email: 'jane@example.com' },
    ]

    ;(global.fetch as jest.Mock).mockResolvedValue({
      ok: true,
      json: async () => mockData,
    })

    render(<DataTable url="/api/data" />)

    // Wait for data to be loaded and rendered
    await waitFor(() => {
      expect(screen.getByText('John')).toBeInTheDocument()
    })

    expect(screen.getByText('jane@example.com')).toBeInTheDocument()
  })

  it('displays error message on fetch failure', async () => {
    ;(global.fetch as jest.Mock).mockResolvedValue({
      ok: false,
    })

    render(<DataTable url="/api/data" />)

    await waitFor(() => {
      expect(screen.getByRole('alert')).toBeInTheDocument()
    })
  })

  it('displays empty state when no data', async () => {
    ;(global.fetch as jest.Mock).mockResolvedValue({
      ok: true,
      json: async () => [],
    })

    render(<DataTable url="/api/data" />)

    await waitFor(() => {
      expect(screen.getByText('No data available')).toBeInTheDocument()
    })
  })

  it('refetches when URL changes', async () => {
    const mockData1 = [{ id: '1', name: 'User1', email: 'user1@example.com' }]
    const mockData2 = [{ id: '2', name: 'User2', email: 'user2@example.com' }]

    ;(global.fetch as jest.Mock)
      .mockResolvedValueOnce({ ok: true, json: async () => mockData1 })
      .mockResolvedValueOnce({ ok: true, json: async () => mockData2 })

    const { rerender } = render(<DataTable url="/api/data1" />)

    await waitFor(() => {
      expect(screen.getByText('User1')).toBeInTheDocument()
    })

    rerender(<DataTable url="/api/data2" />)

    await waitFor(() => {
      expect(screen.getByText('User2')).toBeInTheDocument()
    })

    expect(global.fetch).toHaveBeenCalledTimes(2)
  })
})
```

## Dialog/Modal Testing

```typescript
// src/components/Modal.tsx
import React from 'react'

type ModalProps = {
  isOpen: boolean
  onClose: () => void
  title: string
  children: React.ReactNode
};

export const Modal: React.FC<ModalProps> = ({ isOpen, onClose, title, children }) => {
  if (!isOpen) return null

  return (
    <>
      <div className="modal-overlay" onClick={onClose} aria-hidden="true" />
      <div role="dialog" aria-labelledby="modal-title" className="modal">
        <div className="modal-header">
          <h2 id="modal-title">{title}</h2>
          <button onClick={onClose} aria-label="Close modal">
            X
          </button>
        </div>
        <div className="modal-body">{children}</div>
      </div>
    </>
  )
}
```

```typescript
// src/components/__tests__/Modal.test.tsx
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { Modal } from '../Modal'

describe('Modal Component', () => {
  it('does not render when closed', () => {
    render(<Modal isOpen={false} onClose={() => {}} title="Test Modal">
      Content
    </Modal>)

    expect(screen.queryByRole('dialog')).not.toBeInTheDocument()
  })

  it('renders when open', () => {
    render(<Modal isOpen={true} onClose={() => {}} title="Test Modal">
      Modal content
    </Modal>)

    expect(screen.getByRole('dialog')).toBeInTheDocument()
    expect(screen.getByText('Modal content')).toBeInTheDocument()
  })

  it('displays title', () => {
    render(<Modal isOpen={true} onClose={() => {}} title="My Title">
      Content
    </Modal>)

    expect(screen.getByRole('heading', { name: 'My Title' })).toBeInTheDocument()
  })

  it('closes when close button clicked', async () => {
    const user = userEvent.setup()
    const handleClose = jest.fn()
    render(<Modal isOpen={true} onClose={handleClose} title="Test">
      Content
    </Modal>)

    await user.click(screen.getByLabelText('Close modal'))
    expect(handleClose).toHaveBeenCalled()
  })

  it('closes when overlay clicked', async () => {
    const user = userEvent.setup()
    const handleClose = jest.fn()
    const { container } = render(
      <Modal isOpen={true} onClose={handleClose} title="Test">
        Content
      </Modal>
    )

    const overlay = container.querySelector('.modal-overlay')
    await user.click(overlay!)
    expect(handleClose).toHaveBeenCalled()
  })
})
```

## Custom Hook Testing

```typescript
// src/hooks/useForm.ts
import { useState, useCallback } from 'react'

type FormErrors = {
  [key: string]: string
};

export const useForm = <T extends Record<string, any>>(initialValues: T) => {
  const [values, setValues] = useState(initialValues)
  const [errors, setErrors] = useState<FormErrors>({})

  const handleChange = useCallback((e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target
    setValues(prev => ({ ...prev, [name]: value }))
    setErrors(prev => ({ ...prev, [name]: '' }))
  }, [])

  const setFieldError = useCallback((field: string, error: string) => {
    setErrors(prev => ({ ...prev, [field]: error }))
  }, [])

  const reset = useCallback(() => {
    setValues(initialValues)
    setErrors({})
  }, [initialValues])

  return {
    values,
    errors,
    handleChange,
    setFieldError,
    reset,
  }
}
```

```typescript
// src/hooks/__tests__/useForm.test.tsx
import { renderHook, act } from '@testing-library/react'
import { useForm } from '../useForm'

describe('useForm Hook', () => {
  it('initializes with values', () => {
    const { result } = renderHook(() =>
      useForm({ email: '', password: '' })
    )

    expect(result.current.values).toEqual({ email: '', password: '' })
    expect(result.current.errors).toEqual({})
  })

  it('updates values on change', () => {
    const { result } = renderHook(() =>
      useForm({ name: '', email: '' })
    )

    act(() => {
      result.current.handleChange({
        target: { name: 'email', value: 'test@example.com' },
      } as React.ChangeEvent<HTMLInputElement>)
    })

    expect(result.current.values.email).toBe('test@example.com')
  })

  it('clears error on change', () => {
    const { result } = renderHook(() =>
      useForm({ email: '' })
    )

    act(() => {
      result.current.setFieldError('email', 'Invalid email')
    })

    expect(result.current.errors.email).toBe('Invalid email')

    act(() => {
      result.current.handleChange({
        target: { name: 'email', value: 'test@example.com' },
      } as React.ChangeEvent<HTMLInputElement>)
    })

    expect(result.current.errors.email).toBe('')
  })

  it('resets form to initial values', () => {
    const { result } = renderHook(() =>
      useForm({ name: 'John', email: 'john@example.com' })
    )

    act(() => {
      result.current.handleChange({
        target: { name: 'name', value: 'Jane' },
      } as React.ChangeEvent<HTMLInputElement>)
    })

    expect(result.current.values.name).toBe('Jane')

    act(() => {
      result.current.reset()
    })

    expect(result.current.values.name).toBe('John')
  })
})
```

## Mocking Patterns

```typescript
// src/components/Avatar.tsx
import Image from 'next/image'

type AvatarProps = {
  src: string
  alt: string
};

export const Avatar: React.FC<AvatarProps> = ({ src, alt }) => (
  <Image src={src} alt={alt} width={40} height={40} />
)
```

```typescript
// src/components/__tests__/Avatar.test.tsx
import { render, screen } from '@testing-library/react'
import { Avatar } from '../Avatar'

jest.mock('next/image', () => ({
  __esModule: true,
  default: (props: any) => {
    // eslint-disable-next-line jsx-a11y/alt-text
    return <img {...props} />
  },
}))

describe('Avatar Component', () => {
  it('renders image with correct alt text', () => {
    render(<Avatar src="/avatar.jpg" alt="User avatar" />)
    expect(screen.getByAltText('User avatar')).toBeInTheDocument()
  })

  it('has correct src', () => {
    render(<Avatar src="/avatar.jpg" alt="User avatar" />)
    expect(screen.getByAltText('User avatar')).toHaveAttribute('src', '/avatar.jpg')
  })
})
```

## Testing Best Practices

1. **Query Priority** - Use queries in this order: Role → Label → PlaceholderText → Text → TestId
2. **User Interactions** - Use `userEvent` instead of `fireEvent` for realistic interactions
3. **Async Operations** - Use `waitFor()` for async state changes
4. **Avoid Implementation Details** - Test behavior, not how components are structured
5. **Accessibility** - Use role-based queries to ensure accessible components
6. **Setup and Teardown** - Use `beforeEach` and `afterEach` for clean state
7. **Meaningful Assertions** - Assert on what users see and interact with
8. **Avoid Snapshot Tests** - Prefer explicit assertions over snapshots
9. **Mock Responsibly** - Only mock what's necessary (APIs, routing, etc.)
10. **Test User Flows** - Test complete interactions, not isolated clicks
