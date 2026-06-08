#!/bin/bash
# Install the morning + evening LaunchAgents on macOS.
# - Detects this clone's location automatically
# - Patches the plist templates with the right paths
# - Loads them via launchctl bootstrap
# - No sudo, no Full Disk Access required
set -euo pipefail

# Resolve the absolute path to the knowledge-base root (the directory containing scripts/)
KB_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEMPLATE_DIR="$KB_ROOT/scripts/launchagents"
DEST_DIR="$HOME/Library/LaunchAgents"

if [[ "$(uname)" != "Darwin" ]]; then
    echo "Error: This script is for macOS only. On Linux, use cron or systemd timers instead." >&2
    exit 1
fi

mkdir -p "$DEST_DIR"

AGENTS=(
    "com.businessbrain.kb-morning"
    "com.businessbrain.kb-evening"
    "com.businessbrain.kb-autocommit"
)

echo "Installing LaunchAgents from $KB_ROOT"
echo ""

for AGENT in "${AGENTS[@]}"; do
    TEMPLATE="$TEMPLATE_DIR/$AGENT.plist.template"
    DEST="$DEST_DIR/$AGENT.plist"

    if [[ ! -f "$TEMPLATE" ]]; then
        echo "  ERROR: template not found: $TEMPLATE" >&2
        exit 1
    fi

    # Bootout if already loaded (idempotent re-install)
    if launchctl print "gui/$UID/$AGENT" >/dev/null 2>&1; then
        echo "  $AGENT: already loaded, booting out for re-install..."
        launchctl bootout "gui/$UID" "$DEST" 2>/dev/null || true
    fi

    # Substitute placeholders → write final plist
    sed \
        -e "s|__KB_ROOT__|$KB_ROOT|g" \
        -e "s|__HOME__|$HOME|g" \
        "$TEMPLATE" > "$DEST"

    # Validate
    if ! plutil -lint "$DEST" >/dev/null; then
        echo "  ERROR: invalid plist after substitution: $DEST" >&2
        exit 1
    fi

    # Bootstrap
    launchctl bootstrap "gui/$UID" "$DEST"
    echo "  $AGENT: installed and loaded"
done

echo ""
echo "Verifying scheduled agents..."
launchctl list | grep businessbrain || {
    echo "  ERROR: agents not found in launchctl list" >&2
    exit 1
}

echo ""
echo "Done. Morning routine runs Sun-Thu at 8am; evening routine at 9pm; autocommit every 5 min."
echo ""
echo "To trigger manually for testing:"
echo "  launchctl kickstart -k gui/\$UID/com.businessbrain.kb-morning"
echo "  launchctl kickstart -k gui/\$UID/com.businessbrain.kb-evening"
echo "  launchctl kickstart -k gui/\$UID/com.businessbrain.kb-autocommit"
echo ""
echo "Logs:"
echo "  /tmp/kb-morning-routine.log"
echo "  /tmp/kb-evening-routine.log"
echo "  /tmp/kb-autocommit.log"
