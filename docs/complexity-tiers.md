# Complexity Tiers (Next.js)

Use this to adapt the level of detail automatically based on project complexity.

## Simple
**Signals**: Single app, few routes, minimal data fetching.
**Example**: Add a cached server component for a static page.

## Medium
**Signals**: App Router + dynamic routes + some server actions.
**Example**: Cache product list with tags + revalidate on mutation.

## Complex
**Signals**: Multi-tenant, parallel routes, heavy caching/invalidation.
**Example**: Cache per-tenant data with tags, updateTag for read-your-writes, and streaming fallbacks.
