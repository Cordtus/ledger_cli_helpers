#!/usr/bin/env bash
# Update all installed Ledger apps

VENDOR_ID="${LEDGER_VENDOR_ID:-2c97}"

# Wait for USB
while ! lsusb | grep -qi "$VENDOR_ID"; do
  read -rp "❗ No Ledger seen. Plug in device and press ENTER, or 'q' to quit: " choice
  [[ $choice == q ]] && { echo 'Aborted.'; exit 1; }
done

# Wait for device to unlock/respond
until ledger-live listApps --format json &>/dev/null; do
  read -rp "🔒 Ledger locked/unresponsive. Unlock & press ENTER, or 'q' to quit: " choice
  [[ $choice == q ]] && { echo 'Aborted.'; exit 1; }
done

# Gather installed apps
apps=$(ledger-live listApps --format json \
  | sed -E "s/'/\"/g; s/([[:alnum:]_]+):/\"\1\":/g" \
  | jq -r '.[] .name')

if [[ -z $apps ]]; then
  echo "ℹ️ No apps installed."
  exit 0
fi

echo "🔄 Updating installed apps..."
for app in $apps; do
  echo "→ $app"
  ledger-live app --install "$app"
done
echo "✅ All apps updated."
