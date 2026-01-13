#!/usr/bin/env bash

# ============================================
# superpowers-nextjs Session Start Hook
# Detects Next.js projects and configures environment
# ============================================

set -euo pipefail

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(dirname "$0")")}"
SKILL_DIR="${PLUGIN_ROOT}/skills/using-nextjs-superpowers"

# ============================================
# 1. NEXT.JS PROJECT DETECTION
# ============================================

detect_nextjs_apps() {
    local search_root="${1:-.}"
    local apps=()

    # Search for package.json with "next" dependency
    while IFS= read -r -d '' pkg_file; do
        if grep -qE '"next":\s*"' "$pkg_file" 2>/dev/null; then
            local app_dir
            app_dir=$(dirname "$pkg_file")
            apps+=("$app_dir")
        fi
    done < <(find "$search_root" \
        -name "package.json" \
        -not -path "*/node_modules/*" \
        -not -path "*/.git/*" \
        -print0 2>/dev/null)

    printf '%s\n' "${apps[@]}"
}

# ============================================
# 2. NEXT.JS VERSION DETECTION
# ============================================

get_nextjs_version() {
    local app_dir="$1"
    local version=""

    # Priority 1: package-lock.json
    if [[ -f "$app_dir/package-lock.json" ]]; then
        version=$(grep -A2 '"next":' "$app_dir/package-lock.json" 2>/dev/null | \
            grep '"version"' | head -1 | \
            sed -E 's/.*"version": "([0-9]+\.[0-9]+).*/\1/')
    fi

    # Priority 2: yarn.lock
    if [[ -z "$version" && -f "$app_dir/yarn.lock" ]]; then
        version=$(grep -A1 '"next@' "$app_dir/yarn.lock" 2>/dev/null | \
            grep 'version' | head -1 | \
            sed -E 's/.*version "([0-9]+\.[0-9]+).*/\1/')
    fi

    # Priority 3: pnpm-lock.yaml
    if [[ -z "$version" && -f "$app_dir/pnpm-lock.yaml" ]]; then
        version=$(grep -A5 "next:" "$app_dir/pnpm-lock.yaml" 2>/dev/null | \
            grep "version:" | head -1 | \
            sed -E "s/.*version: '?([0-9]+\.[0-9]+).*/\1/")
    fi

    # Priority 4: bun.lockb (binary, fallback to package.json)
    if [[ -z "$version" && -f "$app_dir/package.json" ]]; then
        version=$(grep '"next"' "$app_dir/package.json" 2>/dev/null | \
            sed -E 's/.*"[\^~]?([0-9]+\.[0-9]+).*/\1/')
    fi

    echo "${version:-unknown}"
}

# ============================================
# 3. ROUTER TYPE DETECTION (App vs Pages)
# ============================================

detect_router_type() {
    local app_dir="$1"
    local router_type="unknown"

    # Check for App Router
    if [[ -d "$app_dir/app" ]] || [[ -d "$app_dir/src/app" ]]; then
        router_type="app"
    fi

    # Check for Pages Router
    if [[ -d "$app_dir/pages" ]] || [[ -d "$app_dir/src/pages" ]]; then
        if [[ "$router_type" == "app" ]]; then
            router_type="hybrid"
        else
            router_type="pages"
        fi
    fi

    echo "$router_type"
}

# ============================================
# 4. PACKAGE MANAGER DETECTION
# ============================================

detect_package_manager() {
    local app_dir="$1"
    local pm_name="npm"
    local pm_command="npm"

    if [[ -f "$app_dir/bun.lockb" ]] || [[ -f "$app_dir/bun.lock" ]]; then
        pm_name="bun"
        pm_command="bun"
    elif [[ -f "$app_dir/pnpm-lock.yaml" ]]; then
        pm_name="pnpm"
        pm_command="pnpm"
    elif [[ -f "$app_dir/yarn.lock" ]]; then
        pm_name="yarn"
        pm_command="yarn"
    elif [[ -f "$app_dir/package-lock.json" ]]; then
        pm_name="npm"
        pm_command="npm"
    fi

    echo "${pm_name}|${pm_command}"
}

# ============================================
# 5. TYPESCRIPT DETECTION
# ============================================

detect_typescript() {
    local app_dir="$1"
    local ts_enabled="false"
    local ts_strict="false"

    if [[ -f "$app_dir/tsconfig.json" ]]; then
        ts_enabled="true"
        if grep -q '"strict":\s*true' "$app_dir/tsconfig.json" 2>/dev/null; then
            ts_strict="true"
        fi
    fi

    echo "${ts_enabled}|${ts_strict}"
}

# ============================================
# 6. NEXTDEVTOOLS MCP DETECTION
# ============================================

detect_nextdevtools_mcp() {
    local app_dir="$1"
    local configured="false"

    # Check various MCP config locations
    if [[ -f "$app_dir/.mcp.json" ]]; then
        if grep -q "next-devtools" "$app_dir/.mcp.json" 2>/dev/null; then
            configured="true"
        fi
    fi

    if [[ -f "$app_dir/.cursor/mcp.json" ]]; then
        if grep -q "next-devtools" "$app_dir/.cursor/mcp.json" 2>/dev/null; then
            configured="true"
        fi
    fi

    # Check next.config for MCP server
    if [[ -f "$app_dir/next.config.js" ]] || [[ -f "$app_dir/next.config.mjs" ]] || [[ -f "$app_dir/next.config.ts" ]]; then
        local config_file
        config_file=$(ls "$app_dir"/next.config.* 2>/dev/null | head -1)
        if [[ -n "$config_file" ]] && grep -q "mcpServer" "$config_file" 2>/dev/null; then
            configured="true"
        fi
    fi

    echo "$configured"
}

# ============================================
# 7. TEST FRAMEWORK DETECTION
# ============================================

detect_test_framework() {
    local app_dir="$1"
    local framework="none"

    if [[ -f "$app_dir/package.json" ]]; then
        if grep -q '"vitest"' "$app_dir/package.json" 2>/dev/null; then
            framework="vitest"
        elif grep -q '"jest"' "$app_dir/package.json" 2>/dev/null; then
            framework="jest"
        fi

        # Also check for Playwright
        if grep -q '"@playwright/test"' "$app_dir/package.json" 2>/dev/null; then
            if [[ "$framework" != "none" ]]; then
                framework="${framework}+playwright"
            else
                framework="playwright"
            fi
        fi
    fi

    echo "$framework"
}

# ============================================
# 8. STYLING DETECTION
# ============================================

detect_styling() {
    local app_dir="$1"
    local styling="css"

    if [[ -f "$app_dir/tailwind.config.js" ]] || [[ -f "$app_dir/tailwind.config.ts" ]] || [[ -f "$app_dir/tailwind.config.mjs" ]]; then
        styling="tailwind"
    elif grep -q '"styled-components"' "$app_dir/package.json" 2>/dev/null; then
        styling="styled-components"
    elif grep -q '"@emotion/react"' "$app_dir/package.json" 2>/dev/null; then
        styling="emotion"
    fi

    echo "$styling"
}

# ============================================
# MAIN EXECUTION
# ============================================

main() {
    local cwd="${PWD}"
    local apps

    # Detect Next.js applications
    mapfile -t apps < <(detect_nextjs_apps "$cwd")

    if [[ ${#apps[@]} -eq 0 ]]; then
        # No Next.js application detected
        exit 0
    fi

    # Determine active application
    local active_app=""
    for app in "${apps[@]}"; do
        if [[ "$cwd" == "$app"* ]]; then
            active_app="$app"
            break
        fi
    done
    [[ -z "$active_app" ]] && active_app="${apps[0]}"

    # Collect information
    local nextjs_version
    local router_type
    local pm_info
    local ts_info
    local devtools_mcp
    local test_framework
    local styling

    nextjs_version=$(get_nextjs_version "$active_app")
    router_type=$(detect_router_type "$active_app")
    pm_info=$(detect_package_manager "$active_app")
    ts_info=$(detect_typescript "$active_app")
    devtools_mcp=$(detect_nextdevtools_mcp "$active_app")
    test_framework=$(detect_test_framework "$active_app")
    styling=$(detect_styling "$active_app")

    # Parse package manager info
    IFS='|' read -r pm_name pm_command <<< "$pm_info"

    # Parse TypeScript info
    IFS='|' read -r ts_enabled ts_strict <<< "$ts_info"

    # Determine if latest version
    local is_latest="false"
    if [[ "$nextjs_version" == "16"* ]] || [[ "$nextjs_version" == "15"* ]]; then
        is_latest="true"
    fi

    # Generate commands
    local dev_cmd="${pm_command} run dev"
    local build_cmd="${pm_command} run build"
    local test_cmd="${pm_command} run test"
    local lint_cmd="${pm_command} run lint"

    if [[ "$pm_name" == "bun" ]]; then
        dev_cmd="bun dev"
        build_cmd="bun run build"
        test_cmd="bun test"
        lint_cmd="bun lint"
    fi

    # Determine guidance
    local guidance=""
    if [[ "$router_type" == "pages" ]]; then
        guidance="Consider migrating to App Router for Server Components and improved performance"
    elif [[ "$devtools_mcp" == "false" && "$nextjs_version" == "16"* ]]; then
        guidance="Enable NextDevTools MCP for enhanced debugging: add mcpServer: true to next.config"
    fi

    # Output JSON context for Claude
    cat <<EOF
{
  "plugin": "superpowers-nextjs",
  "detected_apps": ${#apps[@]},
  "active_app": "$active_app",
  "nextjs": {
    "version": "$nextjs_version",
    "router": "$router_type",
    "is_latest": $is_latest
  },
  "typescript": {
    "enabled": $ts_enabled,
    "strict": $ts_strict
  },
  "package_manager": {
    "name": "$pm_name",
    "command": "$pm_command"
  },
  "devtools_mcp": {
    "configured": $devtools_mcp
  },
  "test_framework": "$test_framework",
  "styling": "$styling",
  "commands": {
    "dev": "$dev_cmd",
    "build": "$build_cmd",
    "test": "$test_cmd",
    "lint": "$lint_cmd"
  },
  "guidance": $(if [[ -n "$guidance" ]]; then echo "\"$guidance\""; else echo "null"; fi)
}
EOF

}

main "$@"
