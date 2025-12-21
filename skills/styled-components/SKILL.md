---
name: nextjs:styled-components
description: Integrate styled-components or CSS-in-JS solutions with App Router and RSC
---

# CSS-in-JS with styled-components for Next.js

Styled-components provide component-scoped styling using tagged template literals in JavaScript. With Next.js App Router and React Server Components, proper integration ensures styles render correctly on both server and client.

## Setup and Configuration

### Installation

```bash
npm install styled-components
npm install -D @types/styled-components babel-plugin-styled-components
```

### Configure Next.js with styled-components

```js
// next.config.js
const nextConfig = {
  compiler: {
    styledComponents: {
      displayName: true,
      ssr: true,
      minify: true,
      transpileTemplateLiterals: true,
      topLevelImportPaths: [],
    },
  },
};

module.exports = nextConfig;
```

### Create Registry Component for Server-Side Rendering

```tsx
// lib/registry.tsx
'use client';

import React, { ReactNode } from 'react';
import { ServerStyleSheet } from 'styled-components';

// For SSR support with Next.js App Router
export function StyledComponentsRegistry({
  children,
}: {
  children: ReactNode;
}) {
  // Only run this effect once
  React.useEffect(() => {
    // This is necessary to ensure styled-components works correctly
    // in Next.js App Router
  }, []);

  return <>{children}</>;
}
```

```tsx
// app/layout.tsx
import type { Metadata } from 'next';
import { StyledComponentsRegistry } from '@/lib/registry';
import StyledGlobals from '@/styles/globals';

export const metadata: Metadata = {
  title: 'My App',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>
        <StyledComponentsRegistry>
          <StyledGlobals />
          {children}
        </StyledComponentsRegistry>
      </body>
    </html>
  );
}
```

## Core Concepts

### Basic Styled Component

```tsx
// components/Button.tsx
'use client';

import styled from 'styled-components';

type StyledButtonProps = {
  $variant?: 'primary' | 'secondary';
  $size?: 'sm' | 'md' | 'lg';
  $fullWidth?: boolean;
};

const StyledButton = styled.button<StyledButtonProps>`
  display: inline-flex;
  align-items: center;
  justify-content: center;
  font-weight: 600;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.2s ease;
  outline: none;

  /* Size variants */
  padding: ${({ $size = 'md' }) => {
    const sizes = {
      sm: '6px 12px',
      md: '10px 20px',
      lg: '14px 28px',
    };
    return sizes[$size];
  }};

  font-size: ${({ $size = 'md' }) => {
    const sizes = {
      sm: '14px',
      md: '16px',
      lg: '18px',
    };
    return sizes[$size];
  }};

  /* Color variants */
  background-color: ${({ $variant = 'primary' }) => {
    const colors = {
      primary: '#007bff',
      secondary: 'transparent',
    };
    return colors[$variant];
  }};

  color: ${({ $variant = 'primary' }) => {
    const colors = {
      primary: 'white',
      secondary: '#007bff',
    };
    return colors[$variant];
  }};

  border: ${({ $variant = 'primary' }) => {
    const borders = {
      primary: 'none',
      secondary: '2px solid #007bff',
    };
    return borders[$variant];
  }};

  width: ${({ $fullWidth }) => ($fullWidth ? '100%' : 'auto')};

  &:hover:not(:disabled) {
    background-color: ${({ $variant = 'primary' }) => {
      const colors = {
        primary: '#0056b3',
        secondary: '#f0f8ff',
      };
      return colors[$variant];
    }};
  }

  &:focus-visible {
    outline: 2px solid #007bff;
    outline-offset: 2px;
  }

  &:disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }
`;

type ButtonProps = React.ButtonHTMLAttributes<HTMLButtonElement> & StyledButtonProps;

export default function Button({
  children,
  $variant = 'primary',
  $size = 'md',
  ...props
}: ButtonProps) {
  return (
    <StyledButton $variant={$variant} $size={$size} {...props}>
      {children}
    </StyledButton>
  );
}
```

### Global Styles

```tsx
// styles/globals.tsx
'use client';

import { createGlobalStyle } from 'styled-components';

const GlobalStyle = createGlobalStyle`
  * {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
  }

  html {
    scroll-behavior: smooth;
  }

  body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto',
      'Oxygen', 'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans',
      'Helvetica Neue', sans-serif;
    font-size: 16px;
    line-height: 1.6;
    color: #1a1a1a;
    background-color: #ffffff;
    transition: background-color 0.3s ease;
  }

  a {
    color: inherit;
    text-decoration: none;
  }

  button {
    font-family: inherit;
  }

  input, textarea, select {
    font-family: inherit;
  }

  /* Responsive text */
  h1 {
    font-size: clamp(24px, 5vw, 48px);
    line-height: 1.2;
  }

  h2 {
    font-size: clamp(20px, 4vw, 36px);
    line-height: 1.3;
  }

  h3 {
    font-size: clamp(18px, 3vw, 28px);
  }

  /* Dark mode support */
  @media (prefers-color-scheme: dark) {
    body {
      background-color: #0f0f0f;
      color: #f5f5f5;
    }
  }
`;

export default GlobalStyle;
```

## Advanced Patterns

### Extending Styled Components

```tsx
// components/Card.tsx
'use client';

import styled from 'styled-components';
import Button from './Button';

const StyledCard = styled.div<{ $elevated?: boolean }>`
  background: white;
  border-radius: 8px;
  padding: 16px;
  transition: all 0.3s ease;

  ${({ $elevated }) =>
    $elevated &&
    `
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  `}

  &:hover {
    ${({ $elevated }) =>
      $elevated &&
      `
      transform: translateY(-2px);
      box-shadow: 0 8px 12px rgba(0, 0, 0, 0.15);
    `}
  }
`;

const StyledCardTitle = styled.h3`
  margin: 0 0 8px 0;
  font-size: 18px;
  font-weight: 700;
  color: #1a1a1a;
`;

const StyledCardContent = styled.p`
  margin: 0 0 16px 0;
  color: #666;
  line-height: 1.6;
`;

const StyledCardFooter = styled.div`
  display: flex;
  gap: 8px;
  margin-top: 16px;
`;

type CardProps = {
  title: string;
  children: React.ReactNode;
  elevated?: boolean;
  actions?: React.ReactNode;
};

export default function Card({
  title,
  children,
  elevated = false,
  actions,
}: CardProps) {
  return (
    <StyledCard $elevated={elevated}>
      <StyledCardTitle>{title}</StyledCardTitle>
      <StyledCardContent>{children}</StyledCardContent>
      {actions && <StyledCardFooter>{actions}</StyledCardFooter>}
    </StyledCard>
  );
}
```

### Styling React Components

```tsx
// components/Input.tsx
'use client';

import styled from 'styled-components';

type StyledInputProps = {
  $error?: boolean;
  $disabled?: boolean;
};

const InputWrapper = styled.div`
  display: flex;
  flex-direction: column;
  gap: 8px;
  width: 100%;
`;

const InputLabel = styled.label`
  font-size: 14px;
  font-weight: 600;
  color: #333;
`;

const StyledInput = styled.input<StyledInputProps>`
  padding: 8px 12px;
  border-radius: 4px;
  border: 1px solid #ddd;
  font-size: 16px;
  font-family: inherit;
  transition: all 0.2s ease;

  &:focus {
    outline: none;
    border-color: #007bff;
    box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.1);
  }

  ${({ $error }) =>
    $error &&
    `
    border-color: #dc3545;
    &:focus {
      box-shadow: 0 0 0 3px rgba(220, 53, 69, 0.1);
    }
  `}

  ${({ $disabled }) =>
    $disabled &&
    `
    background-color: #f5f5f5;
    cursor: not-allowed;
    opacity: 0.6;
  `}
`;

const ErrorMessage = styled.span`
  color: #dc3545;
  font-size: 12px;
`;

type InputProps = React.InputHTMLAttributes<HTMLInputElement> & {
  label?: string;
  error?: string;
};

export default function Input({
  label,
  error,
  disabled,
  ...props
}: InputProps) {
  return (
    <InputWrapper>
      {label && <InputLabel>{label}</InputLabel>}
      <StyledInput
        $error={!!error}
        $disabled={disabled}
        disabled={disabled}
        {...props}
      />
      {error && <ErrorMessage>{error}</ErrorMessage>}
    </InputWrapper>
  );
}
```

### Mixin Patterns

```tsx
// styles/mixins.ts
'use client';

import { css } from 'styled-components';

// Flexbox utilities
export const flexCenter = css`
  display: flex;
  align-items: center;
  justify-content: center;
`;

export const flexBetween = css`
  display: flex;
  align-items: center;
  justify-content: space-between;
`;

export const flexColumn = css`
  display: flex;
  flex-direction: column;
`;

// Spacing utilities
export const absoluteFull = css`
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
`;

// Text utilities
export const truncateText = css`
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
`;

export const multiLineTruncate = (lines: number) => css`
  display: -webkit-box;
  -webkit-line-clamp: ${lines};
  -webkit-box-orient: vertical;
  overflow: hidden;
`;

// Shadow utilities
export const elevation1 = css`
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
`;

export const elevation2 = css`
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
`;

export const elevation3 = css`
  box-shadow: 0 10px 15px rgba(0, 0, 0, 0.1);
`;

// Focus utilities
export const focusRing = (color: string = '#007bff') => css`
  &:focus-visible {
    outline: 2px solid ${color};
    outline-offset: 2px;
  }
`;

// Responsive utilities
export const hideBelow = (breakpoint: string) => css`
  @media (max-width: ${breakpoint}) {
    display: none;
  }
`;
```

```tsx
// components/Modal.tsx
'use client';

import styled from 'styled-components';
import { absoluteFull, flexCenter, elevation2 } from '@/styles/mixins';

const ModalOverlay = styled.div`
  ${absoluteFull}
  ${flexCenter}
  background-color: rgba(0, 0, 0, 0.5);
  z-index: 1000;
`;

const ModalContent = styled.div`
  ${elevation2}
  background: white;
  border-radius: 8px;
  padding: 24px;
  max-width: 500px;
  width: 90vw;
  z-index: 1001;
`;

type ModalProps = {
  isOpen: boolean;
  onClose: () => void;
  children: React.ReactNode;
};

export default function Modal({ isOpen, onClose, children }: ModalProps) {
  if (!isOpen) return null;

  return (
    <ModalOverlay onClick={onClose}>
      <ModalContent onClick={(e) => e.stopPropagation()}>
        {children}
      </ModalContent>
    </ModalOverlay>
  );
}
```

## Theming with styled-components

### Theme Provider Setup

```tsx
// lib/theme.ts
export const lightTheme = {
  colors: {
    primary: '#007bff',
    secondary: '#6c757d',
    danger: '#dc3545',
    success: '#28a745',
    warning: '#ffc107',
    background: '#ffffff',
    surface: '#f8f9fa',
    text: '#1a1a1a',
    textSecondary: '#666666',
    border: '#ddd',
  },
  spacing: {
    xs: '4px',
    sm: '8px',
    md: '16px',
    lg: '24px',
    xl: '32px',
  },
  radii: {
    sm: '4px',
    md: '8px',
    lg: '12px',
  },
  shadows: {
    sm: '0 1px 3px rgba(0, 0, 0, 0.1)',
    md: '0 4px 6px rgba(0, 0, 0, 0.1)',
    lg: '0 10px 15px rgba(0, 0, 0, 0.1)',
  },
  breakpoints: {
    sm: '640px',
    md: '768px',
    lg: '1024px',
    xl: '1280px',
  },
};

export const darkTheme = {
  ...lightTheme,
  colors: {
    primary: '#0ea5e9',
    secondary: '#94a3b8',
    danger: '#f87171',
    success: '#34d399',
    warning: '#fbbf24',
    background: '#0f0f0f',
    surface: '#1a1a1a',
    text: '#f5f5f5',
    textSecondary: '#a0a0a0',
    border: '#333',
  },
};

export type Theme = typeof lightTheme;
```

```tsx
// lib/ThemeProvider.tsx
'use client';

import React, { useState, useEffect } from 'react';
import { ThemeProvider as StyledThemeProvider } from 'styled-components';
import { lightTheme, darkTheme } from './theme';
import GlobalStyle from '@/styles/globals';

type ThemeProviderProps = {
  children: React.ReactNode;
  defaultTheme?: 'light' | 'dark';
};

export function ThemeProvider({
  children,
  defaultTheme = 'light',
}: ThemeProviderProps) {
  const [theme, setTheme] = useState(defaultTheme);
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    // Get theme from localStorage or system preference
    const storedTheme = localStorage.getItem('theme');
    const systemTheme = window.matchMedia('(prefers-color-scheme: dark)')
      .matches
      ? 'dark'
      : 'light';

    const initialTheme = (storedTheme || systemTheme) as 'light' | 'dark';
    setTheme(initialTheme);
    setMounted(true);
  }, []);

  const toggleTheme = (newTheme: 'light' | 'dark') => {
    setTheme(newTheme);
    localStorage.setItem('theme', newTheme);
  };

  const currentTheme = theme === 'dark' ? darkTheme : lightTheme;

  if (!mounted) {
    return <>{children}</>;
  }

  return (
    <StyledThemeProvider theme={currentTheme}>
      <GlobalStyle />
      <ThemeContext.Provider value={{ theme, toggleTheme }}>
        {children}
      </ThemeContext.Provider>
    </StyledThemeProvider>
  );
}

export const ThemeContext = React.createContext<{
  theme: 'light' | 'dark';
  toggleTheme: (theme: 'light' | 'dark') => void;
}>({
  theme: 'light',
  toggleTheme: () => {},
});

export const useTheme = () => React.useContext(ThemeContext);
```

```tsx
// app/layout.tsx
import { ThemeProvider } from '@/lib/ThemeProvider';

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body>
        <ThemeProvider>{children}</ThemeProvider>
      </body>
    </html>
  );
}
```

### Using Theme in Components

```tsx
// components/ThemeToggle.tsx
'use client';

import styled from 'styled-components';
import { useTheme } from '@/lib/ThemeProvider';

const ToggleButton = styled.button`
  padding: ${({ theme }) => theme.spacing.sm} ${({ theme }) => theme.spacing.md};
  background-color: ${({ theme }) => theme.colors.surface};
  border: 1px solid ${({ theme }) => theme.colors.border};
  border-radius: ${({ theme }) => theme.radii.md};
  color: ${({ theme }) => theme.colors.text};
  cursor: pointer;
  transition: all 0.2s ease;

  &:hover {
    background-color: ${({ theme }) => theme.colors.primary};
    color: white;
  }
`;

export default function ThemeToggle() {
  const { theme, toggleTheme } = useTheme();

  return (
    <ToggleButton
      onClick={() => toggleTheme(theme === 'light' ? 'dark' : 'light')}
    >
      {theme === 'light' ? '🌙' : '☀️'}
    </ToggleButton>
  );
}
```

## Server Components with styled-components

### Styled RSC Components

```tsx
// app/page.tsx
import Card from '@/components/Card';
import Button from '@/components/Button';

export default function Home() {
  return (
    <main>
      <Card title="Welcome" elevated>
        <p>This is a server component rendering styled components.</p>
        <Button $variant="primary">Learn More</Button>
      </Card>
    </main>
  );
}
```

## Performance Considerations

1. **Use transient props** (prefixed with `$`) to avoid passing style-related props to DOM
2. **Memoize components** that don't need re-renders
3. **Extract styled components** outside render functions
4. **Use CSS variables** for frequently changing values
5. **Enable CSS minification** in Next.js config
6. **Lazy load** heavy components

## Testing

```tsx
// __tests__/Button.test.tsx
import { render, screen } from '@testing-library/react';
import Button from '@/components/Button';
import 'jest-styled-components';

describe('Button', () => {
  it('renders with correct styles', () => {
    const { container } = render(<Button>Click</Button>);
    const button = screen.getByRole('button');

    expect(button).toHaveStyleRule('cursor', 'pointer');
    expect(button).toHaveStyleRule('border', 'none');
  });
});
```

## File Structure

```
project/
├── app/
│   ├── layout.tsx
│   └── page.tsx
├── components/
│   ├── Button.tsx
│   ├── Card.tsx
│   ├── Input.tsx
│   └── Modal.tsx
├── lib/
│   ├── theme.ts
│   ├── ThemeProvider.tsx
│   └── registry.tsx
└── styles/
    ├── globals.tsx
    └── mixins.ts
```

## Summary

Styled-components with Next.js provides:
- Component-scoped CSS-in-JS styling
- Full dynamic style capability
- Excellent theme support
- Server-side rendering compatibility
- Type-safe component props
- Automatic vendor prefixing
- Dead code elimination
