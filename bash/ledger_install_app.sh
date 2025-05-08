#!/usr/bin/env bash
# Install or update specified Ledger apps

VENDOR_ID="${LEDGER_VENDOR_ID:-2c97}"

if [[ $# -eq 0 ]]; then
  echo "Usage: $(basename "$0") <app1> [app2 ...]"
  exit 1
fi

# Wait for USB
while ! lsusb | grep -qi "$VENDOR_ID"; do
  read -rp "❗ Plug in device and press ENTER, or 'q' to quit: " choice
  [[ $choice == q ]] && { echo 'Aborted.'; exit 1; }
done

# Wait for device to unlock/respond
until ledger-live listApps --format json &>/dev/null; do
  read -rp "🔒 Unlock & press ENTER, or 'q' to quit: " choice
  [[ $choice == q ]] && { echo 'Aborted.'; exit 1; }
done

# Install/update each requested app
for app in "$@"; do
  echo "→ Installing/updating $app..."
  ledger-live app --install "$app"
done
echo "✅ Done."
