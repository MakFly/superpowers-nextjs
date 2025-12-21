---
name: nextjs:nextdevtools-mcp-integration
description: NextDevTools MCP integration for Next.js 16 - development tools, server management, and debugging capabilities
---

# NextDevTools MCP Integration for Next.js 16

NextDevTools MCP provides powerful development utilities for Next.js 16+ applications through Model Context Protocol integration. This skill enables seamless debugging, monitoring, and development workflow optimization.

## Overview

NextDevTools MCP is a comprehensive development toolkit that integrates with Next.js to provide:

- **Real-time Server Monitoring**: Track server state, request/response cycles, and performance metrics
- **Advanced Debugging**: Remote debugging, breakpoint management, and call stack inspection
- **Performance Profiling**: Memory usage, CPU profiling, and bundle analysis
- **Code Hot-Reload**: Automatic reload on file changes with state preservation
- **API Route Testing**: Built-in API testing utilities
- **Error Analysis**: Detailed error tracking and stack trace analysis

## Quick Start

### Installation

```bash
# Install NextDevTools MCP
npm install --save-dev nextdevtools-mcp

# Add to next.config.js
module.exports = {
  experimental: {
    mcp: {
      enabled: true,
      timeout: 5000,
    },
  },
};
```

### Enable in Development

```bash
# Start with MCP enabled
NEXTDEVTOOLS_ENABLED=true npm run dev

# With debugging output
DEBUG=nextdevtools:* npm run dev
```

## Available Tools

### 1. Server Management

```typescript
// getServerStatus()
// Returns current server state and health metrics

const status = await nextDevTools.getServerStatus();
// {
//   isRunning: true,
//   port: 3000,
//   uptime: 125000,
//   memoryUsage: { heapUsed: 45.2, heapTotal: 60.5 },
//   requestsPerSecond: 12.4,
//   errors: 0
// }

// restartServer()
// Gracefully restart the development server
await nextDevTools.restartServer();

// toggleMiddleware(name: string)
// Enable/disable specific middleware
await nextDevTools.toggleMiddleware('cors');
await nextDevTools.toggleMiddleware('compression');
```

### 2. Request/Response Inspection

```typescript
// captureRequest(method, url, options)
// Intercept and analyze requests in detail

const captured = await nextDevTools.captureRequest('GET', '/api/users', {
  duration: 5000, // Capture for 5 seconds
  includeBody: true,
  includeHeaders: true,
});

// {
//   method: 'GET',
//   url: '/api/users',
//   statusCode: 200,
//   duration: 145,
//   headers: { ... },
//   body: { ... },
//   timestamp: 1234567890
// }

// Profile a specific route handler
const profile = await nextDevTools.profileRoute('/api/users', {
  iterations: 100,
  warmup: 10,
});

// {
//   mean: 2.34,
//   median: 2.12,
//   stdDev: 0.45,
//   min: 1.89,
//   max: 3.21,
//   percentile95: 2.98,
//   percentile99: 3.12
// }
```

### 3. Breakpoint & Debugging

```typescript
// setBreakpoint(filePath, line, column?)
// Set breakpoints in your application code
await nextDevTools.setBreakpoint('src/app/api/users/route.ts', 42);

// getBreakpoints()
// List all active breakpoints
const breakpoints = await nextDevTools.getBreakpoints();
// [
//   { file: 'src/app/api/users/route.ts', line: 42, column: 0 },
//   { file: 'src/lib/db.ts', line: 15, column: 2 }
// ]

// clearBreakpoints()
await nextDevTools.clearBreakpoints();

// getStackTrace(errorId)
// Get detailed stack trace for errors
const trace = await nextDevTools.getStackTrace('err_123');
// [
//   { file: 'src/app/api/route.ts', line: 42, function: 'POST' },
//   { file: 'src/lib/handler.ts', line: 8, function: 'processData' },
//   { file: 'node_modules/next/dist/...', line: 156, function: 'next' }
// ]
```

### 4. Performance Analysis

```typescript
// analyzeBundle()
// Analyze bundle composition and size
const bundleAnalysis = await nextDevTools.analyzeBundle({
  includeSourceMaps: true,
  groupByType: true,
});

// {
//   totalSize: 1245000,
//   chunks: [
//     { name: 'main.js', size: 450000, percentage: 36.1 },
//     { name: 'vendor.js', size: 520000, percentage: 41.8 },
//     { name: 'runtime.js', size: 275000, percentage: 22.1 }
//   ],
//   largePackages: [
//     { name: 'react-dom', size: 142000, impact: 'high' },
//     { name: '@tanstack/react-query', size: 89000, impact: 'medium' }
//   ]
// }

// getMemoryProfile()
// Get memory usage breakdown
const memoryProfile = await nextDevTools.getMemoryProfile({
  topN: 20,
});

// {
//   heapUsed: 145.2,
//   heapTotal: 200.5,
//   external: 12.3,
//   rss: 320.4,
//   topAllocations: [
//     { module: 'react', size: 45.2, percentage: 31.1 },
//     { module: 'next', size: 38.5, percentage: 26.5 }
//   ]
// }

// getCPUProfile(duration = 5000)
// Profile CPU usage over time
const cpuProfile = await nextDevTools.getCPUProfile(5000);
// {
//   duration: 5000,
//   functions: [
//     { name: 'processRequest', self: 1200, total: 2500 },
//     { name: 'renderComponent', self: 800, total: 1800 }
//   ],
//   hotspots: [...]
// }
```

### 5. Hot Reload Control

```typescript
// enableHotReload(options)
// Configure hot reload behavior
await nextDevTools.enableHotReload({
  preserveState: true,
  fastRefresh: true,
  errorBoundary: true,
});

// watchFiles(pattern, callback)
// Monitor specific files for changes
await nextDevTools.watchFiles('src/**/*.ts', async (file) => {
  console.log(`File changed: ${file}`);
  await nextDevTools.hotReload(file);
});

// clearCache(scope)
// Clear specific caches
await nextDevTools.clearCache('all');      // All caches
await nextDevTools.clearCache('assets');   // Asset cache
await nextDevTools.clearCache('data');     // Data fetching cache
```

### 6. Environment & Config

```typescript
// getEnvironment()
// Get current environment configuration
const env = await nextDevTools.getEnvironment();
// {
//   NODE_ENV: 'development',
//   NEXT_PUBLIC_API_URL: 'http://localhost:3000',
//   DEBUG: 'nextjs:*',
//   custom: { ... }
// }

// updateEnvVar(key, value)
// Update environment variable at runtime
await nextDevTools.updateEnvVar('DEBUG', 'nextjs:*,nextdevtools:*');

// getConfig()
// Get current Next.js configuration
const config = await nextDevTools.getConfig();
// Returns next.config.js merged with environment overrides
```

## Usage Patterns

### Pattern 1: Development Debugging

```typescript
// In your development workflow
import { nextDevTools } from 'nextdevtools-mcp';

export async function debugRequest(req, res) {
  if (process.env.NODE_ENV === 'development') {
    const capture = await nextDevTools.captureRequest(
      req.method,
      req.url,
      { duration: 10000 }
    );

    console.log('Captured request:', capture);

    // Set breakpoint for next similar request
    await nextDevTools.setBreakpoint(__filename, 10);
  }

  // Your normal handler logic
  res.status(200).json({ ok: true });
}
```

### Pattern 2: Performance Monitoring

```typescript
// Monitor API route performance
export async function GET(req) {
  const startTime = Date.now();

  try {
    const data = await fetchData();

    const duration = Date.now() - startTime;
    if (duration > 1000) {
      console.warn(`Slow request detected: ${duration}ms`);

      // Trigger analysis
      if (process.env.NODE_ENV === 'development') {
        const profile = await nextDevTools.profileRoute(
          req.nextUrl.pathname,
          { iterations: 50 }
        );
        console.log('Performance profile:', profile);
      }
    }

    return Response.json(data);
  } catch (error) {
    console.error('Request error:', error);
    return Response.json({ error }, { status: 500 });
  }
}
```

### Pattern 3: Bundle Analysis

```typescript
// scripts/analyze-bundle.mjs
import { nextDevTools } from 'nextdevtools-mcp';

async function analyzeAndReport() {
  const analysis = await nextDevTools.analyzeBundle({
    includeSourceMaps: true,
    groupByType: true,
  });

  console.log('Bundle Analysis Report');
  console.log('='.repeat(50));
  console.log(`Total Size: ${(analysis.totalSize / 1000).toFixed(2)}KB`);
  console.log('\nLarge Packages:');

  analysis.largePackages.forEach(pkg => {
    const size = (pkg.size / 1000).toFixed(2);
    console.log(`  ${pkg.name}: ${size}KB (${pkg.impact})`);
  });

  // Save report
  import('fs').then(fs => {
    fs.writeFileSync(
      'bundle-report.json',
      JSON.stringify(analysis, null, 2)
    );
  });
}

analyzeAndReport();
```

### Pattern 4: Custom Middleware Profiling

```typescript
// middleware.ts
import { nextDevTools } from 'nextdevtools-mcp';

export async function middleware(request) {
  const start = Date.now();

  // Your middleware logic
  const response = NextResponse.next();

  const duration = Date.now() - start;

  if (process.env.DEBUG_MIDDLEWARE && duration > 50) {
    const profile = await nextDevTools.getStackTrace(
      request.headers.get('x-request-id')
    );
    console.warn('Slow middleware detected:', profile);
  }

  return response;
}
```

## Configuration Options

### next.config.js

```typescript
module.exports = {
  experimental: {
    mcp: {
      enabled: process.env.NODE_ENV === 'development',
      timeout: 5000,

      // Profiling options
      profiling: {
        enabled: true,
        memorySnapshots: true,
        cpuProfiling: true,
        traceEvents: true,
      },

      // Breakpoint options
      breakpoints: {
        enabled: true,
        maxBreakpoints: 50,
        pauseOnException: true,
      },

      // Cache options
      caching: {
        enabled: true,
        ttl: 3600000,
        strategies: ['memory', 'disk'],
      },

      // Logging
      logging: {
        level: 'debug',
        format: 'json',
        file: '.nextdevtools/logs',
      },
    },
  },
};
```

## Best Practices

### 1. Development-Only Features

```typescript
// Only use NextDevTools in development
if (process.env.NODE_ENV === 'development') {
  const { nextDevTools } = await import('nextdevtools-mcp');

  // Profiling and debugging
  const profile = await nextDevTools.profileRoute('/api/data', {
    iterations: 100,
  });
}
```

### 2. Error Reporting Integration

```typescript
// Log errors with detailed context
try {
  await processData();
} catch (error) {
  if (process.env.NODE_ENV === 'development') {
    const stackTrace = await nextDevTools.getStackTrace(error.id);
    console.error('Full trace:', stackTrace);
  }
  throw error;
}
```

### 3. Performance Budgets

```typescript
// Monitor bundle size
const analysis = await nextDevTools.analyzeBundle();
const totalSize = analysis.totalSize / 1000; // KB

if (totalSize > 500) {
  console.warn(`Bundle size exceeds budget: ${totalSize}KB > 500KB`);
}
```

## CLI Commands

```bash
# Start development with MCP enabled
NEXTDEVTOOLS_ENABLED=true npm run dev

# Get server status
nextdevtools status

# Analyze current bundle
nextdevtools analyze-bundle

# Profile specific route
nextdevtools profile /api/route

# Get memory report
nextdevtools memory-report

# Export debug logs
nextdevtools export-logs --output debug-logs.json

# Clear all caches
nextdevtools clear-cache --scope all

# List active breakpoints
nextdevtools list-breakpoints
```

## Troubleshooting

### MCP Connection Issues

```bash
# Check if MCP is running
NEXTDEVTOOLS_DEBUG=true npm run dev

# Increase timeout
NEXTDEVTOOLS_TIMEOUT=10000 npm run dev

# Verify configuration
npx nextdevtools validate-config
```

### Performance Issues

```typescript
// Too much profiling can slow development
// Disable features you don't need

module.exports = {
  experimental: {
    mcp: {
      profiling: {
        cpuProfiling: false,  // Expensive
        memorySnapshots: false,
      },
    },
  },
};
```

## Advanced Features

### Custom Metrics Collection

```typescript
import { nextDevTools } from 'nextdevtools-mcp';

nextDevTools.onMetric((metric) => {
  // Custom handling
  if (metric.duration > 1000) {
    console.warn(`Slow operation: ${metric.name}`);
  }
});
```

### Remote Debugging

```bash
# Enable remote debugging
NEXTDEVTOOLS_INSPECT=true npm run dev
# Opens inspector at chrome://inspect
```

## Integration with Other Tools

NextDevTools MCP works seamlessly with:
- Next.js built-in debugger
- VS Code debugger
- Chrome DevTools
- Performance monitoring services
- Error tracking services

## Resources

- [NextDevTools Documentation](https://nextdevtools.dev)
- [MCP Specification](https://modelcontextprotocol.io)
- [Next.js 16 Docs](https://nextjs.org/docs)
