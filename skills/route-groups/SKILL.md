---
name: nextjs:route-groups
description: Organize routes with (group) folders for shared layouts and logical organization
---

# Route Groups

## Concept

Les Route Groups permettent d'organiser logiquement les routes sans affecter la structure d'URL. Un dossier nommé avec des parenthèses `(name)` ne crée pas de segment dans l'URL, mais permet de partager des layouts et d'organiser le code.

## Syntaxe et Comportement

```
Structure de fichiers            URL résultante
app/(marketing)/page.tsx    →    /
app/(marketing)/about.tsx   →    /about
app/(dashboard)/users.tsx   →    /users

// Les parenthèses ne sont pas dans l'URL
```

### URL vs Structure de Fichiers

```
app/
├── (marketing)/
│   ├── layout.tsx          # Layout unique pour (marketing)
│   ├── page.tsx            # /
│   ├── about/
│   │   └── page.tsx        # /about
│   └── contact/
│       └── page.tsx        # /contact
│
├── (dashboard)/
│   ├── layout.tsx          # Layout unique pour (dashboard)
│   ├── page.tsx            # /dashboard
│   ├── users/
│   │   └── page.tsx        # /dashboard/users
│   └── settings/
│       └── page.tsx        # /dashboard/settings
│
└── blog/
    └── page.tsx            # /blog
```

## Cas d'Usage Principal: Layouts Différents

### Exemple 1: Site Marketing + Dashboard

```typescript
// app/(marketing)/layout.tsx
import { MarketingHeader } from '@/components/MarketingHeader';
import { MarketingFooter } from '@/components/MarketingFooter';

export default function MarketingLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="min-h-screen flex flex-col">
      <MarketingHeader />
      <main className="flex-1">{children}</main>
      <MarketingFooter />
    </div>
  );
}

// app/(marketing)/page.tsx
export default function Home() {
  return (
    <div className="space-y-12">
      <Hero />
      <Features />
      <Pricing />
      <Testimonials />
      <CTA />
    </div>
  );
}

// app/(marketing)/about/page.tsx
export default function About() {
  return (
    <div className="max-w-4xl mx-auto py-12">
      <h1>À propos de nous</h1>
      {/* Contenu */}
    </div>
  );
}

// app/(dashboard)/layout.tsx
import { DashboardHeader } from '@/components/DashboardHeader';
import { DashboardSidebar } from '@/components/DashboardSidebar';
import { requireAuth } from '@/lib/auth';

export default async function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  // Vérifier l'authentification
  await requireAuth();

  return (
    <div className="flex h-screen">
      <DashboardSidebar />
      <div className="flex-1 flex flex-col">
        <DashboardHeader />
        <main className="flex-1 overflow-auto p-6">
          {children}
        </main>
      </div>
    </div>
  );
}

// app/(dashboard)/page.tsx
export default function DashboardHome() {
  return (
    <div>
      <h1 className="text-3xl font-bold mb-6">Tableau de Bord</h1>
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <StatCard title="Utilisateurs" value="1,234" />
        <StatCard title="Revenus" value="$12,345" />
        <StatCard title="Commandes" value="456" />
      </div>
    </div>
  );
}

// app/(dashboard)/users/page.tsx
export default function UsersPage() {
  return (
    <div>
      <h1 className="text-3xl font-bold mb-6">Gestion des Utilisateurs</h1>
      <UsersList />
    </div>
  );
}

// app/(dashboard)/settings/page.tsx
export default function SettingsPage() {
  return (
    <div>
      <h1 className="text-3xl font-bold mb-6">Paramètres</h1>
      <SettingsForm />
    </div>
  );
}

// app/blog/page.tsx
// N'est PAS dans un groupe, donc URL reste /blog
export default function Blog() {
  return <h1>Blog</h1>;
}
```

## Exemple 2: Site Multi-tenant avec Marques

```typescript
// Structure
app/
├── (brands)/
│   ├── [brand]/
│   │   ├── layout.tsx      # Branding spécifique
│   │   ├── page.tsx        # /:brand
│   │   ├── products/
│   │   │   └── page.tsx    # /:brand/products
│   │   └── about/
│   │       └── page.tsx    # /:brand/about
│   └── admin/
│       └── layout.tsx      # Layout admin
│       └── page.tsx        # /admin

// app/(brands)/[brand]/layout.tsx
import { getBrand } from '@/lib/brands';
import { notFound } from 'next/navigation';

type BrandLayoutProps = {
  children: React.ReactNode;
  params: { brand: string };
};

export async function generateStaticParams() {
  const brands = await getAllBrands();
  return brands.map((brand) => ({
    brand: brand.slug,
  }));
}

export default async function BrandLayout({
  children,
  params,
}: BrandLayoutProps) {
  const brand = await getBrand(params.brand);

  if (!brand) {
    notFound();
  }

  return (
    <div
      style={{
        '--primary-color': brand.primaryColor,
        '--secondary-color': brand.secondaryColor,
      } as React.CSSProperties}
    >
      <nav className="bg-[var(--primary-color)]">
        <img src={brand.logo} alt={brand.name} className="h-12" />
      </nav>
      <main>{children}</main>
      <footer className="bg-[var(--primary-color)]">
        <p>&copy; {brand.name}</p>
      </footer>
    </div>
  );
}

// app/(brands)/[brand]/page.tsx
type BrandPageProps = {
  params: { brand: string };
};

export default async function BrandPage({
  params,
}: BrandPageProps) {
  const brand = await getBrand(params.brand);

  return (
    <div className="max-w-6xl mx-auto py-12 px-4">
      <h1 className="text-4xl font-bold">{brand.name}</h1>
      <p className="text-gray-600 mt-2">{brand.description}</p>
      <div dangerouslySetInnerHTML={{ __html: brand.content }} />
    </div>
  );
}

// app/(brands)/[brand]/products/page.tsx
type ProductsPageProps = {
  params: { brand: string };
  searchParams: { sort?: string };
};

export default async function BrandProductsPage({
  params,
  searchParams,
}: ProductsPageProps) {
  const products = await getProductsByBrand(
    params.brand,
    searchParams.sort
  );

  return (
    <div className="max-w-6xl mx-auto py-12 px-4">
      <h1 className="text-3xl font-bold mb-8">Produits</h1>
      <ProductGrid products={products} />
    </div>
  );
}

// app/(brands)/admin/layout.tsx
import { requireAdminAuth } from '@/lib/auth';
import { AdminHeader } from '@/components/AdminHeader';
import { AdminSidebar } from '@/components/AdminSidebar';

export default async function AdminLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  await requireAdminAuth();

  return (
    <div className="flex h-screen bg-gray-100">
      <AdminSidebar />
      <div className="flex-1 flex flex-col">
        <AdminHeader />
        <main className="flex-1 overflow-auto p-6">
          {children}
        </main>
      </div>
    </div>
  );
}

// app/(brands)/admin/page.tsx
export default function AdminDashboard() {
  return (
    <div>
      <h1 className="text-3xl font-bold mb-6">Admin - Tableau de Bord</h1>
      <AdminStats />
    </div>
  );
}
```

## Exemple 3: Structure Marketing + API + Docs

```typescript
// Structure complète
app/
├── (marketing)/           # /
├── (docs)/               # /docs
├── (dashboard)/          # /dashboard
├── api/                  # /api
└── admin/                # /admin

// app/(marketing)/layout.tsx
export default function MarketingLayout({ children }) {
  return (
    <div>
      <PublicNav />
      {children}
      <PublicFooter />
    </div>
  );
}

// app/(marketing)/page.tsx → /
// app/(marketing)/features/page.tsx → /features
// app/(marketing)/pricing/page.tsx → /pricing

// app/(docs)/layout.tsx
export default function DocsLayout({ children }) {
  return (
    <div className="flex">
      <DocsSidebar />
      {children}
    </div>
  );
}

// app/(docs)/getting-started/page.tsx → /getting-started
// app/(docs)/api-reference/page.tsx → /api-reference

// app/(dashboard)/layout.tsx
export default function DashboardLayout({ children }) {
  return (
    <div className="flex">
      <DashboardSidebar />
      <DashboardContent>{children}</DashboardContent>
    </div>
  );
}

// app/(dashboard)/page.tsx → /dashboard
// app/(dashboard)/users/page.tsx → /dashboard/users
// app/(dashboard)/settings/page.tsx → /dashboard/settings

// app/api/users/route.ts → /api/users
// app/admin/page.tsx → /admin
```

## Combinaison avec les Segments Dynamiques

```typescript
// Structure
app/
├── (shop)/
│   ├── products/
│   │   ├── page.tsx               # /products
│   │   └── [id]/
│   │       └── page.tsx           # /products/[id]
│   ├── categories/
│   │   └── [slug]/
│   │       └── page.tsx           # /categories/[slug]
│   └── checkout/
│       └── page.tsx               # /checkout
│
└── (account)/
    ├── profile/
    │   └── page.tsx               # /profile
    ├── orders/
    │   └── page.tsx               # /orders
    └── settings/
        └── page.tsx               # /settings

// app/(shop)/layout.tsx
import { ShopNav } from '@/components/ShopNav';

export default function ShopLayout({ children }) {
  return (
    <div>
      <ShopNav />
      {children}
    </div>
  );
}

// app/(account)/layout.tsx
import { requireAuth } from '@/lib/auth';
import { AccountSidebar } from '@/components/AccountSidebar';

export default async function AccountLayout({ children }) {
  await requireAuth();

  return (
    <div className="flex gap-6">
      <AccountSidebar />
      <div className="flex-1">{children}</div>
    </div>
  );
}
```

## Multiple Groupes au Même Niveau

Les groupes au même niveau partagent le même layout parent, mais peuvent avoir leurs propres layouts.

```typescript
// Structure
app/
├── layout.tsx                   # Layout racine
├── (marketing)/
│   ├── layout.tsx               # Layout marketing
│   ├── page.tsx
│   └── about/page.tsx
│
├── (dashboard)/
│   ├── layout.tsx               # Layout dashboard
│   ├── page.tsx
│   └── users/page.tsx
│
└── (blog)/
    ├── layout.tsx               # Layout blog
    ├── page.tsx
    └── [slug]/page.tsx

// Tous partagent app/layout.tsx
// Mais ont leurs propres layouts internes
```

## Nommage et Conventions

```typescript
// ✓ Bons noms
(marketing)       // Site marketing
(dashboard)       // Dashboard utilisateur
(admin)           // Panel administrateur
(account)         // Compte utilisateur
(docs)            // Documentation
(api)             // API publique
(blog)            // Section blog
(shop)            // Boutique e-commerce

// ✗ Éviter
(main)            // Trop générique
(app)             // Redondant
(content)         // Trop vague
```

## Best Practices

### 1. Organisation Logique
```typescript
// ✓ Bon: Groupes pour séparations logiques claires
app/
├── (public)/      # Pages publiques
├── (auth)/        # Pages d'authentification
├── (dashboard)/   # Tableau de bord
└── api/           # API
```

### 2. Layouts au Bon Niveau
```typescript
// ✓ Bon
app/
├── (marketing)/
│   ├── layout.tsx    # Layout marketing unique
│   └── ...
└── (dashboard)/
    ├── layout.tsx    # Layout dashboard unique
    └── ...

// ✗ Mauvais
app/
├── layout.tsx        # Layout pour TOUT
├── (marketing)/...
└── (dashboard)/...
```

### 3. Partage de Composants
```typescript
// ✓ Bon: Composants partagés dans /components
app/
├── (marketing)/
├── (dashboard)/
└── components/       # Partagés par tous
    ├── Button.tsx
    ├── Card.tsx
    └── Layout.tsx
```

## Points Clés

- **(name)**: Les parenthèses ne créent pas de segment URL
- **Layouts**: Chaque groupe peut avoir son propre layout
- **Organisation**: Facilite la gestion de structures complexes
- **Flexibilité**: Permet des URLs différentes de la structure
- **Imbrication**: Les groupes peuvent être imbriqués
- **Métadonnées**: Chaque groupe peut gérer ses propres métadonnées

## Cas d'Usage Fréquents

| Cas | Structure | Bénéfice |
|-----|-----------|----------|
| Marketing + Dashboard | `(marketing)` + `(dashboard)` | Layouts totalement différents |
| Multi-tenant | `(brands)/[brand]` | Branding par tenant |
| Auth | `(auth)/login` + `(auth)/signup` | Logique commune |
| Docs | `(docs)/[...slug]` | Layout dédié |
| Admin | `(admin)` + `(dashboard)` | Séparation Admin/User |
