---
name: nextjs:using-nextjs-superpowers
description: Entry point for Next.js Superpowers - lightweight workflow guidance and command map.
---

# Using Next.js Superpowers (Compact)

## When to use
- Next.js App Router or Server Components work
- Server Actions, caching, streaming, routing, performance

## How to operate
1. Identify router type (app/pages/hybrid) and Next.js version.
2. Prefer Server Components by default; use Client Components only when needed.
3. Ask before starting any dev server or build.
4. Use the project’s package manager; do not assume npm.

## Recommended entry skills
- `app-router`, `server-components`, `server-actions`
- `data-fetching-patterns`, `caching-strategies`, `revalidation`
- `routing` skills (`dynamic-routes`, `route-groups`, `parallel-routes`)

## Commands (only if user asks to run)
- `/superpowers-nextjs:write-plan`
- `/superpowers-nextjs:execute-plan`
- `/superpowers-nextjs:nextjs-check`
- `/superpowers-nextjs:nextjs-tdd-vitest`
