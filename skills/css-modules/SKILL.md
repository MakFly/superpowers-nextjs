---
name: nextjs:css-modules
description: Use CSS Modules for scoped, component-level styling with TypeScript support
---

# CSS Modules for Next.js

CSS Modules provide scoped, component-level styling with automatic class name generation. Each CSS file becomes a module with locally scoped class names, eliminating naming conflicts and enabling type-safe styling.

## Core Concepts

### What are CSS Modules?

CSS Modules are CSS files where all class names and animation names are scoped locally by default. This means:
- No global namespace pollution
- Automatic class name hashing for production
- Predictable class names in development
- Zero runtime overhead
- Built-in TypeScript support in Next.js

### Why Use CSS Modules?

1. **Scoped Styling**: Classes are automatically scoped to the component
2. **No Naming Conflicts**: Multiple components can use the same class names safely
3. **Type Safety**: Get TypeScript intellisense for class names
4. **Performance**: Classes are hashed in production, reducing CSS size
5. **Developer Experience**: Clear relationship between component and styles
6. **Maintainability**: Easy to modify styles without affecting other components

## Basic Usage

### Simple Component with CSS Module

```tsx
// components/Button.tsx
import styles from './Button.module.css';

export default function Button({
  children,
  variant = 'primary'
}: {
  children: React.ReactNode;
  variant?: 'primary' | 'secondary';
}) {
  return (
    <button className={styles[variant]}>
      {children}
    </button>
  );
}
```

```css
/* components/Button.module.css */
.primary {
  background-color: #007bff;
  color: white;
  padding: 10px 20px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-weight: 600;
  transition: background-color 0.3s ease;
}

.primary:hover {
  background-color: #0056b3;
}

.secondary {
  background-color: transparent;
  color: #007bff;
  padding: 10px 20px;
  border: 2px solid #007bff;
  border-radius: 4px;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.3s ease;
}

.secondary:hover {
  background-color: #007bff;
  color: white;
}
```

### Combining Multiple Classes

```tsx
// components/Card.tsx
import styles from './Card.module.css';

type CardProps = {
  title: string;
  elevated?: boolean;
  interactive?: boolean;
};

export default function Card({
  title,
  elevated = false,
  interactive = false
}: CardProps) {
  const cardClasses = [
    styles.card,
    elevated && styles.elevated,
    interactive && styles.interactive,
  ]
    .filter(Boolean)
    .join(' ');

  return (
    <div className={cardClasses}>
      <h3 className={styles.title}>{title}</h3>
      <p className={styles.content}>Card content goes here</p>
    </div>
  );
}
```

```css
/* components/Card.module.css */
.card {
  background: white;
  border-radius: 8px;
  padding: 16px;
  transition: all 0.3s ease;
}

.elevated {
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.card.interactive:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 12px rgba(0, 0, 0, 0.15);
}

.title {
  margin: 0 0 8px 0;
  font-size: 18px;
  font-weight: 700;
  color: #1a1a1a;
}

.content {
  margin: 0;
  color: #666;
  line-height: 1.6;
}
```

## Advanced Patterns

### Using CSS Module Composition

```tsx
// components/Button.tsx
import styles from './Button.module.css';

type ButtonProps = {
  size?: 'sm' | 'md' | 'lg';
  variant?: 'primary' | 'secondary';
  disabled?: boolean;
};

export default function Button({
  size = 'md',
  variant = 'primary',
  disabled = false,
  children
}: ButtonProps & { children: React.ReactNode }) {
  const classNames = [
    styles.button,
    styles[`size-${size}`],
    styles[`variant-${variant}`],
    disabled && styles.disabled,
  ]
    .filter(Boolean)
    .join(' ');

  return (
    <button className={classNames} disabled={disabled}>
      {children}
    </button>
  );
}
```

```css
/* components/Button.module.css */
.button {
  border: none;
  border-radius: 4px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
  outline: none;
}

.button:focus-visible {
  outline: 2px solid #007bff;
  outline-offset: 2px;
}

/* Size variants */
.size-sm {
  padding: 6px 12px;
  font-size: 14px;
}

.size-md {
  padding: 10px 20px;
  font-size: 16px;
}

.size-lg {
  padding: 14px 28px;
  font-size: 18px;
}

/* Color variants */
.variant-primary {
  background-color: #007bff;
  color: white;
}

.variant-primary:hover:not(.disabled) {
  background-color: #0056b3;
}

.variant-secondary {
  background-color: transparent;
  color: #007bff;
  border: 2px solid #007bff;
}

.variant-secondary:hover:not(.disabled) {
  background-color: #f0f8ff;
}

/* Disabled state */
.disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.disabled:hover {
  background-color: inherit;
  transform: none;
}
```

### Type-Safe Class Name Access

```tsx
// utils/classNameHelper.ts
import { CSSModuleClasses } from 'next/dist/compiled/classnames';

export function mergeClassNames(...classes: (string | undefined | false)[]): string {
  return classes.filter(Boolean).join(' ');
}

export function createStyleGetter<T extends Record<string, string>>(styles: T) {
  return {
    get: (key: keyof T) => styles[key],
    merge: (...keys: (keyof T | false | undefined)[]) =>
      keys.filter(Boolean).map(k => styles[k as keyof T]).join(' '),
  };
}
```

```tsx
// components/Modal.tsx
import styles from './Modal.module.css';
import { createStyleGetter } from '@/utils/classNameHelper';

const styleGetter = createStyleGetter(styles);

export default function Modal({ open }: { open: boolean }) {
  return (
    <>
      {open && (
        <div className={styles.overlay}>
          <div className={styleGetter.merge('modal', 'fadeIn')}>
            <div className={styles.header}>Modal Title</div>
            <div className={styles.body}>Modal content</div>
            <div className={styles.footer}>
              <button className={styles.closeBtn}>Close</button>
            </div>
          </div>
        </div>
      )}
    </>
  );
}
```

### Responsive Design with CSS Modules

```css
/* components/Grid.module.css */
.grid {
  display: grid;
  gap: 16px;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
}

.gridItem {
  background: white;
  border-radius: 8px;
  padding: 16px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

@media (max-width: 768px) {
  .grid {
    grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
    gap: 12px;
  }

  .gridItem {
    padding: 12px;
  }
}

@media (max-width: 480px) {
  .grid {
    grid-template-columns: 1fr;
    gap: 8px;
  }
}
```

```tsx
// components/Grid.tsx
import styles from './Grid.module.css';

export default function Grid({ children }: { children: React.ReactNode }) {
  return (
    <div className={styles.grid}>
      {React.Children.map(children, (child) => (
        <div className={styles.gridItem}>{child}</div>
      ))}
    </div>
  );
}
```

## Best Practices

### 1. **Naming Conventions**

```css
/* Use BEM-like naming for clarity */
.component {
  /* Base styles */
}

.component__element {
  /* Element within component */
}

.component--modifier {
  /* Variant or state */
}
```

### 2. **Organize Styles Logically**

```css
/* Group related styles */
.button {
  /* Layout */
  padding: 10px 20px;
  border-radius: 4px;

  /* Typography */
  font-weight: 600;
  font-size: 16px;

  /* Colors */
  background-color: #007bff;
  color: white;

  /* Interactions */
  cursor: pointer;
  transition: all 0.2s ease;
}
```

### 3. **Keep CSS Modules Lean**

```tsx
// Avoid: Huge CSS files
// Prefer: Small, focused files per component

// components/FormField/FormField.tsx
// components/FormField/FormField.module.css (only styles for FormField)

// ✓ Good organization
import styles from './FormField.module.css';

// ✗ Avoid
import styles from './styles/everything.module.css';
```

### 4. **Use CSS Variables for Themes**

```css
/* styles/variables.module.css */
.root {
  --color-primary: #007bff;
  --color-secondary: #6c757d;
  --color-danger: #dc3545;
  --color-success: #28a745;

  --spacing-xs: 4px;
  --spacing-sm: 8px;
  --spacing-md: 16px;
  --spacing-lg: 24px;

  --radius-sm: 4px;
  --radius-md: 8px;
  --radius-lg: 12px;

  --shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.05);
  --shadow-md: 0 4px 6px rgba(0, 0, 0, 0.1);
  --shadow-lg: 0 10px 15px rgba(0, 0, 0, 0.1);
}
```

```tsx
// components/Button.tsx
import styles from './Button.module.css';
import variables from '@/styles/variables.module.css';

export default function Button({ children }) {
  return <button className={styles.button}>{children}</button>;
}
```

```css
/* components/Button.module.css */
.button {
  background-color: var(--color-primary);
  color: white;
  padding: var(--spacing-sm) var(--spacing-md);
  border-radius: var(--radius-sm);
  box-shadow: var(--shadow-sm);
}

.button:hover {
  box-shadow: var(--shadow-md);
}
```

## Global Styles Integration

```tsx
// app/layout.tsx
import '@/styles/globals.css';
import '@/styles/variables.module.css';
import styles from '@/styles/layout.module.css';

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body className={styles.body}>
        <div className={styles.container}>
          {children}
        </div>
      </body>
    </html>
  );
}
```

## TypeScript Support

```tsx
// Using CSS Modules types for better DX
import type { CSSModuleClasses } from 'next/dist/compiled/classnames';
import styles from './Component.module.css';

type StyleKey = keyof typeof styles;

export default function Component() {
  const getClass = (key: StyleKey): string => styles[key];

  return <div className={getClass('container')}></div>;
}
```

## Performance Tips

1. **Code Splitting**: Each component's CSS is only loaded when needed
2. **Avoid `!important`**: Use specificity and cascading
3. **Minimize Redundancy**: Extract common styles to base components
4. **Use Critical CSS**: Import critical styles at the top level
5. **Optimize Media Queries**: Group breakpoints logically

## File Structure Example

```
project/
├── app/
│   ├── layout.tsx
│   └── layout.module.css
├── components/
│   ├── Button/
│   │   ├── Button.tsx
│   │   └── Button.module.css
│   ├── Card/
│   │   ├── Card.tsx
│   │   └── Card.module.css
│   └── Form/
│       ├── Input.tsx
│       ├── Input.module.css
│       ├── Select.tsx
│       └── Select.module.css
└── styles/
    ├── globals.css
    ├── variables.module.css
    └── reset.css
```

## Troubleshooting

### Issue: Styles Not Applying

```tsx
// ✗ Wrong: Using string literal
<div className="button"></div>

// ✓ Correct: Using CSS Module import
import styles from './Button.module.css';
<div className={styles.button}></div>
```

### Issue: Class Name Not Found

```tsx
// ✓ Use optional chaining for dynamic classes
const className = styles[variant as keyof typeof styles] || styles.default;

// ✓ Or use a helper function
const getStyle = (key: string) => styles[key as keyof typeof styles] || '';
```

## Summary

CSS Modules provide a robust, scalable approach to component styling in Next.js with:
- Zero setup complexity
- Automatic scoping
- Type safety
- Production optimization
- Clear component-to-style mapping
