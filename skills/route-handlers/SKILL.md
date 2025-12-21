---
name: nextjs:route-handlers
description: Create route handlers with Request/Response APIs, streaming, and edge runtime support for advanced API features
---

# Route Handlers in Next.js

Route handlers provide a powerful API for creating advanced endpoint features including streaming, edge runtime deployment, and complex response handling.

## Advanced Request/Response Patterns

```typescript
// app/api/advanced/route.ts
import { NextRequest, NextResponse } from 'next/server';

export async function GET(request: NextRequest) {
  // Extract headers
  const userAgent = request.headers.get('user-agent');
  const authorization = request.headers.get('authorization');
  const contentType = request.headers.get('content-type');

  // Get IP address
  const ip =
    request.headers.get('x-forwarded-for') ||
    request.headers.get('x-real-ip') ||
    'unknown';

  // Get request method and URL
  const method = request.method;
  const url = new URL(request.url);
  const pathname = url.pathname;

  // Create custom response with headers
  const response = new NextResponse(
    JSON.stringify({
      success: true,
      metadata: {
        method,
        pathname,
        ip,
        userAgent,
        timestamp: new Date().toISOString(),
      },
    }),
    {
      status: 200,
      headers: {
        'Content-Type': 'application/json',
        'X-Custom-Header': 'Custom Value',
        'Cache-Control': 'private, no-cache, no-store, must-revalidate',
      },
    }
  );

  return response;
}
```

## Streaming Responses

```typescript
// app/api/stream/route.ts
import { NextRequest } from 'next/server';

export async function GET(request: NextRequest) {
  // Create a ReadableStream
  const stream = new ReadableStream({
    async start(controller) {
      try {
        // Stream data chunks
        for (let i = 1; i <= 10; i++) {
          const chunk = JSON.stringify({
            index: i,
            timestamp: new Date().toISOString(),
            data: `Chunk ${i}`,
          }) + '\n';

          controller.enqueue(new TextEncoder().encode(chunk));

          // Simulate processing delay
          await new Promise((resolve) => setTimeout(resolve, 500));
        }

        controller.close();
      } catch (error) {
        controller.error(error);
      }
    },
  });

  return new Response(stream, {
    headers: {
      'Content-Type': 'application/x-ndjson',
      'Transfer-Encoding': 'chunked',
    },
  });
}
```

## Server-Sent Events (SSE)

```typescript
// app/api/events/route.ts
import { NextRequest } from 'next/server';

export async function GET(request: NextRequest) {
  const stream = new ReadableStream({
    async start(controller) {
      const send = (event: string, data: any) => {
        const message = `event: ${event}\ndata: ${JSON.stringify(data)}\n\n`;
        controller.enqueue(new TextEncoder().encode(message));
      };

      try {
        // Send initial connection event
        send('connected', { message: 'Connected to event stream' });

        // Simulate live events
        for (let i = 0; i < 5; i++) {
          await new Promise((resolve) => setTimeout(resolve, 2000));

          send('update', {
            id: i,
            message: `Update ${i}`,
            timestamp: new Date().toISOString(),
          });
        }

        // Send completion event
        send('complete', { status: 'Stream closed' });
        controller.close();
      } catch (error) {
        send('error', { message: 'Stream error' });
        controller.error(error);
      }
    },
  });

  return new Response(stream, {
    headers: {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
      Connection: 'keep-alive',
    },
  });
}
```

## File Download with Streaming

```typescript
// app/api/download/report/route.ts
import { NextRequest } from 'next/server';

export async function GET(request: NextRequest) {
  try {
    const stream = new ReadableStream({
      async start(controller) {
        const encoder = new TextEncoder();

        // Write CSV header
        controller.enqueue(
          encoder.encode('ID,Name,Email,CreatedAt\n')
        );

        // Stream user data
        const users = await db.user.findMany({
          take: 1000,
        });

        for (const user of users) {
          const csv = `${user.id},"${user.name}","${user.email}","${user.createdAt}"\n`;
          controller.enqueue(encoder.encode(csv));
        }

        controller.close();
      },
    });

    return new Response(stream, {
      status: 200,
      headers: {
        'Content-Type': 'text/csv; charset=utf-8',
        'Content-Disposition': 'attachment; filename="users-report.csv"',
        'Cache-Control': 'no-cache, no-store, must-revalidate',
      },
    });
  } catch (error) {
    console.error('Download error:', error);
    return new Response('Failed to download file', { status: 500 });
  }
}
```

## Webhook Handlers

```typescript
// app/api/webhooks/github/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { createHmac } from 'crypto';

export async function POST(request: NextRequest) {
  try {
    const body = await request.text();
    const signature = request.headers.get('x-hub-signature-256');

    // Verify GitHub signature
    if (!verifyGitHubSignature(body, signature)) {
      return NextResponse.json(
        { success: false, message: 'Invalid signature' },
        { status: 401 }
      );
    }

    const payload = JSON.parse(body);
    const event = request.headers.get('x-github-event');

    // Handle different events
    switch (event) {
      case 'push':
        await handlePushEvent(payload);
        break;
      case 'pull_request':
        await handlePullRequestEvent(payload);
        break;
      case 'issues':
        await handleIssueEvent(payload);
        break;
      default:
        console.log(`Unhandled event: ${event}`);
    }

    return NextResponse.json(
      { success: true, message: `${event} processed` },
      { status: 200 }
    );
  } catch (error) {
    console.error('Webhook error:', error);
    return NextResponse.json(
      { success: false, message: 'Webhook processing failed' },
      { status: 500 }
    );
  }
}

function verifyGitHubSignature(
  body: string,
  signature: string | null
): boolean {
  const secret = process.env.GITHUB_WEBHOOK_SECRET || '';
  const hmac = createHmac('sha256', secret);
  hmac.update(body);
  const hash = `sha256=${hmac.digest('hex')}`;

  return hash === signature;
}

async function handlePushEvent(payload: any) {
  console.log(`Push to ${payload.repository.name}`);
  // Trigger CI/CD pipeline, update cache, etc.
}

async function handlePullRequestEvent(payload: any) {
  console.log(`PR ${payload.action} on ${payload.repository.name}`);
  // Update PR status, run tests, etc.
}

async function handleIssueEvent(payload: any) {
  console.log(`Issue ${payload.action} on ${payload.repository.name}`);
  // Create tickets, notify team, etc.
}
```

## Form Submission Handling

```typescript
// app/api/forms/contact/route.ts
import { NextRequest, NextResponse } from 'next/server';

export async function POST(request: NextRequest) {
  try {
    const formData = await request.formData();

    // Extract fields
    const name = formData.get('name') as string;
    const email = formData.get('email') as string;
    const message = formData.get('message') as string;
    const attachments = formData.getAll('attachments') as File[];

    // Validate
    if (!name || !email || !message) {
      return NextResponse.json(
        { success: false, message: 'Missing required fields' },
        { status: 400 }
      );
    }

    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return NextResponse.json(
        { success: false, message: 'Invalid email format' },
        { status: 400 }
      );
    }

    // Process attachments
    const uploadedFiles = [];
    for (const file of attachments) {
      if (file.size > 5 * 1024 * 1024) {
        // 5MB limit
        return NextResponse.json(
          {
            success: false,
            message: `File ${file.name} exceeds 5MB limit`,
          },
          { status: 400 }
        );
      }

      const buffer = await file.arrayBuffer();
      // Store file...
      uploadedFiles.push(file.name);
    }

    // Save to database
    const submission = await db.contactForm.create({
      data: {
        name,
        email,
        message,
        attachments: uploadedFiles,
        ipAddress: request.headers.get('x-forwarded-for'),
        userAgent: request.headers.get('user-agent'),
      },
    });

    // Send confirmation email
    // await sendEmail(email, 'Contact form received', ...);

    return NextResponse.json(
      {
        success: true,
        data: submission,
        message: 'Form submitted successfully',
      },
      { status: 201 }
    );
  } catch (error) {
    console.error('Form submission error:', error);
    return NextResponse.json(
      { success: false, message: 'Failed to submit form' },
      { status: 500 }
    );
  }
}
```

## Conditional Responses

```typescript
// app/api/content/route.ts
import { NextRequest, NextResponse } from 'next/server';

export async function GET(request: NextRequest) {
  try {
    const accept = request.headers.get('accept');

    // Return JSON
    if (accept?.includes('application/json')) {
      return NextResponse.json({
        success: true,
        data: { message: 'JSON response' },
      });
    }

    // Return HTML
    if (accept?.includes('text/html')) {
      return new NextResponse(
        `<html><body><h1>Content</h1></body></html>`,
        {
          status: 200,
          headers: { 'Content-Type': 'text/html' },
        }
      );
    }

    // Return XML
    if (accept?.includes('application/xml')) {
      return new NextResponse(
        `<?xml version="1.0"?><root><message>XML response</message></root>`,
        {
          status: 200,
          headers: { 'Content-Type': 'application/xml' },
        }
      );
    }

    // Default to JSON
    return NextResponse.json({ success: true, data: 'default' });
  } catch (error) {
    return NextResponse.json(
      { success: false, message: 'Error' },
      { status: 500 }
    );
  }
}
```

## Edge Runtime Route Handler

```typescript
// app/api/edge/route.ts
import { NextRequest, NextResponse } from 'next/server';

export const runtime = 'edge';

export async function GET(request: NextRequest) {
  // Get geographic data on edge
  const country = request.geo?.country;
  const city = request.geo?.city;
  const latitude = request.geo?.latitude;
  const longitude = request.geo?.longitude;

  // Low-latency response from edge
  return NextResponse.json(
    {
      success: true,
      location: {
        country,
        city,
        coordinates: { latitude, longitude },
      },
      timestamp: new Date().toISOString(),
    },
    {
      headers: {
        'Cache-Control': 'public, max-age=60',
      },
    }
  );
}
```

## Timeout Handling

```typescript
// app/api/long-operation/route.ts
import { NextRequest, NextResponse } from 'next/server';

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();

    // Create timeout controller
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 25000); // 25 second timeout

    try {
      // Process with timeout
      const result = await processLongOperation(body, controller.signal);
      clearTimeout(timeoutId);

      return NextResponse.json(
        { success: true, data: result },
        { status: 200 }
      );
    } catch (error) {
      clearTimeout(timeoutId);

      if (error instanceof DOMException && error.name === 'AbortError') {
        return NextResponse.json(
          { success: false, message: 'Operation timeout' },
          { status: 504 }
        );
      }

      throw error;
    }
  } catch (error) {
    console.error('Long operation error:', error);
    return NextResponse.json(
      { success: false, message: 'Operation failed' },
      { status: 500 }
    );
  }
}

async function processLongOperation(data: any, signal: AbortSignal) {
  return new Promise((resolve) => {
    const timer = setInterval(() => {
      if (signal.aborted) {
        clearInterval(timer);
        throw new DOMException('Aborted', 'AbortError');
      }
    }, 100);

    setTimeout(() => {
      clearInterval(timer);
      resolve({ processed: data, duration: '20s' });
    }, 20000);
  });
}
```

## Security Considerations

1. **Signature Verification**: Verify webhook signatures to prevent unauthorized access
2. **Rate Limiting**: Implement rate limiting on streaming endpoints
3. **Request Validation**: Validate all request inputs
4. **Size Limits**: Set maximum payload and file size limits
5. **Timeout Protection**: Implement timeouts for long-running operations
6. **CORS Headers**: Configure CORS properly for cross-origin requests
7. **Content-Type Validation**: Verify content-type before processing

## Best Practices

- Use ReadableStream for memory-efficient data handling
- Implement proper error handling for streaming
- Validate webhook signatures
- Set appropriate response headers
- Use edge runtime for low-latency responses
- Implement timeout handling for long operations
- Monitor streaming endpoint performance
- Log all errors and exceptions
