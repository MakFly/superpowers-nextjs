---
name: nextjs:tailwind-integration
description: Configure and use Tailwind CSS with Next.js including dark mode and custom themes
---

# Tailwind CSS Integration for Next.js

Tailwind CSS is a utility-first CSS framework that enables rapid UI development through composable classes. When integrated with Next.js, it provides instant styling, dark mode support, and customizable theme configuration.

## Setup and Configuration

### Initial Setup

```bash
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p
```

### Configure Tailwind

```js
// tailwind.config.ts
import type { Config } from 'tailwindcss';

const config: Config = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        primary: '#007bff',
        secondary: '#6c757d',
        accent: '#fd7e14',
      },
      spacing: {
        '128': '32rem',
        '144': '36rem',
      },
      fontSize: {
        'xs': ['12px', { lineHeight: '16px' }],
        'sm': ['14px', { lineHeight: '20px' }],
        'base': ['16px', { lineHeight: '24px' }],
        'lg': ['18px', { lineHeight: '28px' }],
      },
    },
  },
  plugins: [],
};

export default config;
```

### PostCSS Configuration

```js
// postcss.config.js
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
};
```

### Import Global Styles

```css
/* app/globals.css */
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  body {
    @apply bg-white dark:bg-slate-950 text-slate-900 dark:text-slate-50;
  }

  h1 {
    @apply text-3xl font-bold;
  }

  h2 {
    @apply text-2xl font-semibold;
  }
}

@layer components {
  .btn-primary {
    @apply px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors;
  }

  .btn-secondary {
    @apply px-4 py-2 bg-gray-200 text-gray-900 rounded-lg hover:bg-gray-300 transition-colors;
  }

  .card {
    @apply bg-white dark:bg-slate-900 rounded-lg shadow-md p-6;
  }
}
```

## Core Patterns

### Responsive Design

```tsx
// components/ResponsiveGrid.tsx
export default function ResponsiveGrid() {
  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
      {/* Grid items automatically adjust based on screen size */}
      <div className="bg-white p-4 rounded-lg shadow">Card 1</div>
      <div className="bg-white p-4 rounded-lg shadow">Card 2</div>
      <div className="bg-white p-4 rounded-lg shadow">Card 3</div>
    </div>
  );
}
```

### Flexbox Layouts

```tsx
// components/FlexLayout.tsx
export default function FlexLayout() {
  return (
    <div className="flex flex-col md:flex-row gap-8 items-start md:items-center justify-between">
      <div className="flex-1">
        <h2 className="text-2xl font-bold mb-4">Section Title</h2>
        <p className="text-gray-600">Content here</p>
      </div>
      <div className="flex-shrink-0 w-full md:w-64">
        <img
          src="/image.jpg"
          alt="Example"
          className="w-full rounded-lg"
        />
      </div>
    </div>
  );
}
```

### Dark Mode Implementation

```tsx
// app/layout.tsx
import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'My App',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body>
        <DarkModeProvider>
          {children}
        </DarkModeProvider>
      </body>
    </html>
  );
}
```

```tsx
// components/DarkModeToggle.tsx
'use client';

import { useEffect, useState } from 'react';

export default function DarkModeToggle() {
  const [isDark, setIsDark] = useState(false);

  useEffect(() => {
    const isDarkMode = localStorage.getItem('darkMode') === 'true' ||
      (!localStorage.getItem('darkMode') &&
       window.matchMedia('(prefers-color-scheme: dark)').matches);

    setIsDark(isDarkMode);
    updateTheme(isDarkMode);
  }, []);

  const updateTheme = (dark: boolean) => {
    if (dark) {
      document.documentElement.classList.add('dark');
    } else {
      document.documentElement.classList.remove('dark');
    }
    localStorage.setItem('darkMode', String(dark));
  };

  const toggleDarkMode = () => {
    const newDarkMode = !isDark;
    setIsDark(newDarkMode);
    updateTheme(newDarkMode);
  };

  return (
    <button
      onClick={toggleDarkMode}
      className="p-2 rounded-lg bg-gray-200 dark:bg-gray-800 text-gray-900 dark:text-white transition-colors"
      aria-label="Toggle dark mode"
    >
      {isDark ? '☀️' : '🌙'}
    </button>
  );
}
```

```tsx
// providers/DarkModeProvider.tsx
'use client';

import { useEffect } from 'react';

export function DarkModeProvider({ children }: { children: React.ReactNode }) {
  useEffect(() => {
    const isDarkMode = localStorage.getItem('darkMode') === 'true' ||
      (!localStorage.getItem('darkMode') &&
       window.matchMedia('(prefers-color-scheme: dark)').matches);

    if (isDarkMode) {
      document.documentElement.classList.add('dark');
    }
  }, []);

  return <>{children}</>;
}
```

## Advanced Patterns

### Custom Theme Configuration

```ts
// tailwind.config.ts
import type { Config } from 'tailwindcss';
import defaultTheme from 'tailwindcss/defaultTheme';

const config: Config = {
  darkMode: 'class',
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter', ...defaultTheme.fontFamily.sans],
        mono: ['JetBrains Mono', ...defaultTheme.fontFamily.mono],
      },
      colors: {
        // Brand colors
        brand: {
          50: '#f0f9ff',
          100: '#e0f2fe',
          200: '#bae6fd',
          300: '#7dd3fc',
          400: '#38bdf8',
          500: '#0ea5e9',
          600: '#0284c7',
          700: '#0369a1',
          800: '#075985',
          900: '#0c3d66',
        },
        // Status colors
        success: '#22c55e',
        warning: '#eab308',
        error: '#ef4444',
        info: '#3b82f6',
        // Semantic colors
        surface: 'rgb(var(--color-surface) / <alpha-value>)',
        'surface-variant': 'rgb(var(--color-surface-variant) / <alpha-value>)',
        'on-surface': 'rgb(var(--color-on-surface) / <alpha-value>)',
      },
      spacing: {
        'safe': 'max(1rem, env(safe-area-inset-left))',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        slideDown: {
          '0%': { transform: 'translateY(-10px)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' },
        },
        pulse: {
          '0%, 100%': { opacity: '1' },
          '50%': { opacity: '.5' },
        },
      },
      animation: {
        fadeIn: 'fadeIn 0.3s ease-in-out',
        slideDown: 'slideDown 0.3s ease-out',
      },
    },
  },
  plugins: [],
};

export default config;
```

### CSS Variables for Runtime Theming

```css
/* app/globals.css */
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
    --color-surface: 255 255 255;
    --color-surface-variant: 249 249 249;
    --color-on-surface: 24 24 24;
  }

  html.dark {
    --color-surface: 15 23 42;
    --color-surface-variant: 30 41 59;
    --color-on-surface: 248 250 252;
  }
}
```

### Component Variants with Tailwind

```tsx
// components/Button.tsx
import { cva, type VariantProps } from 'class-variance-authority';
import { cn } from '@/lib/utils';

const buttonVariants = cva(
  'inline-flex items-center justify-center rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed',
  {
    variants: {
      variant: {
        default: 'bg-primary text-primary-foreground hover:bg-primary/90',
        destructive: 'bg-destructive text-destructive-foreground hover:bg-destructive/90',
        outline: 'border border-input bg-background hover:bg-accent hover:text-accent-foreground',
        secondary: 'bg-secondary text-secondary-foreground hover:bg-secondary/80',
        ghost: 'hover:bg-accent hover:text-accent-foreground',
        link: 'text-primary underline-offset-4 hover:underline',
      },
      size: {
        default: 'h-10 px-4 py-2',
        sm: 'h-9 rounded-md px-3',
        lg: 'h-11 rounded-md px-8',
        icon: 'h-10 w-10',
      },
    },
    defaultVariants: {
      variant: 'default',
      size: 'default',
    },
  }
);

export type ButtonProps = React.ButtonHTMLAttributes<HTMLButtonElement> &
  VariantProps<typeof buttonVariants>;

export default function Button({
  className,
  variant,
  size,
  ...props
}: ButtonProps) {
  return (
    <button
      className={cn(buttonVariants({ variant, size, className }))}
      {...props}
    />
  );
}
```

### Form Styling

```tsx
// components/Form/Input.tsx
import { cn } from '@/lib/utils';

type InputProps = React.InputHTMLAttributes<HTMLInputElement> & {
  label?: string;
  error?: string;
};

export default function Input({
  label,
  error,
  className,
  ...props
}: InputProps) {
  return (
    <div className="space-y-2">
      {label && (
        <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">
          {label}
        </label>
      )}
      <input
        className={cn(
          'w-full px-3 py-2 border rounded-lg bg-white dark:bg-slate-900',
          'border-gray-300 dark:border-slate-700',
          'focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent',
          'text-gray-900 dark:text-white',
          'placeholder-gray-400 dark:placeholder-gray-500',
          error && 'border-red-500 focus:ring-red-500',
          className
        )}
        {...props}
      />
      {error && (
        <p className="text-sm text-red-600 dark:text-red-400">{error}</p>
      )}
    </div>
  );
}
```

```tsx
// components/Form/Form.tsx
'use client';

import { useState } from 'react';
import Input from './Input';
import Button from '@/components/Button';

export default function ContactForm() {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    message: '',
  });
  const [errors, setErrors] = useState<Record<string, string>>({});

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    // Validate and submit
  };

  return (
    <form
      onSubmit={handleSubmit}
      className="max-w-md mx-auto p-6 bg-white dark:bg-slate-900 rounded-lg shadow-lg space-y-4"
    >
      <h2 className="text-2xl font-bold text-gray-900 dark:text-white">
        Contact Us
      </h2>

      <Input
        label="Name"
        placeholder="John Doe"
        value={formData.name}
        onChange={(e) =>
          setFormData({ ...formData, name: e.target.value })
        }
        error={errors.name}
      />

      <Input
        label="Email"
        type="email"
        placeholder="john@example.com"
        value={formData.email}
        onChange={(e) =>
          setFormData({ ...formData, email: e.target.value })
        }
        error={errors.email}
      />

      <div className="space-y-2">
        <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">
          Message
        </label>
        <textarea
          placeholder="Your message..."
          value={formData.message}
          onChange={(e) =>
            setFormData({ ...formData, message: e.target.value })
          }
          className="w-full px-3 py-2 border border-gray-300 dark:border-slate-700 rounded-lg bg-white dark:bg-slate-900 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
          rows={4}
        />
      </div>

      <Button type="submit" className="w-full">
        Send Message
      </Button>
    </form>
  );
}
```

## Utility Patterns

### Creating Reusable Utility Classes

```css
/* app/globals.css */
@layer components {
  /* Layout utilities */
  .container-base {
    @apply mx-auto px-4 sm:px-6 lg:px-8 max-w-7xl;
  }

  .section {
    @apply py-12 md:py-16 lg:py-20;
  }

  /* Typography utilities */
  .text-balance {
    text-wrap: balance;
  }

  .truncate-lines-2 {
    @apply line-clamp-2;
  }

  .truncate-lines-3 {
    @apply line-clamp-3;
  }

  /* Flex utilities */
  .flex-center {
    @apply flex items-center justify-center;
  }

  .flex-between {
    @apply flex items-center justify-between;
  }

  /* Grid utilities */
  .grid-auto {
    @apply grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4;
  }

  /* Shadow utilities */
  .shadow-elevation-1 {
    @apply shadow-sm;
  }

  .shadow-elevation-2 {
    @apply shadow-md;
  }

  .shadow-elevation-3 {
    @apply shadow-lg;
  }

  /* Border utilities */
  .border-base {
    @apply border border-gray-200 dark:border-slate-700;
  }

  /* Animation utilities */
  .transition-smooth {
    @apply transition-all duration-200 ease-in-out;
  }
}
```

```tsx
// Usage in components
export default function Card() {
  return (
    <div className="container-base section">
      <div className="grid-auto">
        <article className="border-base rounded-lg shadow-elevation-1 p-6 transition-smooth hover:shadow-elevation-2">
          <h3 className="text-lg font-semibold truncate-lines-2">
            Card Title
          </h3>
        </article>
      </div>
    </div>
  );
}
```

## Performance Optimization

### Purging Unused Styles

```js
// tailwind.config.ts
import type { Config } from 'tailwindcss';

const config: Config = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
    // Include any dynamic content sources
    './public/**/*.html',
  ],
  // ... rest of config
};

export default config;
```

### Dynamic Class Names

```tsx
// ✓ Safe: Class name is static
<div className={`text-${size}-base`}></div>

// ✗ Avoid: Dynamic class names won't be purged
<div className={`text-${dynamicValue}`}></div>

// ✓ Correct approach
const sizeClasses = {
  sm: 'text-sm',
  md: 'text-base',
  lg: 'text-lg',
};

<div className={sizeClasses[size]}></div>
```

## Testing Styles

```tsx
// __tests__/Button.test.tsx
import { render, screen } from '@testing-library/react';
import Button from '@/components/Button';

describe('Button', () => {
  it('applies correct classes', () => {
    render(<Button>Click me</Button>);
    const button = screen.getByRole('button');
    expect(button).toHaveClass('bg-blue-600');
  });
});
```

## Best Practices

1. **Use `@apply` for repeated patterns**
2. **Extend theme instead of replacing it**
3. **Group responsive breakpoints logically**
4. **Use CSS variables for runtime customization**
5. **Prefer utility classes over custom CSS**
6. **Keep component-specific styles with components**
7. **Use CSS layers for organization**
8. **Test responsive behavior**

## File Structure

```
project/
├── app/
│   ├── globals.css
│   ├── layout.tsx
│   └── page.tsx
├── components/
│   ├── Button.tsx
│   ├── Card.tsx
│   └── Form/
│       ├── Input.tsx
│       └── Form.tsx
├── tailwind.config.ts
└── postcss.config.js
```

## Summary

Tailwind CSS with Next.js provides:
- Utility-first rapid development
- Built-in dark mode support
- Highly customizable theming
- Automatic CSS purging
- Excellent TypeScript support
- Outstanding responsive design capabilities
