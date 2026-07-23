#!/bin/sh
#
# Canary/honeypot detector. canary/fake-vision-service-account.json is a fully fake Google
# Vision service-account file, never a real credential (see canary/README.md). The generic
# egress-proxy allowlist (.devcontainer/egress-proxy/squid.conf) deliberately does NOT include
# oauth2.googleapis.com or any OVH host - so any attempt to actually USE the canary (not just
# read it) shows up here as a blocked, logged CONNECT attempt.
#
# This only detects network exfiltration/usage attempts. It does NOT detect an AI tool that
# just reads the file and prints/pastes its contents without making any network call - that
# needs a human reviewing the actual conversation transcript, not infrastructure.
#
# Usage: ./scripts/check-canary-hits.sh

set -eu

PATTERN='googleapis\.com|oauth2|ovh|kepler\.ai\.cloud|perplexity'

echo "== Recent egress-proxy log (all requests, allowed and denied) =="
docker compose logs egress-proxy --no-color --tail=500

echo
echo "== Suspicious entries (canary-related hosts, allowed or denied) =="
HITS=$(docker compose logs egress-proxy --no-color --tail=500 | grep -Ei "$PATTERN" || true)

if [ -z "$HITS" ]; then
    echo "No hits. Nothing tried to reach a canary-related host."
else
    echo "$HITS"
    echo
    echo "!! Something attempted to reach a canary-related host. Review the timestamp above"
    echo "!! and correlate it with what was running in the app container at that time."
fi
