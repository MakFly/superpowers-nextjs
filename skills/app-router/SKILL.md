---
name: nextjs:app-router
description: Master Next.js App Router fundamentals - layouts, pages, templates, and the component hierarchy
---

# App Router Fundamentals

## Concept

Le Next.js App Router (introduced in Next.js 13) est le système de routing moderne basé sur le système de fichiers. Il remplace le Pages Router avec une architecture plus flexible et performante, utilisant la convention de fichiers spéciaux (`page.tsx`, `layout.tsx`, etc.).

## Architecture Hiérarchique

L'App Router fonctionne sur une hiérarchie de dossiers où chaque dossier représente un segment d'URL:

```
app/
├── layout.tsx           # Root layout (partagé par toutes les pages)
├── page.tsx             # Page d'accueil (/)
├── dashboard/
│   ├── layout.tsx       # Layout partagé pour /dashboard et ses enfants
│   ├── page.tsx         # Page /dashboard
│   └── settings/
│       ├── layout.tsx   # Layout pour /dashboard/settings
│       └── page.tsx     # Page /dashboard/settings
└── blog/
    ├── layout.tsx       # Layout pour /blog
    ├── page.tsx         # Page /blog
    └── [slug]/
        ├── layout.tsx   # Layout pour /blog/[slug]
        └── page.tsx     # Page /blog/[slug]
```

## Types de Fichiers Spéciaux

### page.tsx
Définit l'interface utilisateur pour une route. Seul ce fichier rend la route publiquement accessible.

```typescript
// app/page.tsx - Page d'accueil
export default function Home() {
  return (
    <div className="container">
      <h1>Bienvenue sur Next.js App Router</h1>
      <p>Cette page est rendue à /</p>
    </div>
  );
}

// app/dashboard/page.tsx - Page du tableau de bord
export default function Dashboard() {
  return (
    <div>
      <h2>Tableau de Bord</h2>
      <p>Contenu du dashboard</p>
    </div>
  );
}
```

### layout.tsx
Crée une interface utilisateur partagée entre plusieurs segments. Les layouts sont imbriqués et ne se remontent pas d'état.

```typescript
// app/layout.tsx - Root layout
'use client';

import './globals.css';
import Header from '@/components/Header';
import Footer from '@/components/Footer';

export const metadata = {
  title: 'Ma App',
  description: 'Une application avec Next.js App Router',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="fr">
      <body>
        <Header />
        <main>{children}</main>
        <Footer />
      </body>
    </html>
  );
}

// app/dashboard/layout.tsx - Dashboard layout
import Sidebar from '@/components/Sidebar';

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="flex">
      <Sidebar />
      <div className="flex-1">{children}</div>
    </div>
  );
}
```

### template.tsx
Similaire aux layouts, mais crée une nouvelle instance du composant pour chaque navigation. Les states ne sont pas préservés.

```typescript
// app/dashboard/template.tsx
'use client';

import { useState } from 'react';

export default function DashboardTemplate({
  children,
}: {
  children: React.ReactNode;
}) {
  const [animationState, setAnimationState] = useState(0);

  return (
    <div className={`animate-fade-in state-${animationState}`}>
      {children}
    </div>
  );
}
```

## Hiérarchie des Composants

```
┌─────────────────────────┐
│   Root Layout           │
│   (app/layout.tsx)      │
├─────────────────────────┤
│   Page ou Template      │
│   (partagé par enfants) │
├─────────────────────────┤
│   Segment Layout        │
│   (app/blog/layout.tsx) │
├─────────────────────────┤
│   Page                  │
│   (app/blog/page.tsx)   │
└─────────────────────────┘
```

## Exemple Complet: Blog avec Layouts Imbriqués

```typescript
// app/layout.tsx
import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: {
    default: 'Blog',
    template: '%s | Blog',
  },
  description: 'Blog moderne avec Next.js App Router',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="fr">
      <body className="bg-white text-gray-900">
        <nav className="border-b px-4 py-4">
          <div className="max-w-4xl mx-auto">
            <h1 className="text-2xl font-bold">Mon Blog</h1>
          </div>
        </nav>
        <main className="max-w-4xl mx-auto p-4">
          {children}
        </main>
      </body>
    </html>
  );
}

// app/blog/layout.tsx
import { Sidebar } from '@/components/Sidebar';

export default function BlogLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
      <Sidebar />
      <div className="md:col-span-3">
        {children}
      </div>
    </div>
  );
}

// app/blog/page.tsx
import { getAllPosts } from '@/lib/posts';
import Link from 'next/link';

export const metadata = {
  title: 'Articles',
};

export default async function BlogIndex() {
  const posts = await getAllPosts();

  return (
    <div>
      <h2 className="text-3xl font-bold mb-6">Tous les articles</h2>
      <div className="space-y-4">
        {posts.map((post) => (
          <article key={post.slug} className="p-4 border rounded-lg hover:shadow-lg transition">
            <Link href={`/blog/${post.slug}`}>
              <h3 className="text-xl font-semibold text-blue-600 hover:underline">
                {post.title}
              </h3>
            </Link>
            <p className="text-gray-600 text-sm mt-2">{post.date}</p>
            <p className="text-gray-700 mt-2">{post.excerpt}</p>
          </article>
        ))}
      </div>
    </div>
  );
}

// app/blog/[slug]/layout.tsx
import { getPost } from '@/lib/posts';
import { notFound } from 'next/navigation';

type BlogPostLayoutProps = {
  children: React.ReactNode;
  params: {
    slug: string;
  };
};

export default async function BlogPostLayout({
  children,
  params,
}: BlogPostLayoutProps) {
  const post = await getPost(params.slug);

  if (!post) {
    notFound();
  }

  return (
    <article className="prose prose-lg max-w-none">
      <header className="mb-8">
        <h1 className="text-4xl font-bold mb-2">{post.title}</h1>
        <div className="flex gap-4 text-gray-600">
          <span>Par {post.author}</span>
          <span>{post.date}</span>
          <span className="px-2 bg-gray-200 rounded">{post.readingTime} min</span>
        </div>
      </header>
      {children}
    </article>
  );
}

// app/blog/[slug]/page.tsx
import { getPost } from '@/lib/posts';
import { notFound } from 'next/navigation';

type BlogPostPageProps = {
  params: {
    slug: string;
  };
};

export async function generateMetadata({ params }: BlogPostPageProps) {
  const post = await getPost(params.slug);

  if (!post) {
    return {};
  }

  return {
    title: post.title,
    description: post.excerpt,
    openGraph: {
      title: post.title,
      description: post.excerpt,
      type: 'article',
    },
  };
}

export default async function BlogPostPage({
  params,
}: BlogPostPageProps) {
  const post = await getPost(params.slug);

  if (!post) {
    notFound();
  }

  return (
    <div className="mt-8">
      <div dangerouslySetInnerHTML={{ __html: post.content }} />

      <nav className="mt-12 pt-8 border-t">
        <div className="flex justify-between">
          {post.previous && (
            <a href={`/blog/${post.previous.slug}`} className="text-blue-600 hover:underline">
              ← {post.previous.title}
            </a>
          )}
          {post.next && (
            <a href={`/blog/${post.next.slug}`} className="ml-auto text-blue-600 hover:underline">
              {post.next.title} →
            </a>
          )}
        </div>
      </nav>
    </div>
  );
}
```

## Best Practices

### 1. Organisation Logique
```typescript
// Bonne structure
app/
├── (public)/          # Groupe pour pages publiques
│   ├── page.tsx       # Accueil
│   └── about/
│       └── page.tsx
├── (dashboard)/       # Groupe pour dashboard
│   ├── layout.tsx     # Avec authentification
│   ├── overview/
│   └── settings/
└── api/               # Routes API
```

### 2. Partage de Layouts
```typescript
// app/blog/layout.tsx - Un seul layout pour tous les articles
export default function BlogLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="blog-wrapper">
      {/* UI commune à tous les articles */}
      {children}
    </div>
  );
}

// Tous les enfants (page.tsx) héritent automatiquement
// app/blog/page.tsx, app/blog/[slug]/page.tsx, etc.
```

### 3. Metadata Dynamique
```typescript
// app/products/[id]/page.tsx
export async function generateMetadata({ params }) {
  const product = await getProduct(params.id);

  return {
    title: product.name,
    description: product.description,
    openGraph: {
      images: [product.image],
    },
  };
}
```

## Use Cases Courants

### Landing Page avec Sections
```typescript
// app/layout.tsx
export default function RootLayout({ children }) {
  return (
    <html>
      <body className="flex flex-col min-h-screen">
        <Header />
        {children}
        <Footer />
      </body>
    </html>
  );
}

// app/page.tsx
export default function Home() {
  return (
    <>
      <Hero />
      <Features />
      <Pricing />
      <CTA />
    </>
  );
}
```

### Dashboard Multi-sections
```typescript
// app/(dashboard)/layout.tsx
import { Navbar, Sidebar } from '@/components';

export default function DashboardLayout({ children }) {
  return (
    <div className="flex h-screen">
      <Sidebar />
      <div className="flex-1 flex flex-col">
        <Navbar />
        <main className="flex-1 overflow-auto p-6">
          {children}
        </main>
      </div>
    </div>
  );
}

// app/(dashboard)/analytics/page.tsx
// app/(dashboard)/settings/page.tsx
// Partagent tous le même layout
```

## Points Clés

- **Layouts imbriqués**: Chaque niveau de dossier peut avoir son propre `layout.tsx`
- **Héritage automatique**: Les enfants héritent des layouts parents
- **Page = Route publique**: Seul `page.tsx` rend une route accessible
- **Template vs Layout**: Templates créent une nouvelle instance, layouts les réutilisent
- **Métadonnées**: Peuvent être définies statiquement ou dynamiquement dans `generateMetadata`
