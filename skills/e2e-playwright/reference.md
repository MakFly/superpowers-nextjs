# Reference

# E2E Testing with Playwright

Complete Playwright setup for Next.js end-to-end testing, including cross-browser testing, visual regression, and CI/CD integration.

## Installation

```bash
npm install --save-dev @playwright/test
npx playwright install

# or with yarn
yarn add --dev @playwright/test
yarn playwright install
```

## Configuration

### playwright.config.ts

```typescript
import { defineConfig, devices } from '@playwright/test'

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: [
    ['html'],
    ['json', { outputFile: 'test-results/results.json' }],
    ['junit', { outputFile: 'test-results/junit.xml' }],
  ],
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },
    {
      name: 'Mobile Chrome',
      use: { ...devices['Pixel 5'] },
    },
    {
      name: 'Mobile Safari',
      use: { ...devices['iPhone 12'] },
    },
  ],
})
```

### package.json

```json
{
  "scripts": {
    "test:e2e": "playwright test",
    "test:e2e:ui": "playwright test --ui",
    "test:e2e:debug": "playwright test --debug",
    "test:e2e:headed": "playwright test --headed"
  }
}
```

## Basic Navigation Test

```typescript
// e2e/navigation.spec.ts
import { test, expect } from '@playwright/test'

test.describe('Navigation', () => {
  test.beforeEach(async ({ page }) => {
    // Navigate to home page before each test
    await page.goto('/')
  })

  test('should navigate to home page', async ({ page }) => {
    expect(page.url()).toBe('http://localhost:3000/')
    await expect(page.locator('h1')).toContainText('Welcome')
  })

  test('should navigate between pages', async ({ page }) => {
    await page.click('a[href="/about"]')
    await expect(page).toHaveURL('/about')
    await expect(page.locator('h1')).toContainText('About')
  })

  test('should preserve scroll position on back navigation', async ({ page }) => {
    // Scroll down
    await page.evaluate(() => window.scrollTo(0, 500))
    const scrollBefore = await page.evaluate(() => window.scrollY)

    // Navigate to another page
    await page.click('a[href="/about"]')
    await page.goBack()

    // Check scroll position
    const scrollAfter = await page.evaluate(() => window.scrollY)
    expect(Math.abs(scrollBefore - scrollAfter)).toBeLessThan(10)
  })
})
```

## Form Testing

```typescript
// e2e/forms.spec.ts
import { test, expect } from '@playwright/test'

test.describe('Form Submission', () => {
  test('should submit contact form', async ({ page }) => {
    await page.goto('/contact')

    // Fill form
    await page.fill('input[name="name"]', 'John Doe')
    await page.fill('input[name="email"]', 'john@example.com')
    await page.fill('textarea[name="message"]', 'Hello, this is a test message')

    // Submit form
    await page.click('button[type="submit"]')

    // Verify success message
    await expect(page.locator('text=Thank you')).toBeVisible()
  })

  test('should show validation errors', async ({ page }) => {
    await page.goto('/contact')

    // Try to submit empty form
    await page.click('button[type="submit"]')

    // Check for error messages
    await expect(page.locator('text=Name is required')).toBeVisible()
    await expect(page.locator('text=Email is required')).toBeVisible()
  })

  test('should validate email format', async ({ page }) => {
    await page.goto('/contact')

    await page.fill('input[name="name"]', 'John')
    await page.fill('input[name="email"]', 'invalid-email')
    await page.fill('textarea[name="message"]', 'Message')

    await page.click('button[type="submit"]')

    await expect(page.locator('text=Invalid email')).toBeVisible()
  })

  test('should handle file upload', async ({ page }) => {
    await page.goto('/upload')

    // Upload file
    await page.locator('input[type="file"]').setInputFiles('./test-file.txt')

    // Verify file is uploaded
    await expect(page.locator('text=test-file.txt')).toBeVisible()
  })
})
```

## Authentication Flow

```typescript
// e2e/auth.spec.ts
import { test, expect } from '@playwright/test'

test.describe('Authentication', () => {
  test('should login successfully', async ({ page }) => {
    await page.goto('/login')

    // Fill login form
    await page.fill('input[name="email"]', 'user@example.com')
    await page.fill('input[name="password"]', 'password123')

    // Submit
    await page.click('button[type="submit"]')

    // Wait for redirect to dashboard
    await page.waitForURL('/dashboard')
    expect(page.url()).toContain('/dashboard')
  })

  test('should show error on invalid credentials', async ({ page }) => {
    await page.goto('/login')

    await page.fill('input[name="email"]', 'wrong@example.com')
    await page.fill('input[name="password"]', 'wrongpass')
    await page.click('button[type="submit"]')

    // Check for error message
    await expect(page.locator('text=Invalid credentials')).toBeVisible()
    // Should stay on login page
    expect(page.url()).toContain('/login')
  })

  test('should logout successfully', async ({ page }) => {
    // First login
    await page.goto('/login')
    await page.fill('input[name="email"]', 'user@example.com')
    await page.fill('input[name="password"]', 'password123')
    await page.click('button[type="submit"]')
    await page.waitForURL('/dashboard')

    // Then logout
    await page.click('button:has-text("Logout")')

    // Should redirect to login
    await page.waitForURL('/login')
  })

  test('should persist session across page reload', async ({ page }) => {
    // Login
    await page.goto('/login')
    await page.fill('input[name="email"]', 'user@example.com')
    await page.fill('input[name="password"]', 'password123')
    await page.click('button[type="submit"]')
    await page.waitForURL('/dashboard')

    // Reload page
    await page.reload()

    // Should still be logged in
    expect(page.url()).toContain('/dashboard')
  })
})
```

## API Interception and Mocking

```typescript
// e2e/api-mocking.spec.ts
import { test, expect } from '@playwright/test'

test.describe('API Mocking', () => {
  test('should mock API response', async ({ page }) => {
    // Mock the API endpoint
    await page.route('**/api/users/**', route => {
      route.abort()
    })

    // Or mock with custom response
    await page.route('**/api/users/**', route => {
      route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({
          id: 1,
          name: 'John Doe',
          email: 'john@example.com',
        }),
      })
    })

    await page.goto('/users/1')

    // Verify UI displays mocked data
    await expect(page.locator('text=John Doe')).toBeVisible()
  })

  test('should handle API errors', async ({ page }) => {
    // Mock API error
    await page.route('**/api/users/**', route => {
      route.fulfill({
        status: 500,
        contentType: 'application/json',
        body: JSON.stringify({ error: 'Server error' }),
      })
    })

    await page.goto('/users/1')

    // Should show error message
    await expect(page.locator('text=Error loading user')).toBeVisible()
  })

  test('should intercept and modify requests', async ({ page }) => {
    let capturedRequest: any = null

    await page.route('**/api/posts', route => {
      capturedRequest = route.request()
      route.continue()
    })

    await page.goto('/posts')

    // Verify request was made
    expect(capturedRequest).toBeTruthy()
    expect(capturedRequest.method()).toBe('GET')
  })
})
```

## Visual Regression Testing

```typescript
// e2e/visual-regression.spec.ts
import { test, expect } from '@playwright/test'

test.describe('Visual Regression', () => {
  test('should match homepage snapshot', async ({ page }) => {
    await page.goto('/')

    // Full page screenshot
    await expect(page).toHaveScreenshot('homepage.png')
  })

  test('should match component visually', async ({ page }) => {
    await page.goto('/components')

    // Screenshot specific element
    const button = page.locator('button[type="submit"]')
    await expect(button).toHaveScreenshot('submit-button.png')
  })

  test('should match responsive layouts', async ({ page }) => {
    // Mobile
    await page.setViewportSize({ width: 375, height: 667 })
    await page.goto('/')
    await expect(page).toHaveScreenshot('homepage-mobile.png')

    // Tablet
    await page.setViewportSize({ width: 768, height: 1024 })
    await expect(page).toHaveScreenshot('homepage-tablet.png')

    // Desktop
    await page.setViewportSize({ width: 1920, height: 1080 })
    await expect(page).toHaveScreenshot('homepage-desktop.png')
  })

  test('should verify component in different states', async ({ page }) => {
    await page.goto('/form')

    // Default state
    await expect(page.locator('form')).toHaveScreenshot('form-default.png')

    // Focused state
    await page.locator('input[type="text"]').focus()
    await expect(page.locator('form')).toHaveScreenshot('form-focused.png')

    // Filled state
    await page.fill('input[type="text"]', 'Some value')
    await expect(page.locator('form')).toHaveScreenshot('form-filled.png')
  })
})
```

## Performance Testing

```typescript
// e2e/performance.spec.ts
import { test, expect } from '@playwright/test'

test.describe('Performance', () => {
  test('should load homepage within acceptable time', async ({ page }) => {
    const start = Date.now()
    await page.goto('/', { waitUntil: 'networkidle' })
    const duration = Date.now() - start

    // Should load in less than 3 seconds
    expect(duration).toBeLessThan(3000)
  })

  test('should measure Core Web Vitals', async ({ page }) => {
    await page.goto('/')

    // Measure metrics
    const metrics = await page.evaluate(() => {
      return {
        // Largest Contentful Paint
        lcp: performance.getEntriesByName('largest-contentful-paint')[0]?.startTime,
        // First Input Delay
        fid: performance.getEntriesByType('first-input')[0]?.processingStart,
        // Cumulative Layout Shift
        cls: performance.getEntriesByType('layout-shift').reduce(
          (sum, entry: any) => sum + (entry.hadRecentInput ? 0 : entry.value),
          0
        ),
      }
    })

    // Verify metrics are acceptable
    expect(metrics.lcp).toBeLessThan(2500) // 2.5s
  })

  test('should not have excessive network requests', async ({ page }) => {
    let requestCount = 0

    page.on('request', () => {
      requestCount++
    })

    await page.goto('/')

    // Should have reasonable number of requests
    expect(requestCount).toBeLessThan(50)
  })
})
```

## Accessibility Testing

```typescript
// e2e/accessibility.spec.ts
import { test, expect } from '@playwright/test'
import { injectAxe, checkA11y } from 'axe-playwright'

test.describe('Accessibility', () => {
  test('should not have accessibility violations on homepage', async ({ page }) => {
    await page.goto('/')
    await injectAxe(page)

    await checkA11y(page, null, {
      detailedReport: true,
      detailedReportOptions: {
        html: true,
      },
    })
  })

  test('should have proper heading hierarchy', async ({ page }) => {
    await page.goto('/')

    const headings = await page.locator('h1, h2, h3, h4, h5, h6').all()

    // Should have at least one h1
    const h1 = await page.locator('h1').count()
    expect(h1).toBeGreaterThan(0)

    // Should have proper nesting
    expect(headings.length).toBeGreaterThan(0)
  })

  test('should have alternative text for images', async ({ page }) => {
    await page.goto('/')

    const images = await page.locator('img').all()

    for (const img of images) {
      const alt = await img.getAttribute('alt')
      expect(alt).toBeTruthy()
    }
  })

  test('should be keyboard navigable', async ({ page }) => {
    await page.goto('/')

    // Should be able to navigate with Tab
    await page.keyboard.press('Tab')
    let focusedElement = await page.evaluate(() => document.activeElement?.tagName)
    expect(focusedElement).not.toBe('BODY')

    // Should be able to interact with Enter
    const button = page.locator('button').first()
    await button.focus()
    let clicked = false
    await page.evaluate(() => {
      clicked = false
      document.querySelector('button')?.addEventListener('click', () => {
        clicked = true
      })
    })
  })
})
```

## Running Tests

```bash
# Run all tests
npm run test:e2e

# Run in UI mode (interactive)
npm run test:e2e:ui

# Run in debug mode
npm run test:e2e:debug

# Run headed (visible browser)
npm run test:e2e:headed

# Run specific test file
npx playwright test e2e/navigation.spec.ts

# Run tests matching pattern
npx playwright test --grep "Navigation"

# Run single test
npx playwright test e2e/navigation.spec.ts -g "should navigate to home"
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Playwright Tests

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    timeout-minutes: 60
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: 18

      - name: Install dependencies
        run: npm ci

      - name: Install Playwright Browsers
        run: npx playwright install --with-deps

      - name: Run Playwright tests
        run: npm run test:e2e

      - uses: actions/upload-artifact@v3
        if: always()
        with:
          name: playwright-report
          path: playwright-report/
          retention-days: 30
```

## Best Practices

1. **Use page objects** - Create reusable page objects for complex interactions
2. **Avoid hard waits** - Use `waitForURL`, `waitForNavigation`, `waitForSelector`
3. **Test user flows** - Focus on complete user journeys, not individual clicks
4. **Parallel execution** - Playwright runs tests in parallel for speed
5. **Mock external APIs** - Use `route()` to intercept and mock API calls
6. **Organize tests** - Group related tests in `describe` blocks
7. **Use fixtures** - Create reusable test setup with Playwright fixtures
8. **Screenshot on failure** - Always capture screenshots for debugging
9. **Cross-browser testing** - Test on Chrome, Firefox, and Safari
10. **Mobile testing** - Include mobile device emulation in your tests
