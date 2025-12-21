---
name: nextjs:session-management
description: Manage sessions with cookies, server-side validation, and protected route patterns for secure user state
---

# Session Management in Next.js

Session management combines cookies for client-side identification, server-side validation for security, and protected route patterns to maintain user state securely across the application.

## Cookie-Based Session Storage

```typescript
// lib/session.ts
import { cookies } from 'next/headers';
import { SignJWT, jwtVerify } from 'jose';
import { ResponseCookie } from 'next/dist/compiled/@edge-runtime/cookies';

const secret = new TextEncoder().encode(process.env.SESSION_SECRET || 'secret');
const SESSION_DURATION = 30 * 24 * 60 * 60 * 1000; // 30 days

export type SessionData = {
  userId: string;
  email: string;
  name: string;
  role: string;
  lastActivity: number;
};

export async function createSession(userData: Omit<SessionData, 'lastActivity'>) {
  const cookieStore = await cookies();

  // Create JWT token
  const token = await new SignJWT({
    ...userData,
    lastActivity: Date.now(),
  })
    .setProtectedHeader({ alg: 'HS256' })
    .setExpirationTime('30d')
    .sign(secret);

  // Set cookie
  const cookieOptions: ResponseCookie = {
    name: 'session',
    value: token,
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'lax',
    maxAge: SESSION_DURATION,
    path: '/',
  };

  cookieStore.set(cookieOptions);

  return token;
}

export async function getSession(): Promise<SessionData | null> {
  const cookieStore = await cookies();
  const sessionCookie = cookieStore.get('session');

  if (!sessionCookie?.value) {
    return null;
  }

  try {
    const verified = await jwtVerify(sessionCookie.value, secret);
    return verified.payload as SessionData;
  } catch (error) {
    return null;
  }
}

export async function updateSessionActivity() {
  const session = await getSession();

  if (!session) {
    return null;
  }

  // Update activity timestamp
  session.lastActivity = Date.now();

  return await createSession({
    userId: session.userId,
    email: session.email,
    name: session.name,
    role: session.role,
  });
}

export async function destroySession() {
  const cookieStore = await cookies();
  cookieStore.delete('session');
}

export async function isSessionExpired(session: SessionData): Promise<boolean> {
  const inactivityLimit = 24 * 60 * 60 * 1000; // 24 hours
  const now = Date.now();

  return now - session.lastActivity > inactivityLimit;
}
```

## Protected Routes with Session Validation

```typescript
// app/(protected)/layout.tsx
import { getSession } from '@/lib/session';
import { redirect } from 'next/navigation';
import { ReactNode } from 'react';

export default async function ProtectedLayout({
  children,
}: {
  children: ReactNode;
}) {
  const session = await getSession();

  // Redirect to login if no session
  if (!session) {
    redirect('/login');
  }

  return <>{children}</>;
}

// Specific protected page
// app/(protected)/dashboard/page.tsx
import { getSession, updateSessionActivity } from '@/lib/session';

export default async function DashboardPage() {
  // Update activity timestamp
  await updateSessionActivity();

  const session = await getSession();

  if (!session) {
    return null;
  }

  return (
    <div>
      <h1>Dashboard</h1>
      <p>Welcome, {session.name}</p>
      <p>Your role: {session.role}</p>
    </div>
  );
}
```

## Session Middleware

```typescript
// middleware.ts
import { NextRequest, NextResponse } from 'next/server';
import { jwtVerify } from 'jose';

const secret = new TextEncoder().encode(process.env.SESSION_SECRET || 'secret');

const protectedRoutes = ['/dashboard', '/profile', '/admin', '/settings'];
const publicRoutes = ['/login', '/register', '/forgot-password'];

export async function middleware(request: NextRequest) {
  const pathname = request.nextUrl.pathname;
  const sessionCookie = request.cookies.get('session')?.value;

  // Check if route is protected
  const isProtectedRoute = protectedRoutes.some((route) =>
    pathname.startsWith(route)
  );

  if (isProtectedRoute) {
    // Validate session
    if (!sessionCookie) {
      return NextResponse.redirect(new URL('/login', request.url));
    }

    try {
      await jwtVerify(sessionCookie, secret);

      // Session is valid, continue
      return NextResponse.next();
    } catch (error) {
      // Invalid session, redirect to login
      return NextResponse.redirect(new URL('/login', request.url));
    }
  }

  // Redirect authenticated users away from login page
  if (publicRoutes.includes(pathname) && sessionCookie) {
    try {
      await jwtVerify(sessionCookie, secret);
      return NextResponse.redirect(new URL('/dashboard', request.url));
    } catch (error) {
      // Invalid token, allow access to public route
    }
  }

  return NextResponse.next();
}

export const config = {
  matcher: ['/((?!api|_next|public).*)', '/api/protected/:path*'],
};
```

## Session Server Actions

```typescript
// app/actions/session.ts
'use server';

import {
  createSession,
  destroySession,
  getSession,
  updateSessionActivity,
} from '@/lib/session';
import { prisma } from '@/lib/db';
import bcrypt from 'bcryptjs';
import { redirect } from 'next/navigation';

export async function loginUser(email: string, password: string) {
  try {
    // Find user
    const user = await prisma.user.findUnique({
      where: { email },
      select: {
        id: true,
        email: true,
        name: true,
        password: true,
        role: true,
      },
    });

    if (!user) {
      return { success: false, error: 'Invalid email or password' };
    }

    // Verify password
    const isValid = await bcrypt.compare(password, user.password || '');

    if (!isValid) {
      return { success: false, error: 'Invalid email or password' };
    }

    // Create session
    await createSession({
      userId: user.id,
      email: user.email,
      name: user.name,
      role: user.role,
    });

    return { success: true };
  } catch (error) {
    console.error('Login error:', error);
    return { success: false, error: 'Login failed' };
  }
}

export async function logoutUser() {
  await destroySession();
  redirect('/login');
}

export async function getCurrentSession() {
  return await getSession();
}

export async function refreshSessionActivity() {
  const session = await getSession();

  if (!session) {
    return null;
  }

  return await updateSessionActivity();
}

export async function validateUserPermission(requiredRole: string) {
  const session = await getSession();

  if (!session) {
    return false;
  }

  if (session.role !== requiredRole && session.role !== 'admin') {
    return false;
  }

  return true;
}
```

## Session Context for Client Components

```typescript
// app/context/SessionContext.tsx
'use client';

import { createContext, useContext, useEffect, useState, ReactNode } from 'react';
import { SessionData } from '@/lib/session';
import { getCurrentSession, refreshSessionActivity } from '@/app/actions/session';

type SessionContextType = {
  session: SessionData | null;
  isLoading: boolean;
  refresh: () => Promise<void>;
};

const SessionContext = createContext<SessionContextType | undefined>(undefined);

export function SessionProvider({ children }: { children: ReactNode }) {
  const [session, setSession] = useState<SessionData | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  // Load session on mount
  useEffect(() => {
    const loadSession = async () => {
      try {
        const sessionData = await getCurrentSession();
        setSession(sessionData);
      } catch (error) {
        console.error('Failed to load session:', error);
      } finally {
        setIsLoading(false);
      }
    };

    loadSession();
  }, []);

  // Refresh activity on user interaction
  useEffect(() => {
    const handleActivity = async () => {
      try {
        await refreshSessionActivity();
      } catch (error) {
        console.error('Failed to refresh session:', error);
      }
    };

    // Update activity on interaction
    window.addEventListener('click', handleActivity);
    window.addEventListener('keypress', handleActivity);

    return () => {
      window.removeEventListener('click', handleActivity);
      window.removeEventListener('keypress', handleActivity);
    };
  }, []);

  const refresh = async () => {
    try {
      const sessionData = await getCurrentSession();
      setSession(sessionData);
    } catch (error) {
      console.error('Failed to refresh session:', error);
    }
  };

  return (
    <SessionContext.Provider value={{ session, isLoading, refresh }}>
      {children}
    </SessionContext.Provider>
  );
}

export function useSession() {
  const context = useContext(SessionContext);

  if (context === undefined) {
    throw new Error('useSession must be used within SessionProvider');
  }

  return context;
}
```

## Session Expiration Handler

```typescript
// app/hooks/useSessionExpiration.ts
'use client';

import { useEffect, useCallback } from 'react';
import { useRouter } from 'next/navigation';
import { useSession } from '@/app/context/SessionContext';
import { logoutUser } from '@/app/actions/session';

const INACTIVITY_TIMEOUT = 30 * 60 * 1000; // 30 minutes
const WARNING_TIME = 5 * 60 * 1000; // 5 minutes before expiration

export function useSessionExpiration() {
  const router = useRouter();
  const { session } = useSession();

  const handleSessionExpired = useCallback(async () => {
    console.log('Session expired due to inactivity');
    await logoutUser();
    router.push('/login?reason=session-expired');
  }, [router]);

  const handleSessionWarning = useCallback(() => {
    // Show warning to user (implement your own warning UI)
    console.warn('Session will expire soon');
    // dispatch custom event or show toast
  }, []);

  useEffect(() => {
    if (!session) return;

    let inactivityTimer: NodeJS.Timeout;
    let warningTimer: NodeJS.Timeout;

    const resetTimers = () => {
      clearTimeout(inactivityTimer);
      clearTimeout(warningTimer);

      // Set warning timer
      warningTimer = setTimeout(
        handleSessionWarning,
        INACTIVITY_TIMEOUT - WARNING_TIME
      );

      // Set expiration timer
      inactivityTimer = setTimeout(
        handleSessionExpired,
        INACTIVITY_TIMEOUT
      );
    };

    const handleActivity = () => {
      resetTimers();
    };

    // Reset timers on activity
    window.addEventListener('click', handleActivity);
    window.addEventListener('keypress', handleActivity);
    window.addEventListener('mousemove', handleActivity);

    // Initialize timers
    resetTimers();

    return () => {
      clearTimeout(inactivityTimer);
      clearTimeout(warningTimer);
      window.removeEventListener('click', handleActivity);
      window.removeEventListener('keypress', handleActivity);
      window.removeEventListener('mousemove', handleActivity);
    };
  }, [session, handleSessionExpired, handleSessionWarning]);
}
```

## Multi-Tab Session Sync

```typescript
// app/hooks/useSessionSync.ts
'use client';

import { useEffect } from 'react';
import { useSession } from '@/app/context/SessionContext';

export function useSessionSync() {
  const { refresh } = useSession();

  useEffect(() => {
    const handleStorageChange = (event: StorageEvent) => {
      if (event.key === 'sessionRefresh') {
        refresh();
      }
    };

    const handleVisibilityChange = async () => {
      if (!document.hidden) {
        // Tab became visible, refresh session
        await refresh();
      }
    };

    window.addEventListener('storage', handleStorageChange);
    document.addEventListener('visibilitychange', handleVisibilityChange);

    return () => {
      window.removeEventListener('storage', handleStorageChange);
      document.removeEventListener('visibilitychange', handleVisibilityChange);
    };
  }, [refresh]);

  // Trigger sync in other tabs
  const triggerSync = () => {
    localStorage.setItem('sessionRefresh', Date.now().toString());
  };

  return { triggerSync };
}
```

## Session Storage with Database

```typescript
// lib/session-store.ts
import { prisma } from '@/lib/db';

export type SessionStore = {
  sessionId: string;
  userId: string;
  data: Record<string, any>;
  expiresAt: Date;
  createdAt: Date;
  updatedAt: Date;
};

export async function storeSessionInDatabase(
  sessionId: string,
  userId: string,
  data: Record<string, any>,
  expiresIn: number // milliseconds
) {
  const expiresAt = new Date(Date.now() + expiresIn);

  return await prisma.session.upsert({
    where: { sessionId },
    update: {
      data,
      expiresAt,
      updatedAt: new Date(),
    },
    create: {
      sessionId,
      userId,
      data,
      expiresAt,
    },
  });
}

export async function getSessionFromDatabase(
  sessionId: string
): Promise<SessionStore | null> {
  const session = await prisma.session.findUnique({
    where: { sessionId },
  });

  if (!session) {
    return null;
  }

  // Check if expired
  if (session.expiresAt < new Date()) {
    await prisma.session.delete({
      where: { sessionId },
    });
    return null;
  }

  return session;
}

export async function destroySessionFromDatabase(sessionId: string) {
  return await prisma.session.delete({
    where: { sessionId },
  });
}

export async function cleanupExpiredSessions() {
  return await prisma.session.deleteMany({
    where: {
      expiresAt: {
        lt: new Date(),
      },
    },
  });
}
```

## Security Considerations

1. **HttpOnly Cookies**: Always use HttpOnly flag for session cookies
2. **Secure Flag**: Use Secure flag in production (HTTPS only)
3. **SameSite**: Set SameSite=Lax or Strict to prevent CSRF
4. **Session Expiration**: Implement proper expiration times
5. **Activity Tracking**: Update last activity timestamp
6. **Token Rotation**: Rotate tokens periodically
7. **Secure Storage**: Store sensitive data in database, not cookies
8. **Cleanup**: Implement job to delete expired sessions

## Best Practices

- Use short-lived access tokens with refresh tokens
- Implement session activity tracking
- Validate session on every protected request
- Handle session expiration gracefully
- Implement multi-tab session sync
- Log all session events for audit trail
- Implement proper error handling
- Test session edge cases thoroughly
- Use database storage for sensitive session data
- Monitor session metrics and anomalies
