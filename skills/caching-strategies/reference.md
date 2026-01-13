# Reference

# Advanced Caching Strategies in Next.js

Master the sophisticated caching mechanisms in Next.js 16+ including Cache Components, the `use cache` directive, and intelligent revalidation strategies for maximum performance and freshness.

## Caching Layers in Next.js

### The Four Caching Layers

1. **Request Memoization**: Automatic deduplication of identical requests in the same render
2. **Data Cache**: Persistent cache across builds with revalidation
3. **Full Route Cache**: Static pre-rendering and caching
4. **Router Cache**: Client-side navigation cache

## Request Memoization (Automatic)

Request memoization happens automatically for identical `fetch()` calls:

```typescript
// app/dashboard/page.tsx
export default async function Dashboard() {
  // These three fetches are automatically memoized
  // Only one actual network request is made
  const user1 = await fetch('https://api.example.com/user')
  const user2 = await fetch('https://api.example.com/user')
  const user3 = await fetch('https://api.example.com/user')

  // All three variables contain the same data
  console.log(user1 === user2) // true (same object in memory)

  return (
    <div>
      <Profile data={user1} />
      <Stats data={user2} />
      <Activity data={user3} />
    </div>
  )
}
```

### Memoization Scope

Memoization is limited to a single render pass:

```typescript
// app/page.tsx
import { getUser } from '@/lib/api'

// Request memoization example
export default async function Page() {
  // Render Pass 1: Multiple children can fetch the same data
  const user = await getUser()

  return (
    <div>
      <ProfileHeader user={user} />
      <ProfileContent user={user} />
      <ProfileSidebar user={user} />
    </div>
  )
}

// But if you navigate to a different page and back,
// a new render pass occurs and the cache is cleared
```

## Data Cache with Revalidation

### Time-Based Revalidation (ISR)

```typescript
// app/blog/page.tsx
export const revalidate = 3600 // Revalidate every hour

export default async function BlogPage() {
  const posts = await fetch('https://api.example.com/posts', {
    next: {
      revalidate: 3600 // Cache for 1 hour in seconds
    }
  }).then(r => r.json())

  return (
    <div className="blog">
      <h1>Blog Posts</h1>
      <div className="posts">
        {posts.map(post => (
          <article key={post.id}>
            <h2>{post.title}</h2>
            <p>{post.excerpt}</p>
            <time>{post.publishedAt}</time>
          </article>
        ))}
      </div>
    </div>
  )
}
```

### Tag-Based Revalidation

Use tags for granular cache control and on-demand revalidation:

```typescript
// app/products/page.tsx
export const revalidate = 3600

export default async function ProductsPage() {
  const products = await fetch('https://api.example.com/products', {
    next: {
      revalidate: 3600,
      tags: ['products'] // Add revalidation tag
    }
  }).then(r => r.json())

  return (
    <div className="products">
      <h1>Products</h1>
      {products.map(product => (
        <div key={product.id} className="product-card">
          <h2>{product.name}</h2>
          <p>${product.price}</p>
        </div>
      ))}
    </div>
  )
}

// app/products/[id]/page.tsx
export async function generateMetadata({
  params
}: {
  params: { id: string }
}) {
  const product = await fetch(
    `https://api.example.com/products/${params.id}`,
    {
      next: {
        revalidate: 3600,
        tags: ['products', `product-${params.id}`]
      }
    }
  ).then(r => r.json())

  return {
    title: product.name,
    description: product.description
  }
}

export default async function ProductPage({
  params
}: {
  params: { id: string }
}) {
  const product = await fetch(
    `https://api.example.com/products/${params.id}`,
    {
      next: {
        revalidate: 3600,
        tags: ['products', `product-${params.id}`]
      }
    }
  ).then(r => r.json())

  return (
    <div className="product-detail">
      <h1>{product.name}</h1>
      <img src={product.image} alt={product.name} />
      <p className="price">${product.price}</p>
      <p className="description">{product.description}</p>
    </div>
  )
}
```

### On-Demand Revalidation with Server Actions

```typescript
// lib/actions.ts
'use server'

import { revalidateTag } from 'next/cache'

export async function updateProduct(id: string, data: any) {
  // Update in database
  const response = await fetch(
    `https://api.example.com/products/${id}`,
    {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    }
  )

  const updated = await response.json()

  // Revalidate all product-related caches
  revalidateTag('products')
  revalidateTag(`product-${id}`)

  return updated
}

export async function deleteProduct(id: string) {
  await fetch(`https://api.example.com/products/${id}`, {
    method: 'DELETE'
  })

  // Clear caches
  revalidateTag('products')
  revalidateTag(`product-${id}`)
}

// components/EditProductForm.tsx
'use client'

import { useState } from 'react'
import { updateProduct } from '@/lib/actions'

export function EditProductForm({
  product
}: {
  product: { id: string; name: string; price: number }
}) {
  const [isSubmitting, setIsSubmitting] = useState(false)

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    setIsSubmitting(true)

    const formData = new FormData(e.currentTarget)
    await updateProduct(product.id, {
      name: formData.get('name'),
      price: parseFloat(formData.get('price') as string)
    })

    setIsSubmitting(false)
  }

  return (
    <form onSubmit={handleSubmit}>
      <input
        type="text"
        name="name"
        defaultValue={product.name}
        required
      />
      <input
        type="number"
        name="price"
        defaultValue={product.price}
        required
      />
      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? 'Saving...' : 'Save'}
      </button>
    </form>
  )
}
```

## The `use cache` Directive

Use the `cache` function to wrap expensive computations and cache results:

```typescript
// lib/expensive-operations.ts
import { cache } from 'react'

// Wrap function with cache
export const getCachedUser = cache(async (userId: string) => {
  console.log(`Fetching user ${userId}`) // Only logs once per render
  const response = await fetch(`https://api.example.com/users/${userId}`)
  return response.json()
})

// app/dashboard/page.tsx
import { getCachedUser } from '@/lib/expensive-operations'

export default async function Dashboard() {
  // Even though called 3 times, the fetch only happens once
  const user1 = await getCachedUser('123')
  const user2 = await getCachedUser('123')
  const user3 = await getCachedUser('123')

  return (
    <div>
      <p>All three variables are identical</p>
    </div>
  )
}
```

### Caching Complex Computations

```typescript
// lib/analytics.ts
import { cache } from 'react'

export const getAnalytics = cache(async (userId: string) => {
  // Expensive computation
  const events = await fetch(
    `https://api.example.com/events?userId=${userId}`
  ).then(r => r.json())

  // Process data
  const stats = {
    totalEvents: events.length,
    avgSessionTime:
      events.reduce((acc, e) => acc + e.duration, 0) / events.length,
    lastActive: events[events.length - 1]?.timestamp,
    topPages: calculateTopPages(events),
    conversions: calculateConversions(events)
  }

  return stats
})

// app/analytics/page.tsx
import { getAnalytics } from '@/lib/analytics'

export default async function AnalyticsPage({
  searchParams
}: {
  searchParams: { userId: string }
}) {
  // All these calls use the cached result
  const analytics = await getAnalytics(searchParams.userId)
  const stats = await getAnalytics(searchParams.userId)
  const details = await getAnalytics(searchParams.userId)

  return (
    <div className="analytics">
      <div className="overview">
        <p>Total Events: {analytics.totalEvents}</p>
        <p>Avg Session: {analytics.avgSessionTime}ms</p>
      </div>
      <div className="pages">
        {analytics.topPages.map(page => (
          <div key={page.path}>
            <h4>{page.path}</h4>
            <p>{page.views} views</p>
          </div>
        ))}
      </div>
      <div className="conversions">
        <p>Conversions: {analytics.conversions}</p>
      </div>
    </div>
  )
}
```

## Cache Components (Experimental)

Use Cache Components to wrap expensive subtrees and cache their output:

```typescript
// components/UserRecommendations.tsx
// This component can be wrapped and cached
export async function UserRecommendations({
  userId
}: {
  userId: string
}) {
  // Expensive recommendations computation
  const recommendations = await fetch(
    `https://api.example.com/recommendations/${userId}`
  ).then(r => r.json())

  return (
    <section className="recommendations">
      <h2>Recommended for You</h2>
      <div className="items">
        {recommendations.map(item => (
          <div key={item.id} className="recommendation-card">
            <h3>{item.title}</h3>
            <p>{item.description}</p>
            <div className="score">Match: {item.score}%</div>
          </div>
        ))}
      </div>
    </section>
  )
}

// app/dashboard/page.tsx
import { cache } from 'react'
import { UserRecommendations } from '@/components/UserRecommendations'

// Wrap the component to cache its output
const CachedRecommendations = cache(UserRecommendations)

export default async function Dashboard({
  userId
}: {
  userId: string
}) {
  return (
    <div className="dashboard">
      <header>
        <h1>Your Dashboard</h1>
      </header>

      {/* This expensive component's output is cached */}
      <CachedRecommendations userId={userId} />

      <footer>
        <p>Last updated: {new Date().toLocaleString()}</p>
      </footer>
    </div>
  )
}
```

## Full Route Caching

### Static Generation

Routes are statically generated by default when using `fetch()` with caching:

```typescript
// app/docs/[slug]/page.tsx
export const revalidate = 3600 // Revalidate every hour

export async function generateStaticParams() {
  // Pre-generate these paths at build time
  const docs = await fetch('https://api.example.com/docs', {
    next: { revalidate: 86400 }
  }).then(r => r.json())

  return docs.map(doc => ({
    slug: doc.slug
  }))
}

export default async function DocPage({
  params
}: {
  params: { slug: string }
}) {
  const doc = await fetch(
    `https://api.example.com/docs/${params.slug}`,
    {
      next: { revalidate: 3600, tags: ['docs'] }
    }
  ).then(r => r.json())

  return (
    <article>
      <h1>{doc.title}</h1>
      <div dangerouslySetInnerHTML={{ __html: doc.content }} />
    </article>
  )
}
```

### Dynamic Routes (On-Demand ISR)

```typescript
// app/products/[id]/page.tsx
export const dynamicParams = true // Allow unknown params
export const revalidate = 300 // Revalidate every 5 minutes

export async function generateStaticParams() {
  // Only pre-generate popular products
  const products = await fetch(
    'https://api.example.com/products?popular=true',
    { next: { revalidate: 3600 } }
  ).then(r => r.json())

  return products.map(p => ({
    id: p.id
  }))
}

export default async function ProductPage({
  params
}: {
  params: { id: string }
}) {
  const product = await fetch(
    `https://api.example.com/products/${params.id}`,
    {
      next: { revalidate: 300 }
    }
  ).then(r => r.json())

  // Unknown products are generated on first visit and cached
  // Then revalidated every 5 minutes
  return (
    <div>
      <h1>{product.name}</h1>
      <p>${product.price}</p>
    </div>
  )
}
```

## Router Cache (Client-Side)

Control how long client-side route caches persist:

```typescript
// app/layout.tsx
import { Router } from 'next/router'

// Default router cache is 5 minutes
// You can disable or control it per navigation

// Using Link (default caching)
import Link from 'next/link'

export function Navigation() {
  return (
    <nav>
      <Link href="/about">About</Link>
      <Link href="/blog">Blog</Link>
    </nav>
  )
}

// Programmatic navigation with control
'use client'
import { useRouter } from 'next/navigation'

export function NavigateButton() {
  const router = useRouter()

  const navigateWithPrefetch = async () => {
    // Prefetch the route to warm up the cache
    router.prefetch('/heavy-page')

    // Navigate to the page
    router.push('/heavy-page')
  }

  return <button onClick={navigateWithPrefetch}>Go to Heavy Page</button>
}
```

## Strategic Caching for E-Commerce

A comprehensive example showing optimal caching strategies:

```typescript
// app/shop/page.tsx
export const revalidate = 300 // 5 minutes for category page

type Product = {
  id: string
  name: string
  price: number
  image: string
  slug: string
};

export default async function ShopPage() {
  // Category list changes infrequently - longer cache
  const categories = await fetch(
    'https://api.example.com/categories',
    {
      next: {
        revalidate: 86400, // 1 day
        tags: ['categories']
      }
    }
  ).then(r => r.json())

  // Products update more frequently
  const products: Product[] = await fetch(
    'https://api.example.com/products?limit=20',
    {
      next: {
        revalidate: 300, // 5 minutes
        tags: ['products']
      }
    }
  ).then(r => r.json())

  // Featured products might update daily
  const featured = await fetch(
    'https://api.example.com/products/featured',
    {
      next: {
        revalidate: 3600, // 1 hour
        tags: ['featured-products']
      }
    }
  ).then(r => r.json())

  return (
    <div className="shop">
      <aside>
        <h2>Categories</h2>
        <ul>
          {categories.map(cat => (
            <li key={cat.id}>
              <a href={`/shop?category=${cat.slug}`}>{cat.name}</a>
            </li>
          ))}
        </ul>
      </aside>

      <main>
        <section>
          <h2>Featured Products</h2>
          <div className="grid">
            {featured.map(product => (
              <ProductCard key={product.id} product={product} />
            ))}
          </div>
        </section>

        <section>
          <h2>All Products</h2>
          <div className="grid">
            {products.map(product => (
              <ProductCard key={product.id} product={product} />
            ))}
          </div>
        </section>
      </main>
    </div>
  )
}

// app/products/[slug]/page.tsx
export const revalidate = 600 // 10 minutes

export async function generateStaticParams() {
  // Pre-generate bestsellers at build time
  const products = await fetch(
    'https://api.example.com/products?bestsellers=true',
    { next: { revalidate: 86400 } }
  ).then(r => r.json())

  return products.map(p => ({
    slug: p.slug
  }))
}

export async function generateMetadata({
  params
}: {
  params: { slug: string }
}) {
  const product = await fetch(
    `https://api.example.com/products/${params.slug}`,
    {
      next: {
        revalidate: 600,
        tags: ['products', `product-${params.slug}`]
      }
    }
  ).then(r => r.json())

  return {
    title: product.name,
    description: product.description,
    openGraph: {
      images: [product.image],
      title: product.name,
      description: product.description,
      type: 'website'
    }
  }
}

export default async function ProductPage({
  params
}: {
  params: { slug: string }
}) {
  const [product, reviews, recommendations] = await Promise.all([
    // Product details
    fetch(`https://api.example.com/products/${params.slug}`, {
      next: { revalidate: 600, tags: [`product-${params.slug}`] }
    }).then(r => r.json()),

    // Reviews (update often)
    fetch(`https://api.example.com/products/${params.slug}/reviews`, {
      next: { revalidate: 60, tags: [`product-reviews-${params.slug}`] }
    }).then(r => r.json()),

    // Recommendations (semi-static)
    fetch(`https://api.example.com/products/${params.slug}/related`, {
      next: {
        revalidate: 3600,
        tags: [`product-recommendations-${params.slug}`]
      }
    }).then(r => r.json())
  ])

  return (
    <div className="product-page">
      <section className="product-detail">
        <img src={product.image} alt={product.name} />
        <div>
          <h1>{product.name}</h1>
          <p className="price">${product.price}</p>
          <p className="description">{product.description}</p>
          <AddToCartButton productId={product.id} />
        </div>
      </section>

      <section className="reviews">
        <h2>Customer Reviews</h2>
        {reviews.map(review => (
          <div key={review.id} className="review">
            <p className="rating">{'★'.repeat(review.rating)}</p>
            <p>{review.text}</p>
            <footer>By {review.author}</footer>
          </div>
        ))}
      </section>

      <section className="recommendations">
        <h2>You might also like</h2>
        <div className="grid">
          {recommendations.map(prod => (
            <ProductCard key={prod.id} product={prod} />
          ))}
        </div>
      </section>
    </div>
  )
}
```

## Caching Best Practices

### 1. Different Cache Durations for Different Content

```typescript
export const CACHE_DURATIONS = {
  STATIC: 86400 * 7, // 1 week - rarely changes
  LONG: 86400, // 1 day - occasional updates
  MEDIUM: 3600, // 1 hour - frequent updates
  SHORT: 300, // 5 minutes - changes often
  DYNAMIC: 0 // Revalidate on every request
}

// app/blog/page.tsx
export const revalidate = CACHE_DURATIONS.MEDIUM

export default async function BlogPage() {
  // Category metadata - rarely changes
  const categories = await fetch(
    'https://api.example.com/categories',
    { next: { revalidate: CACHE_DURATIONS.LONG, tags: ['categories'] } }
  ).then(r => r.json())

  // Recent posts - update frequently
  const posts = await fetch(
    'https://api.example.com/posts',
    { next: { revalidate: CACHE_DURATIONS.MEDIUM, tags: ['posts'] } }
  ).then(r => r.json())

  return <div>{/* render */}</div>
}
```

### 2. Use Tags for Related Content

```typescript
// API routes that update products
export async function POST(request: Request) {
  const data = await request.json()

  // Update product in database
  await updateProduct(data)

  // Invalidate all related caches
  await Promise.all([
    revalidateTag('products'),
    revalidateTag(`product-${data.id}`),
    revalidateTag('category-all'),
    revalidateTag('featured-products')
  ])

  return Response.json({ success: true })
}
```

Master caching strategies to build lightning-fast, intelligent Next.js applications that balance performance with freshness.
