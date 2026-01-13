# Reference

# File-Based Routing Conventions

## Concept

Le routing basé sur les fichiers dans Next.js App Router utilise une convention de noms spéciaux pour les fichiers. Chaque fichier a une fonction spécifique dans l'architecture d'une route et fonctionne ensemble pour créer une expérience complète.

## Fichiers Spéciaux et Leur Rôle

### page.tsx
Crée la route publiquement accessible. C'est le seul fichier qui rend réellement une page.

| Aspect | Détail |
|--------|--------|
| Rôle | Définit l'UI pour une route |
| Accessibilité | Public (route accessible) |
| Paramètres | Reçoit `params` et `searchParams` |
| Export | Composant React par défaut |

```typescript
// app/page.tsx
export default function Home() {
  return <h1>Accueil</h1>;
}

// URL accessible: /

// app/products/page.tsx
export default function Products() {
  return <h1>Produits</h1>;
}

// URL accessible: /products

// app/users/[id]/page.tsx
type UserPageProps = {
  params: {
    id: string;
  };
  searchParams: {
    tab?: string;
    sort?: string;
  };
};

export default function UserPage({
  params,
  searchParams,
}: UserPageProps) {
  return (
    <div>
      <h1>Utilisateur {params.id}</h1>
      <p>Onglet: {searchParams.tab || 'profil'}</p>
      <p>Tri: {searchParams.sort || 'défaut'}</p>
    </div>
  );
}

// URLs accessibles:
// /users/123
// /users/123?tab=posts
// /users/123?tab=posts&sort=recent
```

### layout.tsx
Crée une interface partagée pour un segment et ses enfants. Les layouts s'imbriquent et préservent leur état.

```typescript
// app/layout.tsx - Root Layout
export const metadata = {
  title: 'Ma App',
  description: 'Description',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="fr">
      <body className="font-sans">
        <header className="bg-blue-600 text-white p-4">
          <h1>Mon Site</h1>
        </header>
        {children}
        <footer className="bg-gray-800 text-white p-4 mt-12">
          <p>&copy; 2024</p>
        </footer>
      </body>
    </html>
  );
}

// app/dashboard/layout.tsx - Nested Layout
'use client';

import { useState } from 'react';
import { useSidebarState } from '@/hooks/useSidebarState';

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const [isOpen, setIsOpen] = useState(true);

  return (
    <div className="flex h-full">
      <aside
        className={`transition-all duration-300 ${
          isOpen ? 'w-64' : 'w-20'
        } bg-gray-100 border-r`}
      >
        <nav className="p-4">
          <button
            onClick={() => setIsOpen(!isOpen)}
            className="mb-4 p-2 hover:bg-gray-200 rounded"
          >
            {isOpen ? '✕' : '☰'}
          </button>
          {isOpen && (
            <ul className="space-y-2">
              <li><a href="/dashboard">Overview</a></li>
              <li><a href="/dashboard/users">Utilisateurs</a></li>
              <li><a href="/dashboard/settings">Paramètres</a></li>
            </ul>
          )}
        </nav>
      </aside>
      <main className="flex-1 p-6">{children}</main>
    </div>
  );
}

// Tous les enfants héritent de ce layout
// /dashboard
// /dashboard/users
// /dashboard/settings
```

### loading.tsx
Affiche un placeholder pendant que le contenu se charge. Utilisé avec Suspense pour le streaming.

```typescript
// app/blog/loading.tsx
export default function BlogLoading() {
  return (
    <div className="space-y-4">
      <div className="h-12 bg-gray-200 rounded animate-pulse" />
      <div className="h-64 bg-gray-200 rounded animate-pulse" />
      <div className="h-12 bg-gray-200 rounded animate-pulse" />
    </div>
  );
}

// app/blog/[slug]/loading.tsx
export default function PostLoading() {
  return (
    <div className="max-w-2xl">
      <div className="h-12 bg-gray-200 rounded animate-pulse mb-4" />
      <div className="h-6 bg-gray-200 rounded w-1/3 mb-8" />
      <div className="space-y-3">
        {[...Array(10)].map((_, i) => (
          <div
            key={i}
            className="h-4 bg-gray-200 rounded animate-pulse"
          />
        ))}
      </div>
    </div>
  );
}

// Implémentation avec Suspense (niveau page)
import { Suspense } from 'react';
import PostLoading from './loading';

export default function PostPage({ params }) {
  return (
    <Suspense fallback={<PostLoading />}>
      <PostContent slug={params.slug} />
    </Suspense>
  );
}

async function PostContent({ slug }) {
  const post = await getPost(slug);
  return <article>{/* Contenu du post */}</article>;
}
```

### error.tsx
Capture les erreurs dans le segment et ses enfants. Permet une récupération gracieuse.

```typescript
// app/dashboard/error.tsx
'use client';

import { useEffect } from 'react';

type DashboardErrorProps = {
  error: Error & { digest?: string };
  reset: () => void;
};

export default function DashboardError({
  error,
  reset,
}: DashboardErrorProps) {
  useEffect(() => {
    // Log l'erreur
    console.error('Dashboard Error:', error);
  }, [error]);

  return (
    <div className="p-6 bg-red-50 border border-red-200 rounded-lg">
      <h2 className="text-2xl font-bold text-red-900 mb-2">
        Une erreur s'est produite
      </h2>
      <p className="text-red-800 mb-4">
        {error.message || 'Une erreur inattendue s\'est produite'}
      </p>
      {error.digest && (
        <p className="text-sm text-red-600 mb-4">
          ID d'erreur: {error.digest}
        </p>
      )}
      <button
        onClick={() => reset()}
        className="px-4 py-2 bg-red-600 text-white rounded hover:bg-red-700 transition"
      >
        Réessayer
      </button>
    </div>
  );
}

// app/products/[id]/error.tsx
'use client';

import Link from 'next/link';

export default function ProductError({ error, reset }) {
  return (
    <div className="max-w-md mx-auto mt-8 p-6 bg-yellow-50 border border-yellow-200 rounded">
      <h2 className="text-xl font-bold text-yellow-900 mb-2">
        Impossible de charger ce produit
      </h2>
      <p className="text-yellow-800 mb-4">
        Le produit que vous cherchez n'existe pas ou est indisponible.
      </p>
      <div className="flex gap-2">
        <button
          onClick={() => reset()}
          className="px-4 py-2 bg-yellow-600 text-white rounded hover:bg-yellow-700"
        >
          Réessayer
        </button>
        <Link
          href="/products"
          className="px-4 py-2 border border-yellow-600 text-yellow-600 rounded hover:bg-yellow-50"
        >
          Retour aux produits
        </Link>
      </div>
    </div>
  );
}

// Exemple dans une async component
export default async function ProductPage({ params }) {
  try {
    const product = await getProduct(params.id);
    return <ProductDetail product={product} />;
  } catch (error) {
    throw error; // Capturé par error.tsx
  }
}
```

### not-found.tsx
Affiche une page 404 personnalisée pour le segment et ses enfants.

```typescript
// app/not-found.tsx - Global 404
import Link from 'next/link';

export default function NotFound() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50">
      <div className="text-center">
        <h1 className="text-6xl font-bold text-gray-900 mb-2">404</h1>
        <h2 className="text-2xl font-semibold text-gray-700 mb-4">
          Page non trouvée
        </h2>
        <p className="text-gray-600 mb-6">
          Désolé, la page que vous recherchez n'existe pas.
        </p>
        <Link
          href="/"
          className="inline-block px-6 py-3 bg-blue-600 text-white rounded hover:bg-blue-700 transition"
        >
          Retour à l'accueil
        </Link>
      </div>
    </div>
  );
}

// app/blog/[slug]/not-found.tsx - 404 pour articles
import Link from 'next/link';

export default function PostNotFound() {
  return (
    <div className="max-w-2xl mx-auto py-12">
      <div className="text-center">
        <h2 className="text-3xl font-bold text-gray-900 mb-2">
          Article non trouvé
        </h2>
        <p className="text-gray-600 mb-4">
          L'article que vous cherchez n'existe pas.
        </p>
        <Link
          href="/blog"
          className="text-blue-600 hover:underline"
        >
          ← Retour au blog
        </Link>
      </div>
    </div>
  );
}

// Utilisation dans une page
import { notFound } from 'next/navigation';

export default async function PostPage({ params }) {
  const post = await getPost(params.slug);

  if (!post) {
    notFound(); // Affiche not-found.tsx
  }

  return <article>{/* Contenu */}</article>;
}
```

## Structure Complète avec Tous les Fichiers Spéciaux

```typescript
// app/blog/layout.tsx
export default function BlogLayout({ children }) {
  return (
    <div className="blog-container">
      <nav className="blog-nav">
        {/* Navigation partagée */}
      </nav>
      {children}
    </div>
  );
}

// app/blog/page.tsx
import { Suspense } from 'react';
import BlogLoading from './loading';
import { getBlogPosts } from '@/lib/blog';

export const metadata = {
  title: 'Blog',
};

async function BlogContent() {
  const posts = await getBlogPosts();
  return (
    <div className="grid gap-6">
      {posts.map((post) => (
        <article key={post.id} className="p-4 border rounded">
          <h2>{post.title}</h2>
          <p>{post.excerpt}</p>
        </article>
      ))}
    </div>
  );
}

export default function BlogPage() {
  return (
    <Suspense fallback={<BlogLoading />}>
      <BlogContent />
    </Suspense>
  );
}

// app/blog/loading.tsx
export default function BlogLoading() {
  return (
    <div className="space-y-4">
      {[...Array(3)].map((_, i) => (
        <div key={i} className="h-32 bg-gray-200 rounded animate-pulse" />
      ))}
    </div>
  );
}

// app/blog/error.tsx
'use client';

export default function BlogError({ error, reset }) {
  return (
    <div className="p-6 bg-red-50 border border-red-200 rounded">
      <h2>Erreur du blog</h2>
      <button onClick={() => reset()}>Réessayer</button>
    </div>
  );
}

// app/blog/[slug]/page.tsx
import { notFound } from 'next/navigation';
import { getPost } from '@/lib/blog';

type PostPageProps = {
  params: {
    slug: string;
  };
};

export async function generateMetadata({ params }: PostPageProps) {
  const post = await getPost(params.slug);
  if (!post) return {};

  return {
    title: post.title,
    description: post.excerpt,
  };
}

export default async function PostPage({ params }: PostPageProps) {
  const post = await getPost(params.slug);

  if (!post) {
    notFound();
  }

  return (
    <article className="max-w-2xl">
      <h1>{post.title}</h1>
      <div dangerouslySetInnerHTML={{ __html: post.content }} />
    </article>
  );
}

// app/blog/[slug]/not-found.tsx
export default function PostNotFound() {
  return <h2>Article non trouvé</h2>;
}

// app/blog/[slug]/error.tsx
'use client';

export default function PostError({ error, reset }) {
  return (
    <div>
      <h2>Erreur lors du chargement de l'article</h2>
      <button onClick={() => reset()}>Réessayer</button>
    </div>
  );
}
```

## Hiérarchie et Imbrication des Fichiers Spéciaux

```
Request: /blog/nextjs-tutorial
             ↓
    app/blog/[slug]/page.tsx
             ↓
    Intercepte les erreurs → [slug]/error.tsx
             ↓
    Post non trouvé → [slug]/not-found.tsx
             ↓
    En cours de chargement → Montre loading.tsx
             ↓
    Affiche le contenu via [slug]/page.tsx
```

## Best Practices

### 1. Granularité des Erreurs
```typescript
// ✓ Bon: Erreurs spécifiques au segment
// app/dashboard/analytics/error.tsx
// app/dashboard/settings/error.tsx

// ✗ Mauvais: Une seule erreur générique
// app/error.tsx pour tout
```

### 2. Loading States Informatifs
```typescript
// ✓ Bon
export default function PostLoading() {
  return (
    <div className="animate-pulse">
      <div className="h-12 bg-gray-200 mb-4" />
      <div className="space-y-3">
        {[...Array(5)].map((_, i) => (
          <div key={i} className="h-4 bg-gray-200" />
        ))}
      </div>
    </div>
  );
}

// ✗ Mauvais: Skeleton trop simple
export default function PostLoading() {
  return <div>Chargement...</div>;
}
```

### 3. Gestion des Paramètres
```typescript
// ✓ Bon: Validation complète
async function PageComponent({
  params,
  searchParams,
}: {
  params: { id: string };
  searchParams: { page?: string; filter?: string };
}) {
  const id = params.id;
  const page = parseInt(searchParams.page ?? '1');
  const filter = searchParams.filter ?? 'all';

  // Validation
  if (!id || isNaN(page) || page < 1) {
    notFound();
  }

  // Logique
}
```

## Use Cases Courants

### Blog Complet
```typescript
// app/blog/page.tsx - Liste des articles
// app/blog/loading.tsx - Skeleton liste
// app/blog/error.tsx - Erreur lors du chargement
// app/blog/[slug]/page.tsx - Détail d'un article
// app/blog/[slug]/loading.tsx - Skeleton article
// app/blog/[slug]/not-found.tsx - Article inexistant
```

### E-commerce
```typescript
// app/products/page.tsx - Liste produits
// app/products/loading.tsx
// app/products/[id]/page.tsx - Détail produit
// app/products/[id]/not-found.tsx
// app/checkout/page.tsx - Paiement
// app/checkout/error.tsx - Erreur paiement
```

## Points Clés

- **page.tsx**: Rend la route publique
- **layout.tsx**: Partage UI entre segments
- **loading.tsx**: Placeholder pendant le chargement
- **error.tsx**: Gère les erreurs du segment
- **not-found.tsx**: Page 404 personnalisée
- **Imbrication**: Chaque fichier spécial s'applique au segment et ses enfants
- **Ordre d'exécution**: loading → page → error → not-found
