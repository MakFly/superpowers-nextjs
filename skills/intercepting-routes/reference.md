# Reference

# Intercepting Routes

## Concept

Les Intercepting Routes permettent d'afficher une route différente du contexte où elle est demandée, tout en maintenant la route dans l'URL. C'est utile pour afficher des modals, des panels latéraux ou des previews au lieu de naviguer vers une nouvelle page.

Quand l'utilisateur recharge la page, il voit le contenu d'origine (pas le modal intercepté).

## Syntaxe de Base

Les conventions de noms permettent de définir le chemin relatif:

| Convention | Sens |
|-----------|------|
| `(.)` | Intercept au même niveau |
| `(..)` | Intercept au niveau parent |
| `(..)(..)` | Intercept 2 niveaux au-dessus |
| `(...)` | Intercept à la racine |

### Exemple de Structures

```
// Structure pour /blog/[slug] (article)
// Quand on clique sur un lien vers /blog/123, afficher modal au lieu de naviguer

app/
├── blog/
│   ├── page.tsx              # /blog (liste)
│   ├── [slug]/
│   │   ├── page.tsx          # /blog/[slug] (page complète)
│   │   └── (.)modal/         # (.) = même niveau que [slug]
│   │       └── page.tsx      # Affiche le modal

// Quand on accède à /blog/123
// - Si on clique depuis /blog → Affiche modal (intercepté)
// - Si on recharge directement /blog/123 → Page complète
```

```
// Structure pour /gallery/photos/[id]
// Intercepter depuis /gallery/photos ou /gallery

app/
├── gallery/
│   ├── layout.tsx
│   ├── photos/
│   │   ├── page.tsx          # /gallery/photos
│   │   ├── [id]/
│   │   │   ├── page.tsx      # /gallery/photos/[id] (page complète)
│   │   │   └── (..)modal/    # (..) = remonte au niveau /gallery
│   │   │       └── page.tsx  # Affiche modal
│   │   └── (.)modal/         # (.) = au niveau /gallery/photos
│   │       └── page.tsx      # Autre modal
```

## Exemple 1: Blog avec Modal d'Article

```typescript
// app/blog/page.tsx - Liste des articles
import Link from 'next/link';
import { getAllPosts } from '@/lib/blog';

export default async function BlogPage() {
  const posts = await getAllPosts();

  return (
    <div className="max-w-4xl mx-auto py-12 px-4">
      <h1 className="text-4xl font-bold mb-8">Blog</h1>

      <div className="grid gap-6">
        {posts.map((post) => (
          <article
            key={post.slug}
            className="p-6 border rounded-lg hover:shadow-lg transition"
          >
            <Link href={`/blog/${post.slug}`}>
              <h2 className="text-2xl font-bold text-blue-600 hover:underline">
                {post.title}
              </h2>
            </Link>
            <p className="text-gray-600 mt-2">{post.excerpt}</p>
            <div className="flex gap-4 mt-4 text-sm text-gray-500">
              <span>{post.author}</span>
              <span>{post.date}</span>
            </div>
          </article>
        ))}
      </div>
    </div>
  );
}

// app/blog/[slug]/page.tsx - Page complète de l'article
import { getPost } from '@/lib/blog';
import { notFound } from 'next/navigation';

type BlogPostPageProps = {
  params: { slug: string };
};

export async function generateMetadata({ params }: BlogPostPageProps) {
  const post = await getPost(params.slug);
  return {
    title: post?.title,
    description: post?.excerpt,
  };
}

export default async function BlogPostPage({ params }: BlogPostPageProps) {
  const post = await getPost(params.slug);

  if (!post) {
    notFound();
  }

  return (
    <article className="max-w-2xl mx-auto py-12 px-4">
      <header className="mb-8">
        <h1 className="text-4xl font-bold mb-4">{post.title}</h1>
        <div className="flex gap-4 text-gray-600">
          <span>{post.author}</span>
          <span>{post.date}</span>
          <span className="bg-gray-200 px-2 py-1 rounded text-sm">
            {post.readingTime} min
          </span>
        </div>
      </header>

      <div className="prose prose-lg max-w-none">
        <div dangerouslySetInnerHTML={{ __html: post.content }} />
      </div>

      <div className="mt-12 pt-8 border-t">
        <h3 className="font-bold mb-4">Tags</h3>
        <div className="flex gap-2 flex-wrap">
          {post.tags.map((tag) => (
            <span
              key={tag}
              className="bg-blue-100 text-blue-800 px-3 py-1 rounded"
            >
              {tag}
            </span>
          ))}
        </div>
      </div>
    </article>
  );
}

// app/blog/[slug]/(.)modal/page.tsx
// (.) = même niveau que [slug], intercept depuis /blog
'use client';

import { useRouter } from 'next/navigation';
import { getPost } from '@/lib/blog';

type BlogModalPageProps = {
  params: { slug: string };
};

export default async function BlogModal({ params }: BlogModalPageProps) {
  const router = useRouter();
  const post = await getPost(params.slug);

  return (
    <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg shadow-xl max-w-2xl w-full mx-4 max-h-[90vh] overflow-auto">
        {/* Header du modal */}
        <div className="sticky top-0 bg-white border-b p-6 flex justify-between items-center">
          <h2 className="text-2xl font-bold">{post?.title}</h2>
          <button
            onClick={() => router.back()}
            className="text-2xl text-gray-400 hover:text-gray-600"
          >
            ✕
          </button>
        </div>

        {/* Contenu du modal */}
        <div className="p-6">
          <div className="flex gap-4 text-gray-600 mb-4 text-sm">
            <span>{post?.author}</span>
            <span>{post?.date}</span>
          </div>

          <div className="prose prose-sm max-w-none">
            <div dangerouslySetInnerHTML={{ __html: post?.excerpt }} />
          </div>

          <div className="mt-6">
            <button
              onClick={() => router.push(`/blog/${params.slug}`)}
              className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 transition"
            >
              Lire l'article complet
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
```

## Exemple 2: Galerie Photo avec Lightbox

```typescript
// Structure
app/
├── gallery/
│   ├── page.tsx                   # /gallery - liste photos
│   ├── photos/
│   │   ├── page.tsx               # /gallery/photos
│   │   ├── [id]/
│   │   │   ├── page.tsx           # /gallery/photos/[id] - page complète
│   │   │   └── (.)modal/
│   │   │       └── page.tsx       # Modal lightbox
│   │   └── (.)modal/
│   │       └── page.tsx           # Modal depuis /gallery/photos
│   └── (...)modal/
│       └── page.tsx               # Modal depuis n'importe où

// app/gallery/page.tsx
import Link from 'next/link';
import { getGalleryPhotos } from '@/lib/gallery';
import Image from 'next/image';

export default async function GalleryPage() {
  const photos = await getGalleryPhotos();

  return (
    <div className="max-w-6xl mx-auto py-12 px-4">
      <h1 className="text-4xl font-bold mb-8">Galerie</h1>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {photos.map((photo) => (
          <Link key={photo.id} href={`/gallery/photos/${photo.id}`}>
            <div className="relative aspect-square overflow-hidden rounded-lg hover:shadow-lg transition cursor-pointer">
              <Image
                src={photo.thumbnail}
                alt={photo.title}
                fill
                className="object-cover hover:scale-105 transition duration-300"
              />
              <div className="absolute inset-0 bg-black/0 hover:bg-black/40 transition flex items-center justify-center">
                <div className="text-white opacity-0 hover:opacity-100 transition">
                  <p className="font-semibold">{photo.title}</p>
                  <p className="text-sm">{photo.views} vues</p>
                </div>
              </div>
            </div>
          </Link>
        ))}
      </div>
    </div>
  );
}

// app/gallery/photos/[id]/page.tsx
// Page complète d'une photo
import { getPhoto } from '@/lib/gallery';
import { notFound } from 'next/navigation';
import Image from 'next/image';
import Link from 'next/link';

type PhotoPageProps = {
  params: { id: string };
};

export default async function PhotoPage({ params }: PhotoPageProps) {
  const photo = await getPhoto(params.id);

  if (!photo) {
    notFound();
  }

  return (
    <div className="max-w-4xl mx-auto py-12 px-4">
      <Link href="/gallery" className="text-blue-600 hover:underline mb-4 block">
        ← Retour à la galerie
      </Link>

      <div className="bg-white rounded-lg shadow-lg overflow-hidden">
        <div className="relative w-full aspect-video">
          <Image
            src={photo.url}
            alt={photo.title}
            fill
            className="object-contain"
          />
        </div>

        <div className="p-8">
          <h1 className="text-4xl font-bold mb-4">{photo.title}</h1>
          <p className="text-gray-600 mb-6">{photo.description}</p>

          <div className="grid grid-cols-3 gap-4 py-6 border-y">
            <div>
              <p className="text-gray-600">Photographe</p>
              <p className="font-semibold">{photo.photographer}</p>
            </div>
            <div>
              <p className="text-gray-600">Date</p>
              <p className="font-semibold">{photo.date}</p>
            </div>
            <div>
              <p className="text-gray-600">Vues</p>
              <p className="font-semibold">{photo.views}</p>
            </div>
          </div>

          <div className="mt-8">
            <h3 className="font-bold mb-4">Détails techniques</h3>
            <dl className="grid grid-cols-2 gap-4 text-sm">
              <div>
                <dt className="text-gray-600">Appareil</dt>
                <dd className="font-semibold">{photo.camera}</dd>
              </div>
              <div>
                <dt className="text-gray-600">Objectif</dt>
                <dd className="font-semibold">{photo.lens}</dd>
              </div>
              <div>
                <dt className="text-gray-600">Vitesse</dt>
                <dd className="font-semibold">{photo.shutter}</dd>
              </div>
              <div>
                <dt className="text-gray-600">Ouverture</dt>
                <dd className="font-semibold">{photo.aperture}</dd>
              </div>
            </dl>
          </div>
        </div>
      </div>
    </div>
  );
}

// app/gallery/photos/[id]/(.)modal/page.tsx
// Modal quand on clique depuis /gallery
'use client';

import { useRouter } from 'next/navigation';
import { getPhoto } from '@/lib/gallery';
import Image from 'next/image';

type PhotoModalProps = {
  params: { id: string };
};

export default async function PhotoModal({ params }: PhotoModalProps) {
  const router = useRouter();
  const photo = await getPhoto(params.id);

  return (
    <div className="fixed inset-0 bg-black flex items-center justify-center z-50">
      {/* Lightbox */}
      <div className="relative w-full h-full flex items-center justify-center">
        {/* Image */}
        <div className="relative w-[90vw] h-[90vh]">
          <Image
            src={photo?.url || ''}
            alt={photo?.title || ''}
            fill
            className="object-contain"
          />
        </div>

        {/* Overlay controls */}
        <div className="absolute inset-0 flex items-center justify-between px-4">
          {/* Prev button */}
          {photo?.previous && (
            <button
              onClick={() => router.push(`/gallery/photos/${photo.previous.id}`)}
              className="bg-white/20 hover:bg-white/40 text-white p-4 rounded-full transition"
              title="Photo précédente"
            >
              ‹
            </button>
          )}

          {/* Next button */}
          {photo?.next && (
            <button
              onClick={() => router.push(`/gallery/photos/${photo.next.id}`)}
              className="ml-auto bg-white/20 hover:bg-white/40 text-white p-4 rounded-full transition"
              title="Photo suivante"
            >
              ›
            </button>
          )}
        </div>

        {/* Info bottom */}
        <div className="absolute bottom-0 left-0 right-0 bg-black/50 text-white p-6">
          <h2 className="text-2xl font-bold">{photo?.title}</h2>
          <p className="text-gray-300">{photo?.photographer}</p>
        </div>

        {/* Close button */}
        <button
          onClick={() => router.back()}
          className="absolute top-4 right-4 bg-white/20 hover:bg-white/40 text-white p-2 rounded-full transition text-2xl"
        >
          ✕
        </button>
      </div>
    </div>
  );
}
```

## Exemple 3: E-commerce avec Modals Multiples

```typescript
// Structure
app/
├── products/
│   ├── page.tsx                    # /products
│   ├── [id]/
│   │   ├── page.tsx                # /products/[id]
│   │   └── (.)review-modal/
│   │       └── page.tsx            # Modal avis
│   │
│   └── (...)search/                # Modal de recherche (...)
│       └── page.tsx

// app/products/[id]/(.)review-modal/page.tsx
'use client';

import { useRouter } from 'next/navigation';
import { useState } from 'react';
import { submitReview } from '@/lib/reviews';

type ReviewModalProps = {
  params: { id: string };
};

export default function ReviewModal({ params }: ReviewModalProps) {
  const router = useRouter();
  const [rating, setRating] = useState(5);
  const [title, setTitle] = useState('');
  const [content, setContent] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);

    try {
      await submitReview({
        productId: params.id,
        rating,
        title,
        content,
      });

      router.back();
    } catch (error) {
      console.error(error);
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg shadow-xl max-w-md w-full mx-4">
        <div className="flex justify-between items-center p-6 border-b">
          <h2 className="text-xl font-bold">Écrire un avis</h2>
          <button
            onClick={() => router.back()}
            className="text-gray-400 hover:text-gray-600 text-2xl"
          >
            ✕
          </button>
        </div>

        <form onSubmit={handleSubmit} className="p-6 space-y-4">
          {/* Rating */}
          <div>
            <label className="block text-sm font-medium mb-2">Note</label>
            <div className="flex gap-2">
              {[1, 2, 3, 4, 5].map((star) => (
                <button
                  key={star}
                  type="button"
                  onClick={() => setRating(star)}
                  className={`text-2xl transition ${
                    star <= rating ? 'text-yellow-400' : 'text-gray-300'
                  }`}
                >
                  ★
                </button>
              ))}
            </div>
          </div>

          {/* Title */}
          <div>
            <label className="block text-sm font-medium mb-2">Titre</label>
            <input
              type="text"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder="Résumez votre expérience"
              className="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              required
            />
          </div>

          {/* Content */}
          <div>
            <label className="block text-sm font-medium mb-2">Avis</label>
            <textarea
              value={content}
              onChange={(e) => setContent(e.target.value)}
              placeholder="Décrivez votre expérience..."
              rows={4}
              className="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 resize-none"
              required
            />
          </div>

          {/* Buttons */}
          <div className="flex gap-3 pt-4">
            <button
              type="button"
              onClick={() => router.back()}
              className="flex-1 px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 transition"
            >
              Annuler
            </button>
            <button
              type="submit"
              disabled={isSubmitting}
              className="flex-1 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 transition"
            >
              {isSubmitting ? 'Envoi...' : 'Envoyer'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

// app/products/(...)search/page.tsx
// Modal de recherche global
'use client';

import { useRouter } from 'next/navigation';
import { useState } from 'react';
import { searchProducts } from '@/lib/products';

export default function SearchModal() {
  const router = useRouter();
  const [query, setQuery] = useState('');
  const [results, setResults] = useState<any[]>([]);

  const handleSearch = async (value: string) => {
    setQuery(value);
    if (value.length > 2) {
      const found = await searchProducts(value);
      setResults(found);
    }
  };

  return (
    <div className="fixed inset-0 bg-black/50 flex items-start justify-center pt-20 z-50">
      <div className="bg-white rounded-lg shadow-xl w-full max-w-2xl mx-4">
        {/* Search input */}
        <div className="p-4 border-b">
          <input
            autoFocus
            type="text"
            value={query}
            onChange={(e) => handleSearch(e.target.value)}
            placeholder="Chercher un produit..."
            className="w-full px-4 py-2 focus:outline-none text-lg"
          />
        </div>

        {/* Results */}
        <div className="max-h-96 overflow-auto">
          {results.length > 0 ? (
            <ul className="divide-y">
              {results.map((product) => (
                <li key={product.id}>
                  <button
                    onClick={() => {
                      router.back();
                      router.push(`/products/${product.id}`);
                    }}
                    className="w-full text-left p-4 hover:bg-gray-50 transition flex items-center gap-4"
                  >
                    <img
                      src={product.image}
                      alt={product.name}
                      className="w-12 h-12 object-cover rounded"
                    />
                    <div>
                      <p className="font-semibold">{product.name}</p>
                      <p className="text-sm text-gray-600">${product.price}</p>
                    </div>
                  </button>
                </li>
              ))}
            </ul>
          ) : query.length > 2 ? (
            <div className="p-8 text-center text-gray-500">
              Aucun résultat pour "{query}"
            </div>
          ) : (
            <div className="p-8 text-center text-gray-500">
              Commencez à taper pour chercher
            </div>
          )}
        </div>

        {/* Close on Escape */}
        <div className="p-4 border-t text-sm text-gray-600 text-center">
          Appuyez sur <kbd className="bg-gray-100 px-2 py-1 rounded">Esc</kbd> pour fermer
        </div>
      </div>
    </div>
  );
}
```

## Comportement au Rechargement

```typescript
// Quand on clique sur /blog/123 depuis /blog
// URL: /blog/123
// Affichage: Modal (intercepté)

// Si on recharge la page
// URL: /blog/123
// Affichage: Page complète (page.tsx, pas le modal)

// C'est le comportement clé des intercepting routes!
```

## Comparaison Conventions

```
app/
├── blog/
│   ├── [slug]/page.tsx                 # /blog/[slug] page complète
│   │
│   ├── [slug]/(.)modal/page.tsx        # (.) = même niveau
│   │                                   # Intercept depuis /blog
│   │
│   ├── [slug]/(..)modal/page.tsx       # (..) = parent
│   │                                   # Intercept depuis / ou /blog
│   │
│   ├── [slug]/(...modal)/page.tsx      # (...) = racine
│   │                                   # Intercept depuis n'importe où
│   │
│   └── [slug]/(..)(..)/modal/page.tsx  # (..)(..) = 2 niveaux
│                                       # Intercept depuis plus haut
```

## Best Practices

### 1. Modals vs Pages Complètes
```typescript
// ✓ Bon: Modal et page indépendants
/blog/123                   → Page complète
/blog/123 (depuis /blog)    → Modal (intercepté)

// ✗ Mauvais: Forcer le modal partout
// Les users ne peuvent pas voir la page complète
```

### 2. Contenu Approprié
```typescript
// ✓ Bon: Modal pour aperçu/actions rapides
export default function Modal() {
  return <PreviewContent />;  // Léger, rapide
}

// ✗ Mauvais: Modal pour contenu lourd
export default function Modal() {
  return <CompletePageContent />;  // Trop lourd
}
```

### 3. Gestion du Retour
```typescript
// ✓ Bon
const handleClose = () => {
  router.back();  // Retour logique
};

// ✗ Mauvais
const handleClose = () => {
  router.push('/blog');  // Perte du contexte
};
```

## Points Clés

- **Interception**: Affiche une route différente sans changer l'URL
- **(.)**: Même niveau
- **(..)**: Parent
- **(..)(..)**: 2 niveaux au-dessus
- **(...)**: Racine
- **Rechargement**: Affiche la page réelle, pas le modal intercepté
- **Flexibilité**: Permet préviews, modals, actions rapides
- **UX**: Meilleure expérience utilisateur avec contexte préservé
