# Ledger CLI Helpers for Fish
# Requires: ledger-live CLI, jq, node (optional, for JSON parsing)

# Convert JS-style ledger-live output to JSON
function ledgerJsonify --description "Convert ledger-live output to JSON"
    set -l cmd $argv[1]
    set -l raw (ledger-live $cmd 2>/dev/null)
    test -z "$raw"; and return 1

    if command -q node
        echo "$raw" | node -e '
            let d="";
            process.stdin.on("data",c=>d+=c);
            process.stdin.on("end",()=>{
                try{console.log(JSON.stringify(eval("("+d+")")));}
                catch(e){process.exit(1);}
            });' 2>/dev/null; and return 0
    end

    # Fallback: sed-based conversion
    echo "$raw" | sed -E '
        s/([A-Za-z0-9_]+):/"\1":/g
        s/'"'"'/"/g
        s/<Buffer [^>]*>/null/g
        s/: undefined/: null/g'
end

# Check if device is connected
function ledgerConnected --description "Check if Ledger is connected"
    ledger-live deviceInfo >/dev/null 2>&1
end

# Wait for device connection
function ledgerWaitForConnection --description "Wait for Ledger connection"
    if ledgerConnected
        return 0
    end
    echo "[!] Connect and unlock your Ledger, then press Enter (q to quit)"
    read -l resp
    test "$resp" = "q"; and return 1
    ledgerConnected; or begin
        echo "[ERR] Could not connect"
        return 1
    end
end

# List installed app names
function ledgerListApps --description "List installed apps"
    ledgerJsonify "listApps" | jq -r '.[].name'
end

# Install or update apps
function ledgerInstallApp --description "Install or update apps"
    if test (count $argv) -eq 0
        echo "Usage: ledgerInstallApp <app1> [app2 ...]"
        return 1
    end
    ledgerWaitForConnection; or return

    set -l failed
    set -l succeeded 0
    for app in $argv
        echo "[*] Installing $app..."
        if ledger-live app --install "$app"
            set succeeded (math $succeeded + 1)
        else
            set -a failed "$app"
            echo "[ERR] Failed: $app"
        end
    end

    if test (count $failed) -gt 0
        echo "[!] $succeeded succeeded, "(count $failed)" failed: $failed"
        return 1
    end
    echo "[OK] $succeeded app(s) installed."
end

# Update all installed apps
function ledgerUpdateApps --description "Update all installed apps"
    ledgerWaitForConnection; or return

    set -l apps (ledgerListApps)
    if test (count $apps) -eq 0
        echo "[i] No apps installed."
        return
    end

    echo "[*] Updating "(count $apps)" app(s)..."
    set -l failed
    set -l succeeded 0
    for app in $apps
        echo "  - $app"
        if ledger-live app --install "$app"
            set succeeded (math $succeeded + 1)
        else
            set -a failed "$app"
        end
    end

    if test (count $failed) -gt 0
        echo "[!] $succeeded succeeded, "(count $failed)" failed"
        return 1
    end
    echo "[OK] All $succeeded app(s) updated."
end

# Compare semver: returns 0 if v1<v2, 1 if v1=v2, 2 if v1>v2
function ledgerCompareVersions --description "Compare semver strings"
    set -l v1 (string split '.' -- $argv[1])
    set -l v2 (string split '.' -- $argv[2])

    for i in 1 2 3
        set -l a (test -n "$v1[$i]"; and echo $v1[$i]; or echo 0)
        set -l b (test -n "$v2[$i]"; and echo $v2[$i]; or echo 0)
        set a (string replace -r '[^0-9].*' '' -- $a)
        set b (string replace -r '[^0-9].*' '' -- $b)
        test -z "$a"; and set a 0
        test -z "$b"; and set b 0

        if test "$a" -lt "$b"
            return 0
        else if test "$a" -gt "$b"
            return 2
        end
    end
    return 1
end

# Get current firmware version
function ledgerCurrentFw --description "Get current firmware version"
    ledgerJsonify "deviceInfo" | jq -r '.seVersion // .version // .majMin // empty'
end

# Get latest firmware version
function ledgerLatestFw --description "Get latest firmware version"
    ledger-live deviceVersion --format json 2>/dev/null | jq -r '
        .se_firmware_final_version.version
        // .se_firmware_version
        // .latest.seVersion
        // empty'
end

# Update firmware
function ledgerUpdateFirmware --description "Update firmware"
    ledgerWaitForConnection; or return

    set -l cur (ledgerCurrentFw)
    set -l latest (ledgerLatestFw)

    if test -n "$cur"; and test -n "$latest"
        ledgerCompareVersions "$cur" "$latest"
        set -l cmp $status

        if test $cmp -eq 1
            echo "[OK] Firmware up-to-date (v$cur)."
            return
        else if test $cmp -eq 2
            echo "[i] Current ($cur) newer than reported ($latest)."
            return
        else
            echo "[*] Update available: $cur -> $latest"
        end
    else
        echo "[!] Could not determine versions. Proceeding..."
    end

    echo "[*] Starting firmware update..."
    if ledger-live firmwareUpdate --to-my-own-risk
        echo "[OK] Firmware update completed."
    else
        echo "[ERR] Firmware update failed."
        return 1
    end
end
