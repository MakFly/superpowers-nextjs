# Reference

# Data Fetching Patterns in Next.js

Master efficient and secure data fetching patterns using Next.js built-in capabilities. Learn to leverage automatic caching, request deduplication, and proper error handling for optimal performance.

## Core Concepts

### Automatic Request Deduplication

Next.js automatically deduplicates identical `fetch()` calls within the same render pass:

```typescript
// app/dashboard/page.tsx
import { getUserData } from '@/lib/api'

async function DashboardPage() {
  // These three calls are deduped - only one request is made
  const user1 = await fetch('https://api.example.com/user')
  const user2 = await fetch('https://api.example.com/user')
  const user3 = await fetch('https://api.example.com/user')

  // user1, user2, and user3 contain the same data
  // Perfect for building components independently without worrying about duplication

  return (
    <div>
      <UserCard user={user1} />
      <UserStats user={user2} />
      <UserActivity user={user3} />
    </div>
  )
}
```

### The Enhanced fetch() API

Next.js extends the standard `fetch()` API with caching and revalidation options:

```typescript
// Basic fetch with caching options
const data = await fetch(url, {
  next: {
    revalidate: 3600, // Cache for 1 hour in seconds
    tags: ['products'] // Add tags for on-demand revalidation
  }
})

// No cache
const liveData = await fetch(url, {
  cache: 'no-store'
})

// Revalidate on every request (ISR)
const freshData = await fetch(url, {
  next: { revalidate: 0 }
})
```

## Common Fetching Patterns

### Simple Data Fetching in Server Components

```typescript
// app/blog/page.tsx
import Link from 'next/link'
import { formatDate } from '@/lib/utils'

type Post = {
  id: string
  title: string
  slug: string
  excerpt: string
  publishedAt: string
  author: {
    name: string
    image: string
  }
};

export const revalidate = 3600 // Revalidate every hour

export default async function BlogPage() {
  const response = await fetch('https://api.example.com/posts', {
    next: {
      revalidate: 3600,
      tags: ['posts']
    }
  })

  if (!response.ok) {
    throw new Error('Failed to fetch posts')
  }

  const posts: Post[] = await response.json()

  return (
    <div className="blog-grid">
      <h1>Latest Articles</h1>
      <div className="posts">
        {posts.map(post => (
          <article key={post.id} className="post-card">
            <Link href={`/blog/${post.slug}`}>
              <h2>{post.title}</h2>
            </Link>
            <p className="excerpt">{post.excerpt}</p>
            <footer>
              <span className="author">{post.author.name}</span>
              <time dateTime={post.publishedAt}>
                {formatDate(post.publishedAt)}
              </time>
            </footer>
          </article>
        ))}
      </div>
    </div>
  )
}
```

### Fetching with Parameters and Search

```typescript
// app/search/page.tsx
import { Suspense } from 'react'
import SearchResults from '@/components/SearchResults'
import SearchSuggestions from '@/components/SearchSuggestions'

type SearchParams = {
  q?: string
  page?: string
  category?: string
};

export async function generateMetadata({
  searchParams
}: {
  searchParams: SearchParams
}) {
  const query = searchParams.q || ''
  return {
    title: query ? `Search results for "${query}"` : 'Search'
  }
}

export default async function SearchPage({
  searchParams
}: {
  searchParams: SearchParams
}) {
  const query = searchParams.q || ''
  const page = searchParams.page || '1'
  const category = searchParams.category

  // Build query string
  const params = new URLSearchParams()
  if (query) params.append('q', query)
  if (category) params.append('category', category)
  params.append('page', page)

  return (
    <div className="search-page">
      <h1>Search Results</h1>
      {query ? (
        <>
          <p>Results for: <strong>{query}</strong></p>
          <Suspense fallback={<div>Loading results...</div>}>
            <SearchResults searchParams={searchParams} />
          </Suspense>
        </>
      ) : (
        <>
          <p>Enter a search term to begin</p>
          <Suspense fallback={<div>Loading suggestions...</div>}>
            <SearchSuggestions />
          </Suspense>
        </>
      )}
    </div>
  )
}

// Child component with actual fetching
async function SearchResults({
  searchParams
}: {
  searchParams: SearchParams
}) {
  const params = new URLSearchParams()
  if (searchParams.q) params.append('q', searchParams.q)
  if (searchParams.category) params.append('category', searchParams.category)
  params.append('page', searchParams.page || '1')

  const response = await fetch(
    `https://api.example.com/search?${params.toString()}`,
    {
      next: { revalidate: 60 }
    }
  )

  const { results, totalPages } = await response.json()

  return (
    <div>
      <div className="results-list">
        {results.length === 0 ? (
          <p>No results found</p>
        ) : (
          results.map((result: any) => (
            <a key={result.id} href={result.url} className="result-item">
              <h3>{result.title}</h3>
              <p>{result.description}</p>
            </a>
          ))
        )}
      </div>
      {totalPages > 1 && (
        <div className="pagination">
          {Array.from({ length: totalPages }, (_, i) => i + 1).map(p => (
            <a
              key={p}
              href={`?q=${searchParams.q}&page=${p}`}
              className={p === parseInt(searchParams.page || '1') ? 'active' : ''}
            >
              {p}
            </a>
          ))}
        </div>
      )}
    </div>
  )
}
```

## Parallel Data Fetching

### Fetching Multiple Resources

```typescript
// app/dashboard/page.tsx
import { Suspense } from 'react'
import {
  getUser,
  getUserStats,
  getUserRecentActivity,
  getUserNotifications
} from '@/lib/api'

export default async function Dashboard() {
  // Parallel fetching - all requests start at the same time
  const [user, stats, activity, notifications] = await Promise.all([
    getUser(),
    getUserStats(),
    getUserRecentActivity(),
    getUserNotifications()
  ])

  return (
    <div className="dashboard">
      <header>
        <h1>Welcome, {user.name}</h1>
        <div className="user-avatar">{user.initials}</div>
      </header>

      <div className="dashboard-grid">
        <aside>
          <Suspense fallback={<div>Loading stats...</div>}>
            <Stats stats={stats} />
          </Suspense>
        </aside>

        <main>
          <Suspense fallback={<div>Loading activity...</div>}>
            <RecentActivity activity={activity} />
          </Suspense>
        </main>

        <div className="notifications">
          <Suspense fallback={<div>Loading notifications...</div>}>
            <NotificationsList notifications={notifications} />
          </Suspense>
        </div>
      </div>
    </div>
  )
}
```

### Conditional Fetching

```typescript
// app/user/[id]/page.tsx
import { notFound } from 'next/navigation'

type Params = {
  id: string
};

type SearchParams = {
  tab?: 'posts' | 'followers' | 'likes'
};

async function fetchUserData(userId: string) {
  const response = await fetch(
    `https://api.example.com/users/${userId}`,
    {
      next: { revalidate: 300, tags: [`user-${userId}`] }
    }
  )
  if (!response.ok) return null
  return response.json()
}

async function fetchUserPosts(userId: string) {
  const response = await fetch(
    `https://api.example.com/users/${userId}/posts`,
    {
      next: { revalidate: 60, tags: [`user-posts-${userId}`] }
    }
  )
  return response.json()
}

async function fetchUserFollowers(userId: string) {
  const response = await fetch(
    `https://api.example.com/users/${userId}/followers`,
    {
      next: { revalidate: 300, tags: [`user-followers-${userId}`] }
    }
  )
  return response.json()
}

export async function generateMetadata({
  params
}: {
  params: Params
}) {
  const user = await fetchUserData(params.id)
  if (!user) return { title: 'User not found' }

  return {
    title: user.name,
    description: user.bio
  }
}

export default async function UserPage({
  params,
  searchParams
}: {
  params: Params
  searchParams: SearchParams
}) {
  const user = await fetchUserData(params.id)
  if (!user) {
    notFound()
  }

  const tab = searchParams.tab || 'posts'

  // Conditionally fetch based on selected tab
  let tabContent

  if (tab === 'posts') {
    const posts = await fetchUserPosts(params.id)
    tabContent = <PostsList posts={posts} />
  } else if (tab === 'followers') {
    const followers = await fetchUserFollowers(params.id)
    tabContent = <FollowersList followers={followers} />
  }

  return (
    <div className="user-profile">
      <div className="profile-header">
        <img src={user.avatar} alt={user.name} />
        <h1>{user.name}</h1>
        <p>{user.bio}</p>
      </div>

      <div className="tabs">
        <a href={`?tab=posts`} className={tab === 'posts' ? 'active' : ''}>
          Posts
        </a>
        <a href={`?tab=followers`} className={tab === 'followers' ? 'active' : ''}>
          Followers
        </a>
      </div>

      <div className="tab-content">{tabContent}</div>
    </div>
  )
}
```

## Error Handling and Loading States

### Graceful Error Handling

```typescript
// app/products/page.tsx
import { ProductCard } from '@/components/ProductCard'
import { ErrorBoundary } from '@/components/ErrorBoundary'

export const revalidate = 300

export default async function ProductsPage() {
  try {
    const response = await fetch('https://api.example.com/products', {
      next: { revalidate: 300, tags: ['products'] }
    })

    if (!response.ok) {
      if (response.status === 404) {
        throw new Error('Products not found')
      }
      throw new Error(`API error: ${response.status}`)
    }

    const products = await response.json()

    return (
      <div className="products-page">
        <h1>Products</h1>
        <div className="products-grid">
          {products.map(product => (
            <ProductCard key={product.id} product={product} />
          ))}
        </div>
      </div>
    )
  } catch (error) {
    const message =
      error instanceof Error ? error.message : 'An error occurred'

    return (
      <div className="error-container">
        <h1>Failed to load products</h1>
        <p>{message}</p>
        <p>Please try again later.</p>
      </div>
    )
  }
}
```

### Timeout Handling

```typescript
// lib/api.ts
export async function fetchWithTimeout(
  url: string,
  timeoutMs = 5000,
  options = {}
) {
  const controller = new AbortController()
  const timeout = setTimeout(() => controller.abort(), timeoutMs)

  try {
    const response = await fetch(url, {
      ...options,
      signal: controller.signal
    })
    return response
  } finally {
    clearTimeout(timeout)
  }
}

// Usage in server component
async function DataComponent() {
  try {
    const response = await fetchWithTimeout(
      'https://api.example.com/data',
      3000
    )
    const data = await response.json()
    return <div>{/* render data */}</div>
  } catch (error) {
    if (error instanceof Error && error.name === 'AbortError') {
      return <div>Request timed out. Please try again.</div>
    }
    throw error
  }
}
```

## Incremental Static Regeneration (ISR)

### Background Revalidation

```typescript
// app/docs/[slug]/page.tsx
export const revalidate = 3600 // Revalidate every hour

export async function generateStaticParams() {
  // Pre-generate popular docs at build time
  const docs = await fetch('https://api.example.com/docs?featured=true', {
    next: { revalidate: 86400 } // Check once per day
  }).then(r => r.json())

  return docs.map(doc => ({
    slug: doc.slug
  }))
}

export async function generateMetadata({
  params
}: {
  params: { slug: string }
}) {
  const doc = await fetch(
    `https://api.example.com/docs/${params.slug}`,
    {
      next: { revalidate: 3600 }
    }
  ).then(r => r.json())

  return {
    title: doc.title,
    description: doc.description
  }
}

export default async function DocPage({
  params
}: {
  params: { slug: string }
}) {
  const doc = await fetch(
    `https://api.example.com/docs/${params.slug}`,
    {
      next: { revalidate: 3600, tags: ['docs', `doc-${params.slug}`] }
    }
  ).then(r => r.json())

  return (
    <article className="doc">
      <h1>{doc.title}</h1>
      <div
        className="content"
        dangerouslySetInnerHTML={{ __html: doc.html }}
      />
    </article>
  )
}
```

## Combining Server and Client Fetching

### Server-side Initial Load, Client-side Updates

```typescript
// app/notifications/page.tsx
import { NotificationsList } from '@/components/NotificationsList'

export default async function NotificationsPage() {
  // Initial data fetch on server
  const response = await fetch('https://api.example.com/notifications', {
    next: { revalidate: 0 } // Always fresh
  })
  const initialNotifications = await response.json()

  // Pass to client component which can refetch/update
  return (
    <div className="notifications">
      <h1>Notifications</h1>
      <NotificationsList initialNotifications={initialNotifications} />
    </div>
  )
}

// Client component with polling/updates
'use client'
import { useEffect, useState } from 'react'

type Notification = {
  id: string
  message: string
  read: boolean
  timestamp: string
};

export function NotificationsList({
  initialNotifications
}: {
  initialNotifications: Notification[]
}) {
  const [notifications, setNotifications] = useState(initialNotifications)
  const [isLoading, setIsLoading] = useState(false)

  // Poll for new notifications
  useEffect(() => {
    const interval = setInterval(async () => {
      setIsLoading(true)
      try {
        const response = await fetch('/api/notifications')
        const data = await response.json()
        setNotifications(data)
      } finally {
        setIsLoading(false)
      }
    }, 30000) // Poll every 30 seconds

    return () => clearInterval(interval)
  }, [])

  const markAsRead = async (id: string) => {
    await fetch(`/api/notifications/${id}/read`, { method: 'POST' })
    setNotifications(prev =>
      prev.map(n => (n.id === id ? { ...n, read: true } : n))
    )
  }

  return (
    <div className="notifications-list">
      {notifications.length === 0 ? (
        <p>No notifications</p>
      ) : (
        notifications.map(notif => (
          <div key={notif.id} className={`notification ${notif.read ? 'read' : 'unread'}`}>
            <p>{notif.message}</p>
            {!notif.read && (
              <button onClick={() => markAsRead(notif.id)}>
                Mark as read
              </button>
            )}
          </div>
        ))
      )}
    </div>
  )
}
```

## Caching Headers Best Practices

```typescript
// lib/api.ts
export const DEFAULT_CACHE_DURATION = 3600 // 1 hour
export const SHORT_CACHE_DURATION = 60 // 1 minute
export const LONG_CACHE_DURATION = 86400 * 7 // 1 week

export async function fetchWithCache(
  url: string,
  duration: number = DEFAULT_CACHE_DURATION
) {
  return fetch(url, {
    next: {
      revalidate: duration,
      tags: [url] // Tag for granular revalidation
    }
  })
}

// app/page.tsx
import { fetchWithCache, LONG_CACHE_DURATION } from '@/lib/api'

export default async function HomePage() {
  // Cache static content for a week
  const content = await fetchWithCache(
    'https://api.example.com/homepage',
    LONG_CACHE_DURATION
  ).then(r => r.json())

  return <div>{/* render content */}</div>
}
```

Master these patterns to build highly performant, reliable Next.js applications with optimal data fetching strategies.
