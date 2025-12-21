---
name: nextjs:mutations
description: Implement optimistic updates, error handling, and rollback patterns for data mutations
---

# Mutations: Optimistic Updates et Gestion des Erreurs

## Concept

Les mutations dans Next.js modernes combinent les Server Actions avec le hook `useOptimistic` pour créer une expérience utilisateur fluide. L'approche optimiste met à jour l'UI immédiatement avant de confirmer les changements auprès du serveur, tout en gracieusement gérant les erreurs avec rollback automatique.

## Optimistic Updates

### Pattern de Base

```typescript
// app/actions.ts
'use server';

import { db } from '@/lib/db';
import { revalidatePath } from 'next/cache';

export async function toggleTodoStatus(id: string, completed: boolean) {
  try {
    // Simuler une latence réseau
    await new Promise((resolve) => setTimeout(resolve, 500));

    const todo = await db.todo.update({
      where: { id },
      data: { completed },
    });

    revalidatePath('/todos');

    return { success: true, todo };
  } catch (error) {
    throw new Error('Impossible de mettre à jour la tâche');
  }
}

// app/components/TodoItem.tsx
'use client';

import { useOptimistic } from 'react';
import { toggleTodoStatus } from '@/app/actions';
import { useState } from 'react';

type Todo = {
  id: string;
  title: string;
  completed: boolean;
};

export function TodoItem({ todo }: { todo: Todo }) {
  const [optimisticTodo, addOptimisticTodo] = useOptimistic<Todo>(todo);
  const [error, setError] = useState<string | null>(null);

  async function handleToggle() {
    setError(null);

    // Mise à jour optimiste
    addOptimisticTodo({ ...optimisticTodo, completed: !optimisticTodo.completed });

    try {
      await toggleTodoStatus(todo.id, !optimisticTodo.completed);
    } catch (err) {
      // Rollback automatique au changement optimiste
      setError(err instanceof Error ? err.message : 'Erreur');
    }
  }

  return (
    <div>
      <div className="flex items-center gap-2 p-3 border rounded-lg">
        <input
          type="checkbox"
          checked={optimisticTodo.completed}
          onChange={handleToggle}
          disabled={error ? true : false}
          className="w-4 h-4 cursor-pointer"
        />
        <span
          className={`flex-1 ${
            optimisticTodo.completed ? 'line-through text-gray-400' : ''
          }`}
        >
          {optimisticTodo.title}
        </span>
      </div>
      {error && (
        <p className="mt-1 text-sm text-red-600">
          {error}
        </p>
      )}
    </div>
  );
}
```

### Mutations Complexes avec États Multiples

```typescript
// app/actions.ts
'use server';

type UpdatePostRequest = {
  id: string;
  title: string;
  content: string;
  published: boolean;
};

export async function updatePost(data: UpdatePostRequest) {
  try {
    // Validation
    if (!data.title?.trim()) {
      throw new ValidationError('title', 'Le titre est requis');
    }
    if (data.title.length > 200) {
      throw new ValidationError('title', 'Le titre ne peut pas dépasser 200 caractères');
    }

    // Simuler une latence réseau
    await new Promise((resolve) => setTimeout(resolve, 800));

    const post = await db.post.update({
      where: { id: data.id },
      data: {
        title: data.title.trim(),
        content: data.content.trim(),
        published: data.published,
        updatedAt: new Date(),
      },
    });

    revalidatePath('/blog');
    return { success: true, post };
  } catch (error) {
    if (error instanceof ValidationError) {
      return {
        success: false,
        error: error.message,
        field: error.field,
      };
    }
    return { success: false, error: 'Erreur serveur' };
  }
}

class ValidationError extends Error {
  constructor(public field: string, message: string) {
    super(message);
  }
}

// app/components/BlogEditor.tsx
'use client';

import { useOptimistic, useState } from 'react';
import { updatePost } from '@/app/actions';

type Post = {
  id: string;
  title: string;
  content: string;
  published: boolean;
};

export function BlogEditor({ post }: { post: Post }) {
  const [optimisticPost, addOptimisticPost] = useOptimistic<Post>(post);
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [isSaving, setIsSaving] = useState(false);

  async function handleSave(formData: FormData) {
    setErrors({});
    setIsSaving(true);

    const newTitle = formData.get('title') as string;
    const newContent = formData.get('content') as string;
    const newPublished = formData.get('published') === 'on';

    // Mise à jour optimiste
    addOptimisticPost({
      ...optimisticPost,
      title: newTitle,
      content: newContent,
      published: newPublished,
    });

    try {
      const result = await updatePost({
        id: post.id,
        title: newTitle,
        content: newContent,
        published: newPublished,
      });

      if (!result.success) {
        if (result.field) {
          setErrors({ [result.field]: result.error });
        } else {
          setErrors({ general: result.error });
        }
      }
    } catch (error) {
      setErrors({
        general: 'Erreur lors de la sauvegarde',
      });
    } finally {
      setIsSaving(false);
    }
  }

  return (
    <form action={handleSave} className="space-y-4 max-w-2xl">
      <div>
        <label htmlFor="title" className="block text-sm font-medium">
          Titre
        </label>
        <input
          id="title"
          name="title"
          type="text"
          defaultValue={optimisticPost.title}
          disabled={isSaving}
          className="w-full mt-1 px-3 py-2 border rounded-lg disabled:opacity-50"
        />
        {errors.title && (
          <p className="mt-1 text-sm text-red-600">{errors.title}</p>
        )}
      </div>

      <div>
        <label htmlFor="content" className="block text-sm font-medium">
          Contenu
        </label>
        <textarea
          id="content"
          name="content"
          rows={10}
          defaultValue={optimisticPost.content}
          disabled={isSaving}
          className="w-full mt-1 px-3 py-2 border rounded-lg disabled:opacity-50"
        />
      </div>

      <div className="flex items-center gap-2">
        <input
          id="published"
          name="published"
          type="checkbox"
          defaultChecked={optimisticPost.published}
          disabled={isSaving}
          className="rounded disabled:opacity-50"
        />
        <label htmlFor="published" className="text-sm font-medium">
          Publié
        </label>
      </div>

      {errors.general && (
        <div className="p-3 bg-red-100 text-red-800 rounded-lg">
          {errors.general}
        </div>
      )}

      <button
        type="submit"
        disabled={isSaving}
        className="px-6 py-2 bg-blue-600 text-white rounded-lg disabled:opacity-50"
      >
        {isSaving ? 'Sauvegarde...' : 'Sauvegarder'}
      </button>
    </form>
  );
}
```

## Gestion Avancée des Erreurs

### Pattern avec Erreurs Détaillées

```typescript
// lib/mutations.ts
export type MutationResult<T = unknown> = {
  success: boolean;
  data?: T;
  error?: {
    code: string;
    message: string;
    details?: Record<string, string>;
    retry?: boolean;
  };
};

export class MutationError extends Error {
  constructor(
    public code: string,
    message: string,
    public retry = false,
    public details?: Record<string, string>
  ) {
    super(message);
  }
}

// app/actions.ts
'use server';

import { MutationError, MutationResult } from '@/lib/mutations';

export async function createComment(
  postId: string,
  content: string
): Promise<MutationResult> {
  try {
    // Valider la longueur
    if (content.length === 0) {
      throw new MutationError(
        'CONTENT_EMPTY',
        'Le commentaire ne peut pas être vide'
      );
    }

    if (content.length > 5000) {
      throw new MutationError(
        'CONTENT_TOO_LONG',
        'Le commentaire ne doit pas dépasser 5000 caractères'
      );
    }

    // Vérifier le rate limiting
    const userCommentCount = await db.comment.count({
      where: {
        authorId: userId,
        createdAt: {
          gte: new Date(Date.now() - 60000), // Dernière minute
        },
      },
    });

    if (userCommentCount >= 10) {
      throw new MutationError(
        'RATE_LIMIT',
        'Trop de commentaires. Réessayez dans 1 minute.',
        true
      );
    }

    // Créer le commentaire
    const comment = await db.comment.create({
      data: {
        content: content.trim(),
        postId,
        authorId: userId,
      },
    });

    revalidatePath(`/posts/${postId}`);

    return { success: true, data: comment };
  } catch (error) {
    if (error instanceof MutationError) {
      return {
        success: false,
        error: {
          code: error.code,
          message: error.message,
          retry: error.retry,
          details: error.details,
        },
      };
    }

    return {
      success: false,
      error: {
        code: 'UNKNOWN_ERROR',
        message: 'Une erreur inattendue s\'est produite',
      },
    };
  }
}

// app/components/CommentForm.tsx
'use client';

import { createComment } from '@/app/actions';
import { useState } from 'react';

type ErrorState = {
  code: string;
  message: string;
  field?: string;
};

export function CommentForm({ postId }: { postId: string }) {
  const [content, setContent] = useState('');
  const [error, setError] = useState<ErrorState | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  async function handleSubmit() {
    setError(null);
    setIsSubmitting(true);

    try {
      const result = await createComment(postId, content);

      if (!result.success) {
        setError({
          code: result.error!.code,
          message: result.error!.message,
        });

        // Afficher un message de retry si possible
        if (result.error?.retry) {
          // Afficher un bouton de retry
        }
      } else {
        setContent('');
      }
    } catch (err) {
      setError({
        code: 'NETWORK_ERROR',
        message: 'Erreur de connexion. Vérifiez votre internet.',
      });
    } finally {
      setIsSubmitting(false);
    }
  }

  const charCount = content.length;
  const isNearLimit = charCount > 4500;
  const isOverLimit = charCount > 5000;

  return (
    <div className="space-y-3">
      <textarea
        value={content}
        onChange={(e) => setContent(e.target.value)}
        disabled={isSubmitting}
        placeholder="Votre commentaire..."
        className="w-full p-3 border rounded-lg disabled:opacity-50"
        rows={4}
      />

      <div className="flex justify-between items-center">
        <div className={`text-sm ${isNearLimit ? 'text-orange-600' : 'text-gray-500'}`}>
          {charCount}/5000
        </div>

        <button
          onClick={handleSubmit}
          disabled={isSubmitting || isOverLimit || content.trim().length === 0}
          className="px-4 py-2 bg-blue-600 text-white rounded-lg disabled:opacity-50"
        >
          {isSubmitting ? 'Envoi...' : 'Commenter'}
        </button>
      </div>

      {isOverLimit && (
        <div className="p-3 bg-red-100 text-red-800 rounded-lg text-sm">
          Le commentaire dépasse la limite de 5000 caractères
        </div>
      )}

      {error && (
        <div className="p-3 bg-red-100 text-red-800 rounded-lg">
          <p className="font-medium">{error.message}</p>
          {error.code === 'RATE_LIMIT' && (
            <p className="text-sm mt-1">
              Vous pouvez poster à nouveau dans une minute.
            </p>
          )}
        </div>
      )}
    </div>
  );
}
```

## Patterns de Rollback

### Rollback avec État Précédent

```typescript
// app/components/DragAndDropTodoList.tsx
'use client';

import { reorderTodos } from '@/app/actions';
import { useOptimistic, useState } from 'react';

type Todo = {
  id: string;
  title: string;
  order: number;
};

export function DragAndDropTodoList({ todos }: { todos: Todo[] }) {
  const [optimisticTodos, addOptimisticTodos] = useOptimistic<Todo[]>(todos);
  const [error, setError] = useState<string | null>(null);

  async function handleDragEnd(result: any) {
    const { source, destination, draggableId } = result;

    if (!destination) return;
    if (source.index === destination.index) return;

    setError(null);

    // Créer la nouvelle liste avec réordonancement optimiste
    const newTodos = Array.from(optimisticTodos);
    const [movedTodo] = newTodos.splice(source.index, 1);
    newTodos.splice(destination.index, 0, movedTodo);

    // Mettre à jour les numéros d'ordre
    const reorderedTodos = newTodos.map((todo, index) => ({
      ...todo,
      order: index,
    }));

    // Mise à jour optimiste
    addOptimisticTodos(reorderedTodos);

    try {
      const result = await reorderTodos(
        reorderedTodos.map((todo) => ({
          id: todo.id,
          order: todo.order,
        }))
      );

      if (!result.success) {
        setError(result.error);
        // Le rollback automatique va restaurer l'ordre original
      }
    } catch (err) {
      setError('Impossible de réorganiser les tâches');
    }
  }

  return (
    <div className="space-y-2">
      {optimisticTodos.map((todo, index) => (
        <div
          key={todo.id}
          draggable
          onDragEnd={handleDragEnd}
          className="p-3 bg-white border rounded-lg cursor-move hover:shadow-md"
        >
          <span>{index + 1}.</span> {todo.title}
        </div>
      ))}
      {error && (
        <div className="p-3 bg-red-100 text-red-800 rounded-lg text-sm">
          {error}
        </div>
      )}
    </div>
  );
}
```

## Gestion de Multiples Mutations

### Mutations Dépendantes

```typescript
// app/actions.ts
'use server';

export async function createPostWithImage(
  title: string,
  content: string,
  imageFile: File
) {
  try {
    // Étape 1: Uploader l'image
    const imageUrl = await uploadImage(imageFile);

    // Étape 2: Créer le post avec référence à l'image
    const post = await db.post.create({
      data: {
        title,
        content,
        imageUrl,
      },
    });

    revalidatePath('/blog');

    return { success: true, post };
  } catch (error) {
    // Si le post échoue, l'image a déjà été uploadée
    // On pourrait vouloir la nettoyer
    if (error instanceof Error && error.message.includes('post')) {
      // Nettoyer l'image orpheline
      // await deleteImage(imageUrl);
    }

    return { success: false, error: 'Impossible de créer le post' };
  }
}

async function uploadImage(file: File): Promise<string> {
  const formData = new FormData();
  formData.append('file', file);

  const response = await fetch('https://storage.example.com/upload', {
    method: 'POST',
    body: formData,
  });

  if (!response.ok) {
    throw new Error('Upload d\'image échoué');
  }

  const data = await response.json();
  return data.url;
}

// app/components/CreatePostForm.tsx
'use client';

import { createPostWithImage } from '@/app/actions';
import { useState } from 'react';

export function CreatePostForm() {
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [imagePreview, setImagePreview] = useState<string | null>(null);

  async function handleSubmit(formData: FormData) {
    setError(null);
    setIsLoading(true);

    try {
      const title = formData.get('title') as string;
      const content = formData.get('content') as string;
      const imageFile = formData.get('image') as File;

      const result = await createPostWithImage(title, content, imageFile);

      if (!result.success) {
        setError(result.error);
      } else {
        // Rediriger vers le post créé
        // window.location.href = `/blog/${result.post.slug}`;
      }
    } catch (err) {
      setError('Erreur lors de la création du post');
    } finally {
      setIsLoading(false);
    }
  }

  return (
    <form action={handleSubmit} className="space-y-4 max-w-2xl">
      <input name="title" placeholder="Titre" required className="w-full p-2 border rounded" />

      <textarea
        name="content"
        placeholder="Contenu"
        rows={8}
        required
        className="w-full p-2 border rounded"
      />

      <div>
        <input
          name="image"
          type="file"
          accept="image/*"
          onChange={(e) => {
            const file = e.currentTarget.files?.[0];
            if (file) {
              const reader = new FileReader();
              reader.onload = (e) => setImagePreview(e.target?.result as string);
              reader.readAsDataURL(file);
            }
          }}
          className="w-full p-2 border rounded"
        />
        {imagePreview && (
          <img src={imagePreview} alt="Preview" className="mt-2 max-h-48 rounded" />
        )}
      </div>

      {error && (
        <div className="p-3 bg-red-100 text-red-800 rounded-lg">{error}</div>
      )}

      <button
        type="submit"
        disabled={isLoading}
        className="px-6 py-2 bg-blue-600 text-white rounded-lg disabled:opacity-50"
      >
        {isLoading ? 'Création...' : 'Créer'}
      </button>
    </form>
  );
}
```

## Mutation avec Undo

```typescript
// app/actions.ts
'use server';

import { db } from '@/lib/db';
import { nanoid } from 'nanoid';

const undoStack = new Map<string, () => Promise<void>>();

export async function deleteTodoWithUndo(id: string): Promise<string> {
  const todo = await db.todo.findUnique({ where: { id } });

  if (!todo) {
    throw new Error('Tâche introuvable');
  }

  // Supprimer
  await db.todo.delete({ where: { id } });

  // Créer un ID d'undo
  const undoId = nanoid();

  // Stocker la fonction de restauration
  undoStack.set(undoId, async () => {
    await db.todo.create({
      data: {
        id: todo.id,
        title: todo.title,
        completed: todo.completed,
      },
    });
  });

  // Nettoyer après 30 secondes
  setTimeout(() => undoStack.delete(undoId), 30000);

  revalidatePath('/todos');

  return undoId;
}

export async function undoDelete(undoId: string) {
  const undoFn = undoStack.get(undoId);

  if (!undoFn) {
    throw new Error('Impossible de restaurer cette action');
  }

  await undoFn();
  undoStack.delete(undoId);

  revalidatePath('/todos');
}

// app/components/TodoItem.tsx
'use client';

import { deleteTodoWithUndo, undoDelete } from '@/app/actions';
import { useState } from 'react';

export function TodoItem({ todo }: { todo: any }) {
  const [deleted, setDeleted] = useState(false);
  const [undoId, setUndoId] = useState<string | null>(null);
  const [undoTimeLeft, setUndoTimeLeft] = useState(30);

  async function handleDelete() {
    setDeleted(true);
    const id = await deleteTodoWithUndo(todo.id);
    setUndoId(id);
    setUndoTimeLeft(30);

    // Compte à rebours
    const interval = setInterval(() => {
      setUndoTimeLeft((t) => {
        if (t <= 1) {
          clearInterval(interval);
          return 0;
        }
        return t - 1;
      });
    }, 1000);
  }

  async function handleUndo() {
    if (!undoId) return;
    await undoDelete(undoId);
    setDeleted(false);
    setUndoId(null);
  }

  if (deleted) {
    return (
      <div className="p-3 bg-gray-100 rounded-lg flex justify-between items-center">
        <span className="text-gray-600 line-through">{todo.title}</span>
        <div className="flex gap-2">
          <button
            onClick={handleUndo}
            className="text-blue-600 hover:underline text-sm"
          >
            Restaurer
          </button>
          <span className="text-gray-500 text-sm">{undoTimeLeft}s</span>
        </div>
      </div>
    );
  }

  return (
    <div className="p-3 border rounded-lg flex justify-between items-center">
      <span>{todo.title}</span>
      <button
        onClick={handleDelete}
        className="text-red-600 hover:underline text-sm"
      >
        Supprimer
      </button>
    </div>
  );
}
```

## Points Clés

- **useOptimistic**: Mettez à jour l'UI avant la réponse du serveur
- **Rollback automatique**: Les changements optimistes sont défaits en cas d'erreur
- **Gestion d'erreurs détaillée**: Fournissez des codes et messages clairs
- **Validation**: Toujours valider les entrées côté serveur
- **Transactionalité**: Utilisez les transactions pour les mutations multi-étapes
- **Rate limiting**: Protégez les actions contre les abus
