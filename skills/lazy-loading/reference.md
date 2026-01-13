# Reference

# Lazy Loading with Next.js

Lazy loading reduces initial bundle size by splitting code and loading components on demand with dynamic imports and Suspense boundaries.

## Core Concepts

### Benefits of Lazy Loading
- **Reduced Bundle Size**: Ship less JavaScript on initial page
- **Faster Initial Load**: Lower Time to Interactive (TTI)
- **Better Performance**: Load code when needed
- **Optimized Routes**: Route-specific code splitting
- **Bandwidth Efficiency**: Users only download required code

### Lazy Loading Strategies
- Dynamic imports for route splitting
- React.lazy for component-level splitting
- Suspense boundaries for async components
- next/dynamic for Next.js optimization
- Prefetching for anticipated navigation

## Dynamic Imports

### Basic Dynamic Import

```typescript
// No SSR by default
const HeavyComponent = dynamic(() => import('./HeavyComponent'), {
  loading: () => <LoadingSpinner />,
})

export default function Page() {
  return (
    <Suspense fallback={<LoadingSpinner />}>
      <HeavyComponent />
    </Suspense>
  )
}
```

### Dynamic Import with SSR

```typescript
import dynamic from 'next/dynamic'
import { Suspense } from 'react'

const Dashboard = dynamic(() => import('./Dashboard'), {
  ssr: true, // Enable server-side rendering
  loading: () => <DashboardSkeleton />,
})

export default function AdminPage() {
  return (
    <Suspense fallback={<DashboardSkeleton />}>
      <Dashboard />
    </Suspense>
  )
}
```

### Dynamic Import with Error Boundary

```typescript
'use client'

import dynamic from 'next/dynamic'
import { Suspense } from 'react'

type DynamicOptions = {
  ssr?: boolean
  loading?: () => React.ReactNode
  errorComponent?: React.ComponentType<{ error: Error; reset: () => void }>
};

const withDynamicAndError = (
  importFn: () => Promise<{ default: React.ComponentType<any> }>,
  options: DynamicOptions = {}
) => {
  return dynamic(() => importFn(), {
    ssr: options.ssr ?? true,
    loading: options.loading ?? (() => <div>Loading...</div>),
  })
}

const Editor = withDynamicAndError(() => import('./Editor'), {
  ssr: false,
  loading: () => <EditorSkeleton />,
})

export default function DocumentPage() {
  return (
    <Suspense fallback={<EditorSkeleton />}>
      <Editor />
    </Suspense>
  )
}
```

## React.lazy and Suspense

### Basic React.lazy

```typescript
import { Suspense, lazy } from 'react'

const Comments = lazy(() => import('./Comments'))
const Profile = lazy(() => import('./Profile'))

export default function Article() {
  return (
    <article>
      <h1>Article Title</h1>
      <p>Article content...</p>

      <section>
        <h2>Comments</h2>
        <Suspense fallback={<div>Loading comments...</div>}>
          <Comments />
        </Suspense>
      </section>

      <aside>
        <h3>Author Profile</h3>
        <Suspense fallback={<div>Loading profile...</div>}>
          <Profile />
        </Suspense>
      </aside>
    </article>
  )
}
```

### Suspense with Multiple Fallbacks

```typescript
import { Suspense, lazy } from 'react'

const Analytics = lazy(() => import('./Analytics'))
const Notifications = lazy(() => import('./Notifications'))
const Settings = lazy(() => import('./Settings'))

export default function Dashboard() {
  return (
    <div className="grid gap-4">
      <Suspense fallback={<AnalyticsSkeleton />}>
        <Analytics />
      </Suspense>

      <Suspense fallback={<NotificationsSkeleton />}>
        <Notifications />
      </Suspense>

      <Suspense fallback={<SettingsSkeleton />}>
        <Settings />
      </Suspense>
    </div>
  )
}
```

### Nested Suspense Boundaries

```typescript
import { Suspense, lazy } from 'react'

const Header = lazy(() => import('./Header'))
const Sidebar = lazy(() => import('./Sidebar'))
const MainContent = lazy(() => import('./MainContent'))
const Footer = lazy(() => import('./Footer'))

function LoadingSkeleton() {
  return <div className="animate-pulse bg-gray-200 h-20" />
}

export default function Layout() {
  return (
    <div className="flex flex-col min-h-screen">
      <Suspense fallback={<LoadingSkeleton />}>
        <Header />
      </Suspense>

      <div className="flex flex-1">
        <Suspense fallback={<LoadingSkeleton />}>
          <Sidebar />
        </Suspense>

        <Suspense fallback={<LoadingSkeleton />}>
          <MainContent />
        </Suspense>
      </div>

      <Suspense fallback={<LoadingSkeleton />}>
        <Footer />
      </Suspense>
    </div>
  )
}
```

## next/dynamic

### Dynamic Components

```typescript
import dynamic from 'next/dynamic'
import { Suspense } from 'react'

const DynamicHeader = dynamic(() => import('../components/Header'), {
  loading: () => <HeaderSkeleton />,
  ssr: true,
})

const DynamicComponent = dynamic(() => import('../components/Component'), {
  ssr: false,
})

export default function Page() {
  return (
    <>
      <DynamicHeader />
      <Suspense fallback={<div>Loading component...</div>}>
        <DynamicComponent />
      </Suspense>
    </>
  )
}
```

### Named Exports Dynamic Import

```typescript
import dynamic from 'next/dynamic'

const { About } = dynamic(() => import('../components/About').then((mod) => ({ About: mod.About })), {
  loading: () => <div>Loading...</div>,
})

export default function Page() {
  return <About />
}
```

### Dynamic Import with Custom Loading Component

```typescript
'use client'

import dynamic from 'next/dynamic'
import { useState } from 'react'

function LoadingComponent() {
  return (
    <div className="flex items-center justify-center p-8">
      <div className="space-y-2">
        <div className="h-4 bg-gray-200 rounded animate-pulse"></div>
        <div className="h-4 bg-gray-200 rounded animate-pulse w-5/6"></div>
      </div>
    </div>
  )
}

const HeavyChart = dynamic(() => import('../components/Chart'), {
  loading: LoadingComponent,
})

export default function Dashboard() {
  const [showChart, setShowChart] = useState(false)

  return (
    <div>
      <button onClick={() => setShowChart(true)}>
        Load Chart
      </button>
      {showChart && <HeavyChart />}
    </div>
  )
}
```

## Route-Based Code Splitting

### App Router Code Splitting

```typescript
// app/dashboard/page.tsx
import { Suspense } from 'react'
import dynamic from 'next/dynamic'

const DashboardChart = dynamic(() => import('@/components/DashboardChart'), {
  loading: () => <ChartSkeleton />,
})

const DashboardTable = dynamic(() => import('@/components/DashboardTable'), {
  loading: () => <TableSkeleton />,
})

export default function DashboardPage() {
  return (
    <div className="space-y-6">
      <h1>Dashboard</h1>

      <Suspense fallback={<ChartSkeleton />}>
        <DashboardChart />
      </Suspense>

      <Suspense fallback={<TableSkeleton />}>
        <DashboardTable />
      </Suspense>
    </div>
  )
}
```

### Conditional Route Loading

```typescript
import dynamic from 'next/dynamic'
import { Suspense } from 'react'

const AdminPanel = dynamic(() => import('@/components/AdminPanel'), {
  loading: () => <AdminSkeleton />,
})

const UserDashboard = dynamic(
  () => import('@/components/UserDashboard'),
  {
    loading: () => <DashboardSkeleton />,
  }
)

type DashboardPageProps = {
  searchParams: { view?: 'admin' | 'user' }
};

export default function DashboardPage({
  searchParams,
}: DashboardPageProps) {
  const isAdmin = searchParams.view === 'admin'

  return (
    <Suspense fallback={<div>Loading...</div>}>
      {isAdmin ? <AdminPanel /> : <UserDashboard />}
    </Suspense>
  )
}
```

## Progressive Loading Patterns

### Incremental Content Loading

```typescript
'use client'

import dynamic from 'next/dynamic'
import { Suspense, useState } from 'react'

const Section1 = dynamic(() => import('./Section1'), {
  loading: () => <SectionSkeleton />,
})

const Section2 = dynamic(() => import('./Section2'), {
  loading: () => <SectionSkeleton />,
})

const Section3 = dynamic(() => import('./Section3'), {
  loading: () => <SectionSkeleton />,
})

export default function Page() {
  const [showMore, setShowMore] = useState(false)

  return (
    <div className="space-y-8">
      <Suspense fallback={<SectionSkeleton />}>
        <Section1 />
      </Suspense>

      <Suspense fallback={<SectionSkeleton />}>
        <Section2 />
      </Suspense>

      {showMore && (
        <Suspense fallback={<SectionSkeleton />}>
          <Section3 />
        </Suspense>
      )}

      {!showMore && (
        <button
          onClick={() => setShowMore(true)}
          className="px-4 py-2 bg-blue-500 text-white rounded"
        >
          Load More
        </button>
      )}
    </div>
  )
}
```

### Viewport-Based Lazy Loading

```typescript
'use client'

import dynamic from 'next/dynamic'
import { Suspense, useEffect, useRef, useState } from 'react'

const LazySection = dynamic(() => import('./LazySection'), {
  loading: () => <SectionSkeleton />,
})

export default function Page() {
  const sectionRef = useRef<HTMLDivElement>(null)
  const [isVisible, setIsVisible] = useState(false)

  useEffect(() => {
    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          setIsVisible(true)
          observer.disconnect()
        }
      },
      { threshold: 0.1 }
    )

    if (sectionRef.current) {
      observer.observe(sectionRef.current)
    }

    return () => observer.disconnect()
  }, [])

  return (
    <div>
      <div className="h-screen bg-blue-100">Visible content</div>

      <div ref={sectionRef}>
        {isVisible ? (
          <Suspense fallback={<SectionSkeleton />}>
            <LazySection />
          </Suspense>
        ) : (
          <SectionSkeleton />
        )}
      </div>
    </div>
  )
}
```

## Advanced Patterns

### Module-Based Dynamic Loading

```typescript
import dynamic from 'next/dynamic'

type ModuleConfig = {
  name: string
  component: () => Promise<{ default: React.ComponentType<any> }>
  skeleton: React.ComponentType
};

const modules: Record<string, ModuleConfig> = {
  chart: {
    name: 'Chart',
    component: () => import('./modules/Chart'),
    skeleton: () => <ChartSkeleton />,
  },
  table: {
    name: 'Table',
    component: () => import('./modules/Table'),
    skeleton: () => <TableSkeleton />,
  },
  form: {
    name: 'Form',
    component: () => import('./modules/Form'),
    skeleton: () => <FormSkeleton />,
  },
}

export function DynamicModule({ name }: { name: string }) {
  const module = modules[name]
  if (!module) return <div>Module not found</div>

  const Component = dynamic(
    () => module.component() as Promise<{ default: React.ComponentType<any> }>,
    {
      loading: module.skeleton,
    }
  )

  return <Component />
}
```

### Smart Prefetching

```typescript
'use client'

import { useRouter } from 'next/navigation'
import { useEffect } from 'react'

type PrefetchConfig = {
  href: string
  delay?: number
};

export function usePrefetch(configs: PrefetchConfig[]) {
  const router = useRouter()

  useEffect(() => {
    configs.forEach(({ href, delay = 0 }) => {
      setTimeout(() => {
        router.prefetch(href)
      }, delay)
    })
  }, [router, configs])
}

export default function Navigation() {
  usePrefetch([
    { href: '/dashboard', delay: 0 },
    { href: '/analytics', delay: 1000 },
    { href: '/settings', delay: 2000 },
  ])

  return (
    <nav>
      <a href="/dashboard">Dashboard</a>
      <a href="/analytics">Analytics</a>
      <a href="/settings">Settings</a>
    </nav>
  )
}
```

### Error Boundary with Lazy Loading

```typescript
'use client'

import dynamic from 'next/dynamic'
import { ReactNode, Suspense } from 'react'

type ErrorBoundaryProps = {
  children: ReactNode
  fallback?: ReactNode
};

class ErrorBoundary extends React.Component<
  ErrorBoundaryProps,
  { hasError: boolean }
> {
  constructor(props: ErrorBoundaryProps) {
    super(props)
    this.state = { hasError: false }
  }

  static getDerivedStateFromError(error: Error) {
    return { hasError: true }
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    console.error('Component error:', error, errorInfo)
  }

  render() {
    if (this.state.hasError) {
      return this.props.fallback || <div>Something went wrong</div>
    }

    return this.props.children
  }
}

const HeavyComponent = dynamic(
  () => import('./HeavyComponent'),
  {
    loading: () => <Skeleton />,
  }
)

export default function Page() {
  return (
    <ErrorBoundary fallback={<div>Failed to load component</div>}>
      <Suspense fallback={<Skeleton />}>
        <HeavyComponent />
      </Suspense>
    </ErrorBoundary>
  )
}
```

## Performance Optimization

### Bundle Analysis

```typescript
// next.config.js
const { BundleAnalyzerPlugin } = require('@next/bundle-analyzer')

const withBundleAnalyzer = require('@next/bundle-analyzer')({
  enabled: process.env.ANALYZE === 'true',
})

module.exports = withBundleAnalyzer({
  swcMinify: true,
})
```

```bash
ANALYZE=true npm run build
```

### Lazy Load Monitoring

```typescript
'use client'

import dynamic from 'next/dynamic'
import { useEffect, useRef } from 'react'

type LazyLoadMetrics = {
  componentName: string
  startTime: number
  endTime?: number
  loadTime?: number
};

const createLazyLoadMonitor = (componentName: string) => {
  const metrics: LazyLoadMetrics = {
    componentName,
    startTime: performance.now(),
  }

  return {
    onLoad: () => {
      metrics.endTime = performance.now()
      metrics.loadTime = metrics.endTime - metrics.startTime

      console.log(`${componentName} loaded in ${metrics.loadTime}ms`)

      // Send to analytics
      // track('component_lazy_loaded', metrics)
    },
  }
}

const Analytics = dynamic(
  () => import('./Analytics').then((mod) => {
    const monitor = createLazyLoadMonitor('Analytics')
    monitor.onLoad()
    return mod
  }),
  {
    loading: () => <div>Loading Analytics...</div>,
  }
)

export default function Dashboard() {
  return <Analytics />
}
```

## Type-Safe Dynamic Imports

```typescript
import dynamic from 'next/dynamic'

type ComponentType<T> = React.ComponentType<T>

type DynamicOptions<P> = {
  ssr?: boolean
  loading?: ComponentType<{}>
  errorComponent?: ComponentType<{ error: Error }>
};

function createDynamicComponent<P extends object>(
  importFn: () => Promise<{ default: ComponentType<P> }>,
  options?: DynamicOptions<P>
) {
  return dynamic(importFn as any, {
    ssr: options?.ssr ?? true,
    loading: options?.loading,
  }) as ComponentType<P>
}

type ChartProps = {
  data: number[]
  title: string
};

const LazyChart = createDynamicComponent<ChartProps>(
  () => import('./Chart'),
  {
    ssr: false,
    loading: () => <ChartSkeleton />,
  }
)

export default function Page() {
  return (
    <LazyChart
      data={[1, 2, 3, 4, 5]}
      title="Monthly Sales"
    />
  )
}
```

## Best Practices

### Loading States
- Provide skeleton screens matching component layout
- Show loading state immediately
- Avoid long loading delays
- Add loading animations
- Use realistic placeholders

### Code Splitting Strategy
- Split by route first
- Then split heavy components
- Consider code sharing patterns
- Monitor bundle size
- Prefetch anticipated routes

### Performance Tips
- Use dynamic imports for heavy libraries
- Lazy load below-the-fold content
- Prefetch likely next pages
- Monitor Core Web Vitals
- Test on slow networks

### User Experience
- Keep loading UI consistent
- Avoid sudden layout shifts
- Show progress indicators
- Handle errors gracefully
- Test loading performance

## Related Skills

- **Streaming** - Progressive rendering patterns
- **Image Optimization** - Deferred image loading
- **Font Optimization** - Optimized font delivery
