---
name: nextjs:quality-checks
description: Quality assurance checks for Next.js - ESLint, TypeScript, testing, performance, and code standards validation
---

# Quality Checks Skill for Next.js

This skill provides comprehensive quality assurance checks for Next.js projects, ensuring code meets standards before deployment.

## Overview

Quality checks cover:

- **TypeScript**: Type safety and strict mode compliance
- **ESLint**: Code style and best practices
- **Testing**: Unit, integration, and E2E tests
- **Performance**: Lighthouse scores, bundle analysis
- **Accessibility**: WCAG 2.1 compliance
- **Security**: Vulnerability scanning
- **Code Coverage**: Test coverage targets

## Pre-commit Quality Gates

### Setup Pre-commit Hooks

```bash
# Install husky
npx husky-init && npm install

# Add pre-commit hook
npx husky add .husky/pre-commit "npm run quality:check"

# Add pre-push hook
npx husky add .husky/pre-push "npm run test && npm run build"
```

### package.json Scripts

```json
{
  "scripts": {
    "quality:check": "npm run type-check && npm run lint",
    "type-check": "tsc --noEmit",
    "lint": "eslint src --ext ts,tsx --fix",
    "lint:check": "eslint src --ext ts,tsx",
    "test": "vitest run",
    "test:watch": "vitest",
    "test:coverage": "vitest run --coverage",
    "test:e2e": "playwright test",
    "build": "next build",
    "performance:check": "lighthouse http://localhost:3000 --view",
    "security:audit": "npm audit",
    "a11y:check": "axe-playwright"
  }
}
```

## 1. TypeScript Checks

### TypeScript Configuration

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "moduleResolution": "bundler",
    "jsx": "preserve",
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "strictBindCallApply": true,
    "strictPropertyInitialization": true,
    "noImplicitThis": true,
    "alwaysStrict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    },
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true
  },
  "include": ["src", "next-env.d.ts"],
  "exclude": ["node_modules", ".next", "dist"]
}
```

### Type Checking Commands

```bash
# Full type check
npm run type-check

# Check specific file
npx tsc src/components/Button.tsx --noEmit

# Generate type report
npx tsc --noEmit --listFilesOnly > type-report.txt

# Watch mode
npx tsc --watch --noEmit
```

### Type Checking Examples

```typescript
// Bad: Implicit any
function processData(data) {  // Error: Parameter 'data' implicitly has an 'any' type
  return data.value;
}

// Good: Explicit typing
function processData(data: { value: unknown }): unknown {
  return data.value;
}

// Bad: Unused variable
function fetchUser(id: string): User {
  const token = getToken();  // Error: 'token' is declared but never used
  return getUser(id);
}

// Good: Remove unused
function fetchUser(id: string): User {
  return getUser(id);
}

// Bad: Missing return
function getValue(key: string): string {
  if (key === 'name') {
    return 'John';
  }
  // Error: Not all code paths return a value
}

// Good: Handle all paths
function getValue(key: string): string {
  if (key === 'name') {
    return 'John';
  }
  return '';
}
```

## 2. ESLint Checks

### ESLint Configuration

```javascript
// eslint.config.js
import nextPlugin from '@next/eslint-plugin-next';

export default [
  {
    files: ['**/*.ts', '**/*.tsx'],
    languageOptions: {
      parser: '@typescript-eslint/parser',
      parserOptions: {
        ecmaVersion: 2024,
        sourceType: 'module',
        ecmaFeatures: {
          jsx: true,
        },
      },
    },
    plugins: {
      '@typescript-eslint': typescriptPlugin,
      'react': reactPlugin,
      'react-hooks': reactHooksPlugin,
      '@next/next': nextPlugin,
    },
    rules: {
      // TypeScript Rules
      '@typescript-eslint/explicit-function-return-types': 'warn',
      '@typescript-eslint/no-explicit-any': 'error',
      '@typescript-eslint/no-unused-vars': 'error',

      // React Rules
      'react/react-in-jsx-scope': 'off',
      'react/prop-types': 'off',
      'react-hooks/rules-of-hooks': 'error',
      'react-hooks/exhaustive-deps': 'warn',

      // Next.js Rules
      '@next/next/no-img-element': 'warn',
      '@next/next/no-html-link-for-pages': 'warn',

      // General Rules
      'no-console': ['warn', { allow: ['warn', 'error'] }],
      'no-debugger': 'error',
      'prefer-const': 'error',
      'no-var': 'error',
    },
  },
];
```

### ESLint Commands

```bash
# Check all files
npm run lint:check

# Fix automatically fixable issues
npm run lint

# Fix specific file
npx eslint src/components/Button.tsx --fix

# Generate report
npx eslint src --format json > eslint-report.json

# Check single rule
npx eslint src --rule "@typescript-eslint/no-explicit-any: error"
```

### Common ESLint Issues

```typescript
// Issue: Missing return type
const getUser = (id: string) => {  // Error
  return db.user.findById(id);
};

// Fix: Add return type
const getUser = (id: string): Promise<User> => {
  return db.user.findById(id);
};

// Issue: any type
function process(data: any) {  // Error
  return data.value;
}

// Fix: Use proper typing
function process(data: { value: string }): string {
  return data.value;
}

// Issue: Unexhausted dependencies
useEffect(() => {
  console.log(data);
}, []);  // Error: 'data' should be in dependencies

// Fix: Include dependencies
useEffect(() => {
  console.log(data);
}, [data]);  // Correct
```

## 3. Testing Quality Gates

### Test Coverage Requirements

```bash
# Run tests with coverage report
npm run test:coverage

# Expected output:
# ✓ 156 passed
# ✓ Coverage: 82.3% statements, 78.5% branches, 81.2% functions, 82.1% lines
```

### Coverage Configuration

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html', 'lcov'],
      statements: 80,
      branches: 75,
      functions: 80,
      lines: 80,
      exclude: [
        'node_modules/',
        'dist/',
        '.next/',
        '**/*.d.ts',
        '**/*.config.ts',
        '**/mocks/**',
      ],
    },
  },
});
```

### Coverage Report

```bash
# Generate HTML report
npm run test:coverage

# Open report
open coverage/index.html
```

### Test Quality Checklist

```markdown
## Test Quality Standards

### Unit Tests
- [ ] Each function has tests
- [ ] Happy path covered
- [ ] Error cases covered
- [ ] Edge cases covered
- [ ] No flaky tests
- [ ] Tests are isolated
- [ ] Clear test descriptions

### Integration Tests
- [ ] Feature workflows tested
- [ ] Component interactions tested
- [ ] Data flow verified
- [ ] Error scenarios covered
- [ ] Performance acceptable

### E2E Tests
- [ ] Critical user journeys covered
- [ ] Happy path works end-to-end
- [ ] Error handling works
- [ ] Accessibility verified
- [ ] Mobile experience tested

### Test Code Quality
- [ ] DRY (don't repeat yourself)
- [ ] Clear naming
- [ ] Proper setup/teardown
- [ ] No hardcoded values
- [ ] Good use of fixtures
```

## 4. Performance Checks

### Lighthouse Audit

```bash
# Run Lighthouse
npm run performance:check

# Via CLI
npx lighthouse http://localhost:3000 --view
```

### Lighthouse Targets

```markdown
## Performance Metrics

### Lighthouse Scores (target > 90)
- Performance: 95+
- Accessibility: 95+
- Best Practices: 95+
- SEO: 100

### Core Web Vitals
- LCP (Largest Contentful Paint): < 2.5s
- FID (First Input Delay): < 100ms
- CLS (Cumulative Layout Shift): < 0.1

### Load Times
- First Contentful Paint (FCP): < 1.8s
- Time to Interactive (TTI): < 3.7s
- Total Blocking Time (TBT): < 300ms
```

### Bundle Analysis

```bash
# Analyze bundle size
npm run build -- --analyze

# Or use dedicated tool
npx next-bundle-analyzer

# Check for large dependencies
npx webpack-bundle-analyzer .next/static
```

### Image Optimization

```typescript
// Bad: Unoptimized images
<img src="/large-image.jpg" width={400} height={300} />

// Good: Use Next.js Image
import Image from 'next/image';

<Image
  src="/optimized-image.webp"
  alt="Description"
  width={400}
  height={300}
  priority  // For above-the-fold images
  placeholder="blur"  // For smooth loading
/>
```

### Font Optimization

```typescript
// In layout.tsx - Google Fonts
import { Inter, Playfair_Display } from 'next/font/google';

const inter = Inter({ subsets: ['latin'] });
const playfair = Playfair_Display({ subsets: ['latin'] });

export default function RootLayout({ children }) {
  return (
    <html lang="en" className={inter.variable}>
      <body className={`${inter.className} ${playfair.variable}`}>
        {children}
      </body>
    </html>
  );
}
```

## 5. Accessibility Checks

### Accessibility Audit

```bash
# Install axe testing
npm install --save-dev @axe-core/playwright

# Run accessibility tests
npm run a11y:check
```

### Accessibility Standards

```markdown
## WCAG 2.1 Level AA Checklist

### Perceivable
- [ ] Color contrast ratio >= 4.5:1 for normal text
- [ ] All images have alt text
- [ ] Videos have captions
- [ ] Color is not the only way to convey information

### Operable
- [ ] All functionality keyboard accessible
- [ ] No keyboard traps
- [ ] Page title is descriptive
- [ ] Focus order is logical

### Understandable
- [ ] Language is clear and simple
- [ ] Text is easy to read (font size, spacing)
- [ ] Consistent navigation
- [ ] Error messages are helpful

### Robust
- [ ] Valid HTML
- [ ] Proper semantic markup
- [ ] Form labels associated with inputs
- [ ] ARIA used correctly
```

### Accessibility Examples

```typescript
// Bad: Not accessible
<div onClick={handleClick}>Click me</div>
<img src="image.jpg" />
<input type="text" />

// Good: Accessible
<button onClick={handleClick}>Click me</button>
<img src="image.jpg" alt="Description" />
<label htmlFor="name">Name</label>
<input id="name" type="text" />

// Bad: Color only
<span style={{ color: 'red' }}>Required</span>

// Good: Color + indicator
<label>
  Name <span aria-label="required">*</span>
  <input type="text" required />
</label>

// Bad: No keyboard support
<div onMouseEnter={showMenu} onMouseLeave={hideMenu}>
  Menu content
</div>

// Good: Keyboard accessible
<menu
  onMouseEnter={showMenu}
  onMouseLeave={hideMenu}
  onKeyDown={handleMenuKeyboard}
>
  Menu items
</menu>
```

## 6. Security Checks

### Dependency Audit

```bash
# Check for vulnerabilities
npm audit

# Fix vulnerabilities
npm audit fix

# Detailed report
npm audit --json > audit-report.json
```

### Security Best Practices

```typescript
// Bad: SQL injection vulnerability
const query = `SELECT * FROM users WHERE email = '${email}'`;

// Good: Parameterized query
const user = await db.user.findUnique({ where: { email } });

// Bad: XSS vulnerability
<div dangerouslySetInnerHTML={{ __html: userInput }} />

// Good: Sanitized output
import DOMPurify from 'isomorphic-dompurify';

<div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(userInput) }} />

// Bad: Exposed secrets
const API_KEY = 'sk_live_12345678';

// Good: Environment variables
const API_KEY = process.env.API_KEY;

// Bad: Unvalidated user input
const data = JSON.parse(req.body);

// Good: Validated input
import { z } from 'zod';

const schema = z.object({ email: z.string().email() });
const data = schema.parse(req.body);
```

## 7. Code Quality Metrics

### Complexity Analysis

```bash
# Check code complexity
npx complexity-report src

# Review results
# Cyclomatic Complexity: Aim for < 10 per function
# Cognitive Complexity: Aim for < 15 per function
```

### Code Review Checklist

```markdown
## Pull Request Checklist

### Code Quality
- [ ] No console.log statements (except warnings/errors)
- [ ] No commented-out code
- [ ] No TODO comments without context
- [ ] No hardcoded values
- [ ] DRY (don't repeat yourself)
- [ ] Single responsibility principle

### Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] E2E tests pass
- [ ] New code has tests
- [ ] Coverage doesn't decrease

### Performance
- [ ] No performance regressions
- [ ] Bundle size acceptable
- [ ] Images optimized
- [ ] Code split properly

### Security
- [ ] No secrets in code
- [ ] Input validated server-side
- [ ] CSRF protection in place
- [ ] XSS prevention implemented
- [ ] No dependency vulnerabilities

### Accessibility
- [ ] Semantic HTML used
- [ ] Color contrast sufficient
- [ ] Keyboard accessible
- [ ] ARIA labels present
- [ ] Alt text on images

### Documentation
- [ ] Code comments for complex logic
- [ ] README updated if needed
- [ ] API documented
- [ ] Breaking changes noted
```

## Quality Gate Workflow

### CI/CD Pipeline

```yaml
# .github/workflows/quality.yml
name: Quality Checks

on: [push, pull_request]

jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Node
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'

      - name: Install
        run: npm ci

      - name: Type Check
        run: npm run type-check

      - name: Lint
        run: npm run lint:check

      - name: Test
        run: npm run test:coverage

      - name: Upload Coverage
        uses: codecov/codecov-action@v3

      - name: Build
        run: npm run build

      - name: Lighthouse
        run: npm run performance:check

      - name: Security Audit
        run: npm audit --audit-level=moderate
```

## Quality Report Template

```markdown
# Quality Report - Week of 2024-01-15

## Summary
- All quality gates passing
- 2 issues to address
- Performance improved 5%

## Metrics

### Test Coverage
- Overall: 84.2% (target: 80%)
- Statements: 85.1%
- Branches: 82.3%
- Functions: 84.5%
- Lines: 84.8%

### Code Quality
- ESLint: 0 errors, 2 warnings
- TypeScript: 0 errors
- Complexity: Average 6.2 (good)

### Performance
- Lighthouse Score: 94
- LCP: 2.1s (target: < 2.5s)
- CLS: 0.08 (target: < 0.1)
- Bundle: 245KB (target: < 300KB)

### Security
- Vulnerabilities: 0
- Dependencies reviewed: ✓

## Issues & Actions
1. Review 2 ESLint warnings (non-blocking)
2. Improve test coverage in auth module (82% → target 90%)
3. Optimize images in product carousel

## Next Week
- Complete auth test improvements
- Performance optimization sprint
- Security audit review
```

## Resources

- [ESLint Documentation](https://eslint.org)
- [TypeScript Strict Mode](https://www.typescriptlang.org/tsconfig#strict)
- [Vitest Guide](https://vitest.dev)
- [Lighthouse Documentation](https://developers.google.com/web/tools/lighthouse)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [OWASP Security Guidelines](https://owasp.org)
