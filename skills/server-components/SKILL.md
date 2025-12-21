---
name: nextjs:server-components
description: Build with React Server Components (RSC) - async components, data fetching, and zero-JS patterns for optimal performance
---

# React Server Components (RSC) for Next.js

Master building server-side only components that render HTML on the server without sending JavaScript to the browser. Server Components are the default in Next.js and provide a powerful way to build fast, secure applications.

## Core Concepts

### What are Server Components?

Server Components execute exclusively on the server and send only rendered HTML to the browser. They have zero client-side JavaScript overhead and can safely access databases, APIs, and secrets directly.

```typescript
// app/posts/page.tsx - Server Component by default
import { db } from '@/lib/db'
import PostCard from '@/components/PostCard'

export default async function PostsPage() {
  // Direct database access - runs only on server
  const posts = await db.post.findMany({
    orderBy: { createdAt: 'desc' },
    include: { author: true, comments: true }
  })

  return (
    <div className="posts-grid">
      {posts.map(post => (
        <PostCard key={post.id} post={post} />
      ))}
    </div>
  )
}
```

### Key Advantages

- **Zero Client JavaScript**: No hydration overhead for static content
- **Direct Database Access**: Query databases safely without exposing credentials
- **Secret Protection**: API keys and environment variables stay on server
- **Reduced Bundle Size**: Massive libraries only execute on server
- **Security**: Sensitive logic never reaches the browser

## Async Components Pattern

Server Components are async by default, enabling natural data fetching patterns:

```typescript
// app/dashboard/page.tsx
import { Suspense } from 'react'
import { getUser, getUserPosts, getUserStats } from '@/lib/data'
import StatsCard from '@/components/StatsCard'
import PostsList from '@/components/PostsList'
import LoadingSpinner from '@/components/LoadingSpinner'

export const metadata = {
  title: 'Dashboard',
}

// Async server component
async function Dashboard() {
  // Fetch user data - this happens on server during render
  const user = await getUser()

  if (!user) {
    redirect('/login')
  }

  return (
    <div className="dashboard-container">
      <h1>Welcome back, {user.name}</h1>

      {/* Suspense boundaries for progressive loading */}
      <Suspense fallback={<LoadingSpinner />}>
        <UserStats userId={user.id} />
      </Suspense>

      <Suspense fallback={<div>Loading posts...</div>}>
        <UserPostsSection userId={user.id} />
      </Suspense>
    </div>
  )
}

export default Dashboard

// Async child components
async function UserStats({ userId }: { userId: string }) {
  const stats = await getUserStats(userId)

  return (
    <div className="stats-grid">
      <StatsCard title="Posts" value={stats.postCount} />
      <StatsCard title="Followers" value={stats.followerCount} />
      <StatsCard title="Views" value={stats.totalViews} />
    </div>
  )
}

async function UserPostsSection({ userId }: { userId: string }) {
  const posts = await getUserPosts(userId)

  return <PostsList posts={posts} />
}
```

## Data Fetching in Server Components

### Fetching with Next.js `fetch()`

Use the enhanced `fetch()` API for automatic caching and revalidation:

```typescript
// app/blog/[slug]/page.tsx
import Image from 'next/image'
import { notFound } from 'next/navigation'

type Post = {
  id: string
  title: string
  content: string
  image: string
  author: { name: string; avatar: string }
  publishedAt: string
};

export const revalidate = 3600 // ISR: revalidate every hour

export async function generateStaticParams() {
  // Pre-generate paths for popular posts
  const res = await fetch('https://api.example.com/posts?limit=50', {
    next: { revalidate: 86400 } // 1 day
  })
  const posts = await res.json()

  return posts.map(post => ({
    slug: post.slug
  }))
}

async function BlogPost({ params }: { params: { slug: string } }) {
  const res = await fetch(
    `https://api.example.com/posts/${params.slug}`,
    {
      next: {
        revalidate: 3600, // Cache for 1 hour
        tags: ['posts', `post-${params.slug}`]
      }
    }
  )

  if (!res.ok) {
    notFound()
  }

  const post: Post = await res.json()

  return (
    <article className="blog-post">
      <header>
        <h1>{post.title}</h1>
        <div className="meta">
          <Image
            src={post.author.avatar}
            alt={post.author.name}
            width={40}
            height={40}
            className="avatar"
          />
          <div>
            <p className="author">{post.author.name}</p>
            <time dateTime={post.publishedAt}>
              {new Date(post.publishedAt).toLocaleDateString()}
            </time>
          </div>
        </div>
      </header>

      <Image
        src={post.image}
        alt={post.title}
        width={1200}
        height={600}
        priority
        className="featured-image"
      />

      <div
        className="content"
        dangerouslySetInnerHTML={{ __html: post.content }}
      />
    </article>
  )
}

export default BlogPost
```

### Database Queries with Prisma

Direct database access is one of Server Components' superpowers:

```typescript
// app/products/page.tsx
import { prisma } from '@/lib/prisma'
import { ProductCard } from '@/components/ProductCard'

type SearchParams = {
  category?: string
  sort?: 'newest' | 'price-low' | 'price-high'
  page?: string
};

export const revalidate = 300 // 5 minutes

export default async function ProductsPage({
  searchParams
}: {
  searchParams: SearchParams
}) {
  const category = searchParams.category || 'all'
  const sort = searchParams.sort || 'newest'
  const page = parseInt(searchParams.page || '1')
  const pageSize = 12

  // Build dynamic query
  const where =
    category !== 'all'
      ? { category: { slug: category } }
      : {}

  // Get total count for pagination
  const total = await prisma.product.count({ where })

  // Fetch products with relations
  const products = await prisma.product.findMany({
    where,
    include: {
      category: true,
      reviews: {
        take: 5,
        orderBy: { createdAt: 'desc' }
      }
    },
    orderBy:
      sort === 'price-low'
        ? { price: 'asc' }
        : sort === 'price-high'
          ? { price: 'desc' }
          : { createdAt: 'desc' },
    skip: (page - 1) * pageSize,
    take: pageSize
  })

  const totalPages = Math.ceil(total / pageSize)

  return (
    <div className="products-page">
      <h1>Products</h1>

      <div className="filters">
        {/* Filters here */}
      </div>

      <div className="products-grid">
        {products.map(product => (
          <ProductCard key={product.id} product={product} />
        ))}
      </div>

      {totalPages > 1 && (
        <div className="pagination">
          {Array.from({ length: totalPages }, (_, i) => i + 1).map(p => (
            <a
              key={p}
              href={`?page=${p}`}
              className={p === page ? 'active' : ''}
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

## Streaming with Server Components

### Progressive Rendering with Suspense

Implement streaming to show content as it becomes available:

```typescript
// app/search/page.tsx
import { Suspense } from 'react'
import SearchResults from '@/components/SearchResults'
import RelatedProducts from '@/components/RelatedProducts'
import SearchLoader from '@/components/SearchLoader'

type SearchParams = {
  q: string
};

export default function SearchPage({
  searchParams
}: {
  searchParams: SearchParams
}) {
  const query = searchParams.q

  return (
    <div className="search-results">
      <h1>Search: {query}</h1>

      {/* Show results as soon as they're ready */}
      <Suspense fallback={<SearchLoader />}>
        <SearchResults query={query} />
      </Suspense>

      {/* Show recommendations while still searching */}
      <aside>
        <h2>You might also like</h2>
        <Suspense fallback={<div>Loading recommendations...</div>}>
          <RelatedProducts query={query} />
        </Suspense>
      </aside>
    </div>
  )
}

// Can be slow without blocking the UI
async function SearchResults({ query }: { query: string }) {
  const results = await fetch(
    `https://api.example.com/search?q=${encodeURIComponent(query)}`,
    { next: { revalidate: 60 } }
  ).then(r => r.json())

  return (
    <div className="results">
      {results.length === 0 ? (
        <p>No results found</p>
      ) : (
        results.map(result => (
          <a key={result.id} href={result.url}>
            <h3>{result.title}</h3>
            <p>{result.description}</p>
          </a>
        ))
      )}
    </div>
  )
}
```

## Server Component Limitations

Understanding what you cannot do in Server Components:

```typescript
// WRONG - Cannot use browser APIs or hooks
'use client' // This makes it a Client Component
import { useState } from 'react'

async function BadExample() {
  const [count, setCount] = useState(0) // Error: can't use hooks

  const handleClick = () => {
    // Error: can't use event handlers
    setCount(count + 1)
  }

  return <button onClick={handleClick}>{count}</button>
}

// CORRECT - Use client component for interactivity
import ClientCounter from '@/components/ClientCounter'

export default async function GoodExample() {
  const user = await getUser() // Direct database access OK

  return (
    <div>
      <h1>Hello {user.name}</h1>
      <ClientCounter initialValue={0} /> {/* Client component for interactivity */}
    </div>
  )
}
```

## Best Practices

### 1. Minimize Client Component Boundaries

Move `'use client'` as deep as possible to keep most components as Server Components:

```typescript
// app/dashboard/page.tsx - Server Component
import UserProfile from '@/components/UserProfile'
import InteractiveChart from '@/components/InteractiveChart'

export default async function Dashboard() {
  const userData = await fetchUserData()

  return (
    <div>
      {/* Server-rendered user profile */}
      <UserProfile user={userData} />

      {/* Only the chart needs client */}
      <InteractiveChart data={userData.metrics} />
    </div>
  )
}
```

### 2. Use Proper Error Boundaries

Handle errors gracefully in async components:

```typescript
// app/user/[id]/page.tsx
import { notFound } from 'next/navigation'
import { ErrorBoundary } from '@/components/ErrorBoundary'

export default async function UserPage({ params }: { params: { id: string } }) {
  try {
    const user = await getUser(params.id)

    if (!user) {
      notFound()
    }

    return (
      <div>
        <h1>{user.name}</h1>
        <ErrorBoundary>
          <UserPosts userId={user.id} />
        </ErrorBoundary>
      </div>
    )
  } catch (error) {
    throw new Error('Failed to load user')
  }
}
```

### 3. Leverage Metadata

Server Components can set metadata directly:

```typescript
// app/products/[id]/page.tsx
import { Metadata } from 'next'

type Product = {
  id: string
  title: string
  description: string
  image: string
  price: number
};

export async function generateMetadata({
  params
}: {
  params: { id: string }
}): Promise<Metadata> {
  const product = await fetch(
    `https://api.example.com/products/${params.id}`
  ).then(r => r.json() as Promise<Product>)

  return {
    title: product.title,
    description: product.description,
    openGraph: {
      images: [product.image],
      title: product.title,
      description: product.description,
      type: 'website'
    }
  }
}

export default async function ProductPage({
  params
}: {
  params: { id: string }
}) {
  const product: Product = await fetch(
    `https://api.example.com/products/${params.id}`
  ).then(r => r.json())

  return (
    <article>
      <h1>{product.title}</h1>
      <img src={product.image} alt={product.title} />
      <p>{product.description}</p>
      <p className="price">${product.price.toFixed(2)}</p>
    </article>
  )
}
```

## Real-World Examples

### E-Commerce Product Listing with Filters

```typescript
// app/shop/page.tsx
import { Suspense } from 'react'
import { prisma } from '@/lib/prisma'
import ProductCard from '@/components/ProductCard'
import FilterSidebar from '@/components/FilterSidebar'

type Filters = {
  category?: string
  priceMin?: number
  priceMax?: number
  sort?: string
};

export const revalidate = 300

export default async function ShopPage({
  searchParams
}: {
  searchParams: Record<string, string | string[] | undefined>
}) {
  const filters: Filters = {
    category: searchParams.category as string,
    priceMin: searchParams.priceMin ? parseFloat(searchParams.priceMin as string) : undefined,
    priceMax: searchParams.priceMax ? parseFloat(searchParams.priceMax as string) : undefined,
    sort: (searchParams.sort as string) || 'newest'
  }

  const where: any = {}
  if (filters.category) {
    where.category = { slug: filters.category }
  }
  if (filters.priceMin || filters.priceMax) {
    where.price = {}
    if (filters.priceMin) where.price.gte = filters.priceMin
    if (filters.priceMax) where.price.lte = filters.priceMax
  }

  const products = await prisma.product.findMany({
    where,
    include: { category: true, images: true },
    orderBy:
      filters.sort === 'price-low'
        ? { price: 'asc' }
        : filters.sort === 'price-high'
          ? { price: 'desc' }
          : { createdAt: 'desc' }
  })

  return (
    <div className="shop-layout">
      <FilterSidebar />
      <main>
        <div className="products-grid">
          {products.map(product => (
            <ProductCard key={product.id} product={product} />
          ))}
        </div>
      </main>
    </div>
  )
}
```

Server Components are the foundation of modern Next.js applications, providing unmatched performance and security.
