# Reference

# Authentication Patterns in Next.js

Modern authentication in Next.js combines NextAuth.js v5, JWT tokens, and server-side validation to provide secure user authentication and authorization.

## NextAuth.js v5 Setup

```typescript
// auth.ts (root level)
import NextAuth from 'next-auth';
import Credentials from 'next-auth/providers/credentials';
import GitHub from 'next-auth/providers/github';
import Google from 'next-auth/providers/google';
import { PrismaAdapter } from '@auth/prisma-adapter';
import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

export const { handlers, auth, signIn, signOut } = NextAuth({
  adapter: PrismaAdapter(prisma),
  providers: [
    // OAuth Providers
    GitHub({
      clientId: process.env.AUTH_GITHUB_ID || '',
      clientSecret: process.env.AUTH_GITHUB_SECRET || '',
    }),
    Google({
      clientId: process.env.AUTH_GOOGLE_ID || '',
      clientSecret: process.env.AUTH_GOOGLE_SECRET || '',
    }),
    // Credentials Provider
    Credentials({
      name: 'Credentials',
      credentials: {
        email: { label: 'Email', type: 'email' },
        password: { label: 'Password', type: 'password' },
      },
      async authorize(credentials) {
        if (!credentials?.email || !credentials?.password) {
          return null;
        }

        const user = await prisma.user.findUnique({
          where: { email: credentials.email as string },
        });

        if (!user) {
          return null;
        }

        const isPasswordValid = await bcrypt.compare(
          credentials.password as string,
          user.password || ''
        );

        if (!isPasswordValid) {
          return null;
        }

        return {
          id: user.id,
          email: user.email,
          name: user.name,
          role: user.role,
        };
      },
    }),
  ],
  pages: {
    signIn: '/login',
    signOut: '/logout',
    error: '/auth/error',
    verifyRequest: '/auth/verify-request',
    newUser: '/auth/new-user',
  },
  callbacks: {
    async jwt({ token, user, account }) {
      // Initial sign in
      if (user) {
        token.id = user.id;
        token.role = (user as any).role || 'user';
      }

      // OAuth account linking
      if (account) {
        token.provider = account.provider;
      }

      return token;
    },
    async session({ session, token }) {
      if (session.user) {
        session.user.id = token.id as string;
        (session.user as any).role = token.role;
      }
      return session;
    },
    async redirect({ url, baseUrl }) {
      // Allow callbacks if same origin
      if (url.startsWith('/')) return `${baseUrl}${url}`;

      if (new URL(url).origin === baseUrl) return url;

      return baseUrl;
    },
  },
  events: {
    async signIn({ user, account, profile, isNewUser }) {
      console.log(`User ${user?.email} signed in via ${account?.provider}`);

      // Track sign-in events
      if (isNewUser) {
        await logNewUser(user?.email);
      }
    },
    async signOut({ token }) {
      console.log(`User ${token.email} signed out`);
    },
  },
  session: {
    strategy: 'jwt',
    maxAge: 30 * 24 * 60 * 60, // 30 days
    updateAge: 24 * 60 * 60, // Update every 24 hours
  },
  jwt: {
    secret: process.env.NEXTAUTH_SECRET,
    maxAge: 30 * 24 * 60 * 60, // 30 days
  },
});

async function logNewUser(email: string | null | undefined) {
  // Send welcome email, track analytics, etc.
  console.log(`New user registered: ${email}`);
}
```

## API Routes Configuration

```typescript
// app/api/auth/[...nextauth]/route.ts
import { handlers } from '@/auth';

export const { GET, POST } = handlers;
```

## Sign In Server Action

```typescript
// app/actions/auth.ts
'use server';

import { signIn, signOut } from '@/auth';
import { AuthError } from 'next-auth';
import bcrypt from 'bcryptjs';
import { prisma } from '@/lib/db';
import { redirect } from 'next/navigation';

export async function loginWithCredentials(
  email: string,
  password: string
) {
  try {
    const result = await signIn('credentials', {
      email,
      password,
      redirect: false,
    });

    if (!result?.ok) {
      return {
        success: false,
        error: result?.error || 'Invalid email or password',
      };
    }

    return { success: true };
  } catch (error) {
    if (error instanceof AuthError) {
      return {
        success: false,
        error: error.cause?.err?.message || 'Authentication failed',
      };
    }

    throw error;
  }
}

export async function registerUser(
  email: string,
  name: string,
  password: string
) {
  try {
    // Check if user exists
    const existingUser = await prisma.user.findUnique({
      where: { email },
    });

    if (existingUser) {
      return {
        success: false,
        error: 'Email already registered',
      };
    }

    // Validate password strength
    if (password.length < 8) {
      return {
        success: false,
        error: 'Password must be at least 8 characters',
      };
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create user
    const user = await prisma.user.create({
      data: {
        email,
        name,
        password: hashedPassword,
        role: 'user',
      },
    });

    // Sign in user
    await signIn('credentials', {
      email,
      password,
      redirect: false,
    });

    return { success: true, userId: user.id };
  } catch (error) {
    console.error('Registration error:', error);
    return {
      success: false,
      error: 'Failed to register user',
    };
  }
}

export async function logoutUser() {
  await signOut({ redirectTo: '/login' });
}
```

## Protected Components

```typescript
// app/components/ProtectedComponent.tsx
import { auth } from '@/auth';
import { redirect } from 'next/navigation';

export async function ProtectedComponent() {
  const session = await auth();

  if (!session?.user) {
    redirect('/login');
  }

  return (
    <div>
      <h1>Welcome, {session.user.name}</h1>
      <p>Email: {session.user.email}</p>
      <p>Role: {(session.user as any).role}</p>
    </div>
  );
}
```

## Role-Based Component Access

```typescript
// app/components/AdminOnly.tsx
import { auth } from '@/auth';
import { ReactNode } from 'react';

type AdminOnlyProps = {
  children: ReactNode;
  fallback?: ReactNode;
};

export async function AdminOnly({ children, fallback }: AdminOnlyProps) {
  const session = await auth();

  if (!session?.user) {
    return fallback || <div>Please log in</div>;
  }

  const userRole = (session.user as any).role;

  if (userRole !== 'admin') {
    return fallback || <div>Access denied</div>;
  }

  return <>{children}</>;
}
```

## Login Form Component

```typescript
// app/components/LoginForm.tsx
'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { loginWithCredentials } from '@/app/actions/auth';

export function LoginForm() {
  const router = useRouter();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setIsLoading(true);

    try {
      const result = await loginWithCredentials(email, password);

      if (!result.success) {
        setError(result.error);
        return;
      }

      router.push('/dashboard');
      router.refresh();
    } catch (error) {
      setError('An error occurred. Please try again.');
      console.error(error);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      {error && (
        <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded">
          {error}
        </div>
      )}

      <div>
        <label className="block text-sm font-medium mb-2">Email</label>
        <input
          type="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          className="w-full px-4 py-2 border rounded"
          required
          disabled={isLoading}
        />
      </div>

      <div>
        <label className="block text-sm font-medium mb-2">Password</label>
        <input
          type="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          className="w-full px-4 py-2 border rounded"
          required
          disabled={isLoading}
        />
      </div>

      <button
        type="submit"
        disabled={isLoading}
        className="w-full bg-blue-600 text-white py-2 rounded disabled:opacity-50"
      >
        {isLoading ? 'Signing in...' : 'Sign In'}
      </button>
    </form>
  );
}
```

## JWT-Based Custom Authentication

```typescript
// lib/jwt.ts
import { jwtVerify, SignJWT } from 'jose';

const secret = new TextEncoder().encode(process.env.JWT_SECRET || '');

export async function createToken(payload: any, expiresIn: string = '7d') {
  const token = await new SignJWT(payload)
    .setProtectedHeader({ alg: 'HS256' })
    .setExpirationTime(expiresIn)
    .sign(secret);

  return token;
}

export async function verifyToken(token: string) {
  try {
    const verified = await jwtVerify(token, secret);
    return verified.payload;
  } catch (error) {
    return null;
  }
}

// API Route for token creation
// app/api/auth/token/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { createToken } from '@/lib/jwt';

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { userId, email, role } = body;

    const token = await createToken(
      {
        sub: userId,
        email,
        role,
      },
      '7d'
    );

    return NextResponse.json(
      { success: true, token },
      {
        headers: {
          'Set-Cookie': `token=${token}; Path=/; HttpOnly; Secure; SameSite=Strict`,
        },
      }
    );
  } catch (error) {
    return NextResponse.json(
      { success: false, message: 'Failed to create token' },
      { status: 500 }
    );
  }
}
```

## Protected API Routes

```typescript
// lib/auth-utils.ts
import { NextRequest, NextResponse } from 'next/server';
import { auth } from '@/auth';

export async function requireAuth(request: NextRequest) {
  const session = await auth();

  if (!session?.user) {
    return NextResponse.json(
      { success: false, message: 'Unauthorized' },
      { status: 401 }
    );
  }

  return session;
}

export async function requireRole(request: NextRequest, allowedRoles: string[]) {
  const session = await auth();

  if (!session?.user) {
    return null;
  }

  const userRole = (session.user as any).role;

  if (!allowedRoles.includes(userRole)) {
    return NextResponse.json(
      { success: false, message: 'Forbidden' },
      { status: 403 }
    );
  }

  return session;
}

// Usage in API route
// app/api/admin/users/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { requireRole } from '@/lib/auth-utils';

export async function GET(request: NextRequest) {
  const authResult = await requireRole(request, ['admin']);

  if (authResult instanceof NextResponse) {
    return authResult;
  }

  // Proceed with admin-only logic
  const users = await db.user.findMany();

  return NextResponse.json({
    success: true,
    data: users,
  });
}
```

## Refresh Token Pattern

```typescript
// app/api/auth/refresh/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { jwtVerify, SignJWT } from 'jose';

const secret = new TextEncoder().encode(process.env.JWT_SECRET || '');

export async function POST(request: NextRequest) {
  try {
    const refreshToken = request.cookies.get('refresh_token')?.value;

    if (!refreshToken) {
      return NextResponse.json(
        { success: false, message: 'No refresh token' },
        { status: 401 }
      );
    }

    // Verify refresh token
    const verified = await jwtVerify(refreshToken, secret);

    // Create new access token
    const newAccessToken = await new SignJWT(verified.payload)
      .setProtectedHeader({ alg: 'HS256' })
      .setExpirationTime('1h')
      .sign(secret);

    const response = NextResponse.json({
      success: true,
      accessToken: newAccessToken,
    });

    response.cookies.set('token', newAccessToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'strict',
      maxAge: 3600,
    });

    return response;
  } catch (error) {
    return NextResponse.json(
      { success: false, message: 'Token refresh failed' },
      { status: 401 }
    );
  }
}
```

## Security Considerations

1. **Password Hashing**: Use bcrypt or similar for password hashing
2. **HTTPS Only**: Always use HTTPS in production
3. **Secure Cookies**: Set HttpOnly, Secure, and SameSite flags
4. **Token Expiration**: Implement proper token expiration
5. **Refresh Tokens**: Use refresh tokens for long sessions
6. **CSRF Protection**: NextAuth.js handles CSRF automatically
7. **Rate Limiting**: Implement rate limiting on auth endpoints
8. **Audit Logging**: Log all authentication events

## Best Practices

- Use NextAuth.js v5 for production authentication
- Implement role-based access control
- Use server-side session validation
- Implement refresh token rotation
- Monitor failed login attempts
- Implement account lockout after failed attempts
- Send verification emails for registration
- Implement password reset flows
- Use multi-factor authentication
- Keep secrets in environment variables
