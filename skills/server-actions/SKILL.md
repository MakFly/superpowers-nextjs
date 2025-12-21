---
name: nextjs:server-actions
description: Create Server Actions with 'use server' for mutations, form submissions, and data modifications
---

# Server Actions: Exécution de Code Côté Serveur

## Concept

Les Server Actions sont une fonctionnalité de Next.js App Router qui permettent de définir des fonctions asynchrones qui s'exécutent exclusivement sur le serveur. Elles éliminent le besoin de créer des endpoints API explicites pour les mutations simples, offrant une intégration seamless entre le client et le serveur avec une validation et une sécurité intégrées.

## Fondamentaux

### Définition d'une Server Action

Une Server Action est une fonction asynchrone marquée avec `'use server'` au niveau du fichier ou de la fonction.

```typescript
// app/actions.ts - Server Actions dans un fichier dédié
'use server';

import { db } from '@/lib/db';
import { revalidatePath } from 'next/cache';

export async function createTask(title: string, description: string) {
  try {
    // Validation côté serveur
    if (!title || title.trim().length === 0) {
      throw new Error('Le titre est requis');
    }

    // Mutation de la base de données
    const task = await db.task.create({
      data: {
        title: title.trim(),
        description: description.trim(),
        completed: false,
      },
    });

    // Revalidation du cache
    revalidatePath('/tasks');

    return { success: true, task };
  } catch (error) {
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Une erreur est survenue',
    };
  }
}

export async function updateTask(id: string, completed: boolean) {
  try {
    const task = await db.task.update({
      where: { id },
      data: { completed },
    });

    revalidatePath('/tasks');
    return { success: true, task };
  } catch (error) {
    return {
      success: false,
      error: 'Échec de la mise à jour',
    };
  }
}

export async function deleteTask(id: string) {
  try {
    await db.task.delete({
      where: { id },
    });

    revalidatePath('/tasks');
    return { success: true };
  } catch (error) {
    return {
      success: false,
      error: 'Échec de la suppression',
    };
  }
}
```

### Utilisation dans des Composants Client

```typescript
// app/components/TaskForm.tsx
'use client';

import { createTask } from '@/app/actions';
import { useState } from 'react';

export function TaskForm() {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleSubmit(formData: FormData) {
    setLoading(true);
    setError(null);

    try {
      const title = formData.get('title') as string;
      const description = formData.get('description') as string;

      const result = await createTask(title, description);

      if (!result.success) {
        setError(result.error);
      } else {
        // Réinitialiser le formulaire
        (event?.target as HTMLFormElement)?.reset();
      }
    } catch (err) {
      setError('Erreur lors de l\'envoi');
    } finally {
      setLoading(false);
    }
  }

  return (
    <form action={handleSubmit} className="space-y-4">
      <div>
        <label htmlFor="title" className="block text-sm font-medium">
          Titre
        </label>
        <input
          id="title"
          name="title"
          type="text"
          required
          className="mt-1 block w-full px-3 py-2 border rounded-md"
        />
      </div>

      <div>
        <label htmlFor="description" className="block text-sm font-medium">
          Description
        </label>
        <textarea
          id="description"
          name="description"
          rows={4}
          className="mt-1 block w-full px-3 py-2 border rounded-md"
        />
      </div>

      {error && (
        <div className="p-3 bg-red-100 text-red-800 rounded-md">
          {error}
        </div>
      )}

      <button
        type="submit"
        disabled={loading}
        className="px-4 py-2 bg-blue-600 text-white rounded-md disabled:opacity-50"
      >
        {loading ? 'Création...' : 'Créer la tâche'}
      </button>
    </form>
  );
}
```

### Utilisation dans les Layouts et Pages Serveur

```typescript
// app/components/TaskList.tsx
import { db } from '@/lib/db';
import { TaskActions } from './TaskActions';

export async function TaskList() {
  const tasks = await db.task.findMany({
    orderBy: { createdAt: 'desc' },
  });

  return (
    <div className="space-y-2">
      {tasks.length === 0 ? (
        <p className="text-gray-500">Aucune tâche. Créez-en une!</p>
      ) : (
        tasks.map((task) => (
          <div
            key={task.id}
            className="p-4 border rounded-lg flex items-center justify-between"
          >
            <div>
              <h3 className="font-semibold">{task.title}</h3>
              {task.description && (
                <p className="text-gray-600 text-sm mt-1">{task.description}</p>
              )}
            </div>
            <TaskActions task={task} />
          </div>
        ))
      )}
    </div>
  );
}

// app/components/TaskActions.tsx
'use client';

import { updateTask, deleteTask } from '@/app/actions';
import { useState } from 'react';

type TaskActionsProps = {
  task: { id: string; completed: boolean };
};

export function TaskActions({ task }: TaskActionsProps) {
  const [loading, setLoading] = useState(false);

  async function handleToggle() {
    setLoading(true);
    await updateTask(task.id, !task.completed);
    setLoading(false);
  }

  async function handleDelete() {
    if (!confirm('Êtes-vous sûr?')) return;
    setLoading(true);
    await deleteTask(task.id);
    setLoading(false);
  }

  return (
    <div className="flex gap-2">
      <button
        onClick={handleToggle}
        disabled={loading}
        className="px-3 py-1 bg-green-600 text-white rounded text-sm disabled:opacity-50"
      >
        {task.completed ? 'Réactiver' : 'Compléter'}
      </button>
      <button
        onClick={handleDelete}
        disabled={loading}
        className="px-3 py-1 bg-red-600 text-white rounded text-sm disabled:opacity-50"
      >
        Supprimer
      </button>
    </div>
  );
}
```

## Patterns Avancés

### Server Actions avec Binding

```typescript
// app/actions.ts
'use server';

import { db } from '@/lib/db';

export async function assignTaskToUser(taskId: string, userId: string) {
  const task = await db.task.update({
    where: { id: taskId },
    data: { assignedToId: userId },
  });
  return task;
}
```

```typescript
// app/components/UserAssignment.tsx
'use client';

import { bindAction } from '@/lib/actions-helpers';
import { assignTaskToUser } from '@/app/actions';

type UserAssignmentProps = {
  taskId: string;
  users: Array<{ id: string; name: string }>;
};

export function UserAssignment({ taskId, users }: UserAssignmentProps) {
  const assignTask = bindAction(assignTaskToUser, taskId);

  return (
    <div className="space-y-2">
      {users.map((user) => (
        <button
          key={user.id}
          onClick={() => assignTask(user.id)}
          className="block w-full text-left px-4 py-2 hover:bg-gray-100 rounded"
        >
          Assigner à {user.name}
        </button>
      ))}
    </div>
  );
}
```

### Validation des Données avec Zod

```typescript
// app/actions.ts
'use server';

import { z } from 'zod';
import { db } from '@/lib/db';

const createTaskSchema = z.object({
  title: z.string().min(1, 'Le titre est requis').max(200),
  description: z.string().max(1000).optional(),
  priority: z.enum(['low', 'medium', 'high']).default('medium'),
  dueDate: z.coerce.date().optional(),
});

export async function createValidatedTask(input: unknown) {
  try {
    const validatedData = createTaskSchema.parse(input);

    const task = await db.task.create({
      data: validatedData,
    });

    return { success: true, task };
  } catch (error) {
    if (error instanceof z.ZodError) {
      return {
        success: false,
        errors: error.flatten().fieldErrors,
      };
    }
    throw error;
  }
}
```

### Gestion des Erreurs Détaillée

```typescript
// app/actions.ts
'use server';

class ValidationError extends Error {
  constructor(public field: string, message: string) {
    super(message);
  }
}

class AuthorizationError extends Error {
  constructor(message: string = 'Non autorisé') {
    super(message);
  }
}

export async function deleteUserTask(taskId: string, userId: string) {
  try {
    // Récupérer la tâche
    const task = await db.task.findUnique({
      where: { id: taskId },
    });

    if (!task) {
      throw new ValidationError('taskId', 'Tâche introuvable');
    }

    // Vérifier l'autorisation
    if (task.userId !== userId) {
      throw new AuthorizationError('Vous ne pouvez pas supprimer cette tâche');
    }

    // Supprimer
    await db.task.delete({
      where: { id: taskId },
    });

    return { success: true };
  } catch (error) {
    if (error instanceof ValidationError) {
      return { success: false, type: 'validation', field: error.field };
    }
    if (error instanceof AuthorizationError) {
      return { success: false, type: 'authorization' };
    }
    return { success: false, type: 'error' };
  }
}
```

## Best Practices

### 1. Authentification et Autorisation

```typescript
'use server';

import { auth } from '@/auth';
import { db } from '@/lib/db';

export async function updateUserProfile(data: Record<string, unknown>) {
  const session = await auth();

  if (!session?.user?.id) {
    throw new Error('Non authentifié');
  }

  return db.user.update({
    where: { id: session.user.id },
    data,
  });
}
```

### 2. Logging et Monitoring

```typescript
'use server';

import { logger } from '@/lib/logger';

export async function processPayment(amount: number, userId: string) {
  const startTime = Date.now();

  try {
    logger.info('Starting payment', { amount, userId });

    const result = await paymentGateway.charge(amount);

    logger.info('Payment successful', {
      amount,
      userId,
      duration: Date.now() - startTime,
    });

    return { success: true, result };
  } catch (error) {
    logger.error('Payment failed', {
      amount,
      userId,
      error: error instanceof Error ? error.message : 'Unknown error',
    });

    throw error;
  }
}
```

### 3. Rate Limiting

```typescript
'use server';

import { rateLimit } from '@/lib/rate-limit';

export async function submitForm(formData: FormData) {
  const clientId = formData.get('clientId') as string;
  const { success, remaining } = await rateLimit.check(clientId, 5, 3600);

  if (!success) {
    throw new Error(`Rate limited. Réessayez dans ${remaining} secondes.`);
  }

  // Traiter le formulaire
}
```

### 4. Transactionnalité

```typescript
'use server';

import { db } from '@/lib/db';

export async function transferFunds(fromId: string, toId: string, amount: number) {
  return await db.$transaction(async (tx) => {
    // Débiter le compte source
    await tx.account.update({
      where: { id: fromId },
      data: { balance: { decrement: amount } },
    });

    // Créditer le compte cible
    await tx.account.update({
      where: { id: toId },
      data: { balance: { increment: amount } },
    });

    // Enregistrer la transaction
    return tx.transaction.create({
      data: {
        fromId,
        toId,
        amount,
      },
    });
  });
}
```

## Security Considerations

### 1. Validation Entrante

Toujours valider et nettoyer les données reçues du client.

```typescript
'use server';

export async function searchProducts(query: string) {
  // Valider et limiter la longueur
  const sanitizedQuery = query.trim().slice(0, 100);

  if (!sanitizedQuery) {
    return [];
  }

  return db.product.findMany({
    where: {
      name: {
        contains: sanitizedQuery,
        mode: 'insensitive',
      },
    },
    take: 20,
  });
}
```

### 2. Vérification des Permissions

Ne jamais faire confiance aux données du client pour l'authentification.

```typescript
'use server';

import { getCurrentUser } from '@/auth';

export async function updatePost(postId: string, title: string) {
  const user = await getCurrentUser();

  if (!user) {
    throw new Error('Non authentifié');
  }

  const post = await db.post.findUnique({
    where: { id: postId },
  });

  if (post?.authorId !== user.id) {
    throw new Error('Non autorisé');
  }

  return db.post.update({
    where: { id: postId },
    data: { title },
  });
}
```

### 3. Protection CSRF

Next.js fournit une protection CSRF automatique pour les Server Actions.

```typescript
// Automatique - pas de configuration requise
// Les Server Actions utilisent les tokens CSRF par défaut
```

### 4. Éviter l'Exposition de Secrets

```typescript
'use server';

// MAUVAIS - expose la clé API
export async function badExample() {
  return process.env.API_KEY; // NE PAS FAIRE
}

// BON - garde les secrets sur le serveur
export async function goodExample(data: string) {
  const result = await fetch('https://api.example.com/process', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${process.env.API_KEY}`,
    },
    body: JSON.stringify(data),
  });
  return result.json();
}
```

## Patterns Courants

### Formulaire avec Action

```typescript
// app/actions.ts
'use server';

export async function submitContactForm(formData: FormData) {
  const name = formData.get('name') as string;
  const email = formData.get('email') as string;
  const message = formData.get('message') as string;

  // Valider
  if (!name || !email || !message) {
    return { error: 'Tous les champs sont requis' };
  }

  // Envoyer l'email
  await sendEmail({
    to: 'contact@example.com',
    subject: `Message de ${name}`,
    body: message,
    replyTo: email,
  });

  return { success: true };
}

// app/components/ContactForm.tsx
'use client';

import { submitContactForm } from '@/app/actions';
import { useFormState } from 'react-dom';

export function ContactForm() {
  const [state, formAction] = useFormState(submitContactForm, null);

  return (
    <form action={formAction} className="space-y-4">
      <input name="name" placeholder="Nom" required />
      <input name="email" type="email" placeholder="Email" required />
      <textarea name="message" placeholder="Message" required />

      {state?.error && (
        <div className="text-red-600">{state.error}</div>
      )}

      {state?.success && (
        <div className="text-green-600">Message envoyé avec succès!</div>
      )}

      <button type="submit" className="px-4 py-2 bg-blue-600 text-white rounded">
        Envoyer
      </button>
    </form>
  );
}
```

## Points Clés

- **Exécution serveur exclusive**: Les Server Actions ne contiennent jamais de code côté client
- **Type-safe**: Les paramètres et retours sont complètement typés
- **Zéro endpoint API**: Pas besoin de créer des routes API pour les mutations simples
- **Revalidation automatique**: Intégration seamless avec le système de cache
- **Sécurité CSRF**: Protection automatique intégrée
- **Validation**: Effectuer toujours la validation côté serveur
