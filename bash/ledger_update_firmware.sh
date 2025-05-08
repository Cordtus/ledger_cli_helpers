#!/usr/bin/env bash
# Safely update Ledger firmware

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

# Firmware update
echo "🔄 Starting firmware update..."
if ledger-live firmwareUpdate --to-my-own-risk; then
  echo "✅ Firmware update completed."
else
  echo "❗ Firmware update failed (exit code $?)."
fi
