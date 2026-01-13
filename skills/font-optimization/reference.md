# Reference

# Font Optimization with Next.js

Next.js provides built-in font optimization through the `next/font` package, eliminating layout shift and improving performance with self-hosted or external fonts.

## Core Concepts

### Font Loading Performance
- **No Layout Shift (CLS)**: Fonts load in optimal sequence
- **Subsets**: Load only necessary characters
- **Self-Hosting**: Fonts served from CDN for faster load
- **Font Swapping**: Immediate text display while fonts load
- **Variable Fonts**: Single file for multiple weights/styles

### Font Stack Benefits
- Reduced bandwidth (subset only used characters)
- Better performance metrics (no FOUT/FOIT)
- Single HTTP request (vs multiple from Google Fonts)
- Preload and prefetch optimization
- No extra layout recalculations

## Google Fonts Integration

### Basic Google Font

```typescript
import { Geist_Mono, Roboto } from 'next/font/google'

const roboto = Roboto({
  weight: '400',
  subsets: ['latin'],
  variable: '--font-roboto',
})

const geistMono = Geist_Mono({
  subsets: ['latin'],
  variable: '--font-geist-mono',
})

export const metadata = {
  title: 'Font Optimization Demo',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en" className={`${roboto.variable} ${geistMono.variable}`}>
      <body className={roboto.className}>{children}</body>
    </html>
  )
}
```

### Multiple Weights and Styles

```typescript
import { Inter, Playfair_Display } from 'next/font/google'

const inter = Inter({
  weight: ['400', '500', '600', '700'],
  style: ['normal', 'italic'],
  subsets: ['latin', 'latin-ext'],
  display: 'swap',
  variable: '--font-inter',
})

const playfair = Playfair_Display({
  weight: ['400', '700', '900'],
  style: 'normal',
  subsets: ['latin'],
  display: 'swap',
  variable: '--font-playfair',
})

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html
      lang="en"
      className={`${inter.variable} ${playfair.variable}`}
    >
      <body className={inter.className}>{children}</body>
    </html>
  )
}
```

### Variable Fonts

```typescript
import { JetBrains_Mono, Inter } from 'next/font/google'

// Variable font (single file, all weights)
const inter = Inter({
  subsets: ['latin'],
  variable: '--font-sans',
  display: 'swap',
})

const jetBrainsMono = JetBrains_Mono({
  subsets: ['latin'],
  variable: '--font-mono',
  display: 'swap',
})

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html
      lang="en"
      className={`${inter.variable} ${jetBrainsMono.variable}`}
    >
      <body className={inter.className}>{children}</body>
    </html>
  )
}
```

## Self-Hosted Fonts

### Local Font Files

```typescript
import localFont from 'next/font/local'

const customFont = localFont({
  src: [
    {
      path: './fonts/custom-regular.woff2',
      weight: '400',
      style: 'normal',
    },
    {
      path: './fonts/custom-bold.woff2',
      weight: '700',
      style: 'normal',
    },
    {
      path: './fonts/custom-italic.woff2',
      weight: '400',
      style: 'italic',
    },
  ],
  variable: '--font-custom',
  display: 'swap',
})

export const metadata = {
  title: 'Custom Fonts',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en" className={customFont.variable}>
      <body className={customFont.className}>{children}</body>
    </html>
  )
}
```

### Multi-Font Setup

```typescript
import localFont from 'next/font/local'
import { Inter } from 'next/font/google'

const inter = Inter({
  subsets: ['latin'],
  variable: '--font-sans',
})

const displayFont = localFont({
  src: './fonts/display.woff2',
  variable: '--font-display',
  weight: '400',
})

const monoFont = localFont({
  src: [
    {
      path: './fonts/mono-regular.woff2',
      weight: '400',
    },
    {
      path: './fonts/mono-bold.woff2',
      weight: '700',
    },
  ],
  variable: '--font-mono',
})

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html
      lang="en"
      className={`${inter.variable} ${displayFont.variable} ${monoFont.variable}`}
    >
      <body className={inter.className}>{children}</body>
    </html>
  )
}
```

## CSS Variable Integration

### TailwindCSS Font Stack

```typescript
// app/layout.tsx
import { Inter, Inconsolata } from 'next/font/google'

const inter = Inter({
  subsets: ['latin'],
  variable: '--font-sans',
  display: 'swap',
})

const inconsolata = Inconsolata({
  subsets: ['latin'],
  variable: '--font-mono',
  display: 'swap',
})

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html
      lang="en"
      className={`${inter.variable} ${inconsolata.variable}`}
    >
      <body>{children}</body>
    </html>
  )
}
```

```typescript
// tailwind.config.ts
import type { Config } from 'tailwindcss'

const config: Config = {
  content: [
    './app/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['var(--font-sans)'],
        mono: ['var(--font-mono)'],
      },
    },
  },
  plugins: [],
}

export default config
```

### Styled Components Integration

```typescript
'use client'

import { Inter } from 'next/font/google'
import styled from 'styled-components'

const inter = Inter({ subsets: ['latin'] })

const StyledBody = styled.div`
  font-family: ${inter.style.fontFamily};
  font-size: 16px;
  line-height: 1.5;
`

export default function Component() {
  return <StyledBody>Content with optimized font</StyledBody>
}
```

## Font Loading Strategies

### Font Display Options

```typescript
import { Roboto, Playfair_Display } from 'next/font/google'

// Auto (default): Browser determines strategy
const auto = Roboto({
  weight: '400',
  display: 'auto',
})

// Swap: Show fallback immediately
const swap = Roboto({
  weight: '400',
  display: 'swap', // Best for body text
})

// Block: Hide text until font loads (max 3s)
const block = Roboto({
  weight: '400',
  display: 'block', // For critical headings
})

// Fallback: Hide text for 100ms, then fallback (max 3s)
const fallback = Roboto({
  weight: '400',
  display: 'fallback', // Balanced approach
})

// Optional: Wait 100ms, then use fallback indefinitely
const optional = Playfair_Display({
  weight: '700',
  display: 'optional', // Non-critical fonts
})

export default function FontDemo() {
  return (
    <>
      <div className={auto.className}>Auto display (default)</div>
      <div className={swap.className}>Swap display (recommended)</div>
      <div className={block.className}>Block display</div>
      <div className={fallback.className}>Fallback display</div>
      <div className={optional.className}>Optional display</div>
    </>
  )
}
```

### Subset Optimization

```typescript
import { Noto_Sans } from 'next/font/google'

// Load only necessary languages
const notoSans = Noto_Sans({
  weight: ['400', '700'],
  // Only Latin and Latin Extended
  subsets: ['latin', 'latin-ext'],
  display: 'swap',
  // Preload specific subsets
  preload: true,
})

// For CJK fonts, load subset per page
const notoDifference = Noto_Sans({
  weight: '400',
  subsets: ['latin'], // Default for most pages
  display: 'swap',
})

export default function Content() {
  return <div className={notoSans.className}>Optimized content</div>
}
```

## Advanced Patterns

### Font Fallback System

```typescript
import { Inter, Roboto } from 'next/font/google'
import localFont from 'next/font/local'

const primary = localFont({
  src: './fonts/primary.woff2',
  variable: '--font-primary',
  fallback: ['system-ui', 'sans-serif'],
})

const secondary = Inter({
  subsets: ['latin'],
  variable: '--font-secondary',
  fallback: ['Roboto', 'sans-serif'],
})

const tertiary = Roboto({
  weight: '400',
  subsets: ['latin'],
  variable: '--font-tertiary',
  fallback: ['Arial', 'sans-serif'],
})

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html
      lang="en"
      className={`${primary.variable} ${secondary.variable} ${tertiary.variable}`}
    >
      <body>{children}</body>
    </html>
  )
}
```

### Dynamic Font Loading

```typescript
'use client'

import { useEffect, useState } from 'react'

type FontFace = {
  fontFamily: string
  src: string
  fontWeight: string
  fontStyle: string
};

export function useDynamicFont(fonts: FontFace[]) {
  const [loaded, setLoaded] = useState(false)

  useEffect(() => {
    // Load fonts dynamically
    const fontFaces = fonts.map((font) => {
      return new FontFace(
        font.fontFamily,
        `url(${font.src})`,
        {
          weight: font.fontWeight,
          style: font.fontStyle,
        }
      )
    })

    Promise.all(
      fontFaces.map((f) => {
        document.fonts.add(f)
        return f.load()
      })
    )
      .then(() => {
        setLoaded(true)
      })
      .catch((err) => {
        console.error('Font loading error:', err)
      })
  }, [fonts])

  return loaded
}

export default function DynamicFontComponent() {
  const loaded = useDynamicFont([
    {
      fontFamily: 'CustomFont',
      src: '/fonts/custom.woff2',
      fontWeight: '400',
      fontStyle: 'normal',
    },
  ])

  return (
    <div style={{ fontFamily: loaded ? 'CustomFont' : 'serif' }}>
      {loaded ? 'Custom font loaded' : 'Loading...'}
    </div>
  )
}
```

### Conditional Font Loading

```typescript
import { headers } from 'next/headers'
import { Inter, Noto_Sans_JP } from 'next/font/google'

const inter = Inter({
  subsets: ['latin'],
  variable: '--font-inter',
})

const notoSansJp = Noto_Sans_JP({
  subsets: ['latin', 'cyrillic'],
  variable: '--font-noto-jp',
})

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  const headersList = headers()
  const acceptLanguage = headersList.get('accept-language') || ''

  // Load Japanese font only for Japanese users
  const isJapanese = acceptLanguage.includes('ja')
  const fontClass = isJapanese
    ? notoSansJp.variable
    : inter.variable

  return (
    <html lang="en" className={fontClass}>
      <body>{children}</body>
    </html>
  )
}
```

## Performance Monitoring

### Font Loading Metrics

```typescript
'use client'

import { useEffect } from 'react'

export function FontMetrics() {
  useEffect(() => {
    // Monitor font loading
    if (typeof document !== 'undefined' && 'fonts' in document) {
      const fontFaces = (document.fonts as any) as FontFaceSet

      fontFaces.addEventListener('loading', () => {
        console.log('Fonts loading...')
      })

      fontFaces.addEventListener('loadingdone', () => {
        console.log('All fonts loaded')
        // Send to analytics
        // track('fonts_loaded')
      })

      fontFaces.addEventListener('loadingerror', (event) => {
        console.error('Font loading error:', event)
        // Send to error tracking
        // captureException('font_loading_error')
      })
    }
  }, [])

  return null
}
```

### Font Performance Hook

```typescript
'use client'

import { useEffect, useState } from 'react'

export function useFontPerformance() {
  const [metrics, setMetrics] = useState({
    fontsLoaded: false,
    loadTime: 0,
    failedFonts: [] as string[],
  })

  useEffect(() => {
    const startTime = performance.now()

    if (typeof document !== 'undefined' && 'fonts' in document) {
      const fontFaces = (document.fonts as any) as FontFaceSet

      const handleLoadingDone = () => {
        const loadTime = performance.now() - startTime
        setMetrics((prev) => ({
          ...prev,
          fontsLoaded: true,
          loadTime: Math.round(loadTime),
        }))

        // Log performance metric
        console.log(`Fonts loaded in ${loadTime.toFixed(2)}ms`)
      }

      fontFaces.addEventListener('loadingdone', handleLoadingDone)

      return () => {
        fontFaces.removeEventListener('loadingdone', handleLoadingDone)
      }
    }
  }, [])

  return metrics
}
```

## TypeScript Support

### Font Configuration Type Safety

```typescript
import type { Config } from 'next/config'
import { Inter, Roboto_Mono } from 'next/font/google'
import localFont from 'next/font/local'

type FontConfig = {
  primary: ReturnType<typeof Inter>
  mono: ReturnType<typeof Roboto_Mono>
  custom: ReturnType<typeof localFont>
};

const fonts: FontConfig = {
  primary: Inter({
    subsets: ['latin'],
    variable: '--font-primary',
  }),
  mono: Roboto_Mono({
    subsets: ['latin'],
    variable: '--font-mono',
  }),
  custom: localFont({
    src: './fonts/custom.woff2',
    variable: '--font-custom',
  }),
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html
      lang="en"
      className={`${fonts.primary.variable} ${fonts.mono.variable} ${fonts.custom.variable}`}
    >
      <body className={fonts.primary.className}>{children}</body>
    </html>
  )
}
```

## Best Practices

### Optimization Guidelines
- Use CSS variables for dynamic font switching
- Prefer `display: 'swap'` for body text
- Load only necessary subsets
- Use variable fonts when possible
- Self-host critical fonts
- Preload fonts on critical pages

### Font Stack Design
- Define fallback chain: custom > external > system
- Test across browsers and devices
- Monitor font loading performance
- Set appropriate font weights
- Consider language requirements

### Performance Checklist
- Minimize number of font files
- Use WOFF2 format (best compression)
- Preload above-fold fonts
- Use subset optimization
- Test on slow networks
- Monitor Core Web Vitals

## Related Skills

- **Image Optimization** - Prevent layout shift from images
- **Streaming** - Progressive rendering with Suspense
- **Lazy Loading** - Dynamic code splitting
