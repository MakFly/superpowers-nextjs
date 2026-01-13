# Reference

# Middleware in Next.js

Middleware runs before a request is processed and can modify requests and responses, handle authentication, redirects, and request logging at the edge level.

## Basic Middleware Setup

```typescript
// middleware.ts (root level, not in app/)
import { NextRequest, NextResponse } from 'next/server';
import type { NextMiddleware } from 'next/server';

// This function can be marked `async` if using `await` inside
export const middleware: NextMiddleware = async (request: NextRequest) => {
  // Log request
  console.log(`[Middleware] ${request.method} ${request.nextUrl.pathname}`);

  // Continue to next handler
  return NextResponse.next();
};

// Configure which routes use this middleware
export const config = {
  matcher: [
    // Match all routes except:
    // - api/auth/* (authentication routes)
    // - _next/static/* (static files)
    // - _next/image/* (image optimization files)
    // - favicon.ico (favicon file)
    // - public/* (public files)
    '/((?!api/auth|_next/static|_next/image|favicon.ico|public).*)',
  ],
};
```

## Authentication Middleware

```typescript
// middleware.ts
import { NextRequest, NextResponse } from 'next/server';
import { jwtVerify } from 'jose';

const secret = new TextEncoder().encode(process.env.JWT_SECRET || '');

export async function middleware(request: NextRequest) {
  const token = request.cookies.get('token')?.value;

  // Define protected routes
  const protectedRoutes = [
    '/dashboard',
    '/admin',
    '/profile',
    '/settings',
  ];

  const pathname = request.nextUrl.pathname;
  const isProtectedRoute = protectedRoutes.some((route) =>
    pathname.startsWith(route)
  );

  // Check if route is protected
  if (isProtectedRoute) {
    if (!token) {
      // Redirect to login
      return NextResponse.redirect(new URL('/login', request.url));
    }

    try {
      // Verify token
      const verified = await jwtVerify(token, secret);

      // Create response and clone it to add custom headers
      const response = NextResponse.next();

      // Add user info to response headers for components to access
      response.headers.set('x-user-id', verified.payload.sub as string);
      response.headers.set('x-user-role', verified.payload.role as string);

      return response;
    } catch (error) {
      console.error('Token verification failed:', error);
      // Redirect to login for invalid token
      return NextResponse.redirect(new URL('/login', request.url));
    }
  }

  return NextResponse.next();
}

export const config = {
  matcher: ['/((?!api|_next|favicon).*)', '/api/protected/:path*'],
};
```

## Role-Based Access Control (RBAC)

```typescript
// middleware.ts
import { NextRequest, NextResponse } from 'next/server';
import { jwtVerify } from 'jose';

const secret = new TextEncoder().encode(process.env.JWT_SECRET || '');

// Define role-based route access
const roleBasedRoutes: Record<string, string[]> = {
  '/admin': ['admin'],
  '/editor': ['admin', 'editor'],
  '/moderator': ['admin', 'moderator'],
  '/user': ['user', 'editor', 'admin'],
};

export async function middleware(request: NextRequest) {
  const token = request.cookies.get('token')?.value;
  const pathname = request.nextUrl.pathname;

  // Find matching route rule
  const matchedRoute = Object.keys(roleBasedRoutes).find((route) =>
    pathname.startsWith(route)
  );

  if (matchedRoute) {
    if (!token) {
      return NextResponse.redirect(new URL('/login', request.url));
    }

    try {
      const verified = await jwtVerify(token, secret);
      const userRole = verified.payload.role as string;
      const allowedRoles = roleBasedRoutes[matchedRoute];

      // Check if user role is allowed
      if (!allowedRoles.includes(userRole)) {
        return NextResponse.redirect(new URL('/unauthorized', request.url));
      }

      const response = NextResponse.next();
      response.headers.set('x-user-role', userRole);
      return response;
    } catch (error) {
      return NextResponse.redirect(new URL('/login', request.url));
    }
  }

  return NextResponse.next();
}

export const config = {
  matcher: ['/admin/:path*', '/editor/:path*', '/moderator/:path*'],
};
```

## Request Logging and Monitoring

```typescript
// middleware.ts
import { NextRequest, NextResponse } from 'next/server';

export async function middleware(request: NextRequest) {
  const startTime = Date.now();

  const pathname = request.nextUrl.pathname;
  const method = request.method;
  const userAgent = request.headers.get('user-agent');
  const ip =
    request.headers.get('x-forwarded-for') ||
    request.headers.get('x-real-ip') ||
    'unknown';

  // Create response
  const response = NextResponse.next();

  // Add timing header
  const duration = Date.now() - startTime;
  response.headers.set('x-response-time', `${duration}ms`);

  // Log request details
  const logData = {
    timestamp: new Date().toISOString(),
    method,
    pathname,
    ip,
    userAgent,
    duration,
    status: response.status,
  };

  // Send to logging service
  await logRequest(logData);

  return response;
}

async function logRequest(data: any) {
  try {
    // Send to external logging service, e.g., Datadog, LogRocket
    console.log('[Request Log]', JSON.stringify(data));
    // await fetch('https://logs.service.com/log', { method: 'POST', body: JSON.stringify(data) });
  } catch (error) {
    console.error('Logging error:', error);
  }
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico).*)', '/api/:path*'],
};
```

## Conditional Redirects

```typescript
// middleware.ts
import { NextRequest, NextResponse } from 'next/server';

export async function middleware(request: NextRequest) {
  const pathname = request.nextUrl.pathname;
  const token = request.cookies.get('token')?.value;

  // Redirect authenticated users away from login page
  if (pathname === '/login' && token) {
    return NextResponse.redirect(new URL('/dashboard', request.url));
  }

  // Redirect unauthenticated users to login
  if (pathname === '/dashboard' && !token) {
    return NextResponse.redirect(new URL('/login', request.url));
  }

  // Redirect old URLs to new ones
  if (pathname === '/old-path') {
    return NextResponse.redirect(new URL('/new-path', request.url), {
      status: 301, // Permanent redirect
    });
  }

  // Redirect based on locale preference
  const locale = request.headers.get('accept-language')?.split(',')[0] || 'en';
  if (!pathname.startsWith('/en') && !pathname.startsWith('/fr')) {
    return NextResponse.redirect(
      new URL(`/${locale}${pathname}`, request.url)
    );
  }

  return NextResponse.next();
}

export const config = {
  matcher: ['/((?!api|_next|public).*)', '/api/:path*'],
};
```

## Request/Response Modification

```typescript
// middleware.ts
import { NextRequest, NextResponse } from 'next/server';

export async function middleware(request: NextRequest) {
  // Clone request headers
  const requestHeaders = new Headers(request.headers);

  // Add custom headers
  requestHeaders.set('x-request-id', generateRequestId());
  requestHeaders.set('x-processed-at', new Date().toISOString());

  // Get user ID from cookie/token
  const userId = extractUserIdFromToken(request);
  if (userId) {
    requestHeaders.set('x-user-id', userId);
  }

  // Create new request with modified headers
  const response = NextResponse.next({
    request: {
      headers: requestHeaders,
    },
  });

  // Add security headers to response
  response.headers.set('X-Content-Type-Options', 'nosniff');
  response.headers.set('X-Frame-Options', 'DENY');
  response.headers.set('X-XSS-Protection', '1; mode=block');
  response.headers.set('Referrer-Policy', 'strict-origin-when-cross-origin');

  // Add CORS headers for API routes
  if (request.nextUrl.pathname.startsWith('/api/')) {
    response.headers.set('Access-Control-Allow-Origin', '*');
    response.headers.set(
      'Access-Control-Allow-Methods',
      'GET, POST, PUT, DELETE, OPTIONS'
    );
    response.headers.set('Access-Control-Allow-Headers', 'Content-Type');
  }

  return response;
}

function generateRequestId(): string {
  return `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
}

function extractUserIdFromToken(request: NextRequest): string | null {
  const token = request.cookies.get('token')?.value;
  if (!token) return null;

  try {
    // Decode token (simplified, use jwtVerify in production)
    const payload = JSON.parse(
      Buffer.from(token.split('.')[1], 'base64').toString()
    );
    return payload.sub;
  } catch {
    return null;
  }
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico).*)', '/api/:path*'],
};
```

## Maintenance Mode

```typescript
// middleware.ts
import { NextRequest, NextResponse } from 'next/server';

export async function middleware(request: NextRequest) {
  const maintenanceMode = process.env.MAINTENANCE_MODE === 'true';
  const maintenanceBypassToken = process.env.MAINTENANCE_BYPASS_TOKEN;
  const bypassToken = request.cookies.get('maintenance-bypass')?.value;

  // Check maintenance mode
  if (maintenanceMode) {
    // Allow bypass with token
    if (bypassToken === maintenanceBypassToken) {
      return NextResponse.next();
    }

    // Allow admin/API requests
    if (
      request.nextUrl.pathname.startsWith('/api/admin') ||
      request.nextUrl.pathname.startsWith('/admin')
    ) {
      return NextResponse.next();
    }

    // Redirect to maintenance page
    return NextResponse.rewrite(new URL('/maintenance', request.url));
  }

  return NextResponse.next();
}

export const config = {
  matcher: ['/((?!_next|public).*)', '/api/:path*'],
};
```

## Rate Limiting Middleware

```typescript
// middleware.ts
import { NextRequest, NextResponse } from 'next/server';

// In-memory store (use Redis for production)
const requestCounts = new Map<string, { count: number; resetTime: number }>();

export async function middleware(request: NextRequest) {
  const ip =
    request.headers.get('x-forwarded-for') ||
    request.headers.get('x-real-ip') ||
    'unknown';

  const now = Date.now();
  const key = `${ip}-${request.nextUrl.pathname}`;

  let record = requestCounts.get(key);

  // Reset if time window expired
  if (!record || now > record.resetTime) {
    record = { count: 0, resetTime: now + 60000 }; // 1 minute window
    requestCounts.set(key, record);
  }

  record.count++;

  // Check rate limit (e.g., 100 requests per minute)
  const maxRequests = 100;
  if (record.count > maxRequests) {
    return NextResponse.json(
      {
        error: 'Rate limit exceeded',
        retryAfter: Math.ceil((record.resetTime - now) / 1000),
      },
      {
        status: 429,
        headers: {
          'Retry-After': Math.ceil((record.resetTime - now) / 1000).toString(),
        },
      }
    );
  }

  const response = NextResponse.next();
  response.headers.set('X-RateLimit-Limit', maxRequests.toString());
  response.headers.set('X-RateLimit-Remaining', (maxRequests - record.count).toString());
  response.headers.set('X-RateLimit-Reset', record.resetTime.toString());

  return response;
}

export const config = {
  matcher: ['/api/:path*'],
};
```

## Security Considerations

1. **Token Verification**: Properly verify JWT tokens with secrets
2. **Role Validation**: Implement strict role-based access control
3. **Security Headers**: Add CSP, X-Frame-Options, etc.
4. **Rate Limiting**: Implement rate limiting to prevent abuse
5. **Request Signing**: Sign sensitive requests to verify integrity
6. **CORS Configuration**: Configure CORS properly for cross-origin requests
7. **Secrets Management**: Use environment variables for secrets

## Best Practices

- Keep middleware lightweight and performant
- Use matcher patterns efficiently
- Implement proper error handling
- Log security events
- Use edge runtime for faster processing
- Implement timeout handling
- Test middleware thoroughly
- Monitor middleware performance
- Keep middleware updated with security patches
