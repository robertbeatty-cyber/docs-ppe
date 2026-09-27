#!/usr/bin/env bash
# Password wall and REST allowlist checks for ppemedevents.com
#
# Why this exists: four incidents between June and August 2026 (OST #620213, #878267,
# #594224, #970742) all had the same shape. Promoter could not reach the WordPress REST
# API, attendees stopped syncing, and event emails stopped reaching people. Three of the
# four did not follow an update, so a monthly checklist catches them by luck.
#
# How the site is meant to behave (ansible-v2/docs/clients/ppemedevents.md):
#   - The whole site is DELIBERATELY behind a site-wide password (Password Protected
#     plugin). From any address other than Promoter's, the REST API returns 401
#     "Only authenticated users can access the REST API". That is the wall working.
#   - Promoter (209.87.149.23) is let through by IP. It cannot be tested from here,
#     because this script does not run from that address. Check the access log instead
#     (see Section 2b of the checklist).
#   - OttoKit's namespace wp-json/sure-triggers/v1 is allowlisted for everyone and
#     must answer 200.
#
# So this script checks that the wall is up, the OttoKit exception is in place, and TLS
# negotiates. It does NOT prove that Promoter is syncing.
#
# Read-only. No credentials. No dependencies beyond curl. Production only: staging has
# its own protection and gives different answers.
#
# Usage:
#   bash tests/http/ppemedevents-rest-checks.sh
#
# Exit 0 = all checks passed. Exit 1 = at least one failed.

set -uo pipefail
BASE="https://ppemedevents.com"
UA="GorillaDevOps-RegressionCheck/1.0"
FAILED=0
TMP=$(mktemp)
trap 'rm -f "$TMP"' EXIT

pass() { printf '  PASS  %s\n' "$1"; }
fail() { printf '  FAIL  %s\n' "$1"; FAILED=1; }
skip() { printf '  SKIP  %s\n' "$1"; }

get() { # $1 = path. Sets $code and $body.
  code=$(curl -sS -o "$TMP" -w '%{http_code}' -A "$UA" --max-time 20 "$BASE$1" 2>/dev/null)
  [ -n "$code" ] || code=000
  body=$(cat "$TMP" 2>/dev/null)
}

printf '\nppemedevents.com password wall and REST allowlist checks\n\n'

# 1. The wall is up on the REST routes Promoter uses. 401 + rest_cannot_access = correct.
#    200 here means the wall is down and event data is public.
for path in /wp-json/ /wp-json/tribe/events/v1/events /wp-json/tribe/tickets/v1/tickets; do
  get "$path"
  if [ "$code" = "401" ] && [[ "$body" == *rest_cannot_access* ]]; then
    pass "$path is walled (401, as designed)"
  elif [ "$code" = "200" ]; then
    fail "$path returns 200: the password wall is DOWN and event data is public"
  else
    fail "$path returns $code (expected 401 rest_cannot_access)"
  fi
done

# 2. OttoKit exception (#594224, #970742): this namespace must stay reachable.
get /wp-json/sure-triggers/v1
if [ "$code" = "200" ] && [[ "$body" == *'"namespace"'* ]]; then
  pass "sure-triggers/v1 is reachable (OttoKit allowlist in place)"
else
  fail "sure-triggers/v1 returns $code (expected 200). OttoKit cannot connect; check mu-plugin gd-pp-allowlist-ppemedevents.php"
fi

# 3. TLS: cURL error 35 was the 2026-07-21 failure (#878267).
#    --tls-max pins the version; --tlsv1.2 alone would also accept 1.3.
if curl -sS -o /dev/null --tlsv1.2 --tls-max 1.2 --max-time 20 -A "$UA" "$BASE/wp-json/" 2>/dev/null; then
  pass "TLS 1.2 handshake succeeds"
else
  fail "TLS 1.2 handshake failed (exit $?, 35 = cURL 35 family, see #878267)"
fi

curl -sS -o /dev/null --tlsv1.3 --max-time 20 -A "$UA" "$BASE/wp-json/" 2>/dev/null
rc=$?
case "$rc" in
  0) pass "TLS 1.3 handshake succeeds" ;;
  4) skip "TLS 1.3 not supported by this curl build (macOS system curl). Use Homebrew curl to test it" ;;
  *) fail "TLS 1.3 handshake failed (exit $rc, 35 = cURL 35 family, see #878267)" ;;
esac

printf '\n'
if [ "$FAILED" = "0" ]; then
  printf 'RESULT: all checks passed. This does not prove Promoter is syncing: check the access log (checklist Section 2b).\n\n'
  exit 0
else
  printf 'RESULT: FAILURES. See the ppemedevents runbook in ansible-v2 before changing anything.\n'
  printf 'Escalate per the staged website updates SOP.\n\n'
  exit 1
fi
