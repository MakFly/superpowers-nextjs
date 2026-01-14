# Superpowers Next.js

A Next.js 16 focused toolkit for Claude Code providing App Router patterns, Server Components, Server Actions, data fetching strategies, caching, testing, and modern React architecture.

## Features

- **App Router Mastery** - Layouts, pages, route groups, parallel routes, intercepting routes
- **Server Components** - RSC patterns, async components, zero-JS optimization
- **Server Actions** - Form handling, mutations, revalidation strategies
- **Data Fetching** - Caching strategies, streaming, Suspense patterns
- **Testing** - Jest, Vitest, Playwright, React Testing Library
- **Performance** - Image/font optimization, lazy loading, streaming SSR
- **NextDevTools MCP** - Enhanced debugging integration for Next.js 16

## Installation

```bash
claude plugins add superpowers-nextjs
```

Or add to your Claude Code plugins configuration.

### Manual install (git clone)

```bash
git clone https://github.com/MakFly/superpowers-nextjs.git ~/.claude/plugins/superpowers-nextjs
```

Enable the plugin in both configs (Claude + GLM):

```json
// ~/.claude/settings.json
{
  "enabledPlugins": {
    "superpowers-nextjs@custom": true
  }
}
```

```json
// ~/.claude-glm/.claude.json
{
  "enabledPlugins": {
    "superpowers-nextjs@custom": true
  }
}
```

Restart Claude Code.

### Fallback: symlink skills (if plugin skills don’t load)

```bash
ln -s ~/.claude/plugins/superpowers-nextjs/skills/caching-strategies ~/.claude/skills/nextjs-caching-strategies
```

Then call:
```
Use the skill nextjs:caching-strategies
```

### Troubleshooting (Unknown skill)

If you see `Unknown skill`:
1. Restart Claude Code.
2. Run `What skills are available?` to confirm the plugin is loaded.
3. Ensure `enabledPlugins` includes `superpowers-nextjs@custom` in both configs.
4. Use the fallback symlink if the plugin still does not expose skills.

## Quick Start

Once installed, the plugin automatically detects Next.js projects and provides context-aware assistance.

**Complexity tiers**: See `docs/complexity-tiers.md` for simple/medium/complex examples and how to adapt output.

### Interactive Commands

- `/superpowers-nextjs:brainstorm` - Structured ideation for features
- `/superpowers-nextjs:write-plan` - Implementation planning
- `/superpowers-nextjs:execute-plan` - Methodical TDD execution
- `/superpowers-nextjs:nextjs-check` - Quality validation (ESLint, TypeScript, tests)
- `/superpowers-nextjs:nextjs-tdd-vitest` - TDD workflow with Vitest

### Key Skills

| Category | Skills |
|----------|--------|
| Routing | `app-router`, `dynamic-routes`, `route-groups`, `parallel-routes` |
| Data | `server-components`, `data-fetching-patterns`, `caching-strategies` |
| Actions | `server-actions`, `form-handling`, `mutations`, `revalidation` |
| Testing | `testing-with-vitest`, `testing-with-jest`, `e2e-playwright` |
| Performance | `image-optimization`, `streaming`, `lazy-loading` |

## Environment Detection

The plugin automatically detects:

- Next.js version and router type (App/Pages/Hybrid)
- Package manager (npm, yarn, pnpm, bun)
- TypeScript configuration
- NextDevTools MCP configuration
- Test framework (Jest, Vitest, Playwright)
- Styling solution (Tailwind, CSS Modules, styled-components)

## Version Support

| Next.js | Status |
|---------|--------|
| 16.x | Full support |
| 15.x | Full support |
| 14.x | Supported |

## Philosophy

- **Server-first** - Prefer Server Components, use Client Components strategically
- **Type-safe** - Full TypeScript with strict mode
- **Progressive** - Progressive enhancement with streaming
- **Testable** - TDD workflow with comprehensive testing

## License

MIT License - See [LICENSE](LICENSE) for details.
