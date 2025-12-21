# Testing Skills Guide

Complete testing framework for Next.js applications with 4 comprehensive skills covering all testing layers.

## Skills Overview

### 1. Testing with Jest
**Path:** `testing-with-jest/SKILL.md`
**Name:** `nextjs:testing-with-jest`

Complete Jest setup for Next.js projects with React Testing Library.

**Coverage:**
- Installation & configuration (jest.config.js, jest.setup.js)
- Unit testing basics
- Form testing with async operations
- API mocking patterns
- Hook testing with renderHook
- CI/CD GitHub Actions integration

**Key Examples:**
- Button component testing
- LoginForm with error handling
- API fetch mocking
- useCounter hook testing

**Use Cases:**
- Unit tests for components and utilities
- Testing component behavior and integration
- Mocking external APIs and Next.js modules
- Testing React hooks

---

### 2. Testing with Vitest
**Path:** `testing-with-vitest/SKILL.md`
**Name:** `nextjs:testing-with-vitest`

High-performance testing with native ESM and TypeScript support.

**Coverage:**
- Installation & configuration (vitest.config.ts, vitest.setup.ts)
- Basic component testing
- Integration testing with async state
- Async utilities testing (fetchWithRetry, debounce)
- Snapshot testing
- Module mocking patterns
- Performance optimization tips

**Key Examples:**
- Card component testing
- UserProfile integration test
- Async retry pattern testing
- Debounce function testing
- API client mocking

**Use Cases:**
- Fast parallel test execution
- TypeScript projects with native support
- Instant feedback with UI mode
- Modern ESM-based projects

---

### 3. E2E Testing with Playwright
**Path:** `e2e-playwright/SKILL.md`
**Name:** `nextjs:e2e-playwright`

Full browser testing with cross-browser support and visual regression.

**Coverage:**
- Installation & configuration (playwright.config.ts)
- Basic navigation testing
- Form submission testing
- Authentication flows
- API interception and mocking
- Visual regression testing
- Performance testing (Core Web Vitals)
- Accessibility testing with Axe
- CI/CD GitHub Actions integration

**Key Examples:**
- Navigation between pages
- Form validation and submission
- Login/logout flows
- API response mocking
- Visual regression snapshots
- Responsive design testing
- Accessibility compliance checks

**Use Cases:**
- End-to-end user journey testing
- Cross-browser compatibility (Chrome, Firefox, Safari, Mobile)
- Visual regression detection
- Performance monitoring
- Accessibility compliance verification

---

### 4. React Testing Library
**Path:** `react-testing-library/SKILL.md`
**Name:** `nextjs:react-testing-library`

Best practices for user-centric component testing.

**Coverage:**
- Query types and priority order
- Basic component testing
- User event interactions
- Form input testing
- Async testing patterns
- Dialog/Modal testing
- Custom hook testing
- Mocking patterns
- Testing best practices

**Key Examples:**
- Badge component with role queries
- Toggle component with accessibility
- SearchInput with keyboard handling
- DataTable with async loading
- Modal with overlay interactions
- useForm custom hook
- Avatar with next/image mocking

**Use Cases:**
- Component unit testing
- Testing user interactions realistically
- Accessibility-first testing approach
- Form and input validation
- Custom React hooks

---

## Quick Start

### Choose Your Testing Framework

**For Unit/Component Testing:**
- **Jest:** Traditional choice, widely supported, great for beginners
- **Vitest:** Modern alternative, faster, better TypeScript support

**For E2E Testing:**
- **Playwright:** Complete E2E solution with multiple browsers

**For Component Testing:**
- **React Testing Library:** User-centric testing patterns (works with Jest or Vitest)

### Installation Examples

```bash
# Jest + RTL
npm install --save-dev jest @testing-library/react @testing-library/jest-dom

# Vitest + RTL
npm install --save-dev vitest @vitest/ui @testing-library/react jsdom

# Playwright
npm install --save-dev @playwright/test
npx playwright install

# Full Stack
npm install --save-dev \
  jest vitest @vitest/ui \
  @testing-library/react @testing-library/jest-dom \
  @playwright/test \
  jest-environment-jsdom jsdom
```

### Running Tests

```bash
# Jest
npm test
npm run test:watch
npm run test:coverage

# Vitest
npm run test:vitest
npm run test:ui
npm run test:coverage

# Playwright E2E
npm run test:e2e
npm run test:e2e:ui
npm run test:e2e:headed
```

---

## Testing Pyramid Strategy

```
        E2E Tests (Playwright)
           /     \
      Integration Tests
       /              \
   Unit Tests (Jest/Vitest)
```

**Recommended Distribution:**
- Unit Tests: 70% (Jest/Vitest)
- Integration Tests: 20% (Jest/Vitest)
- E2E Tests: 10% (Playwright)

---

## Best Practices Across All Frameworks

### 1. Test User Behavior, Not Implementation
```typescript
// Good
screen.getByRole('button', { name: /submit/i })

// Bad
wrapper.find(Button).simulate('click')
```

### 2. Use Proper Setup and Teardown
```typescript
beforeEach(() => {
  // Setup test state
})

afterEach(() => {
  // Clean up mocks and state
  jest.clearAllMocks()
})
```

### 3. Mock External Dependencies
```typescript
// Mock APIs
jest.mock('fetch')

// Mock next/router
jest.mock('next/router')

// Mock next/image
jest.mock('next/image')
```

### 4. Test Async Operations Properly
```typescript
// Jest/Vitest
await waitFor(() => {
  expect(element).toBeInTheDocument()
})

// Playwright
await page.waitForURL('/dashboard')
```

### 5. Organize Tests Logically
```typescript
describe('LoginForm', () => {
  describe('rendering', () => {
    it('renders form inputs')
  })

  describe('submission', () => {
    it('submits with correct values')
  })

  describe('validation', () => {
    it('shows error on invalid email')
  })
})
```

---

## Coverage Targets

Aim for meaningful coverage, not just numbers:

```
  Statements   : 80%+
  Branches     : 75%+
  Functions    : 80%+
  Lines        : 80%+
```

Focus on:
- Critical user paths
- Error handling
- Edge cases
- Component interactions

---

## CI/CD Integration

All skills include GitHub Actions examples for:
- Running tests on push/PR
- Coverage reporting
- Artifact upload (reports, videos, screenshots)
- Parallel execution

See individual skill files for specific CI/CD configurations.

---

## Common Patterns

### Mocking API Calls
```typescript
// Jest/Vitest
global.fetch = jest.fn(() =>
  Promise.resolve({ ok: true, json: () => mockData })
)

// Playwright
await page.route('**/api/**', route => {
  route.fulfill({ body: JSON.stringify(mockData) })
})
```

### Testing Async Components
```typescript
// Jest/Vitest with waitFor
await waitFor(() => {
  expect(screen.getByText('Loaded')).toBeInTheDocument()
})

// Playwright with waitForSelector
await page.waitForSelector('text=Loaded')
```

### Testing User Interactions
```typescript
// React Testing Library (Jest/Vitest)
const user = userEvent.setup()
await user.type(input, 'text')
await user.click(button)

// Playwright
await page.fill('input', 'text')
await page.click('button')
```

---

## Troubleshooting

### Common Issues

**Tests timing out:**
- Increase Jest/Vitest timeout: `jest.setTimeout(10000)`
- Check for unresolved promises
- Use `waitFor` with proper timeout

**Mock not working:**
- Clear mocks between tests: `jest.clearAllMocks()`
- Mock before importing component
- Check mock path matches actual import

**Async state not updating:**
- Use `act()` wrapper for state updates
- Use `waitFor()` for async operations
- Ensure proper cleanup in afterEach

**Playwright test hanging:**
- Check for unclosed connections
- Use `waitForURL` for navigation
- Set proper timeout in config

---

## Additional Resources

- [Jest Documentation](https://jestjs.io/docs/getting-started)
- [Vitest Documentation](https://vitest.dev/)
- [React Testing Library Docs](https://testing-library.com/docs/react-testing-library/intro/)
- [Playwright Documentation](https://playwright.dev/docs/intro)
- [Testing Best Practices](https://kentcdodds.com/blog/common-mistakes-with-react-testing-library)

