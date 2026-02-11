#!/usr/bin/env bash
# =============================================================================
# update-ppetoolkit.sh -- WP-CLI update & regression checks for ppetoolkit.com
#
# Risk level: CRITICAL
# Strategy:   Core first, LearnDash ALONE (pause for QBank test), then remaining
# Usage:      SSH into Kinsta environment, then: bash update-ppetoolkit.sh
#
# IMPORTANT: This script PAUSES after updating LearnDash and waits for you to
# manually verify QBank functionality in a browser before continuing.
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
    echo -e "${RED}  ************************************************************${NC}"
    echo -e "${RED}  *  WARNING: This appears to be PRODUCTION                  *${NC}"
    echo -e "${RED}  *  ppetoolkit.com is CRITICAL RISK -- double-check that    *${NC}"
    echo -e "${RED}  *  you have tested on staging first and have a backup.     *${NC}"
    echo -e "${RED}  ************************************************************${NC}"
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

if [[ -f "$ERROR_LOG" ]]; then
    ERROR_COUNT_BEFORE=$(grep -c "PHP Fatal" "$ERROR_LOG" 2>/dev/null || echo "0")
    print_info "PHP Fatal errors in log (before): $ERROR_COUNT_BEFORE"
else
    ERROR_COUNT_BEFORE=0
    print_warn "Error log not found at $ERROR_LOG -- skipping error log checks"
fi

# Check LearnDash current version
LD_VERSION_BEFORE=$(wp plugin list --name=sfwd-lms --field=version 2>/dev/null || echo "unknown")
print_info "LearnDash version: $LD_VERSION_BEFORE"

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

# Check if LearnDash has a major version update
LD_HAS_UPDATE=$(wp plugin list --name=sfwd-lms --update=available --format=count 2>/dev/null || echo "0")
if [[ "$LD_HAS_UPDATE" != "0" ]]; then
    LD_NEW_VERSION=$(wp plugin list --name=sfwd-lms --update=available --field=update_version 2>/dev/null || echo "unknown")
    LD_MAJOR_BEFORE=$(echo "$LD_VERSION_BEFORE" | cut -d. -f1)
    LD_MAJOR_AFTER=$(echo "$LD_NEW_VERSION" | cut -d. -f1)

    echo ""
    if [[ "$LD_MAJOR_BEFORE" != "$LD_MAJOR_AFTER" ]]; then
        echo -e "  ${RED}${BOLD}*** LEARNDASH MAJOR VERSION UPDATE DETECTED ***${NC}"
        echo -e "  ${RED}${BOLD}    $LD_VERSION_BEFORE -> $LD_NEW_VERSION${NC}"
        echo ""
        echo -e "  ${YELLOW}This is a major version change. Per the SOP:${NC}"
        echo -e "  ${YELLOW}  - Notify the Technical Lead before proceeding${NC}"
        echo -e "  ${YELLOW}  - LearnDash 5.0 changed API field names (inProgress -> in_progress)${NC}"
        echo -e "  ${YELLOW}  - Custom QBank code may need updates${NC}"
        echo ""
        read -r -p "  Has the Technical Lead approved this major update? (y/N): " confirm
        if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
            echo ""
            echo "Aborted. Get Technical Lead approval before proceeding with major LearnDash updates."
            exit 0
        fi
    else
        print_info "LearnDash update is a minor/patch version ($LD_VERSION_BEFORE -> $LD_NEW_VERSION)"
    fi
fi

echo ""
read -r -p "  Proceed with updates? (y/N): " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Aborted."
    exit 0
fi

# ---------------------------------------------------------------------------
# Update WordPress core
# ---------------------------------------------------------------------------
print_header "Updating WordPress Core"

if [[ "$CORE_UPDATE" != "0" ]]; then
    wp core update
    wp core update-db
    print_pass "WordPress core updated"
else
    print_info "Core already up to date"
fi

# ---------------------------------------------------------------------------
# Update LearnDash ALONE
# ---------------------------------------------------------------------------
print_header "Updating LearnDash (ALONE)"

if [[ "$LD_HAS_UPDATE" != "0" ]]; then
    print_info "Updating sfwd-lms (LearnDash)..."
    if wp plugin update sfwd-lms 2>/dev/null; then
        LD_VERSION_AFTER=$(wp plugin list --name=sfwd-lms --field=version 2>/dev/null || echo "unknown")
        print_pass "LearnDash updated: $LD_VERSION_BEFORE -> $LD_VERSION_AFTER"
    else
        print_fail "LearnDash update failed"
        echo -e "  ${RED}Stopping. Do not proceed with other updates until this is resolved.${NC}"
        exit 1
    fi

    # Flush cache after LearnDash update
    wp cache flush 2>/dev/null || true

    # Check QBank plugins are still active
    echo ""
    print_info "Checking QBank plugins are still active after LearnDash update..."

    QBANK_SLUG="learndash-quiz-customization-question-bank"
    QUIZ_BTN_SLUG="wisdmlabs-quiz-button-customization"

    if wp plugin is-active "$QBANK_SLUG" 2>/dev/null; then
        print_pass "QBank plugin ($QBANK_SLUG) is active"
    else
        # Try alternative slug patterns
        QBANK_FOUND=false
        for alt_slug in "ld-quiz-customization-question-bank" "quiz-customization-question-bank"; do
            if wp plugin is-active "$alt_slug" 2>/dev/null; then
                print_pass "QBank plugin ($alt_slug) is active"
                QBANK_SLUG="$alt_slug"
                QBANK_FOUND=true
                break
            fi
        done
        if [[ "$QBANK_FOUND" == "false" ]]; then
            print_warn "QBank plugin not found with expected slug -- verify manually"
            print_info "Looking for WisdmLabs plugins..."
            wp plugin list --status=active --format=table 2>/dev/null | grep -i "wisdm\|qbank\|question.bank" || print_warn "No matching plugins found in active list"
        fi
    fi

    if wp plugin is-active "$QUIZ_BTN_SLUG" 2>/dev/null; then
        print_pass "Quiz button plugin ($QUIZ_BTN_SLUG) is active"
    else
        for alt_slug in "quiz-button-customization" "ld-quiz-button-customization"; do
            if wp plugin is-active "$alt_slug" 2>/dev/null; then
                print_pass "Quiz button plugin ($alt_slug) is active"
                QUIZ_BTN_SLUG="$alt_slug"
                break
            fi
        done
    fi

    # Check for new PHP errors after LearnDash update
    if [[ -f "$ERROR_LOG" ]]; then
        ERROR_COUNT_POST_LD=$(grep -c "PHP Fatal" "$ERROR_LOG" 2>/dev/null || echo "0")
        NEW_LD_ERRORS=$((ERROR_COUNT_POST_LD - ERROR_COUNT_BEFORE))
        if [[ "$NEW_LD_ERRORS" -gt 0 ]]; then
            print_fail "$NEW_LD_ERRORS new PHP Fatal error(s) after LearnDash update"
            echo ""
            echo -e "  ${RED}Recent fatal errors:${NC}"
            grep "PHP Fatal" "$ERROR_LOG" | tail -5
            echo ""
            echo -e "  ${RED}STOP: Review these errors before continuing.${NC}"
        else
            print_pass "No new PHP Fatal errors after LearnDash update"
        fi
    fi

    # =======================================================================
    # PAUSE -- Manual QBank testing required
    # =======================================================================
    echo ""
    echo -e "${BOLD}${YELLOW}  ================================================================${NC}"
    echo -e "${BOLD}${YELLOW}  |                                                              |${NC}"
    echo -e "${BOLD}${YELLOW}  |   PAUSE -- MANUAL QBANK TESTING REQUIRED                     |${NC}"
    echo -e "${BOLD}${YELLOW}  |                                                              |${NC}"
    echo -e "${BOLD}${YELLOW}  |   LearnDash has been updated. Before continuing, open the     |${NC}"
    echo -e "${BOLD}${YELLOW}  |   site in a browser and test QBank functionality:             |${NC}"
    echo -e "${BOLD}${YELLOW}  |                                                              |${NC}"
    echo -e "${BOLD}${YELLOW}  |   1. Navigate to a quiz page as a student                    |${NC}"
    echo -e "${BOLD}${YELLOW}  |   2. Verify questions load from the question bank             |${NC}"
    echo -e "${BOLD}${YELLOW}  |   3. Submit a quiz and verify scoring works                   |${NC}"
    echo -e "${BOLD}${YELLOW}  |   4. Check the QBank admin interface                         |${NC}"
    echo -e "${BOLD}${YELLOW}  |   5. Verify custom quiz buttons display correctly             |${NC}"
    echo -e "${BOLD}${YELLOW}  |                                                              |${NC}"
    echo -e "${BOLD}${YELLOW}  |   Site: $SITE_URL${NC}"
    echo -e "${BOLD}${YELLOW}  |                                                              |${NC}"
    echo -e "${BOLD}${YELLOW}  |   If QBank is BROKEN: type 'n' and escalate to Tech Lead     |${NC}"
    echo -e "${BOLD}${YELLOW}  |                                                              |${NC}"
    echo -e "${BOLD}${YELLOW}  ================================================================${NC}"
    echo ""
    read -r -p "  Did QBank testing pass? Continue with remaining updates? (y/N): " qbank_confirm
    if [[ "$qbank_confirm" != "y" && "$qbank_confirm" != "Y" ]]; then
        echo ""
        echo -e "${RED}  Stopped. QBank issue detected or testing not completed.${NC}"
        echo -e "${RED}  Do NOT update remaining plugins. Escalate to Technical Lead.${NC}"
        echo ""
        exit 1
    fi
else
    print_info "LearnDash already up to date -- no QBank testing pause needed"
fi

# ---------------------------------------------------------------------------
# Update remaining plugins (one at a time)
# ---------------------------------------------------------------------------
print_header "Updating Remaining Plugins"

# Plugins to update individually (excluding sfwd-lms which was already done)
REMAINING_PLUGINS=(
    "elementor"
    "elementor-pro"
    "gravityforms"
    "code-snippets"
    "frontend-reset-password"
    "ninjafirewall"
    "ninjascanner"
    "sucuri-scanner"
    "imagify"
    "index-wp-mysql-for-speed"
    "ottokit"
    "wp-mail-smtp"
    "stream"
    "wpfront-user-role-editor"
    "git-updater"
    "gp-premium"
    "loginpress"
    "loginpress-pro"
    "lightstart"
    "speculative-loading"
    "embed-optimizer"
    "enhanced-responsive-images"
    "modern-image-formats"
    "png-to-jpg"
    "gravity-forms-custom-post-types"
    "gravityformsactivecampaign"
    "gravityformssurvey"
    "gravityformsuserregistration"
    "gravity-forms-all-fields-template"
    "gravity-pdf"
    "learndash-certificate-builder"
    "learndash-elementor"
    "learndash-gravity-forms"
    "snaporbital-notes"
    "uncanny-toolkit-for-learndash"
    "uncanny-toolkit-pro-for-learndash"
)

REMAINING_UPDATED=0
for plugin in "${REMAINING_PLUGINS[@]}"; do
    if wp plugin list --name="$plugin" --update=available --format=count 2>/dev/null | grep -q "1"; then
        print_info "Updating $plugin..."
        if wp plugin update "$plugin" 2>/dev/null; then
            print_pass "$plugin updated"
            REMAINING_UPDATED=$((REMAINING_UPDATED + 1))
        else
            print_fail "$plugin update failed"
        fi
    fi
done

if [[ "$REMAINING_UPDATED" -eq 0 ]]; then
    print_info "No remaining plugin updates to apply"
else
    print_info "$REMAINING_UPDATED plugin(s) updated"
fi

# ---------------------------------------------------------------------------
# Catch any remaining plugin updates
# ---------------------------------------------------------------------------
print_header "Checking for Remaining Updates"

STILL_REMAINING=$(wp plugin list --update=available --format=count 2>/dev/null || echo "0")
if [[ "$STILL_REMAINING" != "0" ]]; then
    print_info "$STILL_REMAINING plugin(s) still have updates available:"
    wp plugin list --update=available --format=table
    echo ""
    read -r -p "  Update remaining plugins? (y/N): " confirm
    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        wp plugin update --all
        print_pass "Remaining plugins updated"
    else
        print_warn "Skipped $STILL_REMAINING remaining update(s)"
    fi
else
    print_info "All plugins are up to date"
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

WP_VERSION_AFTER=$(wp core version)
ACTIVE_PLUGIN_COUNT_AFTER=$(wp plugin list --status=active --format=count)

print_info "WordPress version: $WP_VERSION_BEFORE -> $WP_VERSION_AFTER"
print_info "Active plugins: $ACTIVE_PLUGIN_COUNT_BEFORE -> $ACTIVE_PLUGIN_COUNT_AFTER"

if [[ "$ACTIVE_PLUGIN_COUNT_AFTER" -lt "$ACTIVE_PLUGIN_COUNT_BEFORE" ]]; then
    print_fail "Active plugin count DECREASED -- a plugin may have been deactivated"
else
    print_pass "Active plugin count unchanged or increased"
fi

# Critical plugins still active
print_header "Critical Plugin Checks"

CRITICAL_PLUGINS=(
    "sfwd-lms"
    "$QBANK_SLUG"
    "$QUIZ_BTN_SLUG"
    "gravityforms"
    "elementor"
    "elementor-pro"
    "ninjafirewall"
)

for plugin in "${CRITICAL_PLUGINS[@]}"; do
    if wp plugin is-active "$plugin" 2>/dev/null; then
        print_pass "$plugin is active"
    else
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
    "/courses/"
    "/wp-login.php"
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

    # Also check for LearnDash-specific errors
    LD_ERRORS=$(grep -c "sfwd-lms\|learndash\|qbank\|question.bank" "$ERROR_LOG" 2>/dev/null || echo "0")
    if [[ "$LD_ERRORS" -gt 0 ]]; then
        print_warn "$LD_ERRORS log entries mention LearnDash/QBank -- review for relevance"
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
echo -e "  LearnDash:  $LD_VERSION_BEFORE -> $(wp plugin list --name=sfwd-lms --field=version 2>/dev/null || echo 'unknown')"
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
echo -e "  ${YELLOW}[ ]${NC} Course listing page displays all courses correctly"
echo -e "  ${YELLOW}[ ]${NC} Individual course and lesson pages load"
echo -e "  ${YELLOW}[ ]${NC} QBank: quiz questions load from question bank"
echo -e "  ${YELLOW}[ ]${NC} QBank: quiz submission and scoring works"
echo -e "  ${YELLOW}[ ]${NC} QBank: admin interface is accessible"
echo -e "  ${YELLOW}[ ]${NC} Custom quiz buttons (start/finish) display correctly"
echo -e "  ${YELLOW}[ ]${NC} Course progress tracking updates correctly"
echo -e "  ${YELLOW}[ ]${NC} Student dashboard shows correct enrollment data"
echo -e "  ${YELLOW}[ ]${NC} Certificate generation works"
echo -e "  ${YELLOW}[ ]${NC} Gravity Forms submissions work"
echo -e "  ${YELLOW}[ ]${NC} No JavaScript console errors on key pages"
echo -e "  ${YELLOW}[ ]${NC} Mobile responsive layout displays correctly"
echo ""
echo -e "  Full checklist: checklists/regression-test-ppetoolkit-com.md"
echo ""
