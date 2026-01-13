# Reference

# Bootstrap Check - Project Configuration Verification

The Bootstrap Check is a comprehensive diagnostic tool that verifies your Next.js project is properly configured and ready for development. It validates all critical configuration files, dependencies, and project structure to ensure optimal development experience.

## Overview

This skill performs a complete health check of your Next.js 16 project, examining:
- Project structure and directory layout
- Configuration file integrity
- TypeScript setup and type safety
- ESLint configuration and code quality rules
- App Router and directory structure
- Environment variables and secrets
- Build and runtime dependencies
- Development tooling configuration

## Configuration Files Checklist

### Core Next.js Configuration

#### next.config.js or next.config.mjs
```javascript
// Expected: next.config.js or next.config.mjs should exist
const nextConfig = {
  reactStrictMode: true,
  experimental: {
    serverComponentsExternalPackages: [],
  },
}

module.exports = nextConfig
```

**Validation Points:**
- File exists in project root
- Exports valid Next.js configuration object
- `reactStrictMode` is enabled for development
- `experimental.serverComponentsExternalPackages` configured if using heavy dependencies on server
- TypeScript compatibility (`.mjs` or proper `.js` export)

**Check Status:**
```bash
✓ next.config.js exists
✓ Configuration is valid JavaScript/TypeScript
✓ reactStrictMode: true
✓ All experimental features properly configured
```

### TypeScript Configuration

#### tsconfig.json
```json
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "strict": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [
      {
        "name": "next"
      }
    ],
    "paths": {
      "@/*": ["./*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
```

**Validation Points:**
- File exists in project root
- `strict`: true for maximum type safety
- `moduleResolution`: bundler (modern resolution)
- Path aliases configured (especially `@/*`)
- `allowImportingTsExtensions`: true for proper ESM handling
- `isolatedModules`: true for faster compilation
- next plugin included in plugins array

**Check Status:**
```bash
✓ tsconfig.json exists
✓ strict mode enabled
✓ moduleResolution set to 'bundler'
✓ Path aliases configured
✓ Plugin integration verified
```

#### Verifying TypeScript Setup
```bash
# Check for type errors
tsc --noEmit

# Validate tsconfig syntax
npx tsc -p tsconfig.json --listFiles

# Check for any ignored errors
grep -r "// @ts-ignore" src/
```

### ESLint Configuration

#### .eslintrc.json or eslint.config.js
```javascript
// Modern ESLint flat config (v8.56+)
import js from '@eslint/js'
import nextPlugin from '@next/eslint-plugin-next'

export default [
  {
    files: ['**/*.{js,mjs,cjs,ts,tsx}'],
    languageOptions: {
      parserOptions: {
        ecmaVersion: 'latest',
        sourceType: 'module',
        ecmaFeatures: {
          jsx: true,
        },
      },
    },
  },
  js.configs.recommended,
  {
    files: ['**/*.{ts,tsx}'],
    rules: nextPlugin.configs.recommended.rules,
  },
]
```

Or legacy format:
```json
{
  "extends": ["next/core-web-vitals"],
  "rules": {
    "react/no-unescaped-entities": "warn",
    "@next/next/no-html-link-for-pages": "off"
  }
}
```

**Validation Points:**
- `.eslintrc.json` or `eslint.config.js` exists
- Extends or imports `next/core-web-vitals` or `@next/eslint-plugin-next`
- Rules are properly configured
- No conflicting rule definitions
- TypeScript support enabled (eslint-plugin-typescript)

**Check Status:**
```bash
✓ ESLint configuration found
✓ Next.js plugin integrated
✓ Core web vitals rules enabled
✓ TypeScript rules configured
```

#### Verifying ESLint Rules
```bash
# Check entire project
npm run lint

# Check specific file
npx eslint src/components/Button.tsx

# Fix auto-fixable issues
npm run lint:fix

# Show rule details
npx eslint --print-config src/pages/index.tsx
```

### App Router Configuration

#### Directory Structure
```
src/
├── app/
│   ├── layout.tsx         # Root layout
│   ├── page.tsx           # Home page
│   ├── error.tsx          # Error boundary
│   ├── loading.tsx        # Loading state
│   ├── not-found.tsx      # 404 page
│   ├── (auth)/
│   │   ├── layout.tsx     # Auth group layout
│   │   ├── login/
│   │   │   └── page.tsx
│   │   └── register/
│   │       └── page.tsx
│   └── api/
│       └── route.ts       # API route
├── components/
│   ├── Button.tsx
│   └── Header.tsx
├── lib/
│   └── utils.ts
└── styles/
    └── globals.css
```

**Validation Points:**
- `src/app/` directory exists (or `app/` at root)
- `app/layout.tsx` (root layout) exists
- `app/page.tsx` (home page) exists
- No legacy `pages/` directory (or properly isolated if used)
- Route groups properly named with parentheses
- API routes in `app/api/` directory with `route.ts`

**Check Status:**
```bash
✓ App Router directory structure valid
✓ Root layout.tsx found
✓ Home page.tsx configured
✓ No conflicting pages/ directory
✓ API routes properly structured
```

#### App Router File Validation
```bash
# List app directory structure
find src/app -type f -name "*.tsx" -o -name "*.ts" | sort

# Check for duplicate routing
find src -name "page.tsx" -o -name "layout.tsx" | grep -E "(pages|app)"

# Validate route segments
npx next routes --show-detailed
```

### Environment Configuration

#### .env.local
```bash
# Database
DATABASE_URL=postgresql://user:password@localhost:5432/dbname

# API Keys
NEXT_PUBLIC_API_URL=https://api.example.com
SECRET_API_KEY=sk_live_xxxxx

# Third-party Services
STRIPE_PUBLIC_KEY=pk_live_xxxxx
STRIPE_SECRET_KEY=sk_live_xxxxx
```

**Validation Points:**
- `.env.local` exists in project root
- `.env.local` is in `.gitignore` (NEVER commit secrets!)
- Environment variables are properly typed
- No hardcoded secrets in code
- `NEXT_PUBLIC_*` variables for client-side use
- Secret variables clearly prefixed

#### Type-Safe Environment Variables
```typescript
// lib/env.ts
const requiredEnvVars = [
  'DATABASE_URL',
  'STRIPE_SECRET_KEY',
] as const

for (const envVar of requiredEnvVars) {
  if (!process.env[envVar]) {
    throw new Error(`Missing required environment variable: ${envVar}`)
  }
}

export const env = {
  databaseUrl: process.env.DATABASE_URL!,
  stripeSecretKey: process.env.STRIPE_SECRET_KEY!,
  apiUrl: process.env.NEXT_PUBLIC_API_URL!,
} as const
```

**Check Status:**
```bash
✓ .env.local exists
✓ .env.local in .gitignore
✓ Required variables defined
✓ No secrets in repository
✓ Type-safe env variables configured
```

### Build Configuration Files

#### package.json
```json
{
  "name": "my-nextjs-app",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "type-check": "tsc --noEmit",
    "test": "jest",
    "test:watch": "jest --watch"
  },
  "dependencies": {
    "next": "^16.0.0",
    "react": "^19.0.0",
    "react-dom": "^19.0.0"
  },
  "devDependencies": {
    "@types/node": "^20.0.0",
    "@types/react": "^19.0.0",
    "@types/react-dom": "^19.0.0",
    "typescript": "^5.3.0",
    "eslint": "^8.54.0",
    "eslint-config-next": "^16.0.0"
  }
}
```

**Validation Points:**
- package.json exists
- `next` version is 16.x
- React version is 19.x or higher
- TypeScript is dev dependency
- eslint-config-next matches next version
- Scripts defined: dev, build, start, lint
- No duplicate or conflicting dependencies

**Check Status:**
```bash
✓ package.json structure valid
✓ Next.js 16 installed
✓ React 19 installed
✓ TypeScript configured
✓ ESLint properly integrated
```

#### .gitignore
```gitignore
# Dependencies
node_modules/
/.pnp
.pnp.js

# Testing
/coverage

# Next.js
/.next/
/out/

# Production
/build

# Misc
.DS_Store
*.pem

# Debug
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Local env files
.env.local
.env.*.local

# Vercel
.vercel

# IDE
.idea/
.vscode/
*.swp
```

**Validation Points:**
- `.gitignore` exists
- `.env.local` is ignored
- `.next/` directory is ignored
- `node_modules/` is ignored
- IDE configuration directories are ignored

## Diagnostic Commands

### Complete Project Health Check
```bash
# Run comprehensive bootstrap check
npx next-superpowers bootstrap-check

# Output:
# ============================================
# Next.js Project Bootstrap Check
# ============================================
#
# Configuration Files:
#   ✓ next.config.js exists and is valid
#   ✓ tsconfig.json properly configured
#   ✓ .eslintrc.json found
#   ✓ .gitignore configured
#
# TypeScript:
#   ✓ Strict mode enabled
#   ✓ 0 type errors found
#   ✓ All imports properly typed
#
# ESLint:
#   ✓ No critical issues
#   ⚠ 3 warnings in src/pages/api/route.ts
#
# App Router:
#   ✓ Root layout.tsx found
#   ✓ Home page.tsx configured
#   ✓ 12 routes detected
#
# Environment:
#   ✓ .env.local exists
#   ✓ All required variables present
#
# Overall Status: ✓ READY FOR DEVELOPMENT
```

### Configuration Validation Commands

```bash
# Validate Next.js configuration
npm run build -- --debug

# Check TypeScript compilation
npx tsc --noEmit --incremental

# Verify ESLint rules
npx eslint . --max-warnings=0

# Analyze project structure
npx next routes

# Check for missing environment variables
npm run validate:env

# Verify all dependencies are installed
npm ls --all

# Check for vulnerabilities
npm audit
```

### File Structure Verification

```bash
# Check required directories exist
bash -c 'for dir in src/app src/components src/lib; do
  [ -d "$dir" ] && echo "✓ $dir exists" || echo "✗ $dir missing"
done'

# List all routes in app directory
find src/app -name "page.tsx" | sort

# Count configuration files
ls -la | grep -E "^\." | head -20

# Verify critical files
for file in next.config.js tsconfig.json .eslintrc.json package.json; do
  [ -f "$file" ] && echo "✓ $file" || echo "✗ $file MISSING"
done
```

### TypeScript Deep Check

```bash
# Full type checking with detailed output
npx tsc --noEmit --pretty --explainFiles

# Check specific file
npx tsc --noEmit src/app/page.tsx

# Generate type report
npx tsc --noEmit --listFilesOnly | wc -l

# Find any type assertion issues
grep -r "as const" src/ --include="*.ts" --include="*.tsx"

# Check for implicit any
npx tsc --noImplicitAny --noEmit
```

### ESLint Detailed Analysis

```bash
# Generate detailed report
npx eslint . --format=json > eslint-report.json

# Show rules and their severity
npx eslint --print-config src/app/page.tsx

# Fix all auto-fixable issues
npx eslint . --fix

# Check specific rule
npx eslint . --rule="react/no-unescaped-entities: off"

# Count issues by severity
npx eslint . --format=json | jq '[.[] | .messages[]] | group_by(.severity) | map({severity: .[0].severity, count: length})'
```

## Automated Fix Commands

### Auto-fix Configuration Issues

```bash
# Initialize missing configuration files
npx create-next-app init-config

# Fix ESLint issues automatically
npx eslint . --fix

# Update TypeScript compiler options
npx tsc --init --strict

# Format code with Prettier (if configured)
npx prettier --write .

# Audit and fix dependencies
npm audit fix

# Reinstall dependencies cleanly
rm -rf node_modules package-lock.json && npm install
```

### Dependency Updates

```bash
# Update Next.js to latest
npm install next@latest react@latest react-dom@latest

# Update TypeScript
npm install -D typescript@latest

# Update ESLint
npm install -D eslint@latest eslint-config-next@latest

# Update all dev dependencies
npm update --save-dev

# Check for outdated packages
npm outdated
```

## Common Issues & Solutions

### Issue: TypeScript "Cannot find module" errors

**Diagnosis:**
```bash
# Check path aliases in tsconfig.json
grep -A 5 '"paths"' tsconfig.json

# Verify actual file structure matches alias
ls src/components/
```

**Solution:**
1. Ensure path aliases in `tsconfig.json` match actual directory structure
2. Restart TypeScript server in IDE
3. Run `npm install` to ensure all dependencies are resolved

### Issue: ESLint not recognizing Next.js rules

**Diagnosis:**
```bash
# Check eslint config includes next plugin
cat .eslintrc.json | grep next

# Check eslint-config-next installation
npm ls eslint-config-next
```

**Solution:**
1. Install missing eslint-config-next: `npm install -D eslint-config-next`
2. Update `.eslintrc.json` to extend `next/core-web-vitals`
3. Restart ESLint server

### Issue: Missing environment variables at runtime

**Diagnosis:**
```bash
# Check .env.local exists
ls -la .env.local

# Verify required vars are defined
grep "NEXT_PUBLIC" .env.local

# Test build process
npm run build
```

**Solution:**
1. Create `.env.local` in project root
2. Add all required environment variables
3. Ensure `.env.local` is in `.gitignore`
4. Restart development server

### Issue: App Router conflicts with Pages Router

**Diagnosis:**
```bash
# Check for both app and pages directories
ls -la src/app src/pages 2>&1

# Find duplicate routes
find src -name "page.tsx" | head -5
```

**Solution:**
1. Choose either App Router (recommended) or Pages Router
2. Move all routes to one directory
3. Delete the unused router directory
4. Update imports and configurations

### Issue: Hot reload not working

**Diagnosis:**
```bash
# Check next.config.js for conflicting settings
cat next.config.js | grep -i "hot"

# Verify node_modules integrity
npm ls next
```

**Solution:**
1. Remove `.next` build cache: `rm -rf .next`
2. Reinstall dependencies: `npm install`
3. Restart development server
4. Check for conflicting webpack plugins in `next.config.js`

## Checklist Template

Print and use this checklist for manual verification:

```
NEXT.JS PROJECT BOOTSTRAP CHECKLIST
==================================

Configuration Files:
☐ next.config.js exists and is valid
☐ tsconfig.json properly configured with strict mode
☐ .eslintrc.json or eslint.config.js configured
☐ .gitignore includes .env.local and .next/

TypeScript:
☐ strict mode enabled in tsconfig.json
☐ No TypeScript compilation errors
☐ Path aliases configured (@/*)
☐ Type definitions installed for dependencies

ESLint:
☐ eslint-config-next installed
☐ No critical linting issues
☐ Rules properly configured
☐ IDE integration working

App Router:
☐ src/app/layout.tsx exists
☐ src/app/page.tsx exists
☐ No conflicting pages/ directory
☐ Route structure is logical

Environment:
☐ .env.local exists (not in git)
☐ All required variables defined
☐ Type-safe env validation implemented
☐ No hardcoded secrets in code

Dependencies:
☐ Next.js 16+ installed
☐ React 19+ installed
☐ TypeScript 5+ installed
☐ No duplicate versions
☐ npm audit shows no critical issues

Development Setup:
☐ npm install completes successfully
☐ npm run dev starts without errors
☐ npm run build succeeds
☐ npm run lint passes
☐ Hot reload working in development

Project Structure:
☐ src/ directory exists
☐ src/components/ for UI components
☐ src/lib/ for utilities
☐ Public assets in public/
☐ README.md with setup instructions

Status: ☐ READY ☐ NEEDS FIXES
```

## Next Steps

1. **Run Bootstrap Check**: Execute complete diagnostic
2. **Address Issues**: Fix any identified configuration problems
3. **Verify Compilation**: Run `npm run build` successfully
4. **Test Development**: Start `npm run dev` and verify hot reload
5. **Commit Configuration**: Ensure all config files are tracked in git
