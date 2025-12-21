---
name: nextjs:revalidation
description: Master revalidatePath, revalidateTag, and on-demand revalidation for cache invalidation
---

# Revalidation du Cache: revalidatePath et revalidateTag

## Concept

La revalidation est le processus d'invalidation du cache Next.js après une mutation de données. Au lieu de faire en sorte que le contenu devienne obsolète, la revalidation permet de régénérer le contenu statique à la demande (ISR - Incremental Static Regeneration). Next.js offre deux stratégies principales: `revalidatePath` pour invalider une route spécifique et `revalidateTag` pour invalider le contenu basé sur des tags.

## revalidatePath

### Comportement Fondamental

```typescript
// app/actions.ts
'use server';

import { revalidatePath } from 'next/cache';
import { db } from '@/lib/db';

export async function createTask(title: string) {
  // Créer la tâche dans la base de données
  const task = await db.task.create({
    data: { title },
  });

  // Invalider le cache pour les pages qui affichent les tâches
  revalidatePath('/tasks');

  return task;
}

// app/page.tsx (page serveur)
import { db } from '@/lib/db';

export const revalidate = 60; // Revalider tous les 60 secondes (ISR)

export default async function TasksPage() {
  const tasks = await db.task.findMany();

  return (
    <div>
      <h1>Mes tâches</h1>
      <ul>
        {tasks.map((task) => (
          <li key={task.id}>{task.title}</li>
        ))}
      </ul>
    </div>
  );
}
```

### Revalidation par Segments de Route

```typescript
// app/actions.ts
'use server';

import { revalidatePath } from 'next/cache';
import { db } from '@/lib/db';

export async function updateBlogPost(id: string, data: any) {
  const post = await db.post.update({
    where: { id },
    data,
  });

  // Invalider la page du post
  revalidatePath(`/blog/${post.slug}`);

  // Invalider la liste des posts
  revalidatePath('/blog');

  // Invalider le layout du blog
  revalidatePath('/blog', 'layout');

  return post;
}

export async function deleteBlogPost(id: string) {
  const post = await db.post.findUnique({ where: { id } });

  await db.post.delete({ where: { id } });

  // Invalider toutes les routes blog
  revalidatePath('/blog', 'layout');

  return post;
}

// app/blog/layout.tsx
import { db } from '@/lib/db';

export const revalidate = 3600; // Cache pendant 1 heure

export default async function BlogLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const stats = await db.post.aggregate({
    _count: true,
  });

  return (
    <div>
      <div className="sidebar">
        <p>Total d'articles: {stats._count}</p>
      </div>
      {children}
    </div>
  );
}

// app/blog/[slug]/page.tsx
export const revalidate = 600; // Cache pendant 10 minutes

export default async function BlogPost({ params }: { params: { slug: string } }) {
  const post = await db.post.findUnique({
    where: { slug: params.slug },
  });

  return <article>{post?.content}</article>;
}
```

### Revalidation avec Patterns Complexes

```typescript
// app/actions.ts
'use server';

import { revalidatePath } from 'next/cache';
import { db } from '@/lib/db';

export async function updateUser(userId: string, data: any) {
  const user = await db.user.update({
    where: { id: userId },
    data,
  });

  // Invalider les pages utilisateur
  revalidatePath(`/users/${user.username}`);

  // Invalider le profil utilisateur
  revalidatePath(`/users/${user.username}/profile`);

  // Invalider les paramètres dynamiques
  revalidatePath(`/dashboard/[slug]`, 'page');

  return user;
}

export async function publishProduct(productId: string) {
  const product = await db.product.update({
    where: { id: productId },
    data: { published: true },
  });

  // Invalider le catalogue
  revalidatePath('/products');

  // Invalider la page du produit
  revalidatePath(`/products/${product.slug}`);

  // Invalider tous les chemins commençant par /admin
  revalidatePath('/admin', 'layout');

  return product;
}
```

## revalidateTag

### Stratégie Basée sur les Tags

`revalidateTag` offre une granularité plus fine en permettant d'invalider le cache basé sur des identifiants logiques plutôt que sur les chemins d'accès.

```typescript
// app/actions.ts
'use server';

import { revalidateTag } from 'next/cache';
import { db } from '@/lib/db';

export async function addCommentToPost(postId: string, content: string) {
  const comment = await db.comment.create({
    data: {
      content,
      postId,
    },
  });

  // Invalider le tag associé au post
  revalidateTag(`post-${postId}`);
  revalidateTag('all-posts');

  return comment;
}

export async function deleteComment(commentId: string) {
  const comment = await db.comment.findUnique({
    where: { id: commentId },
  });

  await db.comment.delete({ where: { id: commentId } });

  if (comment) {
    revalidateTag(`post-${comment.postId}`);
    revalidateTag('all-posts');
  }
}

// app/blog/[slug]/page.tsx
import { db } from '@/lib/db';

export const revalidate = 3600; // ISR avec 1 heure de cache

type BlogPostPageProps = {
  params: { slug: string };
};

export async function generateMetadata({ params }: BlogPostPageProps) {
  const post = await db.post.findUnique({
    where: { slug: params.slug },
  });

  return {
    title: post?.title,
    description: post?.excerpt,
  };
}

export default async function BlogPostPage({ params }: BlogPostPageProps) {
  // Utiliser fetch avec tags pour la revalidation
  const post = await fetch(`/api/posts/${params.slug}`, {
    next: { tags: [`post-${params.slug}`, 'all-posts'] },
  }).then((res) => res.json());

  // Ou utiliser des fonctions helper
  const post2 = await getPostWithTag(params.slug);

  return (
    <article>
      <h1>{post.title}</h1>
      <p>{post.content}</p>
      <Comments postId={post.id} />
    </article>
  );
}

// lib/db-helpers.ts
import { db } from '@/lib/db';
import { unstable_cache } from 'next/cache';

export const getPostWithTag = unstable_cache(
  async (slug: string) => {
    return db.post.findUnique({
      where: { slug },
      include: { comments: true },
    });
  },
  ['get-post-with-tag'],
  {
    tags: ['posts'],
    revalidate: 3600,
  }
);
```

### Utilisation avec Fetch

```typescript
// app/blog/page.tsx
import { db } from '@/lib/db';

export const revalidate = 600; // Cache 10 minutes

export default async function BlogPage() {
  // Fetch avec tags pour la revalidation
  const posts = await fetch('https://api.example.com/posts', {
    next: { tags: ['all-posts', 'blog-listing'] },
  }).then((res) => res.json());

  return (
    <div className="space-y-4">
      {posts.map((post: any) => (
        <article key={post.id} className="border p-4 rounded-lg">
          <h2 className="text-2xl font-bold">{post.title}</h2>
          <p className="text-gray-600">{post.excerpt}</p>
        </article>
      ))}
    </div>
  );
}

// app/actions.ts
'use server';

import { revalidateTag } from 'next/cache';

export async function publishNewPost(postData: any) {
  // Créer le post via l'API
  const response = await fetch('https://api.example.com/posts', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(postData),
  });

  const newPost = await response.json();

  // Invalider le cache pour tous les posts
  revalidateTag('all-posts');
  revalidateTag('blog-listing');

  return newPost;
}
```

## Patterns Avancés

### Revalidation Basée sur les Dépendances

```typescript
// lib/cache.ts
import { unstable_cache } from 'next/cache';
import { db } from '@/lib/db';

export const getPosts = unstable_cache(
  async () => {
    return db.post.findMany({
      orderBy: { createdAt: 'desc' },
      include: { author: true, comments: true },
    });
  },
  ['posts-list'],
  {
    tags: ['posts', 'posts-list'],
    revalidate: 3600,
  }
);

export const getPostById = unstable_cache(
  async (id: string) => {
    return db.post.findUnique({
      where: { id },
      include: { author: true, comments: true },
    });
  },
  ['post-detail'],
  {
    tags: (id) => ['post', `post-${id}`, 'posts'],
    revalidate: 1800,
  }
);

// app/actions.ts
'use server';

import { revalidateTag } from 'next/cache';

export async function updatePost(id: string, data: any) {
  const post = await db.post.update({
    where: { id },
    data,
  });

  // Invalider tous les tags associés
  revalidateTag('posts');
  revalidateTag('posts-list');
  revalidateTag(`post-${id}`);

  return post;
}
```

### Revalidation On-Demand

```typescript
// app/api/revalidate/route.ts
import { revalidatePath, revalidateTag } from 'next/cache';
import { NextRequest, NextResponse } from 'next/server';

const REVALIDATION_SECRET = process.env.REVALIDATION_SECRET;

export async function POST(request: NextRequest) {
  const secret = request.headers.get('authorization')?.replace('Bearer ', '');

  if (secret !== REVALIDATION_SECRET) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  const { type, path, tags } = await request.json();

  try {
    if (type === 'path' && path) {
      revalidatePath(path);
      return NextResponse.json({
        revalidated: true,
        message: `Path "${path}" revalidated`,
      });
    } else if (type === 'tag' && tags && Array.isArray(tags)) {
      tags.forEach((tag) => revalidateTag(tag));
      return NextResponse.json({
        revalidated: true,
        message: `Tags "${tags.join(', ')}" revalidated`,
      });
    }

    return NextResponse.json({ error: 'Invalid request' }, { status: 400 });
  } catch (err) {
    return NextResponse.json({ error: 'Revalidation failed' }, { status: 500 });
  }
}

// Utilisation
// curl -X POST http://localhost:3000/api/revalidate \
//   -H "Authorization: Bearer your-secret-key" \
//   -H "Content-Type: application/json" \
//   -d '{"type": "path", "path": "/blog"}'

// curl -X POST http://localhost:3000/api/revalidate \
//   -H "Authorization: Bearer your-secret-key" \
//   -H "Content-Type: application/json" \
//   -d '{"type": "tag", "tags": ["posts", "blog-listing"]}'
```

### Webhooks de Revalidation

```typescript
// app/api/webhooks/sanity.ts
import { revalidateTag } from 'next/cache';
import { NextRequest, NextResponse } from 'next/server';

// Webhooks Sanity CMS
export async function POST(request: NextRequest) {
  const body = await request.json();

  // Valider la signature Sanity
  const isValid = await verifySanitySignature(request, body);
  if (!isValid) {
    return NextResponse.json({ error: 'Invalid signature' }, { status: 401 });
  }

  // Revalidater basé sur le type de document modifié
  if (body._type === 'post') {
    revalidateTag('posts');
    revalidateTag(`post-${body._id}`);
    revalidateTag('blog-listing');
  }

  if (body._type === 'author') {
    revalidateTag(`author-${body._id}`);
    revalidateTag('posts');
  }

  return NextResponse.json({ revalidated: true });
}

async function verifySanitySignature(request: NextRequest, body: any) {
  // Implémentation de la vérification de signature Sanity
  return true;
}
```

### Revalidation avec Délai

```typescript
// app/actions.ts
'use server';

import { revalidatePath, revalidateTag } from 'next/cache';
import { db } from '@/lib/db';

export async function schedulePostPublication(
  postId: string,
  publishDate: Date
) {
  const now = new Date();
  const delay = publishDate.getTime() - now.getTime();

  // Mettre à jour le post pour le marquer comme programmé
  const post = await db.post.update({
    where: { id: postId },
    data: {
      publishedAt: publishDate,
      status: 'scheduled',
    },
  });

  // Programmer la revalidation pour la date de publication
  if (delay > 0) {
    setTimeout(() => {
      revalidatePath(`/blog/${post.slug}`);
      revalidatePath('/blog');
      revalidateTag('posts');
      revalidateTag(`post-${postId}`);
    }, delay);
  }

  return post;
}

// Ou utiliser une tâche en arrière-plan (Bull, RabbitMQ, etc.)
export async function schedulePostPublicationWithQueue(
  postId: string,
  publishDate: Date
) {
  const post = await db.post.update({
    where: { id: postId },
    data: { publishedAt: publishDate, status: 'scheduled' },
  });

  // Ajouter une tâche à la queue
  await queue.add('revalidate-post', {
    postId,
    slug: post.slug,
    publishDate,
  });

  return post;
}
```

## Stratégies de Caching Hybrides

### ISR avec Fallback

```typescript
// app/products/[slug]/page.tsx
import { db } from '@/lib/db';
import { notFound } from 'next/navigation';

export const revalidate = 3600; // Cache 1 heure

type ProductPageProps = {
  params: { slug: string };
};

export async function generateStaticParams() {
  // Générer les routes pour les produits populaires
  const products = await db.product.findMany({
    where: { featured: true },
    select: { slug: true },
  });

  return products.map((p) => ({
    slug: p.slug,
  }));
}

export default async function ProductPage({ params }: ProductPageProps) {
  const product = await db.product.findUnique({
    where: { slug: params.slug },
  });

  if (!product) {
    notFound();
  }

  return (
    <div>
      <h1>{product.name}</h1>
      <p>{product.description}</p>
      <span className="text-2xl font-bold">{product.price}€</span>
    </div>
  );
}

// app/actions.ts
'use server';

import { revalidatePath, revalidateTag } from 'next/cache';

export async function updateProduct(slug: string, data: any) {
  const product = await db.product.update({
    where: { slug },
    data,
  });

  // Revalidater la page du produit
  revalidatePath(`/products/${slug}`);

  // Revalidater la liste des produits
  revalidatePath('/products');

  // Revalidater le layout products
  revalidatePath('/products', 'layout');

  // Revalidater avec tags
  revalidateTag(`product-${product.id}`);
  revalidateTag('products');

  return product;
}
```

### Stale-While-Revalidate

```typescript
// lib/cache-strategies.ts
import { unstable_cache } from 'next/cache';
import { db } from '@/lib/db';

// Cache 30 jours, mais revalidate en arrière-plan après 1 jour
export const getCachedUser = unstable_cache(
  async (userId: string) => {
    return db.user.findUnique({
      where: { id: userId },
    });
  },
  ['user-cache'],
  {
    revalidate: 86400, // 1 jour
    tags: ['users'],
  }
);

// Validation rapide, revalidation agressif
export const getLiveData = unstable_cache(
  async () => {
    return fetch('https://api.example.com/live-data').then((r) => r.json());
  },
  ['live-data'],
  {
    revalidate: 60, // 1 minute
    tags: ['live'],
  }
);
```

## Best Practices

### 1. Granularité des Tags

```typescript
// BON: Tags spécifiques
revalidateTag(`post-${postId}`);
revalidateTag(`author-${authorId}`);
revalidateTag('posts-list');

// MAUVAIS: Tags trop généraux
revalidateTag('data');
revalidateTag('cache');
```

### 2. Combiner Paths et Tags

```typescript
// app/actions.ts
'use server';

export async function updatePost(postId: string, data: any) {
  const post = await db.post.update({
    where: { id: postId },
    data,
  });

  // Utiliser revalidatePath pour les routes statiques
  revalidatePath(`/blog/${post.slug}`);

  // Utiliser revalidateTag pour les dépendances complexes
  revalidateTag(`post-${postId}`);
  revalidateTag('posts');
}
```

### 3. Monitoring et Logging

```typescript
// lib/revalidate-logger.ts
import { revalidatePath, revalidateTag } from 'next/cache';
import { logger } from '@/lib/logger';

export async function revalidateWithLogging(
  type: 'path' | 'tag',
  value: string
) {
  const startTime = Date.now();

  try {
    if (type === 'path') {
      revalidatePath(value);
    } else {
      revalidateTag(value);
    }

    logger.info(`Revalidation successful`, {
      type,
      value,
      duration: Date.now() - startTime,
    });
  } catch (error) {
    logger.error(`Revalidation failed`, {
      type,
      value,
      error: error instanceof Error ? error.message : 'Unknown error',
    });
    throw error;
  }
}
```

## Points Clés

- **revalidatePath**: Invalide le cache pour une route spécifique
- **revalidateTag**: Invalide le cache basé sur des identifiants logiques
- **ISR**: Revalidation incrémentale des pages statiques générées
- **Granularité**: Utiliser des tags spécifiques pour un contrôle fin
- **Webhooks**: Intégrer des revalidations déclenchées par des événements externes
- **Performance**: Revalider intelligemment pour éviter les requêtes inutiles
