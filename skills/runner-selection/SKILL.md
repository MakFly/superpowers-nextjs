---
name: nextjs:runner-selection
description: Select and configure the appropriate package manager (npm/yarn/pnpm/bun) based on project configuration
---

# Package Manager Runner Selection

Choosing the right package manager for your Next.js project is crucial for development workflow efficiency and team consistency. This skill guides you through detecting available runners, configuring them appropriately, and switching between them seamlessly.

## Package Manager Detection

The system automatically detects which package managers are available in your environment and which one is currently being used in your project.

### Detection Mechanism

The runner selection system checks for:

1. **Lockfile Detection** (Primary Method)
   - `package-lock.json` → npm
   - `yarn.lock` → yarn
   - `pnpm-lock.yaml` → pnpm
   - `bun.lockb` → bun

2. **Package Manager Binary** (Fallback)
   - Checks if `npm`, `yarn`, `pnpm`, or `bun` is available in PATH
   - Verifies version compatibility with Next.js 16

3. **Project Configuration**
   - `package.json` field: `"packageManager"` field (npm 7+)
   - `.npmrc` or `.yarnrc` files for manager-specific config
   - CI/CD environment hints (GitHub Actions, etc.)

### Detection Commands

```bash
# Detect current package manager
detect:runner

# List all available package managers
list:runners

# Check package manager versions
version:all

# Verify lockfile consistency
validate:lockfile
```

## NPM - Node Package Manager

**Best for**: Default choice, maximum compatibility, simple projects

### Installation
```bash
# Already included with Node.js 16.13+
npm --version
```

### Common Commands
```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build

# Run production server
npm start

# Add new package
npm install [package-name]

# Remove package
npm uninstall [package-name]

# Update packages
npm update

# Check for vulnerabilities
npm audit

# Fix vulnerabilities
npm audit fix
```

### Configuration Files
- `package.json` - Main project manifest
- `package-lock.json` - Exact dependency resolution
- `.npmrc` - npm configuration settings

### Advantages
- Default for most Node.js projects
- Best documentation and Stack Overflow support
- No additional installation required
- Works everywhere Node.js is installed

### Considerations
- Larger lockfile sizes in complex projects
- Slower dependency resolution compared to modern alternatives
- Less efficient disk space usage
- Limited workspace support

## Yarn - Facebook's Package Manager

**Best for**: Workspaces, faster installs, deterministic builds

### Installation
```bash
# Using npm
npm install -g yarn

# Using corepack (recommended for Node 16.13+)
corepack enable yarn

# Check version
yarn --version
```

### Common Commands
```bash
# Install dependencies
yarn install

# Start development server
yarn dev

# Build for production
yarn build

# Run production server
yarn start

# Add new package
yarn add [package-name]

# Remove package
yarn remove [package-name]

# Update packages
yarn upgrade

# Check for vulnerabilities
yarn audit

# Fix vulnerabilities
yarn audit --fix
```

### Configuration Files
- `package.json` - Main project manifest
- `yarn.lock` - Exact dependency resolution
- `.yarnrc` or `.yarnrc.yml` - Yarn configuration
- `yarn-error.log` - Error logs

### Workspace Support
```bash
# Define workspaces in package.json
{
  "workspaces": [
    "packages/app",
    "packages/shared"
  ]
}

# Install all workspace dependencies
yarn install

# Run command in specific workspace
yarn workspace @myapp/shared add lodash
```

### Advantages
- Excellent monorepo and workspace support
- Faster dependency resolution and installation
- Better deterministic builds
- Offline-first mode support

### Considerations
- Additional installation required
- Less stable for Windows development
- Larger community than Bun but smaller than npm
- Yarn 3 (latest) has breaking changes from Yarn 1

## PNPM - Performant Node Package Manager

**Best for**: Monorepos, disk space efficiency, fast dependency resolution

### Installation
```bash
# Using npm
npm install -g pnpm

# Using corepack (recommended)
corepack enable pnpm

# Check version
pnpm --version
```

### Common Commands
```bash
# Install dependencies
pnpm install

# Start development server
pnpm dev

# Build for production
pnpm build

# Run production server
pnpm start

# Add new package
pnpm add [package-name]

# Add as dev dependency
pnpm add -D [package-name]

# Remove package
pnpm remove [package-name]

# Update packages
pnpm update

# Check for vulnerabilities
pnpm audit

# Fix vulnerabilities
pnpm audit --fix
```

### Workspace Configuration
```bash
# Define workspaces in pnpm-workspace.yaml
packages:
  - 'packages/*'
  - 'apps/*'

# Install all workspace dependencies
pnpm install

# Filter specific workspace
pnpm --filter @myapp/shared add lodash

# Run scripts across workspaces
pnpm -r dev
```

### Configuration Files
- `package.json` - Main project manifest
- `pnpm-lock.yaml` - Exact dependency resolution
- `pnpm-workspace.yaml` - Workspace definition
- `.npmrc` - npm-compatible configuration

### Advanced Features
```bash
# Install dependencies with hardlinks
pnpm install --prefer-offline

# Check disk usage
pnpm store status

# Prune unused packages
pnpm prune

# Rebuild native modules
pnpm rebuild
```

### Advantages
- Exceptional disk space efficiency via content-addressable storage
- Fastest installation times in most benchmarks
- Superior monorepo and workspace support
- Stricter dependency resolution prevents phantom dependencies
- Best for large-scale projects

### Considerations
- Smaller ecosystem compared to npm/yarn
- Stricter requirements can cause compatibility issues with poorly-written packages
- Less mainstream adoption in enterprise
- Learning curve for monorepo configurations

## Bun - Modern JavaScript Runtime

**Best for**: Ultra-fast development, all-in-one solution, new projects

### Installation
```bash
# Official install script
curl -fsSL https://bun.sh/install | bash

# Using Homebrew (macOS)
brew install bun

# Check version
bun --version
```

### Common Commands
```bash
# Install dependencies
bun install

# Start development server
bun dev

# Build for production
bun build

# Run production server
bun start

# Add new package
bun add [package-name]

# Add as dev dependency
bun add -d [package-name]

# Remove package
bun remove [package-name]

# Update packages
bun update

# Check for vulnerabilities
bun audit

# Fix vulnerabilities
bun audit --fix
```

### Configuration Files
- `package.json` - Main project manifest
- `bun.lockb` - Binary lockfile format (faster)
- `bunfig.toml` - Bun-specific configuration

### Monorepo Support
```bash
# Define workspaces in package.json
{
  "workspaces": ["apps/*", "packages/*"]
}

# Install all dependencies
bun install

# Run script in workspace
bun --cwd=apps/web dev
```

### Unique Features
```bash
# Run TypeScript directly
bun run script.ts

# Execute JSX
bun run component.jsx

# Built-in test runner
bun test

# Built-in bundler
bun build ./src/index.ts --outdir ./dist
```

### Advantages
- Exceptionally fast - 3-4x faster than npm in most cases
- All-in-one runtime: package manager + bundler + test runner + transpiler
- Modern JavaScript and JSX support built-in
- Perfect for Next.js development with instant hot reload
- Smaller binary lockfile format
- Built-in testing framework

### Considerations
- Newer project with smaller community
- Less mature ecosystem plugins
- May have compatibility issues with some legacy packages
- Primarily optimized for modern JavaScript

## Migration Guide

### Switching from npm to yarn

```bash
# Remove npm lockfile
rm package-lock.json

# Install yarn (if not already installed)
npm install -g yarn

# Initialize yarn
yarn install

# Set as package manager (Node 16.13+)
npm config set package-manager yarn
```

### Switching from npm to pnpm

```bash
# Remove npm lockfile
rm package-lock.json

# Install pnpm
npm install -g pnpm

# Initialize pnpm
pnpm install

# Set as package manager
npm config set package-manager pnpm
```

### Switching from yarn to bun

```bash
# Remove yarn lockfile
rm yarn.lock

# Install bun
curl -fsSL https://bun.sh/install | bash

# Initialize bun
bun install

# Mark preference in package.json
# Add: "packageManager": "bun@latest"
```

## Configuration per Runner

### NPM Configuration (.npmrc)
```ini
# Set registry
registry=https://registry.npmjs.org/

# Set authentication token
//registry.npmjs.org/:_authToken=YOUR_TOKEN

# Enable strict SSL
strict-ssl=true

# Increase timeout
fetch-timeout=60000
```

### Yarn Configuration (.yarnrc.yml)
```yaml
nodeLinker: node-modules
npmRegistryServer: https://registry.npmjs.org
enableScripts: true
enableImmutableInstalls: false
```

### PNPM Configuration (.npmrc or .pnpmrc)
```ini
store-dir=.pnpm-store
shamefully-hoist=true
strict-peer-dependencies=false
public-hoist-whitelist=*
```

### Bun Configuration (bunfig.toml)
```toml
[install]
production = false

[run]
root = "."
cwd = "."

[test]
preload = ["setup.ts"]
```

## Consistency Enforcement

### Team Standards

```json
{
  "packageManager": "npm@10.0.0"
}
```

Specify exact version in `package.json` to ensure all team members use the same runner.

### Pre-commit Validation

```bash
# Verify correct runner is being used
validate:runner

# Check lockfile integrity
validate:lockfile

# Ensure dependencies are clean
validate:deps
```

### CI/CD Configuration

```yaml
# .github/workflows/ci.yml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/setup-node@v4
        with:
          node-version: 18.17

      # Enable Corepack for managed runners
      - run: corepack enable
```

## Decision Matrix

Choose based on your needs:

| Factor | npm | yarn | pnpm | bun |
|--------|-----|------|------|-----|
| Speed | ★★★ | ★★★★ | ★★★★★ | ★★★★★ |
| Disk Usage | ★★ | ★★★ | ★★★★★ | ★★★★ |
| Monorepo | ★★★ | ★★★★ | ★★★★★ | ★★★★ |
| Learning Curve | ★★★★★ | ★★★★ | ★★★ | ★★★★ |
| Stability | ★★★★★ | ★★★★ | ★★★★ | ★★★ |
| Compatibility | ★★★★★ | ★★★★ | ★★★★ | ★★★ |
| Team Support | ★★★★★ | ★★★★ | ★★★ | ★★ |

## Next Steps

1. **Identify Current Runner**: Check which package manager your project currently uses
2. **Verify Configuration**: Review your runner's configuration files
3. **Install Dependencies**: Run install command for your selected runner
4. **Test Setup**: Verify dev server starts correctly with your runner
5. **Document Choice**: Include runner information in team documentation

