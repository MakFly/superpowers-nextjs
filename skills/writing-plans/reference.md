# Reference

# Writing Plans Skill for Next.js

This skill helps create detailed implementation plans for Next.js features, breaking down complex requirements into actionable tasks with clear dependencies and milestones.

## Overview

Writing effective implementation plans involves:

- **Requirements Analysis**: Breaking down feature specifications
- **Task Decomposition**: Splitting work into manageable units
- **Dependency Mapping**: Identifying task relationships
- **Estimation**: Sizing effort and duration
- **Resource Planning**: Assigning ownership and skills
- **Risk Planning**: Anticipating and mitigating blockers
- **Milestone Setting**: Creating measurable progress points

## Implementation Plan Template

### 1. Feature Overview

```markdown
## Feature: [Feature Name]
**Status**: PLANNED / IN_PROGRESS / REVIEW / COMPLETED

### Summary
Brief one-sentence description of what you're building.

### Objectives
- Primary goal
- Secondary goals
- Non-goals

### Success Criteria
- Feature completeness
- Performance targets
- Quality metrics
- User acceptance criteria

### Timeline
**Start**: YYYY-MM-DD
**Target Completion**: YYYY-MM-DD
**Buffer**: 20% for unknowns

### Team
- **Lead**: [Name]
- **Developers**: [Names]
- **Designer**: [Name]
- **QA**: [Name]
```

### 2. Requirements Analysis

```markdown
## Technical Requirements

### Functional Requirements
- [ ] Requirement 1 - User can X
- [ ] Requirement 2 - System shows Y
- [ ] Requirement 3 - Data persists to Z

### Non-Functional Requirements
- Performance: < 500ms response time
- Availability: 99.9% uptime
- Scalability: Handle 10k concurrent users
- Security: Encrypt sensitive data
- Accessibility: WCAG 2.1 Level AA

### Constraints
- Must use existing authentication system
- Cannot modify database schema (breaking change)
- Must work on mobile devices
- Must support IE 11 (if applicable)

### Data Model

\`\`\`typescript
// User action on product
type UserAction = {
  id: string;
  userId: string;
  productId: string;
  action: 'view' | 'click' | 'purchase';
  timestamp: Date;
  metadata?: Record<string, unknown>;
};

type Database = {
  userActions: UserAction[];
};
\`\`\`

### API Surface

```typescript
// GET /api/products/:id/views
// Response: { views: number, trending: boolean }

// POST /api/actions
// Body: { userId, productId, action }
// Response: { success: boolean }

// GET /api/analytics/trending
// Response: { products: Product[], period: string }
```

### External Dependencies
- Next.js 14+
- TanStack Query for data fetching
- Clerk for authentication
- PostgreSQL for persistence
```

### 3. Task Breakdown

```markdown
## Task Breakdown

### Phase 1: Foundation (Weeks 1-2)

#### Task 1.1: Setup & Infrastructure
- **Owner**: DevOps
- **Effort**: 8 hours
- **Dependencies**: None
- **Description**: Configure environment, databases, monitoring
- **Acceptance Criteria**:
  - [ ] Development environment runs locally
  - [ ] CI/CD pipeline passes
  - [ ] Staging environment accessible
- **Subtasks**:
  - [ ] Create database schema
  - [ ] Setup environment variables
  - [ ] Configure monitoring/logging

#### Task 1.2: Data Model Definition
- **Owner**: Backend Lead
- **Effort**: 6 hours
- **Dependencies**: Task 1.1
- **Description**: Define database schema, migrations, types
- **Acceptance Criteria**:
  - [ ] TypeScript types generated
  - [ ] Migrations created
  - [ ] Database seeded with test data
- **Subtasks**:
  - [ ] Create Prisma/Drizzle schema
  - [ ] Write migrations
  - [ ] Generate TypeScript types

#### Task 1.3: API Routes Skeleton
- **Owner**: Backend Lead
- **Effort**: 4 hours
- **Dependencies**: Task 1.2
- **Description**: Create empty API endpoint handlers
- **Acceptance Criteria**:
  - [ ] All routes return 200 with mock data
  - [ ] Request/response types defined
  - [ ] Routes documented in code
- **Subtasks**:
  - [ ] Create route handlers
  - [ ] Add middleware (auth, logging)
  - [ ] Write API documentation

### Phase 2: Core Implementation (Weeks 2-4)

#### Task 2.1: Server Components & Data Fetching
- **Owner**: Backend/Frontend
- **Effort**: 12 hours
- **Dependencies**: Task 1.3
- **Description**: Implement data fetching with TanStack Query
- **Acceptance Criteria**:
  - [ ] Data loads without errors
  - [ ] Loading states show
  - [ ] Error handling works
  - [ ] Cache invalidation works
- **Subtasks**:
  - [ ] Setup TanStack Query
  - [ ] Implement data fetching hooks
  - [ ] Add error boundaries
  - [ ] Add loading skeletons

#### Task 2.2: UI Components
- **Owner**: Frontend Lead
- **Effort**: 20 hours
- **Dependencies**: Task 2.1
- **Description**: Build all visual components
- **Acceptance Criteria**:
  - [ ] Components match design
  - [ ] Responsive on mobile/tablet/desktop
  - [ ] Accessible (WCAG 2.1 AA)
  - [ ] Performance passes Lighthouse
- **Subtasks**:
  - [ ] Create component structure
  - [ ] Add Tailwind styling
  - [ ] Implement animations
  - [ ] Add accessibility attributes

#### Task 2.3: Client Interactions
- **Owner**: Frontend Lead
- **Effort**: 10 hours
- **Dependencies**: Task 2.2
- **Description**: Add form handling and user interactions
- **Acceptance Criteria**:
  - [ ] Forms submit without errors
  - [ ] Validation works client and server
  - [ ] Loading states during submission
  - [ ] Success/error messages shown
- **Subtasks**:
  - [ ] Setup form library (React Hook Form)
  - [ ] Add client-side validation
  - [ ] Add optimistic updates
  - [ ] Handle errors gracefully

### Phase 3: Integration & Polish (Weeks 4-5)

#### Task 3.1: End-to-End Testing
- **Owner**: QA / Frontend
- **Effort**: 12 hours
- **Dependencies**: Phase 2 complete
- **Description**: Test feature completely
- **Acceptance Criteria**:
  - [ ] Happy path works
  - [ ] All edge cases handled
  - [ ] No console errors
  - [ ] Performance acceptable
- **Subtasks**:
  - [ ] Manual testing checklist
  - [ ] Automated e2e tests (Playwright)
  - [ ] Accessibility audit
  - [ ] Performance audit

#### Task 3.2: Documentation
- **Owner**: Tech Lead
- **Effort**: 4 hours
- **Dependencies**: Phase 2 complete
- **Description**: Document feature for other developers
- **Acceptance Criteria**:
  - [ ] README updated
  - [ ] API documented
  - [ ] Architecture decision logged
  - [ ] Setup instructions clear
- **Subtasks**:
  - [ ] Write README section
  - [ ] Document API endpoints
  - [ ] Create ADR
  - [ ] Add code examples

#### Task 3.3: Performance Optimization
- **Owner**: DevOps / Frontend Lead
- **Effort**: 8 hours
- **Dependencies**: Task 3.1
- **Description**: Optimize performance metrics
- **Acceptance Criteria**:
  - [ ] LCP < 2.5s
  - [ ] CLS < 0.1
  - [ ] Bundle size within budget
  - [ ] Load test passes
- **Subtasks**:
  - [ ] Run Lighthouse audit
  - [ ] Optimize images
  - [ ] Code split
  - [ ] Cache optimization

### Phase 4: Release & Monitoring (Week 5)

#### Task 4.1: Release Preparation
- **Owner**: DevOps Lead
- **Effort**: 4 hours
- **Dependencies**: Phase 3 complete
- **Description**: Prepare for production release
- **Acceptance Criteria**:
  - [ ] All tests passing
  - [ ] Code reviewed and approved
  - [ ] Release notes prepared
  - [ ] Rollback plan documented
- **Subtasks**:
  - [ ] Final code review
  - [ ] Run integration tests
  - [ ] Create release notes
  - [ ] Document rollback procedure

#### Task 4.2: Monitoring & Observability
- **Owner**: DevOps Lead
- **Effort**: 4 hours
- **Dependencies**: Task 4.1
- **Description**: Setup monitoring for the feature
- **Acceptance Criteria**:
  - [ ] Error tracking active
  - [ ] Performance monitoring active
  - [ ] Alerts configured
  - [ ] Dashboards created
- **Subtasks**:
  - [ ] Configure error tracking (Sentry)
  - [ ] Setup performance monitoring
  - [ ] Create dashboards
  - [ ] Configure alerts
```

### 4. Dependency Graph

```markdown
## Task Dependencies

\`\`\`
1.1 (Infrastructure)
  ↓
1.2 (Data Model) ──────────────────┐
  ↓                                 ↓
1.3 (API Routes) ────────────→ 2.1 (Data Fetching)
  ↑                                 ↓
  └─ Auth Middleware          2.2 (UI Components)
                                    ↓
                              2.3 (Interactions)
                                    ↓
                              3.1 (Testing) ──┐
                                    ↓         ↓
                              3.2 (Docs) 3.3 (Perf)
                                    ↓         ↓
                              4.1 (Release) ←─┘
                                    ↓
                              4.2 (Monitoring)
\`\`\`

### Critical Path
- Must complete before moving to next
- Determines minimum project duration
- Monitor for delays

### Parallel Work
- Infrastructure + API skeleton can happen simultaneously
- UI development can start as API is being built
- Testing should happen throughout, not just Phase 3
```

### 5. Risk Assessment

```markdown
## Risk Analysis

### Risk 1: Database Performance at Scale
- **Likelihood**: Medium
- **Impact**: High
- **Mitigation**:
  - [ ] Design queries with performance in mind
  - [ ] Add database indexes
  - [ ] Load test with realistic data volumes
  - [ ] Setup query monitoring
- **Owner**: Database Team
- **Review Date**: Week 2

### Risk 2: Client-Server Data Mismatch
- **Likelihood**: High
- **Impact**: Medium
- **Mitigation**:
  - [ ] Strong typing (TypeScript)
  - [ ] Shared types between client/server
  - [ ] API testing
  - [ ] Version API endpoints
- **Owner**: Tech Lead
- **Review Date**: Week 2

### Risk 3: Performance Regression
- **Likelihood**: Medium
- **Impact**: High
- **Mitigation**:
  - [ ] Setup performance budgets
  - [ ] Automated Lighthouse checks in CI
  - [ ] Bundle size monitoring
  - [ ] Regular performance audits
- **Owner**: DevOps Lead
- **Review Date**: Week 3

### Risk 4: Accessibility Issues
- **Likelihood**: Medium
- **Impact**: Medium
- **Mitigation**:
  - [ ] Use semantic HTML
  - [ ] Follow WCAG 2.1 guidelines
  - [ ] Automated accessibility testing
  - [ ] Manual accessibility audit
- **Owner**: Frontend Lead
- **Review Date**: Week 4

### Risk 5: Scope Creep
- **Likelihood**: High
- **Impact**: High
- **Mitigation**:
  - [ ] Clear scope definition
  - [ ] Change request process
  - [ ] Regular scope reviews
  - [ ] MVP mindset
- **Owner**: Product Lead
- **Review Date**: Weekly
```

### 6. Success Metrics

```markdown
## Definition of Done

### Feature Completeness
- [ ] All requirements implemented
- [ ] All acceptance criteria met
- [ ] Code reviewed and approved
- [ ] Tested across browsers/devices

### Code Quality
- [ ] TypeScript strict mode: 100% pass
- [ ] ESLint: 0 errors
- [ ] Test coverage: > 80%
- [ ] No console warnings/errors

### Performance
- [ ] Lighthouse score: > 90
- [ ] LCP: < 2.5s
- [ ] CLS: < 0.1
- [ ] FID: < 100ms

### Security
- [ ] No security vulnerabilities found
- [ ] Authenticated endpoints verified
- [ ] Data validation server-side
- [ ] HTTPS enforced

### Documentation
- [ ] Code comments for complex logic
- [ ] API documentation complete
- [ ] Architecture decision logged
- [ ] Setup instructions provided

### User Experience
- [ ] Loading states shown
- [ ] Error messages helpful
- [ ] Mobile experience tested
- [ ] Accessibility audit passed
```

## Implementation Plan Examples

### Example 1: Add Analytics Feature

```markdown
## Feature: User Analytics Dashboard

### Overview
Track and visualize user behavior across the platform.

### Requirements
- Track page views, clicks, purchases
- Real-time analytics dashboard
- Historical data (30, 90, 365 days)
- Export to CSV

### Tasks

#### Phase 1: Data Collection
- [ ] Add event tracking middleware (2d)
- [ ] Create analytics database schema (1d)
- [ ] Setup event ingestion API (1d)

#### Phase 2: Dashboard UI
- [ ] Create analytics page layout (2d)
- [ ] Build metric cards (1d)
- [ ] Create charts with Recharts (2d)

#### Phase 3: Export & Optimization
- [ ] CSV export functionality (1d)
- [ ] Query optimization (1d)
- [ ] Caching strategy (1d)

### Timeline: 2 weeks
```

### Example 2: Implement Real-time Notifications

```markdown
## Feature: Real-time Notifications

### Overview
Push notifications to users as events occur.

### Requirements
- Server-sent events (SSE) or WebSocket
- Notification UI component
- Mark as read functionality
- Notification history

### Tasks

#### Phase 1: Infrastructure
- [ ] Choose SSE vs WebSocket (1d)
- [ ] Implement message queue (2d)
- [ ] Setup connection manager (2d)

#### Phase 2: Notification System
- [ ] Build notification model (1d)
- [ ] Notification sender service (2d)
- [ ] UI components (2d)

#### Phase 3: Polish
- [ ] Error handling & reconnection (2d)
- [ ] Performance testing (1d)
- [ ] Documentation (1d)

### Timeline: 2.5 weeks
```

## Task Management Best Practices

### Estimation Techniques

```typescript
// Story Points Estimation (Fibonacci: 1, 2, 3, 5, 8, 13...)
// 1 = < 2 hours
// 2 = 2-4 hours
// 3 = 4-8 hours
// 5 = 1-2 days
// 8 = 2-3 days
// 13 = 3-5 days
// 21+ = Too big, break down

type Task = {
  id: string;
  name: string;
  storyPoints: number; // 1-21
  owner: string;
  dependencies: string[];
  dueDate: Date;
};

function getTotalEffort(tasks: Task[]): number {
  return tasks.reduce((sum, t) => sum + t.storyPoints, 0);
}

function getEstimatedWeeks(totalPoints: number): number {
  // Typical team: 15-20 points per week
  return Math.ceil(totalPoints / 20);
}
```

### Status Tracking

```markdown
## Task Status

- **Not Started** / **PLANNED** - Requirements clear, not started
- **In Progress** - Work actively happening
- **Blocked** - Waiting on dependency or decision
- **In Review** - Code/work being reviewed
- **Ready to Merge** - Approved, pending merge
- **Complete** - Merged and verified

### Status Updates
- Update daily during standup
- Track blockers immediately
- Escalate risks as they appear
```

### Progress Reporting

```markdown
## Weekly Status Report

### Completed (Week 4)
- [x] Task 2.1: Server Components - DONE
- [x] Task 2.2: UI Components (70%) - IN_PROGRESS
- [x] Fixed performance issue with queries

### In Progress (Week 5)
- [ ] Task 2.2: UI Components - 80% complete
- [ ] Task 2.3: Client Interactions - 30% complete
- [ ] Task 3.1: Testing - 10% complete

### Blocked
- Task 1.4 awaiting design approval (due Friday)

### Risks
- Performance regression detected in latest build (investigating)
- Scope creep: 3 new feature requests received

### Next Week
- Complete UI components
- Start testing phase
- Performance optimization sprint
```

## Tools for Planning

- **Linear/Jira**: Task tracking
- **Figma**: Design mockups
- **Excalidraw**: Architecture diagrams
- **Notion**: Documentation
- **GitHub Projects**: Integration with code
- **Google Docs**: Collaborative planning

## Resources

- [Planning and Estimation Guide](https://www.mountaingoatsoftware.com/agile/scrum)
- [Task Breakdown Strategies](https://www.atlassian.com/agile)
- [Risk Management](https://en.wikipedia.org/wiki/Risk_management)
