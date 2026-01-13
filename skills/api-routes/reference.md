# Reference

# API Routes in Next.js

Next.js App Router provides a file-based routing system for creating API endpoints. Each `route.ts` file in the `app/api` directory automatically becomes an API endpoint.

## Project Structure

```
app/
├── api/
│   ├── users/
│   │   ├── route.ts           # GET, POST /api/users
│   │   └── [id]/
│   │       └── route.ts       # GET, PUT, DELETE /api/users/[id]
│   ├── posts/
│   │   ├── route.ts           # GET, POST /api/posts
│   │   └── [id]/
│   │       ├── route.ts       # GET, PUT, DELETE /api/posts/[id]
│   │       └── comments/
│   │           └── route.ts   # GET, POST /api/posts/[id]/comments
│   └── webhooks/
│       └── github/
│           └── route.ts       # POST /api/webhooks/github
```

## Basic GET/POST Endpoint

```typescript
// app/api/users/route.ts
import { NextRequest, NextResponse } from 'next/server';

// GET /api/users
export async function GET(request: NextRequest) {
  try {
    // Query parameters from URL
    const searchParams = request.nextUrl.searchParams;
    const page = searchParams.get('page') || '1';
    const limit = searchParams.get('limit') || '10';

    // Fetch data from database or external API
    const users = await db.user.findMany({
      skip: (parseInt(page) - 1) * parseInt(limit),
      take: parseInt(limit),
    });

    return NextResponse.json(
      {
        success: true,
        data: users,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total: await db.user.count(),
        },
      },
      { status: 200 }
    );
  } catch (error) {
    console.error('GET /api/users error:', error);
    return NextResponse.json(
      { success: false, message: 'Failed to fetch users' },
      { status: 500 }
    );
  }
}

// POST /api/users
export async function POST(request: NextRequest) {
  try {
    const body = await request.json();

    // Validate request body
    if (!body.email || !body.name) {
      return NextResponse.json(
        { success: false, message: 'Missing required fields: email, name' },
        { status: 400 }
      );
    }

    // Create user in database
    const newUser = await db.user.create({
      data: {
        email: body.email,
        name: body.name,
        role: body.role || 'user',
      },
    });

    return NextResponse.json(
      {
        success: true,
        data: newUser,
        message: 'User created successfully',
      },
      { status: 201 }
    );
  } catch (error) {
    if (error instanceof SyntaxError) {
      return NextResponse.json(
        { success: false, message: 'Invalid JSON in request body' },
        { status: 400 }
      );
    }

    console.error('POST /api/users error:', error);
    return NextResponse.json(
      { success: false, message: 'Failed to create user' },
      { status: 500 }
    );
  }
}
```

## Dynamic Route Handlers

```typescript
// app/api/users/[id]/route.ts
import { NextRequest, NextResponse } from 'next/server';

type RouteParams = {
  params: {
    id: string;
  };
};

// GET /api/users/[id]
export async function GET(
  request: NextRequest,
  { params }: RouteParams
) {
  try {
    const userId = params.id;

    // Validate ID format
    if (!userId || isNaN(Number(userId))) {
      return NextResponse.json(
        { success: false, message: 'Invalid user ID' },
        { status: 400 }
      );
    }

    const user = await db.user.findUnique({
      where: { id: parseInt(userId) },
      include: {
        posts: true,
        profile: true,
      },
    });

    if (!user) {
      return NextResponse.json(
        { success: false, message: 'User not found' },
        { status: 404 }
      );
    }

    return NextResponse.json(
      { success: true, data: user },
      { status: 200 }
    );
  } catch (error) {
    console.error(`GET /api/users/${params.id} error:`, error);
    return NextResponse.json(
      { success: false, message: 'Failed to fetch user' },
      { status: 500 }
    );
  }
}

// PUT /api/users/[id]
export async function PUT(
  request: NextRequest,
  { params }: RouteParams
) {
  try {
    const userId = params.id;
    const body = await request.json();

    // Check if user exists
    const existingUser = await db.user.findUnique({
      where: { id: parseInt(userId) },
    });

    if (!existingUser) {
      return NextResponse.json(
        { success: false, message: 'User not found' },
        { status: 404 }
      );
    }

    // Update user
    const updatedUser = await db.user.update({
      where: { id: parseInt(userId) },
      data: {
        name: body.name || existingUser.name,
        email: body.email || existingUser.email,
        updatedAt: new Date(),
      },
    });

    return NextResponse.json(
      {
        success: true,
        data: updatedUser,
        message: 'User updated successfully',
      },
      { status: 200 }
    );
  } catch (error) {
    console.error(`PUT /api/users/${params.id} error:`, error);
    return NextResponse.json(
      { success: false, message: 'Failed to update user' },
      { status: 500 }
    );
  }
}

// DELETE /api/users/[id]
export async function DELETE(
  request: NextRequest,
  { params }: RouteParams
) {
  try {
    const userId = params.id;

    // Delete user
    const deletedUser = await db.user.delete({
      where: { id: parseInt(userId) },
    });

    return NextResponse.json(
      {
        success: true,
        data: deletedUser,
        message: 'User deleted successfully',
      },
      { status: 200 }
    );
  } catch (error) {
    if (error instanceof PrismaClientKnownRequestError && error.code === 'P2025') {
      return NextResponse.json(
        { success: false, message: 'User not found' },
        { status: 404 }
      );
    }

    console.error(`DELETE /api/users/${params.id} error:`, error);
    return NextResponse.json(
      { success: false, message: 'Failed to delete user' },
      { status: 500 }
    );
  }
}
```

## Request Body Parsing

```typescript
// app/api/posts/route.ts
export async function POST(request: NextRequest) {
  try {
    const contentType = request.headers.get('content-type');

    let body;

    if (contentType?.includes('application/json')) {
      body = await request.json();
    } else if (contentType?.includes('application/x-www-form-urlencoded')) {
      const formData = await request.formData();
      body = Object.fromEntries(formData);
    } else if (contentType?.includes('multipart/form-data')) {
      const formData = await request.formData();
      // Handle file uploads
      const file = formData.get('file') as File;
      const title = formData.get('title') as string;

      if (!file) {
        return NextResponse.json(
          { success: false, message: 'No file provided' },
          { status: 400 }
        );
      }

      // Process file upload
      const arrayBuffer = await file.arrayBuffer();
      // ... store or process file

      body = { title, fileName: file.name };
    } else {
      body = await request.text();
    }

    // Process body
    const post = await db.post.create({
      data: body,
    });

    return NextResponse.json(
      { success: true, data: post },
      { status: 201 }
    );
  } catch (error) {
    console.error('POST /api/posts error:', error);
    return NextResponse.json(
      { success: false, message: 'Failed to create post' },
      { status: 500 }
    );
  }
}
```

## Error Handling

```typescript
// app/api/data/route.ts
import { NextRequest, NextResponse } from 'next/server';

export async function GET(request: NextRequest) {
  try {
    // Simulate processing
    const data = await fetchFromDatabase();
    return NextResponse.json({ success: true, data });
  } catch (error) {
    // Handle different error types
    if (error instanceof ValidationError) {
      return NextResponse.json(
        { success: false, message: error.message, code: 'VALIDATION_ERROR' },
        { status: 400 }
      );
    }

    if (error instanceof NotFoundError) {
      return NextResponse.json(
        { success: false, message: error.message, code: 'NOT_FOUND' },
        { status: 404 }
      );
    }

    if (error instanceof UnauthorizedError) {
      return NextResponse.json(
        { success: false, message: 'Unauthorized', code: 'UNAUTHORIZED' },
        { status: 401 }
      );
    }

    // Generic error
    console.error('API error:', error);
    return NextResponse.json(
      {
        success: false,
        message: 'Internal server error',
        code: 'INTERNAL_ERROR',
      },
      { status: 500 }
    );
  }
}
```

## Response Headers

```typescript
// app/api/export/route.ts
export async function GET(request: NextRequest) {
  try {
    const data = await generateCSV();

    return new NextResponse(data, {
      status: 200,
      headers: {
        'Content-Type': 'text/csv; charset=utf-8',
        'Content-Disposition': 'attachment; filename="export.csv"',
        'Cache-Control': 'no-cache, no-store, must-revalidate',
      },
    });
  } catch (error) {
    console.error('Export error:', error);
    return NextResponse.json(
      { success: false, message: 'Failed to export data' },
      { status: 500 }
    );
  }
}
```

## CORS Configuration

```typescript
// app/api/public/route.ts
export async function OPTIONS(request: NextRequest) {
  return new NextResponse(null, {
    status: 200,
    headers: {
      'Access-Control-Allow-Origin': process.env.ALLOWED_ORIGINS || '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      'Access-Control-Max-Age': '86400',
    },
  });
}

export async function POST(request: NextRequest) {
  const response = NextResponse.json(
    { success: true, data: 'processed' },
    { status: 200 }
  );

  response.headers.set(
    'Access-Control-Allow-Origin',
    process.env.ALLOWED_ORIGINS || '*'
  );
  response.headers.set(
    'Access-Control-Allow-Methods',
    'GET, POST, PUT, DELETE, OPTIONS'
  );

  return response;
}
```

## Security Considerations

1. **Input Validation**: Always validate and sanitize request data
2. **Rate Limiting**: Implement rate limiting to prevent abuse
3. **Authentication**: Verify user identity before processing sensitive operations
4. **Authorization**: Check permissions for resource access
5. **HTTPS Only**: Ensure all API endpoints use HTTPS in production
6. **CORS**: Configure CORS properly for cross-origin requests
7. **Logging**: Log API requests for audit trails

## Best Practices

- Use TypeScript for type safety
- Separate business logic from route handlers
- Implement consistent error handling
- Use HTTP status codes correctly
- Document API endpoints with OpenAPI/Swagger
- Validate all inputs
- Implement proper authentication and authorization
- Handle concurrent requests safely
- Use database transactions for multiple operations
- Monitor and log API performance
