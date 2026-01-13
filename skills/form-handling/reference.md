# Reference

# Gestion des Formulaires: useFormState et useFormStatus

## Concept

La gestion moderne des formulaires dans Next.js combine les Server Actions avec les hooks `useFormState` et `useFormStatus` pour créer des formulaires hautement réactifs et robustes. Ces outils permettent une progressive enhancement native, où les formulaires fonctionnent même sans JavaScript.

## Fondamentaux

### useFormState

`useFormState` lie un Server Action à un formulaire HTML, capturant l'état et les réponses du serveur.

```typescript
// app/actions.ts
'use server';

import { z } from 'zod';
import { db } from '@/lib/db';

const loginSchema = z.object({
  email: z.string().email('Email invalide'),
  password: z.string().min(8, 'Le mot de passe doit contenir au moins 8 caractères'),
});

export async function login(prevState: any, formData: FormData) {
  try {
    const email = formData.get('email') as string;
    const password = formData.get('password') as string;

    const validatedData = loginSchema.parse({ email, password });

    // Vérifier l'identité
    const user = await db.user.findUnique({
      where: { email: validatedData.email },
    });

    if (!user || !await verifyPassword(password, user.password)) {
      return {
        error: 'Email ou mot de passe incorrect',
        email: validatedData.email,
      };
    }

    // Créer la session
    await createSession(user);

    return {
      success: true,
      user: { id: user.id, email: user.email, name: user.name },
    };
  } catch (error) {
    if (error instanceof z.ZodError) {
      return {
        error: 'Validation échouée',
        fieldErrors: error.flatten().fieldErrors,
      };
    }
    return { error: 'Une erreur est survenue' };
  }
}

// app/components/LoginForm.tsx
'use client';

import { login } from '@/app/actions';
import { useFormState, useFormStatus } from 'react-dom';

export function LoginForm() {
  const [state, formAction] = useFormState(login, {});

  return (
    <form action={formAction} className="space-y-4 max-w-md">
      <div>
        <label htmlFor="email" className="block text-sm font-medium">
          Email
        </label>
        <input
          id="email"
          name="email"
          type="email"
          defaultValue={state.email}
          className="mt-1 block w-full px-3 py-2 border rounded-md"
          required
        />
        {state.fieldErrors?.email && (
          <p className="mt-1 text-sm text-red-600">
            {state.fieldErrors.email[0]}
          </p>
        )}
      </div>

      <div>
        <label htmlFor="password" className="block text-sm font-medium">
          Mot de passe
        </label>
        <input
          id="password"
          name="password"
          type="password"
          className="mt-1 block w-full px-3 py-2 border rounded-md"
          required
        />
        {state.fieldErrors?.password && (
          <p className="mt-1 text-sm text-red-600">
            {state.fieldErrors.password[0]}
          </p>
        )}
      </div>

      {state.error && (
        <div className="p-3 bg-red-100 text-red-800 rounded-md">
          {state.error}
        </div>
      )}

      {state.success && (
        <div className="p-3 bg-green-100 text-green-800 rounded-md">
          Connexion réussie! Redirection...
        </div>
      )}

      <SubmitButton />
    </form>
  );
}

function SubmitButton() {
  const { pending } = useFormStatus();

  return (
    <button
      type="submit"
      disabled={pending}
      className="w-full px-4 py-2 bg-blue-600 text-white rounded-md disabled:opacity-50"
    >
      {pending ? 'Connexion...' : 'Se connecter'}
    </button>
  );
}
```

### useFormStatus

`useFormStatus` fournit l'état du formulaire parent le plus proche, permettant d'afficher un feedback immédiat.

```typescript
// app/actions.ts
'use server';

export async function saveSettings(formData: FormData) {
  const userId = formData.get('userId') as string;
  const theme = formData.get('theme') as string;
  const notifications = formData.get('notifications') === 'on';

  await new Promise((resolve) => setTimeout(resolve, 1000)); // Simulation

  const result = await db.userSettings.update({
    where: { userId },
    data: { theme, notifications },
  });

  return { success: true, settings: result };
}

// app/components/SettingsForm.tsx
'use client';

import { saveSettings } from '@/app/actions';
import { useFormState, useFormStatus } from 'react-dom';

export function SettingsForm({ userId }: { userId: string }) {
  const [state, formAction] = useFormState(saveSettings, {});

  return (
    <form action={formAction} className="space-y-6">
      <input type="hidden" name="userId" value={userId} />

      <div>
        <label className="block text-sm font-medium mb-2">Thème</label>
        <ThemeSelector />
      </div>

      <div>
        <label className="block text-sm font-medium mb-2">Notifications</label>
        <NotificationToggle />
      </div>

      {state.success && (
        <div className="p-3 bg-green-100 text-green-800 rounded-md">
          Paramètres mis à jour avec succès!
        </div>
      )}

      <SaveButton />
    </form>
  );
}

function ThemeSelector() {
  const { pending } = useFormStatus();

  return (
    <select
      name="theme"
      disabled={pending}
      className="block w-full px-3 py-2 border rounded-md disabled:opacity-50"
    >
      <option value="light">Clair</option>
      <option value="dark">Sombre</option>
      <option value="auto">Automatique</option>
    </select>
  );
}

function NotificationToggle() {
  const { pending } = useFormStatus();

  return (
    <input
      type="checkbox"
      name="notifications"
      disabled={pending}
      defaultChecked={true}
      className="rounded disabled:opacity-50"
    />
  );
}

function SaveButton() {
  const { pending } = useFormStatus();

  return (
    <button
      type="submit"
      disabled={pending}
      className="px-6 py-2 bg-blue-600 text-white rounded-md disabled:opacity-50"
    >
      {pending ? (
        <span className="flex items-center gap-2">
          <span className="animate-spin">⚙️</span>
          Sauvegarde en cours...
        </span>
      ) : (
        'Sauvegarder'
      )}
    </button>
  );
}
```

## Patterns Avancés

### Formulaire Multi-étapes

```typescript
// app/actions.ts
'use server';

import { createSession } from '@/auth';
import { db } from '@/lib/db';

type SignupState = {
  step: 'personal' | 'security' | 'confirmation';
  personalData?: { name: string; email: string };
  error?: string;
  success?: boolean;
};

export async function signupStep1(
  prevState: SignupState,
  formData: FormData
): Promise<SignupState> {
  const name = formData.get('name') as string;
  const email = formData.get('email') as string;

  // Vérifier que l'email n'existe pas
  const existing = await db.user.findUnique({ where: { email } });
  if (existing) {
    return {
      ...prevState,
      step: 'personal',
      error: 'Cet email est déjà utilisé',
    };
  }

  return {
    step: 'security',
    personalData: { name, email },
  };
}

export async function signupStep2(
  prevState: SignupState,
  formData: FormData
): Promise<SignupState> {
  const password = formData.get('password') as string;
  const confirmPassword = formData.get('confirmPassword') as string;

  if (password !== confirmPassword) {
    return {
      ...prevState,
      error: 'Les mots de passe ne correspondent pas',
    };
  }

  if (password.length < 8) {
    return {
      ...prevState,
      error: 'Le mot de passe doit contenir au moins 8 caractères',
    };
  }

  return {
    step: 'confirmation',
    personalData: prevState.personalData,
  };
}

export async function signupComplete(
  prevState: SignupState,
  formData: FormData
): Promise<SignupState> {
  if (!prevState.personalData) {
    return { ...prevState, error: 'Données manquantes' };
  }

  try {
    const password = formData.get('password') as string;

    const user = await db.user.create({
      data: {
        name: prevState.personalData.name,
        email: prevState.personalData.email,
        password: await hashPassword(password),
      },
    });

    await createSession(user);

    return { step: 'confirmation', success: true };
  } catch (error) {
    return { step: 'confirmation', error: 'Erreur lors de la création du compte' };
  }
}

// app/components/SignupForm.tsx
'use client';

import { useState } from 'react';
import { useFormState, useFormStatus } from 'react-dom';
import { signupStep1, signupStep2, signupComplete } from '@/app/actions';

export function SignupForm() {
  const [state, formAction] = useFormState(signupStep1, {
    step: 'personal',
  } as any);

  return (
    <form action={formAction} className="max-w-md space-y-4">
      {state.step === 'personal' && (
        <>
          <h2 className="text-xl font-bold">Étape 1: Informations personnelles</h2>
          <input
            name="name"
            placeholder="Nom complet"
            required
            className="w-full px-3 py-2 border rounded-md"
          />
          <input
            name="email"
            type="email"
            placeholder="Email"
            required
            className="w-full px-3 py-2 border rounded-md"
          />
        </>
      )}

      {state.step === 'security' && (
        <>
          <h2 className="text-xl font-bold">Étape 2: Sécurité</h2>
          <input
            name="password"
            type="password"
            placeholder="Mot de passe"
            required
            className="w-full px-3 py-2 border rounded-md"
          />
          <input
            name="confirmPassword"
            type="password"
            placeholder="Confirmer le mot de passe"
            required
            className="w-full px-3 py-2 border rounded-md"
          />
        </>
      )}

      {state.step === 'confirmation' && !state.success && (
        <>
          <h2 className="text-xl font-bold">Confirmer</h2>
          <p className="text-gray-600">
            Bienvenue, {state.personalData?.name}! Cliquez sur "Créer un compte" pour confirmer.
          </p>
        </>
      )}

      {state.error && (
        <div className="p-3 bg-red-100 text-red-800 rounded-md">
          {state.error}
        </div>
      )}

      {state.success && (
        <div className="p-3 bg-green-100 text-green-800 rounded-md">
          Compte créé avec succès!
        </div>
      )}

      <StepButton step={state.step} />
    </form>
  );
}

type StepButtonProps = {
  step: 'personal' | 'security' | 'confirmation';
};

function StepButton({ step }: StepButtonProps) {
  const { pending } = useFormStatus();

  const buttonText = {
    personal: 'Suivant',
    security: 'Continuer',
    confirmation: 'Créer un compte',
  };

  return (
    <button
      type="submit"
      disabled={pending}
      className="w-full px-4 py-2 bg-blue-600 text-white rounded-md disabled:opacity-50"
    >
      {pending ? 'Traitement...' : buttonText[step]}
    </button>
  );
}
```

### Validation Progressive avec Feedback

```typescript
// app/actions.ts
'use server';

export async function validateEmail(formData: FormData) {
  const email = formData.get('email') as string;

  // Validation basique
  if (!email.includes('@')) {
    return { valid: false, error: 'Email invalide' };
  }

  // Vérifier la disponibilité
  const exists = await db.user.findUnique({ where: { email } });

  return {
    valid: !exists,
    error: exists ? 'Cet email est déjà utilisé' : null,
  };
}

// app/components/EmailInput.tsx
'use client';

import { validateEmail } from '@/app/actions';
import { useOptimistic } from 'react';
import { useState, useEffect } from 'react';

export function EmailInput() {
  const [email, setEmail] = useState('');
  const [validation, setValidation] = useState<any>(null);
  const [isChecking, setIsChecking] = useState(false);

  useEffect(() => {
    if (!email) return;

    const timer = setTimeout(async () => {
      setIsChecking(true);
      const result = await validateEmail(
        new FormData((() => {
          const form = new FormData();
          form.append('email', email);
          return form;
        })())
      );
      setValidation(result);
      setIsChecking(false);
    }, 500);

    return () => clearTimeout(timer);
  }, [email]);

  return (
    <div>
      <input
        type="email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        placeholder="Email"
        className="w-full px-3 py-2 border rounded-md"
      />
      {isChecking && <p className="text-gray-500 text-sm mt-1">Vérification...</p>}
      {validation?.error && (
        <p className="text-red-600 text-sm mt-1">{validation.error}</p>
      )}
      {validation?.valid && !isChecking && (
        <p className="text-green-600 text-sm mt-1">Email disponible!</p>
      )}
    </div>
  );
}
```

### Gestion des Fichiers

```typescript
// app/actions.ts
'use server';

import { writeFile, mkdir } from 'fs/promises';
import { join } from 'path';

const UPLOAD_DIR = join(process.cwd(), 'public', 'uploads');

export async function uploadFile(formData: FormData) {
  try {
    const file = formData.get('file') as File;

    if (!file) {
      return { error: 'Aucun fichier fourni' };
    }

    // Valider le type de fichier
    const allowedTypes = ['image/jpeg', 'image/png', 'application/pdf'];
    if (!allowedTypes.includes(file.type)) {
      return { error: 'Type de fichier non autorisé' };
    }

    // Valider la taille (max 5MB)
    if (file.size > 5 * 1024 * 1024) {
      return { error: 'Fichier trop volumineux' };
    }

    // Créer le répertoire s'il n'existe pas
    await mkdir(UPLOAD_DIR, { recursive: true });

    // Générer un nom unique
    const timestamp = Date.now();
    const filename = `${timestamp}-${file.name}`;
    const filepath = join(UPLOAD_DIR, filename);

    // Sauvegarder le fichier
    const bytes = await file.arrayBuffer();
    await writeFile(filepath, Buffer.from(bytes));

    return {
      success: true,
      filename,
      url: `/uploads/${filename}`,
    };
  } catch (error) {
    return { error: 'Erreur lors de l\'upload' };
  }
}

// app/components/FileUpload.tsx
'use client';

import { uploadFile } from '@/app/actions';
import { useFormState, useFormStatus } from 'react-dom';
import { useState } from 'react';

export function FileUpload() {
  const [state, formAction] = useFormState(uploadFile, {});
  const [preview, setPreview] = useState<string | null>(null);

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.currentTarget.files?.[0];
    if (file && file.type.startsWith('image/')) {
      const reader = new FileReader();
      reader.onload = (e) => setPreview(e.target?.result as string);
      reader.readAsDataURL(file);
    }
  };

  return (
    <form action={formAction} className="space-y-4">
      <div className="border-2 border-dashed rounded-lg p-8 text-center">
        <input
          type="file"
          name="file"
          onChange={handleFileChange}
          className="hidden"
          id="file-input"
        />
        <label htmlFor="file-input" className="cursor-pointer">
          <div className="text-4xl mb-2">📁</div>
          <p className="text-gray-600">Cliquez pour sélectionner un fichier</p>
          <p className="text-sm text-gray-500">JPG, PNG ou PDF - Max 5MB</p>
        </label>
      </div>

      {preview && (
        <div className="relative">
          <img src={preview} alt="Preview" className="max-h-48 rounded-lg" />
        </div>
      )}

      {state.error && (
        <div className="p-3 bg-red-100 text-red-800 rounded-md">
          {state.error}
        </div>
      )}

      {state.success && (
        <div className="p-3 bg-green-100 text-green-800 rounded-md">
          <p>Fichier uploadé avec succès!</p>
          <p className="text-sm">{state.url}</p>
        </div>
      )}

      <UploadButton />
    </form>
  );
}

function UploadButton() {
  const { pending } = useFormStatus();

  return (
    <button
      type="submit"
      disabled={pending}
      className="w-full px-4 py-2 bg-blue-600 text-white rounded-md disabled:opacity-50"
    >
      {pending ? 'Upload...' : 'Uploader'}
    </button>
  );
}
```

## Progressive Enhancement

### Formulaire Fonctionnant sans JavaScript

```typescript
// app/actions.ts
'use server';

import { redirect } from 'next/navigation';

export async function subscribeNewsletter(formData: FormData) {
  const email = formData.get('email') as string;

  if (!email || !email.includes('@')) {
    // Sans JS, on retourne au formulaire avec un message d'erreur
    // Avec JS, useFormState capture le résultat
    return { error: 'Email invalide' };
  }

  try {
    await db.subscriber.create({
      data: { email },
    });

    // Redirection - fonctionne avec et sans JavaScript
    redirect('/thank-you');
  } catch (error) {
    return { error: 'Cet email est déjà inscrit' };
  }
}

// app/components/NewsletterForm.tsx
'use client';

import { subscribeNewsletter } from '@/app/actions';
import { useFormState } from 'react-dom';

export function NewsletterForm() {
  const [state, formAction] = useFormState(subscribeNewsletter, {});

  return (
    <form action={formAction} className="flex gap-2">
      <input
        name="email"
        type="email"
        placeholder="Votre email"
        className="flex-1 px-4 py-2 border rounded-md"
        required
      />
      <button
        type="submit"
        className="px-4 py-2 bg-blue-600 text-white rounded-md"
      >
        S'inscrire
      </button>
      {state.error && (
        <p className="text-red-600 text-sm">{state.error}</p>
      )}
    </form>
  );
}
```

## Best Practices

### 1. Types Génériques pour les Actions

```typescript
type FormAction<T> = (prevState: T, formData: FormData) => Promise<T>;

type FormState = {
  errors?: Record<string, string[]>;
  success?: boolean;
  message?: string;
};

export const createPost: FormAction<FormState> = async (prevState, formData) => {
  // Implémentation
  return prevState;
};
```

### 2. Retry Logic

```typescript
// lib/actions-helpers.ts
export async function withRetry<T>(
  fn: () => Promise<T>,
  maxRetries = 3,
  delayMs = 1000
): Promise<T> {
  let lastError;

  for (let i = 0; i < maxRetries; i++) {
    try {
      return await fn();
    } catch (error) {
      lastError = error;
      if (i < maxRetries - 1) {
        await new Promise((resolve) => setTimeout(resolve, delayMs));
      }
    }
  }

  throw lastError;
}
```

### 3. Optimistic Updates

```typescript
'use client';

import { useOptimistic } from 'react';
import { updateTodoStatus } from '@/app/actions';

type Todo = {
  id: string;
  title: string;
  completed: boolean;
};

export function TodoItem({ todo }: { todo: Todo }) {
  const [optimisticTodo, addOptimisticTodo] = useOptimistic<Todo>(
    todo,
    (state, completed: boolean) => ({
      ...state,
      completed,
    })
  );

  async function handleToggle() {
    addOptimisticTodo(!optimisticTodo.completed);
    await updateTodoStatus(todo.id, !optimisticTodo.completed);
  }

  return (
    <div className="flex items-center gap-2">
      <input
        type="checkbox"
        checked={optimisticTodo.completed}
        onChange={handleToggle}
      />
      <span className={optimisticTodo.completed ? 'line-through' : ''}>
        {optimisticTodo.title}
      </span>
    </div>
  );
}
```

## Points Clés

- **useFormState**: Lie un Server Action à un formulaire HTML
- **useFormStatus**: Accède à l'état du formulaire parent
- **Progressive enhancement**: Les formulaires fonctionnent sans JavaScript
- **Validation côté serveur**: Toujours valider sur le serveur
- **Type-safe**: Les données sont complètement typées
- **Optimistic updates**: Mettez à jour l'UI avant la réponse du serveur
