# Reference

# Image Optimization with Next.js

Next.js Image component provides automatic optimization for web performance through lazy loading, responsive sizing, and modern image format support.

## Core Concepts

### Why Image Optimization Matters
- **Bandwidth Reduction**: Serve optimized WebP/AVIF formats (25-35% smaller)
- **Performance**: Automatic lazy loading prevents blocking page load
- **Responsive Design**: Serve correct size for device without manual breakpoints
- **Layout Stability**: Prevents Cumulative Layout Shift (CLS) with explicit dimensions

### Image Component Benefits
- Automatic srcset generation
- Responsive image sizing
- WebP/AVIF format support
- Lazy loading by default
- Placeholder blur support

## Basic Usage

### Simple Image Component

```typescript
import Image from 'next/image'

export default function ProductCard() {
  return (
    <Image
      src="/products/laptop.jpg"
      alt="High-performance laptop"
      width={400}
      height={300}
      priority={false}
    />
  )
}
```

### Static Import (Type-Safe)

```typescript
import Image from 'next/image'
import productImage from '@/public/laptop.jpg'

export default function ProductCard() {
  return (
    <Image
      src={productImage}
      alt="Laptop product"
      placeholder="blur"
      blurDataURL="data:image/svg+xml,..."
    />
  )
}
```

## Responsive Images

### Using `fill` Prop for Container-Based Sizing

```typescript
'use client'

import Image from 'next/image'
import { useState } from 'react'

export default function ResponsiveHero() {
  return (
    <div className="relative w-full h-96 bg-gray-200">
      <Image
        src="/hero-banner.jpg"
        alt="Hero banner"
        fill
        className="object-cover"
        priority
        sizes="(max-width: 768px) 100vw,
               (max-width: 1200px) 50vw,
               100vw"
      />
    </div>
  )
}
```

### Responsive Images with Multiple Sizes

```typescript
import Image from 'next/image'

export default function ResponsiveGallery() {
  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
      {[1, 2, 3, 4, 5, 6].map((id) => (
        <div key={id} className="relative aspect-square">
          <Image
            src={`/gallery/image-${id}.jpg`}
            alt={`Gallery image ${id}`}
            fill
            className="object-cover rounded-lg"
            sizes="(max-width: 768px) 100vw,
                   (max-width: 1200px) 50vw,
                   33vw"
          />
        </div>
      ))}
    </div>
  )
}
```

## Advanced Optimization

### Blur Placeholder Pattern

```typescript
import Image from 'next/image'
import { getPlaiceholder } from 'plaiceholder'

export async function ImageWithBlur() {
  const { base64, img } = await getPlaiceholder(
    '/products/item.jpg'
  )

  return (
    <Image
      {...img}
      alt="Product item"
      placeholder="blur"
      blurDataURL={base64}
    />
  )
}
```

### Progressive Image Loading

```typescript
'use client'

import Image from 'next/image'
import { useState } from 'react'

export default function ProgressiveImage({
  src,
  alt,
}: {
  src: string
  alt: string
}) {
  const [isLoading, setIsLoading] = useState(true)

  return (
    <div className="relative bg-gray-200">
      <Image
        src={src}
        alt={alt}
        width={800}
        height={600}
        className={`transition-opacity duration-300 ${
          isLoading ? 'opacity-0' : 'opacity-100'
        }`}
        onLoadingComplete={() => setIsLoading(false)}
      />
      {isLoading && (
        <div className="absolute inset-0 bg-gray-300 animate-pulse" />
      )}
    </div>
  )
}
```

### Image Gallery with Lightbox

```typescript
'use client'

import Image from 'next/image'
import { useState } from 'react'

type GalleryImage = {
  id: string
  src: string
  alt: string
  thumbnail: string
};

export default function ImageGallery({
  images,
}: {
  images: GalleryImage[]
}) {
  const [selectedId, setSelectedId] = useState<string | null>(null)
  const selected = images.find((img) => img.id === selectedId)

  return (
    <>
      <div className="grid grid-cols-4 gap-2">
        {images.map((img) => (
          <button
            key={img.id}
            onClick={() => setSelectedId(img.id)}
            className="relative aspect-square border-2 border-transparent hover:border-blue-500 rounded"
          >
            <Image
              src={img.thumbnail}
              alt={img.alt}
              fill
              className="object-cover"
              sizes="25vw"
            />
          </button>
        ))}
      </div>

      {selected && (
        <div
          className="fixed inset-0 bg-black/80 flex items-center justify-center z-50"
          onClick={() => setSelectedId(null)}
        >
          <div
            className="relative max-w-2xl max-h-[90vh] w-full h-full"
            onClick={(e) => e.stopPropagation()}
          >
            <Image
              src={selected.src}
              alt={selected.alt}
              fill
              className="object-contain"
              priority
            />
          </div>
        </div>
      )}
    </>
  )
}
```

## Format Optimization

### Automatic Format Selection

```typescript
import Image from 'next/image'

export default function ModernFormats() {
  return (
    <div className="space-y-4">
      <Image
        src="/image.jpg"
        alt="Auto-optimized image"
        width={800}
        height={600}
        // Next.js automatically serves WebP/AVIF to supported browsers
      />
    </div>
  )
}
```

### next.config.js Configuration

```javascript
/** @type {import('next').NextConfig} */
const nextConfig = {
  images: {
    // Device sizes for responsive images
    deviceSizes: [640, 750, 828, 1080, 1200, 1920, 2048, 3840],

    // Image sizes for different layouts
    imageSizes: [16, 32, 48, 64, 96, 128, 256, 384],

    // Supported formats
    formats: ['image/webp', 'image/avif'],

    // Allowed image domains
    domains: ['example.com', 'cdn.example.com'],

    // Custom cache settings
    minimumCacheTTL: 60,

    // Dangerously unoptimized (development only)
    unoptimized: process.env.NODE_ENV === 'development',
  },
}

module.exports = nextConfig
```

## Priority and Lazy Loading

### Critical Images (Above the Fold)

```typescript
import Image from 'next/image'

export default function HeroSection() {
  return (
    <Image
      src="/hero.jpg"
      alt="Hero image"
      width={1200}
      height={600}
      priority // LCP optimization
      loading="eager"
    />
  )
}
```

### Deferred Images (Below the Fold)

```typescript
import Image from 'next/image'

export default function TeaserSection() {
  return (
    <Image
      src="/teaser.jpg"
      alt="Teaser image"
      width={800}
      height={400}
      // priority is false by default
      // Image loads when entering viewport
    />
  )
}
```

## Dynamic Image Sizing

### Responsive Image Component

```typescript
'use client'

import Image from 'next/image'
import { useEffect, useRef, useState } from 'react'

type ResponsiveImageProps = {
  src: string
  alt: string
  ratio?: number // width/height ratio
};

export default function ResponsiveImage({
  src,
  alt,
  ratio = 16 / 9,
}: ResponsiveImageProps) {
  const containerRef = useRef<HTMLDivElement>(null)
  const [width, setWidth] = useState(0)

  useEffect(() => {
    const observer = new ResizeObserver(() => {
      if (containerRef.current) {
        setWidth(containerRef.current.offsetWidth)
      }
    })

    if (containerRef.current) {
      observer.observe(containerRef.current)
      setWidth(containerRef.current.offsetWidth)
    }

    return () => observer.disconnect()
  }, [])

  return (
    <div ref={containerRef} style={{ aspectRatio: ratio }} className="w-full">
      <Image
        src={src}
        alt={alt}
        width={width}
        height={Math.round(width / ratio)}
        className="w-full h-full object-cover"
        sizes="(max-width: 768px) 100vw, 50vw"
      />
    </div>
  )
}
```

## Performance Monitoring

### Image Performance Component

```typescript
'use client'

import Image from 'next/image'
import { useRef } from 'react'

export default function MonitoredImage({
  src,
  alt,
}: {
  src: string
  alt: string
}) {
  const imgRef = useRef<HTMLImageElement>(null)

  const handleLoadingComplete = () => {
    if (imgRef.current) {
      const metrics = {
        alt: alt,
        src: src,
        naturalWidth: imgRef.current.naturalWidth,
        naturalHeight: imgRef.current.naturalHeight,
      }
      console.log('Image loaded:', metrics)

      // Send to analytics
      // track('image_loaded', metrics)
    }
  }

  return (
    <Image
      ref={imgRef}
      src={src}
      alt={alt}
      width={800}
      height={600}
      onLoadingComplete={handleLoadingComplete}
      onError={(error) => {
        console.error('Image failed to load:', error)
        // Handle error gracefully
      }}
    />
  )
}
```

## Best Practices

### Layout Stability
- Always specify width and height (or aspect ratio)
- Use `priority` for above-fold images
- Avoid dynamic image sources when possible

### Format Selection
- Rely on automatic format conversion
- Use modern formats (WebP/AVIF)
- Test format support across browsers

### Responsive Design
- Use `sizes` prop for responsive images
- Set appropriate `deviceSizes` in config
- Test on real devices and connections

### Accessibility
- Always provide descriptive `alt` text
- Use semantic HTML with images
- Consider text alternatives for decorative images

### Performance
- Compress source images before serving
- Use appropriate image dimensions
- Monitor Core Web Vitals
- Cache optimized images appropriately

## Advanced Patterns

### Image with Fallback

```typescript
'use client'

import Image from 'next/image'
import { useState } from 'react'

export default function ImageWithFallback({
  src,
  alt,
  fallback,
}: {
  src: string
  alt: string
  fallback: string
}) {
  const [imgSrc, setImgSrc] = useState(src)

  return (
    <Image
      src={imgSrc}
      alt={alt}
      width={400}
      height={300}
      onError={() => setImgSrc(fallback)}
    />
  )
}
```

### Image Comparison Slider

```typescript
'use client'

import Image from 'next/image'
import { useRef } from 'react'

export default function ImageComparison({
  before,
  after,
  alt,
}: {
  before: string
  after: string
  alt: string
}) {
  const containerRef = useRef<HTMLDivElement>(null)

  const handleMouseMove = (
    e: React.MouseEvent<HTMLDivElement>
  ) => {
    if (!containerRef.current) return

    const rect = containerRef.current.getBoundingClientRect()
    const percent = ((e.clientX - rect.left) / rect.width) * 100

    const afterImage = containerRef.current.querySelector(
      '[data-after]'
    ) as HTMLDivElement | null

    if (afterImage) {
      afterImage.style.width = `${percent}%`
    }
  }

  return (
    <div
      ref={containerRef}
      className="relative w-full max-w-2xl mx-auto overflow-hidden rounded-lg cursor-col-resize"
      onMouseMove={handleMouseMove}
    >
      <div className="relative aspect-video">
        <Image
          src={before}
          alt={`${alt} - before`}
          fill
          className="object-cover"
          sizes="100vw"
        />
      </div>
      <div
        data-after
        className="absolute top-0 left-0 w-1/2 h-full overflow-hidden"
      >
        <div className="relative w-full aspect-video">
          <Image
            src={after}
            alt={`${alt} - after`}
            fill
            className="object-cover"
            sizes="50vw"
          />
        </div>
      </div>
    </div>
  )
}
```

## Related Skills

- **Font Optimization** - Prevent layout shift from custom fonts
- **Lazy Loading** - Dynamic imports for code splitting
- **Streaming** - Progressive rendering with Suspense
