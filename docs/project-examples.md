# Project Examples (Any Domain)

Use these examples as memory anchors. Pick the closest complexity tier.

## Simple
**Example**: Marketing site with 3 pages and static content.
- Routes: `/`, `/pricing`, `/contact`
- Data: static JSON or CMS at build time
- Goal: fast load, minimal JS

## Medium
**Example**: SaaS dashboard with auth and CRUD.
- Routes: `/login`, `/app`, `/app/settings`, `/app/billing`
- Data: server components + server actions
- Goal: secure auth, basic caching, good UX

## Complex
**Example**: Multi-tenant platform with heavy caching.
- Routes: parallel routes + dynamic segments (`/org/[id]/...`)
- Data: cache tags, revalidation, streaming
- Goal: scale, isolated tenant data, consistent updates
