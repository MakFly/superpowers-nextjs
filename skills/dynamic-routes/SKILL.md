---
name: nextjs:dynamic-routes
description: Implement dynamic routes with [param], [...catchAll], and [[...optionalCatchAll]] patterns
---

# Routes Dynamiques

## Concept

Les routes dynamiques permettent de créer des segments basés sur les données plutôt que sur des chemins fixes. Next.js App Router fournit trois patterns pour créer des routes dynamiques avec des segments variables.

## Types de Segments Dynamiques

### 1. Segment Dynamique: [param]

Capture un seul segment d'URL et le passe comme paramètre au composant.

```typescript
// Structure
app/users/[id]/page.tsx  →  /users/123, /users/456, etc.
app/posts/[slug]/page.tsx  →  /posts/hello-world, /posts/nextjs-guide, etc.

// Accès aux paramètres
type PageProps = {
  params: {
    id: string;
  };
};

export default function UserPage({ params }: PageProps) {
  return <h1>Utilisateur {params.id}</h1>;
}
```

#### Exemple Complet: Blog avec Articles Dynamiques

```typescript
// app/blog/[slug]/page.tsx
import { notFound } from 'next/navigation';
import { getPost, getAllPosts } from '@/lib/blog';
import Link from 'next/link';
import { format } from 'date-fns';

type BlogPostPageProps = {
  params: {
    slug: string;
  };
};

// Génère les routes statiques au build time
export async function generateStaticParams() {
  const posts = await getAllPosts();
  return posts.map((post) => ({
    slug: post.slug,
  }));
}

// Génère la métadonnée pour chaque article
export async function generateMetadata({ params }: BlogPostPageProps) {
  const post = await getPost(params.slug);

  if (!post) {
    return {
      title: 'Article non trouvé',
    };
  }

  return {
    title: post.title,
    description: post.excerpt,
    openGraph: {
      title: post.title,
      description: post.excerpt,
      type: 'article',
      publishedTime: post.publishedAt,
      authors: [post.author],
      images: [post.image],
    },
    twitter: {
      card: 'summary_large_image',
      title: post.title,
      description: post.excerpt,
      images: [post.image],
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
    <article className="max-w-2xl mx-auto py-12 px-4">
      {/* Header */}
      <header className="mb-8">
        <h1 className="text-4xl font-bold mb-4">{post.title}</h1>

        <div className="flex items-center gap-4 text-gray-600">
          <img
            src={post.author.image}
            alt={post.author.name}
            className="w-12 h-12 rounded-full"
          />
          <div>
            <p className="font-semibold text-gray-900">{post.author.name}</p>
            <p className="text-sm">
              {format(new Date(post.publishedAt), 'd MMMM yyyy')}
            </p>
          </div>
          <span className="ml-auto text-sm bg-blue-100 text-blue-800 px-3 py-1 rounded">
            {post.readingTime} min de lecture
          </span>
        </div>

        {post.image && (
          <img
            src={post.image}
            alt={post.title}
            className="w-full h-96 object-cover rounded-lg mt-6"
          />
        )}
      </header>

      {/* Contenu */}
      <div className="prose prose-lg max-w-none mb-8">
        <div dangerouslySetInnerHTML={{ __html: post.content }} />
      </div>

      {/* Tags */}
      {post.tags && post.tags.length > 0 && (
        <div className="flex gap-2 my-8 pb-8 border-b">
          {post.tags.map((tag) => (
            <Link
              key={tag}
              href={`/blog?tag=${tag}`}
              className="px-3 py-1 bg-gray-200 text-gray-800 rounded hover:bg-gray-300 transition"
            >
              #{tag}
            </Link>
          ))}
        </div>
      )}

      {/* Navigation Articles */}
      {(post.previous || post.next) && (
        <nav className="flex justify-between items-center gap-4 py-8">
          {post.previous ? (
            <Link
              href={`/blog/${post.previous.slug}`}
              className="flex-1 p-4 border rounded-lg hover:shadow-lg transition group"
            >
              <p className="text-sm text-gray-600 mb-1">← Article précédent</p>
              <h3 className="font-semibold group-hover:text-blue-600">
                {post.previous.title}
              </h3>
            </Link>
          ) : (
            <div />
          )}

          {post.next && (
            <Link
              href={`/blog/${post.next.slug}`}
              className="flex-1 p-4 border rounded-lg hover:shadow-lg transition group text-right"
            >
              <p className="text-sm text-gray-600 mb-1">Article suivant →</p>
              <h3 className="font-semibold group-hover:text-blue-600">
                {post.next.title}
              </h3>
            </Link>
          )}
        </nav>
      )}

      {/* Commentaires */}
      <section className="mt-12 pt-8 border-t">
        <h2 className="text-2xl font-bold mb-6">Commentaires</h2>
        <CommentSection postId={post.id} />
      </section>
    </article>
  );
}
```

### 2. Route Catch-All: [...slug]

Capture tous les segments restants et les passe comme array.

```typescript
// Structure
app/docs/[...slug]/page.tsx
// Routes:
// /docs
// /docs/guide
// /docs/guide/installation
// /docs/guide/installation/npm
// /docs/guide/installation/npm/options

// Accès aux paramètres
type PageProps = {
  params: {
    slug: string[];  // Array de segments
  };
};

export default function DocsPage({ params }: PageProps) {
  const path = params.slug.join(' / ');
  return <h1>Documentation: {path}</h1>;
}
```

#### Exemple Complet: Système de Documentation

```typescript
// app/docs/[...slug]/page.tsx
import { notFound } from 'next/navigation';
import { getDocPage, getAllDocPages, getTableOfContents } from '@/lib/docs';
import Link from 'next/link';
import { Breadcrumb } from '@/components/Breadcrumb';
import { TableOfContents } from '@/components/TableOfContents';
import { EditOnGithub } from '@/components/EditOnGithub';

type DocsPageProps = {
  params: {
    slug: string[];
  };
};

export async function generateStaticParams() {
  const pages = await getAllDocPages();
  return pages.map((page) => ({
    slug: page.path.split('/'),
  }));
}

export async function generateMetadata({ params }: DocsPageProps) {
  const path = params.slug.join('/');
  const page = await getDocPage(path);

  if (!page) {
    return {
      title: 'Page non trouvée - Documentation',
    };
  }

  return {
    title: `${page.title} - Documentation`,
    description: page.description,
    openGraph: {
      title: page.title,
      description: page.description,
      type: 'website',
    },
  };
}

export default async function DocsPage({
  params,
}: DocsPageProps) {
  const path = params.slug.join('/');
  const page = await getDocPage(path);
  const toc = await getTableOfContents(path);

  if (!page) {
    notFound();
  }

  return (
    <div className="grid grid-cols-1 lg:grid-cols-4 gap-8 max-w-6xl mx-auto">
      {/* Sidebar - Table des matières globale */}
      <aside className="hidden lg:block">
        <nav className="sticky top-4 space-y-2">
          <DocsNav currentPath={path} />
        </nav>
      </aside>

      {/* Contenu principal */}
      <main className="lg:col-span-2">
        {/* Breadcrumb */}
        <Breadcrumb
          segments={params.slug.map((seg, i) => ({
            label: seg,
            href: `/docs/${params.slug.slice(0, i + 1).join('/')}`,
          }))}
        />

        {/* Titre et description */}
        <article>
          <h1 className="text-4xl font-bold mb-4">{page.title}</h1>
          <p className="text-gray-600 text-lg mb-8">{page.description}</p>

          {/* Contenu */}
          <div className="prose prose-lg max-w-none mb-12">
            <div dangerouslySetInnerHTML={{ __html: page.content }} />
          </div>

          {/* Navigation entre pages */}
          <div className="border-t pt-8 flex justify-between">
            {page.previous && (
              <Link
                href={`/docs/${page.previous.path}`}
                className="flex-1 p-4 mr-4 border rounded hover:shadow-lg transition"
              >
                <p className="text-sm text-gray-600">← Précédent</p>
                <p className="font-semibold">{page.previous.title}</p>
              </Link>
            )}
            {page.next && (
              <Link
                href={`/docs/${page.next.path}`}
                className="flex-1 p-4 border rounded hover:shadow-lg transition text-right"
              >
                <p className="text-sm text-gray-600">Suivant →</p>
                <p className="font-semibold">{page.next.title}</p>
              </Link>
            )}
          </div>

          {/* Lien Éditer */}
          <EditOnGithub path={page.githubPath} />
        </article>
      </main>

      {/* Sidebar droite - Sommaire de la page */}
      <aside className="hidden lg:block">
        <div className="sticky top-4">
          <h3 className="font-bold mb-4">Sur cette page</h3>
          <ul className="space-y-2 text-sm">
            {toc.map((heading) => (
              <li
                key={heading.id}
                style={{ paddingLeft: `${(heading.level - 2) * 1}rem` }}
              >
                <a
                  href={`#${heading.id}`}
                  className="text-gray-600 hover:text-gray-900 transition"
                >
                  {heading.text}
                </a>
              </li>
            ))}
          </ul>
        </div>
      </aside>
    </div>
  );
}

// app/docs/layout.tsx
import { Navbar } from '@/components/Navbar';
import { Footer } from '@/components/Footer';

export default function DocsLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="min-h-screen flex flex-col">
      <Navbar />
      <div className="flex-1 py-12 px-4 bg-white">
        {children}
      </div>
      <Footer />
    </div>
  );
}

// lib/docs.ts
type DocPage = {
  path: string;
  title: string;
  description: string;
  content: string;
  githubPath: string;
  previous?: { title: string; path: string };
  next?: { title: string; path: string };
};

export async function getDocPage(path: string): Promise<DocPage | null> {
  // Implémentation: charger depuis fichiers ou base de données
  // Exemple avec fichiers MDX
  try {
    const doc = await import(`@/docs/${path}.mdx`);
    return {
      path,
      title: doc.metadata.title,
      description: doc.metadata.description,
      content: doc.default,
      githubPath: `docs/${path}.mdx`,
      previous: doc.metadata.previous,
      next: doc.metadata.next,
    };
  } catch {
    return null;
  }
}

export async function getAllDocPages(): Promise<Array<{ path: string }>> {
  // Retourner toutes les pages disponibles
  return [
    { path: 'getting-started' },
    { path: 'getting-started/installation' },
    { path: 'getting-started/first-app' },
    { path: 'guide/styling' },
    { path: 'guide/data-fetching' },
    // ...
  ];
}

export async function getTableOfContents(path: string) {
  // Extraire les headings du contenu
  return [
    { level: 2, text: 'Installation', id: 'installation' },
    { level: 3, text: 'NPM', id: 'npm' },
    { level: 3, text: 'Yarn', id: 'yarn' },
  ];
}
```

### 3. Route Catch-All Optionnelle: [[...slug]]

Capture tous les segments (y compris aucun) et les passe comme array.

```typescript
// Structure
app/shop/[[...slug]]/page.tsx
// Routes:
// /shop               (slug = [])
// /shop/category
// /shop/category/subcategory
// /shop/category/subcategory/product

// Accès aux paramètres
type PageProps = {
  params: {
    slug?: string[];  // Array optionnel
  };
};

export default function ShopPage({ params }: PageProps) {
  if (!params.slug || params.slug.length === 0) {
    return <h1>Tous les produits</h1>;
  }

  const [category, ...rest] = params.slug;
  return (
    <div>
      <h1>Catégorie: {category}</h1>
      {rest.length > 0 && <p>Sous-catégories: {rest.join(', ')}</p>}
    </div>
  );
}
```

#### Exemple Complet: E-commerce avec Catégories

```typescript
// app/shop/[[...slug]]/page.tsx
import { notFound } from 'next/navigation';
import {
  getCategory,
  getAllCategories,
  getProduct,
  filterProducts,
} from '@/lib/shop';
import ProductGrid from '@/components/ProductGrid';
import CategoryFilter from '@/components/CategoryFilter';
import Breadcrumb from '@/components/Breadcrumb';

type ShopPageProps = {
  params: {
    slug?: string[];
  };
  searchParams: {
    sort?: string;
    price?: string;
    inStock?: string;
  };
};

export async function generateStaticParams() {
  const categories = await getAllCategories();

  const params = [
    { slug: undefined }, // /shop
    ...categories.map((cat) => ({
      slug: [cat.slug],
    })),
    // Pour sous-catégories
    ...categories.flatMap((cat) =>
      (cat.subcategories || []).map((subcat) => ({
        slug: [cat.slug, subcat.slug],
      }))
    ),
  ];

  return params;
}

export async function generateMetadata({ params }: ShopPageProps) {
  if (!params.slug) {
    return {
      title: 'Boutique - Tous les produits',
      description: 'Découvrez notre collection complète',
    };
  }

  const category = await getCategory(params.slug[0]);

  if (!category) {
    return {
      title: 'Catégorie non trouvée',
    };
  }

  return {
    title: `${category.name} - Boutique`,
    description: category.description,
  };
}

export default async function ShopPage({
  params,
  searchParams,
}: ShopPageProps) {
  const filters = {
    sort: searchParams.sort || 'newest',
    price: searchParams.price,
    inStock: searchParams.inStock === 'true',
  };

  // Page principale (aucun slug)
  if (!params.slug || params.slug.length === 0) {
    const products = await filterProducts({
      ...filters,
    });

    return (
      <div className="max-w-7xl mx-auto px-4 py-12">
        <h1 className="text-4xl font-bold mb-2">Tous les produits</h1>
        <p className="text-gray-600 mb-8">
          Découvrez notre collection complète de {products.length} produits
        </p>

        <div className="grid grid-cols-1 lg:grid-cols-5 gap-8">
          <aside className="lg:col-span-1">
            <CategoryFilter />
          </aside>

          <div className="lg:col-span-4">
            <ProductGrid products={products} />
          </div>
        </div>
      </div>
    );
  }

  // Catégorie ou sous-catégorie
  const [categorySlug, subcategorySlug] = params.slug;
  const category = await getCategory(categorySlug);

  if (!category) {
    notFound();
  }

  const products = await filterProducts({
    category: categorySlug,
    subcategory: subcategorySlug,
    ...filters,
  });

  return (
    <div className="max-w-7xl mx-auto px-4 py-12">
      {/* Breadcrumb */}
      <Breadcrumb
        segments={[
          { label: 'Boutique', href: '/shop' },
          { label: category.name, href: `/shop/${categorySlug}` },
          ...(subcategorySlug
            ? [
                {
                  label: category.subcategories?.find(
                    (s) => s.slug === subcategorySlug
                  )?.name || '',
                  href: `/shop/${categorySlug}/${subcategorySlug}`,
                },
              ]
            : []),
        ]}
      />

      {/* Header */}
      <h1 className="text-4xl font-bold mb-2 mt-6">{category.name}</h1>
      {category.description && (
        <p className="text-gray-600 mb-8">{category.description}</p>
      )}

      {/* Contenu */}
      <div className="grid grid-cols-1 lg:grid-cols-5 gap-8">
        <aside className="lg:col-span-1">
          <CategoryFilter active={categorySlug} />
        </aside>

        <div className="lg:col-span-4">
          {products.length > 0 ? (
            <ProductGrid products={products} />
          ) : (
            <div className="text-center py-12">
              <p className="text-gray-600 text-lg">
                Aucun produit trouvé dans cette catégorie
              </p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
```

## Comparaison des Trois Patterns

| Pattern | Exemple | Capture | Cas d'Usage |
|---------|---------|---------|------------|
| `[param]` | `/blog/[slug]` | Un segment | Article unique, profil utilisateur |
| `[...slug]` | `/docs/[...slug]` | Tous les segments | Documentation multi-niveaux |
| `[[...slug]]` | `/shop/[[...slug]]` | 0 ou plus | Pages avec filtres optionnels |

## generateStaticParams

Génère les paramètres statiquement au build time pour éviter les routes 404 en production.

```typescript
// app/products/[id]/page.tsx
export async function generateStaticParams() {
  const products = await getAllProducts();

  return products.map((product) => ({
    id: product.id.toString(),
  }));
}

export default async function ProductPage({
  params,
}: {
  params: { id: string };
}) {
  const product = await getProduct(params.id);

  if (!product) {
    notFound();
  }

  return <ProductDetail product={product} />;
}

// app/docs/[...slug]/page.tsx
export async function generateStaticParams() {
  const pages = await getAllDocPages();

  return pages.map((page) => ({
    slug: page.path.split('/'),
  }));
}
```

## Best Practices

### 1. Validation des Paramètres
```typescript
// ✓ Bon
export default async function UserPage({
  params: { id },
}: {
  params: { id: string };
}) {
  // Valider l'ID
  if (!id || !/^\d+$/.test(id)) {
    notFound();
  }

  const user = await getUser(parseInt(id));

  if (!user) {
    notFound();
  }

  return <UserDetail user={user} />;
}
```

### 2. Gestion des Segments Vides
```typescript
// ✓ Bon avec [[...slug]]
if (!params.slug || params.slug.length === 0) {
  // Page par défaut
  return <DefaultView />;
}

// Décomposer les segments
const [first, ...rest] = params.slug;
```

### 3. Métadonnées Dynamiques
```typescript
export async function generateMetadata({ params }: PageProps) {
  const item = await getItem(params.id);

  if (!item) {
    return { title: 'Non trouvé' };
  }

  return {
    title: item.title,
    description: item.description,
    openGraph: {
      title: item.title,
      images: [item.image],
    },
  };
}
```

## Points Clés

- **[param]**: Capture un seul segment
- **[...slug]**: Capture tous les segments
- **[[...slug]]**: Capture zéro ou plus segments
- **generateStaticParams()**: Pré-génère les routes au build
- **notFound()**: Affiche la page 404 personnalisée
- **Validation**: Toujours valider les paramètres reçus
