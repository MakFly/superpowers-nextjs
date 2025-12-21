---
name: nextjs:composition-patterns
description: Apply component composition, render props, and compound components for reusable UI
---

# Component Composition Patterns for Next.js

Advanced composition patterns enable building flexible, reusable, and maintainable React components. These patterns provide alternatives to inheritance and promote code reuse through composition.

## Core Composition Concepts

### Composition Over Inheritance

React fundamentally uses composition, not inheritance. Components are built from smaller components, allowing flexible and predictable component behavior.

```tsx
// ✗ Avoid: Inheritance (not idiomatic React)
class PrimaryButton extends Button {}

// ✓ Prefer: Composition through props
<Button variant="primary" />

// ✓ Or: Composition through wrapper
<PrimaryButton>Click me</PrimaryButton>
```

## Basic Composition Patterns

### Component Props Pattern

```tsx
// components/Card.tsx
type CardProps = {
  children: React.ReactNode;
  title?: string;
  footer?: React.ReactNode;
  elevated?: boolean;
};

export default function Card({
  children,
  title,
  footer,
  elevated = false,
}: CardProps) {
  return (
    <div
      className={`rounded-lg p-6 ${
        elevated ? 'shadow-lg' : 'shadow-md'
      }`}
    >
      {title && <h3 className="text-lg font-bold mb-4">{title}</h3>}
      <div>{children}</div>
      {footer && <div className="mt-4 pt-4 border-t">{footer}</div>}
    </div>
  );
}

// Usage
<Card
  title="User Profile"
  footer={<button>Save</button>}
  elevated
>
  <p>User information content here</p>
</Card>
```

### Slot Pattern (Named Children)

```tsx
// components/Dialog.tsx
type DialogProps = {
  open: boolean;
  onClose: () => void;
  header?: React.ReactNode;
  body: React.ReactNode;
  footer?: React.ReactNode;
};

export default function Dialog({
  open,
  onClose,
  header,
  body,
  footer,
}: DialogProps) {
  if (!open) return null;

  return (
    <div className="fixed inset-0 bg-black/50 flex items-center justify-center">
      <div className="bg-white rounded-lg max-w-md w-full">
        {header && (
          <div className="border-b px-6 py-4">
            {header}
          </div>
        )}
        <div className="px-6 py-4">
          {body}
        </div>
        {footer && (
          <div className="border-t px-6 py-4 flex gap-2 justify-end">
            {footer}
          </div>
        )}
      </div>
    </div>
  );
}

// Usage
<Dialog
  open={isOpen}
  onClose={handleClose}
  header={<h2>Confirm Action</h2>}
  body={<p>Are you sure you want to continue?</p>}
  footer={
    <>
      <button onClick={handleClose}>Cancel</button>
      <button onClick={handleConfirm}>Confirm</button>
    </>
  }
/>
```

## Advanced Patterns

### Render Props Pattern

Render props allow passing a function as a child to pass data back to parent components.

```tsx
// hooks/useFetchData.ts
import { useState, useEffect } from 'react';

type UseFetchProps<T> = {
  url: string;
  dependencies?: React.DependencyList;
};

type UseFetchReturn<T> = {
  data: T | null;
  loading: boolean;
  error: Error | null;
};

export function useFetchData<T>({
  url,
  dependencies = [],
}: UseFetchProps<T>): UseFetchReturn<T> {
  const [state, setState] = useState<UseFetchReturn<T>>({
    data: null,
    loading: true,
    error: null,
  });

  useEffect(() => {
    let mounted = true;

    const fetchData = async () => {
      try {
        const response = await fetch(url);
        if (!response.ok) throw new Error('Failed to fetch');
        const data = await response.json();
        if (mounted) {
          setState({ data, loading: false, error: null });
        }
      } catch (error) {
        if (mounted) {
          setState({
            data: null,
            loading: false,
            error: error as Error,
          });
        }
      }
    };

    fetchData();
    return () => {
      mounted = false;
    };
  }, dependencies);

  return state;
}

// components/DataFetcher.tsx
type DataFetcherProps<T> = {
  url: string;
  children: (props: UseFetchReturn<T>) => React.ReactNode;
};

export function DataFetcher<T>({
  url,
  children,
}: DataFetcherProps<T>) {
  const state = useFetchData<T>({ url });
  return <>{children(state)}</>;
}

// Usage
<DataFetcher<User[]> url="/api/users">
  {({ data, loading, error }) => {
    if (loading) return <div>Loading...</div>;
    if (error) return <div>Error: {error.message}</div>;
    return (
      <ul>
        {data?.map((user) => (
          <li key={user.id}>{user.name}</li>
        ))}
      </ul>
    );
  }}
</DataFetcher>
```

### Compound Components Pattern

Compound components work together as a group, sharing internal state while maintaining clean APIs.

```tsx
// components/Select/Select.tsx
'use client';

import React, { createContext, useContext, useState } from 'react';

type SelectContextType = {
  isOpen: boolean;
  selectedValue: string | null;
  setIsOpen: (open: boolean) => void;
  setSelectedValue: (value: string) => void;
};

const SelectContext = createContext<SelectContextType | undefined>(
  undefined
);

const useSelect = () => {
  const context = useContext(SelectContext);
  if (!context) {
    throw new Error('useSelect must be used within SelectProvider');
  }
  return context;
};

type SelectProps = {
  children: React.ReactNode;
  value?: string;
  onChange?: (value: string) => void;
};

export function Select({
  children,
  value: initialValue = '',
  onChange,
}: SelectProps) {
  const [isOpen, setIsOpen] = useState(false);
  const [selectedValue, setSelectedValue] = useState(initialValue);

  const handleSetSelectedValue = (value: string) => {
    setSelectedValue(value);
    onChange?.(value);
    setIsOpen(false);
  };

  return (
    <SelectContext.Provider
      value={{
        isOpen,
        selectedValue,
        setIsOpen,
        setSelectedValue: handleSetSelectedValue,
      }}
    >
      <div className="relative inline-block w-full">
        {children}
      </div>
    </SelectContext.Provider>
  );
}

// components/Select/SelectTrigger.tsx
export function SelectTrigger({
  children,
  ...props
}: React.ButtonHTMLAttributes<HTMLButtonElement>) {
  const { isOpen, setIsOpen } = useSelect();

  return (
    <button
      {...props}
      onClick={() => setIsOpen(!isOpen)}
      className="w-full px-4 py-2 border rounded-lg text-left flex justify-between items-center"
    >
      {children}
      <span>{isOpen ? '▲' : '▼'}</span>
    </button>
  );
}

// components/Select/SelectContent.tsx
export function SelectContent({
  children,
}: {
  children: React.ReactNode;
}) {
  const { isOpen } = useSelect();

  if (!isOpen) return null;

  return (
    <div className="absolute top-full mt-1 w-full bg-white border rounded-lg shadow-lg z-50">
      {children}
    </div>
  );
}

// components/Select/SelectItem.tsx
export function SelectItem({
  value,
  children,
}: {
  value: string;
  children: React.ReactNode;
}) {
  const { selectedValue, setSelectedValue } = useSelect();
  const isSelected = selectedValue === value;

  return (
    <button
      onClick={() => setSelectedValue(value)}
      className={`w-full px-4 py-2 text-left hover:bg-blue-100 ${
        isSelected ? 'bg-blue-50 font-bold' : ''
      }`}
    >
      {children}
    </button>
  );
}

// Usage
<Select value="us" onChange={(value) => setCountry(value)}>
  <SelectTrigger>United States</SelectTrigger>
  <SelectContent>
    <SelectItem value="us">United States</SelectItem>
    <SelectItem value="ca">Canada</SelectItem>
    <SelectItem value="mx">Mexico</SelectItem>
  </SelectContent>
</Select>
```

### Higher-Order Components (HOC)

HOCs wrap components to add additional functionality.

```tsx
// hoc/withAuthentication.tsx
import { redirect } from 'next/navigation';

type WithAuthenticationProps = {
  isAuthenticated: boolean;
};

export function withAuthentication<P extends object>(
  Component: React.ComponentType<P>
) {
  return function ProtectedComponent(
    props: P & WithAuthenticationProps
  ) {
    const { isAuthenticated, ...rest } = props;

    if (!isAuthenticated) {
      redirect('/login');
    }

    return <Component {...(rest as P)} />;
  };
}

// Usage
export default withAuthentication(DashboardPage);
```

```tsx
// hoc/withTheme.tsx
import { createContext, useContext } from 'react';

type Theme = {
  primary: string;
  secondary: string;
};

const ThemeContext = createContext<Theme | undefined>(undefined);

export function withTheme<P extends object>(
  Component: React.ComponentType<P & { theme: Theme }>
) {
  return function ThemedComponent(props: P) {
    const theme: Theme = {
      primary: '#007bff',
      secondary: '#6c757d',
    };

    return <Component {...props} theme={theme} />;
  };
}

// Usage
type ThemedComponentProps = {
  theme: Theme;
};

function MyComponent({ theme }: ThemedComponentProps) {
  return (
    <div style={{ color: theme.primary }}>
      Themed content
    </div>
  );
}

export default withTheme(MyComponent);
```

```tsx
// hoc/withDataFetching.tsx
type WithDataFetchingProps<T> = {
  data: T | null;
  loading: boolean;
  error: Error | null;
};

export function withDataFetching<T, P extends object>(
  url: string,
  Component: React.ComponentType<P & WithDataFetchingProps<T>>
) {
  return function DataFetchingComponent(props: P) {
    const { data, loading, error } = useFetchData<T>({ url });

    if (loading) return <div>Loading...</div>;
    if (error) return <div>Error: {error.message}</div>;

    return <Component {...props} data={data} loading={loading} error={error} />;
  };
}

// Usage
type User = {
  id: number;
  name: string;
};

type UserListProps = {
  data: User[] | null;
  loading: boolean;
  error: Error | null;
};

function UserList({ data }: UserListProps) {
  return (
    <ul>
      {data?.map((user) => (
        <li key={user.id}>{user.name}</li>
      ))}
    </ul>
  );
}

export default withDataFetching<User[]>('/api/users', UserList);
```

### Container and Presentational Components

Separate data logic from presentation.

```tsx
// components/UserProfile/UserProfileContainer.tsx
'use client';

import { useState, useEffect } from 'react';
import UserProfilePresentation from './UserProfilePresentation';

type User = {
  id: string;
  name: string;
  email: string;
  bio: string;
};

type UserProfileContainerProps = {
  userId: string;
};

export default function UserProfileContainer({
  userId,
}: UserProfileContainerProps) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchUser = async () => {
      try {
        const response = await fetch(`/api/users/${userId}`);
        if (!response.ok) throw new Error('Failed to fetch user');
        const data = await response.json();
        setUser(data);
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Unknown error');
      } finally {
        setLoading(false);
      }
    };

    fetchUser();
  }, [userId]);

  const handleUpdate = async (updates: Partial<User>) => {
    try {
      const response = await fetch(`/api/users/${userId}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(updates),
      });
      if (!response.ok) throw new Error('Failed to update user');
      const updatedUser = await response.json();
      setUser(updatedUser);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error');
    }
  };

  return (
    <UserProfilePresentation
      user={user}
      loading={loading}
      error={error}
      onUpdate={handleUpdate}
    />
  );
}

// components/UserProfile/UserProfilePresentation.tsx
type User = {
  id: string;
  name: string;
  email: string;
  bio: string;
};

type UserProfilePresentationProps = {
  user: User | null;
  loading: boolean;
  error: string | null;
  onUpdate: (updates: Partial<User>) => Promise<void>;
};

export default function UserProfilePresentation({
  user,
  loading,
  error,
  onUpdate,
}: UserProfilePresentationProps) {
  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;
  if (!user) return <div>User not found</div>;

  return (
    <div className="max-w-md mx-auto p-6 bg-white rounded-lg shadow-md">
      <h2 className="text-2xl font-bold mb-4">{user.name}</h2>
      <p className="text-gray-600 mb-2">Email: {user.email}</p>
      <p className="text-gray-600 mb-4">Bio: {user.bio}</p>
      <button
        onClick={() =>
          onUpdate({ name: `${user.name} (Updated)` })
        }
        className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
      >
        Update Profile
      </button>
    </div>
  );
}
```

## Advanced Composition Techniques

### Flexible Component APIs

```tsx
// components/Button.tsx - supports multiple usage patterns
type ButtonProps =
  | {
      variant: 'text';
      label: string;
    }
  | {
      variant: 'icon';
      icon: React.ReactNode;
      ariaLabel: string;
    }
  | {
      variant: 'primary' | 'secondary';
      children: React.ReactNode;
    };

export default function Button(props: ButtonProps & React.ButtonHTMLAttributes<HTMLButtonElement>) {
  const { variant, ...buttonProps } = props as any;

  if (variant === 'text') {
    return <button {...buttonProps}>{buttonProps.label}</button>;
  }

  if (variant === 'icon') {
    return (
      <button {...buttonProps} aria-label={buttonProps.ariaLabel}>
        {buttonProps.icon}
      </button>
    );
  }

  return (
    <button
      {...buttonProps}
      className={`px-4 py-2 rounded ${
        variant === 'primary'
          ? 'bg-blue-600 text-white'
          : 'bg-gray-200 text-gray-900'
      }`}
    >
      {buttonProps.children}
    </button>
  );
}
```

### Polymorphic Components

```tsx
// components/Polymorphic.tsx
import React from 'react';

type PolymorphicProps<T extends React.ElementType> = {
  as?: T;
  children: React.ReactNode;
} & React.ComponentPropsWithoutRef<T>;

export function Box<T extends React.ElementType = 'div'>({
  as: Component = 'div',
  children,
  ...props
}: PolymorphicProps<T>) {
  return (
    <Component {...props} className="p-4 border rounded-lg">
      {children}
    </Component>
  );
}

// Usage
<Box as="section">Section content</Box>
<Box as="article">Article content</Box>
<Box as="div">Div content</Box>
```

### Custom Hooks for Logic Reuse

```tsx
// hooks/usePagination.ts
import { useState } from 'react';

type UsePaginationProps = {
  itemsPerPage: number;
  totalItems: number;
};

export function usePagination({
  itemsPerPage,
  totalItems,
}: UsePaginationProps) {
  const [currentPage, setCurrentPage] = useState(1);
  const totalPages = Math.ceil(totalItems / itemsPerPage);
  const startIndex = (currentPage - 1) * itemsPerPage;
  const endIndex = startIndex + itemsPerPage;

  return {
    currentPage,
    totalPages,
    startIndex,
    endIndex,
    goToPage: (page: number) =>
      setCurrentPage(Math.min(Math.max(1, page), totalPages)),
    nextPage: () => setCurrentPage((p) => Math.min(p + 1, totalPages)),
    prevPage: () => setCurrentPage((p) => Math.max(1, p - 1)),
  };
}

// Usage
function DataTable({ items }: { items: any[] }) {
  const { currentPage, totalPages, startIndex, endIndex, nextPage, prevPage } =
    usePagination({
      itemsPerPage: 10,
      totalItems: items.length,
    });

  const paginatedItems = items.slice(startIndex, endIndex);

  return (
    <div>
      <table>
        <tbody>
          {paginatedItems.map((item) => (
            <tr key={item.id}>
              <td>{item.name}</td>
            </tr>
          ))}
        </tbody>
      </table>
      <div className="flex gap-2">
        <button onClick={prevPage}>Previous</button>
        <span>Page {currentPage} of {totalPages}</span>
        <button onClick={nextPage}>Next</button>
      </div>
    </div>
  );
}
```

## Composition Patterns Comparison

| Pattern | Use Case | Pros | Cons |
|---------|----------|------|------|
| **Slot Pattern** | Multiple regions in component | Simple, declarative | Limited flexibility |
| **Render Props** | Dynamic content rendering | Flexible, testable | Callback hell |
| **Compound Components** | Related UI elements | Intuitive API, scalable | More complex |
| **HOC** | Cross-cutting concerns | Reusable logic, compose | Wrapper hell, type complexity |
| **Container/Presentation** | Logic/UI separation | Clear separation, testable | Boilerplate |
| **Custom Hooks** | Logic reuse | Simple, composable | Limited scope |

## Best Practices

1. **Favor composition over inheritance**: Use component composition for flexibility
2. **Keep components small**: Single responsibility principle
3. **Use TypeScript**: Ensure type safety across composed components
4. **Extract logic to hooks**: Reuse logic without wrapper components
5. **Name components clearly**: Indicate composition and purpose
6. **Document APIs**: Clear prop documentation for composed components
7. **Test independently**: Test logic and presentation separately
8. **Avoid prop drilling**: Use context for deeply nested components

## Real-World Example: Form System

```tsx
// components/Form/Form.tsx
type FormProps<T> = {
  onSubmit: (data: T) => Promise<void>;
  children: React.ReactNode;
};

export function Form<T extends Record<string, any>>({
  onSubmit,
  children,
}: FormProps<T>) {
  const [formData, setFormData] = useState<T>({} as T);
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [submitting, setSubmitting] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitting(true);
    try {
      await onSubmit(formData);
    } catch (error) {
      setErrors({
        submit: error instanceof Error ? error.message : 'Unknown error',
      });
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <FormContext.Provider
      value={{
        formData,
        errors,
        submitting,
        setFormData,
        setErrors,
      }}
    >
      <form onSubmit={handleSubmit}>
        {children}
      </form>
    </FormContext.Provider>
  );
}

// Usage
<Form<{ email: string; password: string }>
  onSubmit={async (data) => {
    await loginUser(data);
  }}
>
  <FormField name="email" label="Email" type="email" />
  <FormField name="password" label="Password" type="password" />
  <button type="submit">Login</button>
</Form>
```

## Summary

Component composition patterns provide:
- Flexible and reusable component designs
- Separation of concerns
- Easier testing and maintenance
- Scalable architecture
- Type-safe APIs
