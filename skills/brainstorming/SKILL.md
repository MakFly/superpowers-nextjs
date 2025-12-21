---
name: nextjs:brainstorming
description: Structured ideation and feature discovery for Next.js applications - design patterns, architecture decisions, and implementation strategies
---

# Brainstorming Skill for Next.js

This skill guides structured thinking and ideation for Next.js features, helping you discover, analyze, and design solutions before implementation.

## Overview

Brainstorming in the Next.js context involves:

- **Problem Analysis**: Understand the core problem and constraints
- **Solution Exploration**: Generate multiple approaches and patterns
- **Architecture Design**: Plan component hierarchy and data flow
- **Technology Selection**: Choose appropriate Next.js features
- **Risk Assessment**: Identify potential challenges and mitigation
- **Decision Documentation**: Record rationale for future reference

## Brainstorming Process

### Phase 1: Problem Definition

Start by clearly defining what you're building:

```markdown
## Problem Statement

### What are we solving?
- User need/pain point
- Business requirement
- Technical challenge

### Constraints
- Performance requirements (CLS, LCP, FID)
- Browser support
- SEO requirements
- Security considerations
- Budget/timeline

### Success Criteria
- User experience metrics
- Performance targets
- Conversion/engagement goals
- Developer experience

### Scope
- MVP features
- Phase 2 additions
- Out of scope items
```

### Phase 2: Feature Exploration

Generate ideas without filtering:

```markdown
## Feature Ideas

### Idea 1: Real-time Notifications
**Description**: Live update system for user notifications
**Use Next.js Features**:
- WebSocket integration
- Server-Sent Events (SSE)
- Next.js API Routes

**Considerations**:
- Browser compatibility
- Scalability for concurrent users
- Fallback mechanisms

### Idea 2: Content Management
**Description**: Dynamic content loading system
**Use Next.js Features**:
- Dynamic Routes [slug]
- Incremental Static Regeneration (ISR)
- Data fetching (getServerSideProps/getStaticProps)

**Considerations**:
- Cache invalidation
- SEO optimization
- Performance at scale

### Idea 3: Interactive Dashboard
**Description**: Real-time analytics and monitoring
**Use Next.js Features**:
- Client components for interactivity
- Server components for data
- Streaming responses
- Suspense boundaries

**Considerations**:
- Data freshness requirements
- User permissions
- Real-time update mechanism
```

### Phase 3: Architecture Patterns

Select or design patterns matching your needs:

```typescript
// Pattern 1: App Router with Server Components
// Best for: Content-heavy, SEO-sensitive, server-first apps
export default async function Dashboard() {
  const data = await fetchServerData();
  return <ClientVisualization data={data} />;
}

// Pattern 2: Hybrid Server/Client Components
// Best for: Interactive features with heavy server data
'use client';
export default function SearchableTable() {
  const [query, setQuery] = useState('');
  const { data } = useSuspenseQuery(['search', query], () =>
    fetch(`/api/search?q=${query}`).then(r => r.json())
  );
  return <Table data={data} />;
}

// Pattern 3: API-First Architecture
// Best for: Decoupled frontend/backend, multiple clients
export async function GET(req) {
  const data = await fetchData();
  return Response.json(data);
}

// Pattern 4: Database + Streaming
// Best for: Large dataset handling, progressive rendering
export async function GET(req) {
  const stream = await streamDatabaseResults();
  return new Response(stream, {
    headers: { 'Content-Type': 'text/event-stream' },
  });
}
```

### Phase 4: Technology Stack Decision

Evaluate technology choices:

```markdown
## Technology Selection Matrix

| Requirement | Option A | Option B | Choice | Rationale |
|-------------|----------|----------|--------|-----------|
| **Data Fetching** | TanStack Query | SWR | TanStack Query | Advanced caching, dev tools |
| **Form Handling** | React Hook Form | TanStack Form | TanStack Form | Better TS support, validation |
| **Styling** | Tailwind CSS | CSS Modules | Tailwind CSS | Rapid development, theming |
| **Database** | Prisma | Drizzle | Prisma | Ecosystem maturity |
| **Authentication** | NextAuth.js | Clerk | Clerk | Better UX, SSR support |
| **Deployment** | Vercel | Netlify | Vercel | Next.js optimization |

## Feature-Technology Mapping

### Authentication
- NextAuth.js (self-hosted)
- Clerk (managed)
- Auth0 (enterprise)
- Firebase Auth (quick setup)

### Real-time Communication
- WebSocket libraries
- Socket.io
- Pusher
- Firebase Realtime

### File Storage
- Local filesystem
- AWS S3
- Cloudinary (images)
- Firebase Storage

### Analytics
- Google Analytics
- PostHog
- Mixpanel
- Custom solution
```

### Phase 5: Data Flow Design

Map data movement through your app:

```typescript
// Example: E-commerce Product Page

// Data Sources
const productAPI = '/api/products/[id]';     // Database
const reviewsAPI = '/api/products/[id]/reviews'; // CMS
const inventoryAPI = '/api/inventory/[id]';  // Real-time

// Server Component (server-side data)
export default async function ProductPage({ params }) {
  // Fetch data on server
  const product = await getProduct(params.id);
  const reviews = await getReviews(params.id);

  return (
    <div>
      <ProductInfo product={product} />
      <Suspense fallback={<ReviewsSkeleton />}>
        <ReviewsList reviews={reviews} />
      </Suspense>
      <ClientInventoryChecker productId={params.id} />
    </div>
  );
}

// Client Component (interactive, real-time)
'use client';
function ClientInventoryChecker({ productId }) {
  const { data: inventory } = useQuery(
    ['inventory', productId],
    () => fetch(`/api/inventory/${productId}`).then(r => r.json()),
    { refetchInterval: 5000 } // Poll every 5 seconds
  );

  return <InventoryStatus inventory={inventory} />;
}
```

### Phase 6: Performance Planning

Plan performance considerations:

```markdown
## Performance Checklist

### Page Load Performance
- [ ] Code splitting strategy
- [ ] Image optimization (Next.js Image)
- [ ] Font loading strategy
- [ ] Critical CSS inlining
- [ ] Script deferral strategy

### Runtime Performance
- [ ] Component granularity
- [ ] Re-render prevention (useMemo, useCallback)
- [ ] List virtualization for large datasets
- [ ] Lazy loading below the fold
- [ ] State management (avoid prop drilling)

### Data Loading Performance
- [ ] Caching strategy (HTTP, client-side)
- [ ] Request batching
- [ ] Pagination vs infinite scroll
- [ ] Prefetching strategy
- [ ] Streaming responses

### Metrics Targets
- LCP (Largest Contentful Paint): < 2.5s
- FID (First Input Delay): < 100ms
- CLS (Cumulative Layout Shift): < 0.1
- TTL (Time to Load): < 3s
```

### Phase 7: Error & Edge Cases

Plan for failure modes:

```markdown
## Error Handling Strategy

### Network Errors
- [ ] Retry logic with exponential backoff
- [ ] Fallback UI
- [ ] Offline detection
- [ ] Sync queue for failed requests

### Data Validation
- [ ] Server-side validation (security)
- [ ] Client-side validation (UX)
- [ ] Type safety (TypeScript)
- [ ] Schema validation (Zod, Yup)

### Authentication/Authorization
- [ ] Token refresh strategy
- [ ] Unauthorized redirect
- [ ] Permission checks on routes
- [ ] CSRF protection

### Edge Cases
- [ ] Empty states
- [ ] Loading states
- [ ] Error states
- [ ] Null/undefined handling
- [ ] Race condition prevention
```

## Brainstorming Templates

### Feature Request Template

```markdown
## Feature: [Feature Name]

### Business Value
- What problem does it solve?
- User impact
- Expected engagement increase

### Technical Requirements
- Data needed
- API endpoints
- Database schema changes

### Next.js Features to Use
- [ ] Server Components
- [ ] Client Components
- [ ] API Routes
- [ ] Middleware
- [ ] Dynamic Routes
- [ ] ISR/Revalidation

### Implementation Approach
- Component structure
- State management
- Data flow
- Testing strategy

### Success Metrics
- User metrics
- Performance metrics
- Error rates

### Risks & Mitigations
| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| Performance degradation | Medium | High | Implement caching, lazy loading |
| User confusion | Low | Medium | Clear UI, onboarding |
```

### Architecture Decision Template

```markdown
## ADR: [Decision Title]

### Status
- PROPOSED / ACCEPTED / DEPRECATED

### Context
- What forces us to this decision?
- Alternatives considered
- Trade-offs

### Decision
- What is the decision?
- Why this choice?

### Consequences
- Positive outcomes
- Risks/limitations
- Implementation effort

### Examples
[Concrete code examples]

### Related Decisions
- Links to other ADRs
```

## Common Brainstorming Topics

### State Management

```markdown
## Should we use external state management?

### Simple form state
- Use React hooks: useState, useReducer
- No external library needed

### Cross-component state
- React Context API
- Zustand (lightweight)
- Jotai (atomic approach)

### Server state
- TanStack Query (React Query)
- SWR
- Server Components + revalidation

### Global app state
- Redux (complex apps)
- MobX (reactive)
- Zustand (simple)

### Decision
Use TanStack Query for server state, Zustand for UI state
```

### Routing Strategy

```markdown
## File-based vs Programmatic Routing

### File-based (Next.js default)
✓ Simple, automatic
✓ Good for marketing sites
✗ Less flexible for dynamic structures

### Programmatic (API + dynamic)
✓ Complex requirements
✓ Fine-grained control
✗ More code to maintain

### Decision
Use file-based for core structure, dynamic [slug] for content
```

### Authentication Strategy

```markdown
## Self-hosted vs Third-party

### Self-hosted (NextAuth.js, Lucia)
✓ Full control
✓ No external dependencies
✗ More maintenance

### Third-party (Clerk, Auth0)
✓ Battle-tested security
✓ Rich features (MFA, social)
✗ Extra cost, vendor lock-in

### Decision
Use Clerk for rapid development, migration path to NextAuth if needed
```

## Decision Making Framework

### Evaluation Criteria

```typescript
type Decision = {
  name: string;
  options: Option[];
  criteria: Criterion[];
};

type Option = {
  name: string;
  scores: Record<string, number>; // 1-5 scale
  pros: string[];
  cons: string[];
};

type Criterion = {
  name: string;
  weight: number;
  importance: 'critical' | 'high' | 'medium' | 'low';
};

// Example: Calculate weighted score
function evaluateOption(option, criteria) {
  let totalScore = 0;
  let totalWeight = 0;

  criteria.forEach(c => {
    totalScore += (option.scores[c.name] || 0) * c.weight;
    totalWeight += c.weight;
  });

  return totalScore / totalWeight;
}
```

## Documentation Practices

After brainstorming, document decisions:

```markdown
# Architecture Decisions Log

## ADR-001: Use Next.js App Router
- Date: 2024-01-15
- Status: ACCEPTED
- Team: Engineering
- Rationale: Better performance, Server Components, modern patterns

## ADR-002: TanStack Query for Data Fetching
- Date: 2024-01-15
- Status: ACCEPTED
- Rationale: Advanced caching, dev tools, type safety

## ADR-003: Clerk for Authentication
- Date: 2024-01-20
- Status: ACCEPTED
- Rationale: Faster development, rich features, good DX

## ADR-004: Tailwind CSS for Styling
- Date: 2024-01-15
- Status: ACCEPTED
- Rationale: Rapid development, consistency, theme support
```

## Collaboration Best Practices

### Brainstorming Session Structure

1. **Problem Statement (10 min)**
   - Clearly define the challenge
   - Discuss constraints and goals

2. **Idea Generation (20 min)**
   - No filtering, all ideas welcome
   - Build on each other's ideas
   - Capture everything

3. **Clustering (10 min)**
   - Group similar ideas
   - Identify themes
   - Remove duplicates

4. **Evaluation (15 min)**
   - Assess feasibility
   - Estimate effort
   - Identify risks

5. **Decision (10 min)**
   - Choose direction
   - Assign next steps
   - Document decision

## Tools & Techniques

### Visual Planning
- Architecture diagrams (Excalidraw, Miro)
- Data flow diagrams
- Component hierarchy trees
- Wireframes/mockups

### Written Planning
- ADR documents
- Design documents
- Requirements specifications
- Risk assessments

### Collaborative Tools
- Whiteboards
- Shared documents
- Figma (design)
- GitHub Discussions

## Resources

- [Next.js Best Practices](https://nextjs.org/docs)
- [React Patterns](https://react.dev)
- [System Design Interview](https://systemdesigninterview.com)
- [Software Architecture Patterns](https://www.patterns.dev)
