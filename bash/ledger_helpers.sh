#!/usr/bin/env bash
# Ledger CLI Helpers for Bash
# Requires: ledger-live CLI, jq, node (optional, for JSON parsing)

# Convert JS-style ledger-live output to JSON
ledgerJsonify() {
  local cmd="$1"
  local raw
  raw=$(ledger-live "$cmd" 2>/dev/null) || return 1
  [[ -z "$raw" ]] && return 1

  if command -v node &>/dev/null; then
    echo "$raw" | node -e '
      let d="";
      process.stdin.on("data",c=>d+=c);
      process.stdin.on("end",()=>{
        try{console.log(JSON.stringify(eval("("+d+")")));}
        catch(e){process.exit(1);}
      });' 2>/dev/null && return 0
  fi

  # Fallback: sed-based conversion
  echo "$raw" | sed -E "s/([A-Za-z0-9_]+):/\"\1\":/g; s/'/\"/g; s/<Buffer [^>]*>/null/g; s/: undefined/: null/g"
}

# Check if device is connected and responsive
ledgerConnected() {
  ledger-live deviceInfo &>/dev/null
}

# Wait for device connection
ledgerWaitForConnection() {
  if ledgerConnected; then return 0; fi
  echo "[!] Connect and unlock your Ledger, then press Enter (q to quit)"
  read -r resp
  [[ "$resp" == "q" ]] && return 1
  ledgerConnected || { echo "[ERR] Could not connect"; return 1; }
}

# List installed app names
ledgerListApps() {
  ledgerJsonify "listApps" | jq -r '.[].name'
}

# Install or update apps
ledgerInstallApp() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: ledgerInstallApp <app1> [app2 ...]"
    return 1
  fi
  ledgerWaitForConnection || return

  local failed=() succeeded=0
  for app in "$@"; do
    echo "[*] Installing $app..."
    if ledger-live app --install "$app"; then
      ((succeeded++))
    else
      failed+=("$app")
      echo "[ERR] Failed: $app"
    fi
  done

  if [[ ${#failed[@]} -gt 0 ]]; then
    echo "[!] $succeeded succeeded, ${#failed[@]} failed: ${failed[*]}"
    return 1
  fi
  echo "[OK] $succeeded app(s) installed."
}

# Update all installed apps
ledgerUpdateApps() {
  ledgerWaitForConnection || return

  local apps
  mapfile -t apps < <(ledgerListApps)
  if [[ ${#apps[@]} -eq 0 ]]; then
    echo "[i] No apps installed."
    return
  fi

  echo "[*] Updating ${#apps[@]} app(s)..."
  local failed=() succeeded=0
  for app in "${apps[@]}"; do
    echo "  - $app"
    if ledger-live app --install "$app"; then
      ((succeeded++))
    else
      failed+=("$app")
    fi
  done

  if [[ ${#failed[@]} -gt 0 ]]; then
    echo "[!] $succeeded succeeded, ${#failed[@]} failed"
    return 1
  fi
  echo "[OK] All $succeeded app(s) updated."
}

# Compare semver strings: returns 0 if v1<v2, 1 if v1=v2, 2 if v1>v2
ledgerCompareVersions() {
  local IFS=.
  local v1=($1) v2=($2)
  for i in 0 1 2; do
    local a=${v1[i]:-0} b=${v2[i]:-0}
    a=${a%%[^0-9]*} b=${b%%[^0-9]*}
    [[ -z "$a" ]] && a=0
    [[ -z "$b" ]] && b=0
    ((a < b)) && return 0
    ((a > b)) && return 2
  done
  return 1
}

# Get current firmware version
ledgerCurrentFw() {
  ledgerJsonify "deviceInfo" | jq -r '.seVersion // .version // .majMin // empty'
}

# Get latest available firmware version
ledgerLatestFw() {
  ledger-live deviceVersion --format json 2>/dev/null | jq -r '
    .se_firmware_final_version.version
    // .se_firmware_version
    // .latest.seVersion
    // empty'
}

# Update firmware
ledgerUpdateFirmware() {
  ledgerWaitForConnection || return

  local cur latest
  cur=$(ledgerCurrentFw)
  latest=$(ledgerLatestFw)

  if [[ -n "$cur" && -n "$latest" ]]; then
    ledgerCompareVersions "$cur" "$latest"
    local cmp=$?
    if [[ $cmp -eq 1 ]]; then
      echo "[OK] Firmware up-to-date (v$cur)."
      return
    elif [[ $cmp -eq 2 ]]; then
      echo "[i] Current ($cur) newer than reported ($latest)."
      return
    else
      echo "[*] Update available: $cur -> $latest"
    fi
  else
    echo "[!] Could not determine versions. Proceeding..."
  fi

  echo "[*] Starting firmware update..."
  if ledger-live firmwareUpdate --to-my-own-risk; then
    echo "[OK] Firmware update completed."
  else
    echo "[ERR] Firmware update failed."
    return 1
  fi
}
