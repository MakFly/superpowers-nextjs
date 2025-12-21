---
name: nextjs:parallel-routes
description: Create simultaneous rendering with @folder slots for complex dashboard layouts
---

# Parallel Routes (Slots)

## Concept

Les Parallel Routes permettent de rendre simultanément plusieurs segments indépendants dans la même mise en page. Cela est utile pour les dashboards complexes, les barres latérales dynamiques et les modaux, où différentes sections se mettent à jour indépendamment.

## Syntaxe

Les slots utilisent la convention `@slotName` pour nommer les dossiers:

```
app/
├── layout.tsx
├── page.tsx
├── @sidebar/
│   └── default.tsx          # Contenu par défaut du slot @sidebar
├── @content/
│   └── default.tsx          # Contenu par défaut du slot @content
└── @modals/
    └── default.tsx          # Contenu par défaut du slot @modals
```

### Structure d'URL vs Structure de Fichiers

```
URL: /dashboard/analytics
     ↓
Charge:
- app/dashboard/layout.tsx (reçoit les slots)
- app/dashboard/@sidebar/default.tsx
- app/dashboard/@content/analytics/page.tsx
- app/dashboard/@modals/default.tsx (ou unmatched.tsx)
```

## Utilisation Basique: Dashboard Multi-sections

```typescript
// app/dashboard/layout.tsx
// Reçoit les slots comme props
type DashboardLayoutProps = {
  children: React.ReactNode;      // page.tsx
  sidebar: React.ReactNode;        // @sidebar/...
  content: React.ReactNode;        // @content/...
  modals: React.ReactNode;         // @modals/...
};

export default function DashboardLayout({
  children,
  sidebar,
  content,
  modals,
}: DashboardLayoutProps) {
  return (
    <div className="flex h-screen bg-gray-100">
      {/* Sidebar - rendu indépendamment */}
      <aside className="w-64 bg-white border-r border-gray-200">
        {sidebar}
      </aside>

      {/* Contenu principal */}
      <main className="flex-1 overflow-auto">
        {content || children}
      </main>

      {/* Modals - rendu indépendamment */}
      <div className="modal-container">
        {modals}
      </div>
    </div>
  );
}

// app/dashboard/page.tsx - Page par défaut
export default function DashboardHome() {
  return <h1>Dashboard</h1>;
}

// app/dashboard/@sidebar/default.tsx
import Link from 'next/link';

export default function SidebarDefault() {
  return (
    <nav className="p-4 space-y-2">
      <Link href="/dashboard" className="block p-2 hover:bg-gray-100 rounded">
        Accueil
      </Link>
      <Link href="/dashboard/analytics" className="block p-2 hover:bg-gray-100 rounded">
        Analytics
      </Link>
      <Link href="/dashboard/reports" className="block p-2 hover:bg-gray-100 rounded">
        Rapports
      </Link>
      <Link href="/dashboard/settings" className="block p-2 hover:bg-gray-100 rounded">
        Paramètres
      </Link>
    </nav>
  );
}

// app/dashboard/@content/default.tsx
export default function ContentDefault() {
  return (
    <div className="p-8">
      <p className="text-gray-500">Sélectionnez une section dans le menu</p>
    </div>
  );
}

// app/dashboard/@content/analytics/page.tsx
'use client';

import { BarChart, LineChart } from '@/components/Charts';
import { useEffect, useState } from 'react';

export default function AnalyticsPage() {
  const [data, setData] = useState(null);

  useEffect(() => {
    // Charger les données d'analytics
    fetchAnalytics().then(setData);
  }, []);

  return (
    <div className="p-8">
      <h2 className="text-3xl font-bold mb-6">Analytics</h2>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="font-semibold mb-4">Visites par jour</h3>
          {data && <LineChart data={data.visits} />}
        </div>

        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="font-semibold mb-4">Revenue par mois</h3>
          {data && <BarChart data={data.revenue} />}
        </div>
      </div>

      <div className="bg-white p-6 rounded-lg shadow">
        <h3 className="font-semibold mb-4">Détails</h3>
        {data && <DataTable data={data.details} />}
      </div>
    </div>
  );
}

// app/dashboard/@content/reports/page.tsx
import { ReportsList } from '@/components/ReportsList';

export default function ReportsPage() {
  return (
    <div className="p-8">
      <h2 className="text-3xl font-bold mb-6">Rapports</h2>
      <ReportsList />
    </div>
  );
}

// app/dashboard/@modals/default.tsx
export default function ModalsDefault() {
  return null; // Aucun modal par défaut
}
```

## Exemple Avancé: Dashboard avec Modals et Notifications

```typescript
// app/dashboard/layout.tsx
type DashboardLayoutProps = {
  children: React.ReactNode;
  sidebar: React.ReactNode;
  stats: React.ReactNode;
  modals: React.ReactNode;
  notifications: React.ReactNode;
};

export default function DashboardLayout({
  children,
  sidebar,
  stats,
  modals,
  notifications,
}: DashboardLayoutProps) {
  return (
    <div className="flex h-screen">
      {/* Sidebar */}
      <aside className="w-64 bg-gray-900 text-white overflow-auto">
        {sidebar}
      </aside>

      {/* Contenu principal */}
      <div className="flex-1 flex flex-col">
        {/* Top bar avec stats */}
        <header className="bg-white border-b border-gray-200 p-4">
          <div className="grid grid-cols-4 gap-4">
            {stats}
          </div>
        </header>

        {/* Contenu page */}
        <main className="flex-1 overflow-auto p-6">
          {children}
        </main>
      </div>

      {/* Modals */}
      {modals}

      {/* Notifications */}
      <div className="fixed top-4 right-4 space-y-2 z-50">
        {notifications}
      </div>
    </div>
  );
}

// app/dashboard/@sidebar/default.tsx
'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';

export default function Sidebar() {
  const pathname = usePathname();

  const isActive = (href: string) => pathname.startsWith(href);

  return (
    <nav className="p-6 space-y-4">
      <div className="mb-8">
        <h2 className="text-xl font-bold">Dashboard</h2>
      </div>

      <Link
        href="/dashboard"
        className={`block px-4 py-2 rounded transition ${
          pathname === '/dashboard'
            ? 'bg-blue-600'
            : 'hover:bg-gray-800'
        }`}
      >
        Accueil
      </Link>

      <div>
        <h3 className="px-4 py-2 text-xs font-semibold text-gray-400 uppercase tracking-wider">
          Analytics
        </h3>
        <Link
          href="/dashboard/analytics"
          className={`block px-4 py-2 rounded transition ${
            isActive('/dashboard/analytics')
              ? 'bg-blue-600'
              : 'hover:bg-gray-800'
          }`}
        >
          Données
        </Link>
        <Link
          href="/dashboard/reports"
          className={`block px-4 py-2 rounded transition ${
            isActive('/dashboard/reports')
              ? 'bg-blue-600'
              : 'hover:bg-gray-800'
          }`}
        >
          Rapports
        </Link>
      </div>

      <div>
        <h3 className="px-4 py-2 text-xs font-semibold text-gray-400 uppercase tracking-wider">
          Gestion
        </h3>
        <Link
          href="/dashboard/users"
          className={`block px-4 py-2 rounded transition ${
            isActive('/dashboard/users')
              ? 'bg-blue-600'
              : 'hover:bg-gray-800'
          }`}
        >
          Utilisateurs
        </Link>
        <Link
          href="/dashboard/content"
          className={`block px-4 py-2 rounded transition ${
            isActive('/dashboard/content')
              ? 'bg-blue-600'
              : 'hover:bg-gray-800'
          }`}
        >
          Contenu
        </Link>
      </div>

      <div>
        <h3 className="px-4 py-2 text-xs font-semibold text-gray-400 uppercase tracking-wider">
          Paramètres
        </h3>
        <Link
          href="/dashboard/settings"
          className={`block px-4 py-2 rounded transition ${
            isActive('/dashboard/settings')
              ? 'bg-blue-600'
              : 'hover:bg-gray-800'
          }`}
        >
          Généraux
        </Link>
      </div>
    </nav>
  );
}

// app/dashboard/@stats/default.tsx
import { getStats } from '@/lib/dashboard';

type StatCardProps = {
  label: string;
  value: string | number;
  change: number;
};

function StatCard({ label, value, change }: StatCardProps) {
  const isPositive = change >= 0;
  return (
    <div className="bg-white p-4 rounded-lg shadow">
      <p className="text-gray-600 text-sm">{label}</p>
      <p className="text-2xl font-bold mt-1">{value}</p>
      <p className={`text-sm mt-1 ${isPositive ? 'text-green-600' : 'text-red-600'}`}>
        {isPositive ? '↑' : '↓'} {Math.abs(change)}% vs mois dernier
      </p>
    </div>
  );
}

export default async function Stats() {
  const stats = await getStats();

  return (
    <>
      <StatCard label="Utilisateurs" value={stats.users} change={12} />
      <StatCard label="Revenue" value={`$${stats.revenue}`} change={8} />
      <StatCard label="Commandes" value={stats.orders} change={15} />
      <StatCard label="Taux de conversion" value={`${stats.conversion}%`} change={-2} />
    </>
  );
}

// app/dashboard/@modals/default.tsx
export default function ModalsDefault() {
  return null;
}

// app/dashboard/@modals/[...slug]/page.tsx
'use client';

import { useRouter } from 'next/navigation';
import { useEffect } from 'react';

type ModalPageProps = {
  params: {
    slug: string[];
  };
};

export default function ModalPage({ params }: ModalPageProps) {
  const router = useRouter();
  const [modalType, ...rest] = params.slug;

  const handleClose = () => {
    router.back();
  };

  return (
    <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-40">
      <div className="bg-white rounded-lg shadow-lg max-w-md w-full mx-4">
        <div className="flex justify-between items-center p-6 border-b">
          <h2 className="text-xl font-bold">
            {modalType === 'edit-profile' && 'Modifier le profil'}
            {modalType === 'new-report' && 'Créer un rapport'}
            {modalType === 'delete-confirm' && 'Confirmer la suppression'}
          </h2>
          <button
            onClick={handleClose}
            className="text-gray-400 hover:text-gray-600"
          >
            ✕
          </button>
        </div>

        <div className="p-6">
          {modalType === 'edit-profile' && <EditProfileForm onClose={handleClose} />}
          {modalType === 'new-report' && <NewReportForm onClose={handleClose} />}
          {modalType === 'delete-confirm' && <DeleteConfirmDialog onClose={handleClose} />}
        </div>
      </div>
    </div>
  );
}

// app/dashboard/@notifications/default.tsx
'use client';

import { useEffect, useState } from 'react';
import { useNotifications } from '@/hooks/useNotifications';

type Notification = {
  id: string;
  type: 'success' | 'error' | 'info' | 'warning';
  message: string;
};

export default function Notifications() {
  const notifications = useNotifications();

  return (
    <>
      {notifications.map((notification) => (
        <div
          key={notification.id}
          className={`px-4 py-3 rounded-lg text-white ${
            notification.type === 'success'
              ? 'bg-green-500'
              : notification.type === 'error'
              ? 'bg-red-500'
              : notification.type === 'warning'
              ? 'bg-yellow-500'
              : 'bg-blue-500'
          }`}
        >
          {notification.message}
        </div>
      ))}
    </>
  );
}
```

## Fichiers Spéciaux avec Slots

### default.tsx
Affiché quand aucune page n'existe pour ce slot.

```typescript
// app/dashboard/@sidebar/default.tsx
export default function SidebarDefault() {
  return <nav>Menu par défaut</nav>;
}
```

### unmatched.tsx
Affiché quand la route n'existe pas pour ce slot (optionnel).

```typescript
// app/dashboard/@modals/unmatched.tsx
export default function UnmatchedModals() {
  return null; // Ou afficher une page 404 spécifique
}
```

## Parallel Routes avec Segments Dynamiques

```typescript
// Structure
app/dashboard/
├── layout.tsx
├── @sidebar/default.tsx
├── @content/
│   ├── default.tsx
│   ├── [section]/
│   │   └── page.tsx
│   └── [section]/[subsection]/
│       └── page.tsx
└── @modals/
    ├── default.tsx
    └── [...slug]/page.tsx

// app/dashboard/@content/[section]/page.tsx
type PageProps = {
  params: { section: string };
};

export default function SectionPage({ params }: PageProps) {
  return <h1>Section: {params.section}</h1>;
}

// app/dashboard/@content/[section]/[subsection]/page.tsx
type PageProps = {
  params: { section: string; subsection: string };
};

export default function SubsectionPage({ params }: PageProps) {
  return (
    <div>
      <h1>{params.section}</h1>
      <h2>{params.subsection}</h2>
    </div>
  );
}
```

## Navigation et État entre Slots

```typescript
// app/dashboard/page.tsx
'use client';

import Link from 'next/link';
import { useRouter } from 'next/navigation';

export default function Dashboard() {
  const router = useRouter();

  const openModal = (modalType: string) => {
    // Navigue vers /dashboard/modals/[type]
    router.push(`/dashboard/modals/${modalType}`);
  };

  const goToSection = (section: string) => {
    // Navigue vers /dashboard/[section]
    router.push(`/dashboard/${section}`);
  };

  return (
    <div>
      <h1 className="text-3xl font-bold mb-6">Tableau de Bord</h1>

      <div className="space-y-4 mb-8">
        <button
          onClick={() => goToSection('analytics')}
          className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
        >
          Voir Analytics
        </button>

        <button
          onClick={() => openModal('edit-profile')}
          className="px-4 py-2 bg-green-600 text-white rounded hover:bg-green-700"
        >
          Éditer le Profil
        </button>
      </div>
    </div>
  );
}
```

## Parallel Routes avec Route Groups

```typescript
// Structure
app/
├── (dashboard)/
│   ├── layout.tsx
│   ├── @sidebar/default.tsx
│   ├── @content/default.tsx
│   ├── @modals/default.tsx
│   ├── page.tsx
│   ├── analytics/[...page].tsx
│   └── reports/[...page].tsx
│
└── (marketing)/
    ├── layout.tsx
    ├── page.tsx
    └── about/page.tsx
```

## Best Practices

### 1. Organiser les Slots Logiquement
```typescript
// ✓ Bon
@sidebar         // Navigation latérale
@content         // Contenu principal
@modals          // Modals et overlays
@notifications   // Notifications

// ✗ Mauvais
@left            // Trop vague
@middle          // Trop vague
@right           // Trop vague
```

### 2. Utiliser default.tsx pour les Fallbacks
```typescript
// ✓ Bon
export default function SidebarDefault() {
  return <Sidebar />;
}

// ✗ Mauvais
export default function SidebarDefault() {
  return null;  // Crée des pages blanches
}
```

### 3. Gestion des Modals
```typescript
// ✓ Bon: Modals indépendants du contenu
export default function ModalPage({ params }) {
  return (
    <Modal>
      {/* Contenu modal */}
    </Modal>
  );
}

// Les utilisateurs peuvent avoir une page ET un modal
```

## Cas d'Usage Courants

| Cas | Slots | Bénéfice |
|-----|-------|----------|
| Dashboard | `@sidebar`, `@content`, `@stats`, `@modals` | Mises à jour indépendantes |
| E-commerce | `@sidebar`, `@products`, `@cart`, `@modals` | Panier indépendant |
| Admin | `@nav`, `@main`, `@notifications` | Notifications en temps réel |
| SaaS | `@menu`, `@content`, `@settings`, `@help` | Plusieurs sections |

## Points Clés

- **Slots**: Dossiers nommés `@name`
- **Indépendance**: Chaque slot se met à jour indépendamment
- **default.tsx**: Contenu par défaut quand aucune page
- **unmatched.tsx**: Optionnel, pour routes non trouvées
- **Layout reçoit les slots**: Comme props
- **Navigation**: Changer les slots sans toucher aux autres
- **Combinaison**: Fonctionne avec segments dynamiques et groupes
