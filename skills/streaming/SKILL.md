---
name: nextjs:streaming
description: Use streaming SSR with loading.tsx, Suspense, and progressive rendering patterns
---

# Streaming and Progressive Rendering with Next.js

Streaming enables faster Time to First Byte (TTFB) by rendering HTML progressively to the browser instead of waiting for all data to be ready.

## Core Concepts

### Streaming Benefits
- **Faster TTFB**: Send initial HTML immediately
- **Progressive Enhancement**: Show content as it becomes ready
- **Better UX**: Users see content sooner
- **Reduced Blocking**: Don't wait for slow queries
- **SEO Friendly**: HTML sent progressively to crawlers

### How Streaming Works
1. Server renders static content immediately
2. Browser receives and displays HTML
3. Suspense boundaries load asynchronously
4. Dynamic content streams as ready
5. Client hydrates as JavaScript loads

## Suspense with Streaming

### Basic Suspense Boundary

```typescript
// app/page.tsx
import { Suspense } from 'react'

async function SlowData() {
  // Simulate slow data fetch
  await new Promise(resolve => setTimeout(resolve, 2000))
  return <div>Slow data loaded</div>
}

function LoadingFallback() {
  return <div className="animate-pulse">Loading...</div>
}

export default function Page() {
  return (
    <div className="space-y-4">
      <h1>Fast Content</h1>
      <p>This loads immediately</p>

      <Suspense fallback={<LoadingFallback />}>
        <SlowData />
      </Suspense>
    </div>
  )
}
```

### Multiple Suspense Boundaries

```typescript
// app/dashboard/page.tsx
import { Suspense } from 'react'

async function UserProfile() {
  await fetchUser()
  return <Profile />
}

async function RecentActivity() {
  await fetchActivity()
  return <Activity />
}

async function Analytics() {
  await fetchAnalytics()
  return <Chart />
}

export default function Dashboard() {
  return (
    <div className="grid gap-6">
      <Suspense fallback={<ProfileSkeleton />}>
        <UserProfile />
      </Suspense>

      <Suspense fallback={<ActivitySkeleton />}>
        <RecentActivity />
      </Suspense>

      <Suspense fallback={<ChartSkeleton />}>
        <Analytics />
      </Suspense>
    </div>
  )
}
```

### Nested Suspense Boundaries

```typescript
// app/products/page.tsx
import { Suspense } from 'react'

async function ProductList() {
  const products = await fetchProducts()

  return (
    <div className="grid gap-4">
      {products.map((product) => (
        <Suspense key={product.id} fallback={<ProductCardSkeleton />}>
          <ProductCard productId={product.id} />
        </Suspense>
      ))}
    </div>
  )
}

async function ProductCard({ productId }: { productId: string }) {
  const details = await fetchProductDetails(productId)
  return <div>{details.name}</div>
}

export default function Page() {
  return (
    <div>
      <h1>Products</h1>
      <Suspense fallback={<ProductListSkeleton />}>
        <ProductList />
      </Suspense>
    </div>
  )
}
```

## Loading UI Patterns

### Loading File Pattern

```typescript
// app/dashboard/loading.tsx
export default function Loading() {
  return (
    <div className="space-y-4">
      <div className="h-8 bg-gray-200 rounded animate-pulse"></div>
      <div className="grid gap-4 grid-cols-3">
        <div className="h-24 bg-gray-200 rounded animate-pulse"></div>
        <div className="h-24 bg-gray-200 rounded animate-pulse"></div>
        <div className="h-24 bg-gray-200 rounded animate-pulse"></div>
      </div>
      <div className="h-64 bg-gray-200 rounded animate-pulse"></div>
    </div>
  )
}
```

### Layout with Loading Skeleton

```typescript
// app/dashboard/layout.tsx
import { ReactNode } from 'react'

export default function DashboardLayout({
  children,
  sidebar,
}: {
  children: ReactNode
  sidebar: ReactNode
}) {
  return (
    <div className="flex">
      <aside className="w-64 bg-gray-100">
        {sidebar}
      </aside>
      <main className="flex-1">
        {children}
      </main>
    </div>
  )
}
```

```typescript
// app/dashboard/@sidebar/loading.tsx
export default function SidebarLoading() {
  return (
    <div className="space-y-4 p-4">
      {[...Array(5)].map((_, i) => (
        <div key={i} className="h-10 bg-gray-300 rounded animate-pulse" />
      ))}
    </div>
  )
}
```

### Incremental Static Regeneration with Streaming

```typescript
// app/blog/[slug]/page.tsx
import { notFound } from 'next/navigation'
import { Suspense } from 'react'

async function BlogPost({ slug }: { slug: string }) {
  const post = await fetch(
    `https://api.example.com/posts/${slug}`,
    {
      next: { revalidate: 60 }, // ISR: revalidate every 60s
    }
  ).then(res => res.json())

  if (!post) notFound()

  return <article>{post.content}</article>
}

async function Comments({ slug }: { slug: string }) {
  const comments = await fetch(
    `https://api.example.com/posts/${slug}/comments`,
    {
      next: { revalidate: 10 }, // Revalidate comments more frequently
    }
  ).then(res => res.json())

  return <div>{comments}</div>
}

export default function Page({ params }: { params: { slug: string } }) {
  return (
    <div className="max-w-2xl mx-auto">
      <Suspense fallback={<ArticleSkeleton />}>
        <BlogPost slug={params.slug} />
      </Suspense>

      <section className="mt-8">
        <h2>Comments</h2>
        <Suspense fallback={<CommentsSkeleton />}>
          <Comments slug={params.slug} />
        </Suspense>
      </section>
    </div>
  )
}
```

## Server Components with Streaming

### Async Server Component

```typescript
// app/posts/page.tsx
import { Suspense } from 'react'

async function PostsList() {
  const posts = await fetch('https://api.example.com/posts', {
    next: { revalidate: 60 },
  }).then(res => res.json())

  return (
    <ul className="space-y-4">
      {posts.map((post) => (
        <li key={post.id} className="p-4 border rounded">
          <h3>{post.title}</h3>
          <p>{post.excerpt}</p>
        </li>
      ))}
    </ul>
  )
}

function PostsListSkeleton() {
  return (
    <ul className="space-y-4">
      {[...Array(3)].map((_, i) => (
        <li key={i} className="p-4 border rounded animate-pulse">
          <div className="h-4 bg-gray-200 rounded w-3/4"></div>
          <div className="h-4 bg-gray-200 rounded w-full mt-2"></div>
        </li>
      ))}
    </ul>
  )
}

export default function Page() {
  return (
    <div>
      <h1>Posts</h1>
      <Suspense fallback={<PostsListSkeleton />}>
        <PostsList />
      </Suspense>
    </div>
  )
}
```

### Mixed Server and Client Components

```typescript
// app/dashboard/page.tsx
'use client'

import { Suspense, useState } from 'react'
import { fetchUserStats } from '@/lib/api'

async function UserStats() {
  const stats = await fetchUserStats()
  return (
    <div className="grid grid-cols-3 gap-4">
      {/* Stats cards */}
    </div>
  )
}

function StatsLoading() {
  return (
    <div className="grid grid-cols-3 gap-4">
      {[...Array(3)].map((_, i) => (
        <div key={i} className="h-24 bg-gray-200 rounded animate-pulse" />
      ))}
    </div>
  )
}

export default function Dashboard() {
  const [filter, setFilter] = useState('week')

  return (
    <div>
      <div className="flex gap-2 mb-6">
        {['day', 'week', 'month'].map((period) => (
          <button
            key={period}
            onClick={() => setFilter(period)}
            className={`px-4 py-2 rounded ${
              filter === period ? 'bg-blue-500 text-white' : 'bg-gray-200'
            }`}
          >
            {period}
          </button>
        ))}
      </div>

      <Suspense fallback={<StatsLoading />}>
        <UserStats />
      </Suspense>
    </div>
  )
}
```

## Advanced Streaming Patterns

### Streaming Search Results

```typescript
// app/search/page.tsx
import { Suspense } from 'react'

async function SearchResults({ query }: { query: string }) {
  const results = await fetch(
    `https://api.example.com/search?q=${query}`,
    { next: { revalidate: 0 } }
  ).then(res => res.json())

  if (results.length === 0) {
    return <p>No results found for "{query}"</p>
  }

  return (
    <ul className="space-y-4">
      {results.map((result) => (
        <li key={result.id} className="p-4 border rounded">
          <h3>{result.title}</h3>
          <p>{result.description}</p>
        </li>
      ))}
    </ul>
  )
}

type SearchPageProps = {
  searchParams: { q?: string };
};

export default function SearchPage({ searchParams }: SearchPageProps) {
  const query = searchParams.q || ''

  if (!query) {
    return <p>Enter a search term</p>
  }

  return (
    <div>
      <h1>Search results for: {query}</h1>
      <Suspense fallback={<SearchSkeleton />}>
        <SearchResults query={query} />
      </Suspense>
    </div>
  )
}
```

### Parallel Streaming

```typescript
// app/checkout/page.tsx
import { Suspense } from 'react'

async function OrderSummary() {
  const order = await fetchOrder()
  return <div>{/* Order details */}</div>
}

async function ShippingInfo() {
  const shipping = await fetchShipping()
  return <div>{/* Shipping info */}</div>
}

async function PaymentOptions() {
  const options = await fetchPaymentOptions()
  return <div>{/* Payment options */}</div>
}

export default function CheckoutPage() {
  return (
    <div className="grid grid-cols-2 gap-6">
      <div>
        <Suspense fallback={<OrderSkeleton />}>
          <OrderSummary />
        </Suspense>
      </div>

      <div className="space-y-6">
        <Suspense fallback={<ShippingSkeleton />}>
          <ShippingInfo />
        </Suspense>

        <Suspense fallback={<PaymentSkeleton />}>
          <PaymentOptions />
        </Suspense>
      </div>
    </div>
  )
}
```

### Segment Loading State

```typescript
// app/dashboard/(overview)/loading.tsx
export default function DashboardLoading() {
  return (
    <div className="space-y-6">
      {/* Header skeleton */}
      <div className="h-10 bg-gray-200 rounded animate-pulse"></div>

      {/* Content skeleton */}
      <div className="grid grid-cols-3 gap-4">
        {[...Array(3)].map((_, i) => (
          <div
            key={i}
            className="h-32 bg-gray-200 rounded animate-pulse"
          ></div>
        ))}
      </div>
    </div>
  )
}
```

## Performance Optimization

### Suspense with useTransition

```typescript
'use client'

import { useTransition } from 'react'
import { useRouter } from 'next/navigation'
import { Suspense } from 'react'

export default function Navigation() {
  const router = useRouter()
  const [isPending, startTransition] = useTransition()

  const handleNavigate = (href: string) => {
    startTransition(() => {
      router.push(href)
    })
  }

  return (
    <nav className="space-y-2">
      <button
        onClick={() => handleNavigate('/dashboard')}
        disabled={isPending}
        className="block px-4 py-2 rounded hover:bg-gray-100 disabled:opacity-50"
      >
        Dashboard
        {isPending && <span> (loading...)</span>}
      </button>
      <button
        onClick={() => handleNavigate('/settings')}
        disabled={isPending}
        className="block px-4 py-2 rounded hover:bg-gray-100 disabled:opacity-50"
      >
        Settings
        {isPending && <span> (loading...)</span>}
      </button>
    </nav>
  )
}
```

### Smart Prefetching with Suspense

```typescript
// app/layout.tsx
import { Suspense } from 'react'

async function Navigation() {
  // Prefetch critical data
  const navItems = await fetch('https://api.example.com/nav', {
    next: { revalidate: 3600 }, // Cache for 1 hour
  }).then(res => res.json())

  return (
    <nav>
      {navItems.map((item) => (
        <a key={item.id} href={item.href}>
          {item.label}
        </a>
      ))}
    </nav>
  )
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html>
      <body>
        <Suspense fallback={<NavSkeleton />}>
          <Navigation />
        </Suspense>
        {children}
      </body>
    </html>
  )
}
```

## Skeleton Screens

### Reusable Skeleton Components

```typescript
// components/Skeletons.tsx
export function CardSkeleton() {
  return (
    <div className="p-4 border rounded space-y-4">
      <div className="h-4 bg-gray-200 rounded w-3/4"></div>
      <div className="h-4 bg-gray-200 rounded"></div>
      <div className="h-4 bg-gray-200 rounded w-5/6"></div>
    </div>
  )
}

export function TableSkeleton() {
  return (
    <div className="space-y-4">
      {[...Array(5)].map((_, i) => (
        <div key={i} className="flex gap-4">
          <div className="h-4 bg-gray-200 rounded flex-1"></div>
          <div className="h-4 bg-gray-200 rounded flex-1"></div>
          <div className="h-4 bg-gray-200 rounded flex-1"></div>
        </div>
      ))}
    </div>
  )
}

export function ChartSkeleton() {
  return (
    <div className="h-64 bg-gray-200 rounded animate-pulse"></div>
  )
}

export function ProfileSkeleton() {
  return (
    <div className="space-y-4">
      <div className="w-16 h-16 bg-gray-200 rounded-full animate-pulse"></div>
      <div className="h-4 bg-gray-200 rounded w-3/4"></div>
      <div className="h-4 bg-gray-200 rounded w-1/2"></div>
    </div>
  )
}
```

### Context-Aware Skeleton

```typescript
'use client'

type SkeletonProps = {
  type: 'card' | 'table' | 'list' | 'chart';
  count?: number;
};

export function DynamicSkeleton({ type, count = 1 }: SkeletonProps) {
  const skeletonMap: Record<string, React.ReactNode> = {
    card: <CardSkeleton />,
    table: <TableSkeleton />,
    list: <ListSkeleton />,
    chart: <ChartSkeleton />,
  }

  return (
    <>
      {[...Array(count)].map((_, i) => (
        <div key={i}>{skeletonMap[type]}</div>
      ))}
    </>
  )
}
```

## Error Handling with Streaming

### Error Boundary with Fallback

```typescript
'use client'

import { ReactNode } from 'react'

type ErrorBoundaryProps = {
  children: ReactNode
  fallback?: ReactNode
};

type ErrorBoundaryState = {
  hasError: boolean
  error?: Error
};

export class StreamingErrorBoundary extends React.Component<
  ErrorBoundaryProps,
  ErrorBoundaryState
> {
  constructor(props: ErrorBoundaryProps) {
    super(props)
    this.state = { hasError: false }
  }

  static getDerivedStateFromError(error: Error): ErrorBoundaryState {
    return { hasError: true, error }
  }

  componentDidCatch(error: Error) {
    console.error('Streaming error:', error)
  }

  render() {
    if (this.state.hasError) {
      return (
        this.props.fallback || (
          <div className="p-4 bg-red-100 border border-red-400 rounded">
            <h3 className="font-bold">Error loading content</h3>
            <p>{this.state.error?.message}</p>
          </div>
        )
      )
    }

    return this.props.children
  }
}
```

### Suspense with Error Handling

```typescript
// app/posts/[id]/page.tsx
import { Suspense } from 'react'
import { StreamingErrorBoundary } from '@/components/StreamingErrorBoundary'

async function PostContent({ id }: { id: string }) {
  const post = await fetch(`https://api.example.com/posts/${id}`, {
    next: { revalidate: 60 },
  }).then(res => res.json())

  if (!post) throw new Error('Post not found')

  return <article>{post.content}</article>
}

export default function PostPage({ params }: { params: { id: string } }) {
  return (
    <div>
      <StreamingErrorBoundary fallback={<div>Failed to load post</div>}>
        <Suspense fallback={<PostSkeleton />}>
          <PostContent id={params.id} />
        </Suspense>
      </StreamingErrorBoundary>
    </div>
  )
}
```

## Monitoring Streaming Performance

```typescript
'use client'

import { useEffect } from 'react'

export function StreamingMetrics() {
  useEffect(() => {
    // Monitor streaming performance
    if ('PerformanceObserver' in window) {
      const observer = new PerformanceObserver((list) => {
        for (const entry of list.getEntries()) {
          if (entry.name.includes('streaming')) {
            console.log('Streaming metric:', entry)
            // Send to analytics
            // track('streaming_metric', entry)
          }
        }
      })

      observer.observe({ entryTypes: ['measure'] })

      return () => observer.disconnect()
    }
  }, [])

  return null
}
```

## Best Practices

### Streaming Strategy
- Use Suspense for independent data loads
- Nest boundaries by component dependency
- Provide meaningful loading states
- Balance between speed and completeness
- Test with slow networks

### Skeleton Design
- Match component layout exactly
- Use realistic dimensions
- Add subtle animations
- Keep file sizes small
- Test accessibility

### Error Handling
- Catch streaming errors gracefully
- Provide meaningful error messages
- Allow retry mechanisms
- Log errors for debugging
- Monitor error rates

### Performance
- Measure TTFB improvements
- Monitor Core Web Vitals
- Profile with actual network conditions
- Test on real devices
- Optimize slow queries first

## Related Skills

- **Lazy Loading** - Dynamic imports and code splitting
- **Image Optimization** - Progressive image loading
- **Font Optimization** - Non-blocking font delivery
