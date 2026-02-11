#!/usr/bin/env bash
# =============================================================================
# update-ppemedevents.sh -- WP-CLI update & regression checks for ppemedevents.com
#
# Risk level: Standard
# Strategy:   Core first, then bulk plugin update
# Usage:      SSH into Kinsta environment, then: bash update-ppemedevents.sh
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Colors
# ---------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# ---------------------------------------------------------------------------
# Helper functions
# ---------------------------------------------------------------------------
print_header()  { echo -e "\n${BOLD}${BLUE}=== $1 ===${NC}\n"; }
print_pass()    { echo -e "  ${GREEN}[PASS]${NC} $1"; }
print_fail()    { echo -e "  ${RED}[FAIL]${NC} $1"; FAILURES=$((FAILURES + 1)); }
print_warn()    { echo -e "  ${YELLOW}[WARN]${NC} $1"; WARNINGS=$((WARNINGS + 1)); }
print_info()    { echo -e "  ${BLUE}[INFO]${NC} $1"; }

# ---------------------------------------------------------------------------
# Counters
# ---------------------------------------------------------------------------
FAILURES=0
WARNINGS=0

# ---------------------------------------------------------------------------
# Verify WP-CLI is available
# ---------------------------------------------------------------------------
if ! command -v wp &> /dev/null; then
    echo -e "${RED}ERROR: WP-CLI is not installed or not in PATH.${NC}"
    exit 1
fi

# ---------------------------------------------------------------------------
# Detect environment
# ---------------------------------------------------------------------------
print_header "Environment Detection"

SITE_URL=$(wp option get siteurl 2>/dev/null || echo "")
if [[ -z "$SITE_URL" ]]; then
    echo -e "${RED}ERROR: Could not detect site URL. Are you in the WordPress root directory?${NC}"
    echo "Try: cd ~/public"
    exit 1
fi

print_info "Site URL: $SITE_URL"

if echo "$SITE_URL" | grep -qi "staging"; then
    print_info "Environment: STAGING"
else
    echo ""
    echo -e "${YELLOW}  ************************************************************${NC}"
    echo -e "${YELLOW}  *  WARNING: This appears to be PRODUCTION                  *${NC}"
    echo -e "${YELLOW}  *  Make sure you have a manual backup before proceeding.    *${NC}"
    echo -e "${YELLOW}  ************************************************************${NC}"
    echo ""
    read -r -p "  Continue on production? (y/N): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "Aborted."
        exit 0
    fi
fi

# ---------------------------------------------------------------------------
# Pre-update snapshot
# ---------------------------------------------------------------------------
print_header "Pre-Update Snapshot"

WP_VERSION_BEFORE=$(wp core version)
ACTIVE_PLUGIN_COUNT_BEFORE=$(wp plugin list --status=active --format=count)
ERROR_LOG="/www/kinsta/logs/error.log"

print_info "WordPress version: $WP_VERSION_BEFORE"
print_info "Active plugins: $ACTIVE_PLUGIN_COUNT_BEFORE"

# Capture error log baseline
if [[ -f "$ERROR_LOG" ]]; then
    ERROR_COUNT_BEFORE=$(grep -c "PHP Fatal" "$ERROR_LOG" 2>/dev/null || echo "0")
    print_info "PHP Fatal errors in log (before): $ERROR_COUNT_BEFORE"
else
    ERROR_COUNT_BEFORE=0
    print_warn "Error log not found at $ERROR_LOG -- skipping error log checks"
fi

echo ""
print_info "Current plugin versions:"
wp plugin list --status=active --format=table

# ---------------------------------------------------------------------------
# Check available updates
# ---------------------------------------------------------------------------
print_header "Available Updates"

CORE_UPDATE=$(wp core check-update --format=count 2>/dev/null || echo "0")
PLUGIN_UPDATES=$(wp plugin list --update=available --format=count 2>/dev/null || echo "0")

print_info "Core updates available: $CORE_UPDATE"
print_info "Plugin updates available: $PLUGIN_UPDATES"

if [[ "$CORE_UPDATE" == "0" && "$PLUGIN_UPDATES" == "0" ]]; then
    print_info "No updates available. Nothing to do."
    exit 0
fi

echo ""
if [[ "$PLUGIN_UPDATES" != "0" ]]; then
    wp plugin list --update=available --format=table
fi

echo ""
read -r -p "  Proceed with updates? (y/N): " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Aborted."
    exit 0
fi

# ---------------------------------------------------------------------------
# Run updates -- core first, then bulk plugins
# ---------------------------------------------------------------------------
print_header "Updating WordPress Core"

if [[ "$CORE_UPDATE" != "0" ]]; then
    wp core update
    wp core update-db
    print_pass "WordPress core updated"
else
    print_info "Core already up to date"
fi

print_header "Updating Plugins (Bulk)"

if [[ "$PLUGIN_UPDATES" != "0" ]]; then
    wp plugin update --all
    print_pass "All plugins updated"
else
    print_info "No plugin updates to apply"
fi

# ---------------------------------------------------------------------------
# Clear caches
# ---------------------------------------------------------------------------
print_header "Clearing Caches"

wp cache flush 2>/dev/null && print_pass "Object cache flushed" || print_warn "Cache flush returned non-zero (may be OK if no object cache)"

# ---------------------------------------------------------------------------
# Post-update checks
# ---------------------------------------------------------------------------
print_header "Post-Update Checks"

# WordPress version
WP_VERSION_AFTER=$(wp core version)
print_info "WordPress version: $WP_VERSION_BEFORE -> $WP_VERSION_AFTER"

# Active plugin count
ACTIVE_PLUGIN_COUNT_AFTER=$(wp plugin list --status=active --format=count)
print_info "Active plugins: $ACTIVE_PLUGIN_COUNT_BEFORE -> $ACTIVE_PLUGIN_COUNT_AFTER"

if [[ "$ACTIVE_PLUGIN_COUNT_AFTER" -lt "$ACTIVE_PLUGIN_COUNT_BEFORE" ]]; then
    print_fail "Active plugin count DECREASED -- a plugin may have been deactivated"
else
    print_pass "Active plugin count unchanged or increased"
fi

# Critical plugins still active
print_header "Critical Plugin Checks"

CRITICAL_PLUGINS=(
    "the-events-calendar"
    "event-tickets"
    "wp-mail-smtp-pro"
    "ninjafirewall"
)

for plugin in "${CRITICAL_PLUGINS[@]}"; do
    if wp plugin is-active "$plugin" 2>/dev/null; then
        print_pass "$plugin is active"
    else
        # Check if the plugin exists but is inactive vs not installed
        if wp plugin list --name="$plugin" --format=count 2>/dev/null | grep -q "1"; then
            print_fail "$plugin is INSTALLED but NOT ACTIVE"
        else
            print_warn "$plugin not found (slug may differ -- verify manually)"
        fi
    fi
done

# Key page HTTP checks
print_header "Key Page HTTP Checks"

KEY_PAGES=(
    "/"
    "/events/"
)

for page in "${KEY_PAGES[@]}"; do
    url="${SITE_URL}${page}"
    http_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 15 "$url" 2>/dev/null || echo "000")
    if [[ "$http_code" == "200" ]]; then
        print_pass "$page returned HTTP $http_code"
    elif [[ "$http_code" == "000" ]]; then
        print_fail "$page -- connection failed (timeout or DNS error)"
    elif [[ "$http_code" =~ ^3[0-9][0-9]$ ]]; then
        print_warn "$page returned HTTP $http_code (redirect -- may be OK)"
    else
        print_fail "$page returned HTTP $http_code"
    fi
done

# Database check
print_header "Database Check"

if wp db check --quiet 2>/dev/null; then
    print_pass "Database integrity check passed"
else
    print_fail "Database integrity check reported issues"
fi

# Cron check
print_header "Cron Check"

CRON_COUNT=$(wp cron event list --format=count 2>/dev/null || echo "0")
if [[ "$CRON_COUNT" -gt "0" ]]; then
    print_pass "WP-Cron has $CRON_COUNT scheduled events"
else
    print_warn "No cron events found (unusual)"
fi

# Error log check
print_header "Error Log Check"

if [[ -f "$ERROR_LOG" ]]; then
    ERROR_COUNT_AFTER=$(grep -c "PHP Fatal" "$ERROR_LOG" 2>/dev/null || echo "0")
    NEW_ERRORS=$((ERROR_COUNT_AFTER - ERROR_COUNT_BEFORE))
    if [[ "$NEW_ERRORS" -le 0 ]]; then
        print_pass "No new PHP Fatal errors in log"
    else
        print_fail "$NEW_ERRORS new PHP Fatal error(s) detected in log"
        echo ""
        echo -e "  ${YELLOW}Recent fatal errors:${NC}"
        grep "PHP Fatal" "$ERROR_LOG" | tail -5
    fi
else
    print_warn "Error log not found -- skipping"
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
print_header "Summary"

echo -e "  Site:       $SITE_URL"
echo -e "  WP Core:    $WP_VERSION_BEFORE -> $WP_VERSION_AFTER"
echo -e "  Plugins:    $ACTIVE_PLUGIN_COUNT_BEFORE active -> $ACTIVE_PLUGIN_COUNT_AFTER active"
echo ""

if [[ "$FAILURES" -eq 0 && "$WARNINGS" -eq 0 ]]; then
    echo -e "  ${GREEN}${BOLD}ALL CHECKS PASSED${NC}"
elif [[ "$FAILURES" -eq 0 ]]; then
    echo -e "  ${YELLOW}${BOLD}PASSED WITH $WARNINGS WARNING(S)${NC}"
else
    echo -e "  ${RED}${BOLD}$FAILURES CHECK(S) FAILED${NC} (plus $WARNINGS warning(s))"
    echo -e "  ${RED}Review failures above before proceeding.${NC}"
fi

# ---------------------------------------------------------------------------
# Manual testing reminders
# ---------------------------------------------------------------------------
print_header "Manual Testing Reminders"

echo -e "  The following items require browser testing:"
echo ""
echo -e "  ${YELLOW}[ ]${NC} Events calendar page loads and displays events correctly"
echo -e "  ${YELLOW}[ ]${NC} Individual event pages load with correct details"
echo -e "  ${YELLOW}[ ]${NC} Event ticket purchase/registration flow works"
echo -e "  ${YELLOW}[ ]${NC} Calendar navigation (month/list/day views) works"
echo -e "  ${YELLOW}[ ]${NC} No JavaScript console errors on key pages"
echo -e "  ${YELLOW}[ ]${NC} Mobile responsive layout displays correctly"
echo ""
echo -e "  Full checklist: checklists/regression-test-ppemedevents-com.md"
echo ""
