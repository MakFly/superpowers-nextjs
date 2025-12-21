---
name: nextjs:using-nextjs-superpowers
description: Entry point for Next.js Superpowers - essential workflows, philosophy, and interactive commands for productive Next.js 16 development
---

# Using Next.js Superpowers

Welcome to the Next.js Superpowers framework - a comprehensive toolkit designed to supercharge your Next.js 16 development workflow. This skill provides the foundation and essential entry points for leveraging the full power of modern Next.js development.

## Package Manager Runner Selection

Before you start any workflow, select your preferred package manager. Each runner has distinct advantages:

| Runner | Install | Dev | Build | Run | Best For |
|--------|---------|-----|-------|-----|----------|
| **npm** | `npm install` | `npm run dev` | `npm run build` | `npm start` | Default, wide compatibility |
| **yarn** | `yarn install` | `yarn dev` | `yarn build` | `yarn start` | Workspaces, performance |
| **pnpm** | `pnpm install` | `pnpm dev` | `pnpm build` | `pnpm start` | Disk space, monorepos |
| **bun** | `bun install` | `bun dev` | `bun build` | `bun start` | Speed, all-in-one runtime |

## Essential Workflows

### 1. Project Initialization & Verification
- **Initialize fresh project**: Set up a new Next.js 16 application with type safety and modern tooling
- **Bootstrap check**: Verify all critical configuration files and project structure
- **Environment validation**: Ensure all required environment variables are configured
- **Dependency audit**: Check for outdated or vulnerable packages

### 2. Development & Debugging
- **Hot reload testing**: Verify hot module replacement is working correctly
- **TypeScript validation**: Run type checking across the entire project
- **ESLint verification**: Check code quality and style consistency
- **Debug mode activation**: Enable detailed logging and debugging information

### 3. Performance & Optimization
- **Bundle analysis**: Analyze JavaScript bundle size and composition
- **Image optimization**: Verify image optimization configuration
- **Code splitting validation**: Check automatic code splitting behavior
- **Cache strategy review**: Review static generation and ISR configuration

### 4. Testing & Quality Assurance
- **Unit tests**: Execute Jest test suite
- **Integration tests**: Run end-to-end tests with Playwright
- **Type coverage**: Generate TypeScript coverage reports
- **Lint fixes**: Auto-fix code style issues

### 5. Build & Deployment
- **Production build**: Create optimized production bundle
- **Build analysis**: Examine build size and performance metrics
- **Static export**: Generate static site for CDN deployment
- **Docker optimization**: Prepare containerized builds

## Development Philosophy

### Server-First Architecture
Next.js 16 emphasizes server components and server actions as the primary development paradigm:
- **React Server Components (RSC)** enable data fetching directly within components
- **Server Actions** replace traditional API routes for mutations
- **Automatic code splitting** between server and client code
- **Zero JavaScript by default** for server-rendered content

### Type Safety First
TypeScript is integrated throughout the entire stack:
- **Strict mode enabled** by default in new projects
- **Type-safe server actions** with automatic serialization
- **Type-safe environment variables** with validation
- **End-to-end type safety** from database to UI

### Performance By Default
Modern optimizations are built into the framework:
- **Automatic code splitting** via dynamic imports
- **Image optimization** with next/image component
- **Font optimization** with next/font
- **CSS modules** and module federation support
- **Streaming** for progressive rendering

### Developer Experience
The framework is optimized for rapid development:
- **Fast refresh** for instant feedback loop
- **Error recovery** with detailed error messages
- **Built-in debugging** with Node.js inspector support
- **CLI utilities** for common development tasks

## Interactive Commands

### Development Commands
```bash
# Start development server with full hot reload
dev

# Run TypeScript compiler in watch mode
type:check

# Validate ESLint rules
lint

# Auto-fix linting issues
lint:fix

# Run all tests in watch mode
test

# Check code coverage metrics
test:coverage
```

### Build & Analysis Commands
```bash
# Create production build
build

# Analyze bundle composition
analyze

# Check build output size
size

# Validate all configurations
validate
```

### Debugging Commands
```bash
# Enable verbose logging
debug

# Run with Node.js inspector
debug:node

# Launch browser DevTools
debug:chrome

# Check environment configuration
env:check
```

### Project Health Commands
```bash
# Comprehensive project audit
audit

# Fix common issues automatically
fix

# Generate health report
health:report

# Update dependencies safely
update:deps
```

## Version Support & Compatibility

| Feature | Next.js 16 | Node.js | React |
|---------|-----------|--------|-------|
| App Router | ✅ Stable | 18.17+ | 19+ |
| Server Components | ✅ Full | 18.17+ | 19+ |
| Streaming | ✅ Full | 18.17+ | 19+ |
| Server Actions | ✅ Stable | 18.17+ | 19+ |
| Dynamic Imports | ✅ Full | 18.17+ | 19+ |
| TypeScript 5.x | ✅ Full | 18.17+ | 19+ |

## Quick Reference Commands

### Most Common Workflows
```bash
# New developer? Start here
npx next-superpowers bootstrap-check

# Select your package manager
select:runner

# Verify your setup
verify:setup

# Start developing
dev

# Build for production
build

# Deploy to production
deploy
```

### Troubleshooting
```bash
# Check what's wrong
diagnose

# Fix automatically
fix:auto

# Get detailed help
help --verbose

# View current configuration
config:show
```

## Next Steps

1. **Run Bootstrap Check**: Execute `bootstrap-check` to verify your project configuration
2. **Select Package Manager**: Use `runner-selection` to configure your preferred package manager
3. **Start Development**: Run your development server and begin building
4. **Explore Features**: Navigate through the skills and commands to discover advanced workflows

## Resources

- [Next.js 16 Documentation](https://nextjs.org)
- [React 19 Documentation](https://react.dev)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [Superpowers Framework Guide](./docs)
