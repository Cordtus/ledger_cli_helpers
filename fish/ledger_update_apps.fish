function ledger_update_apps
    # 1) USB detection
    while not lsusb | grep -qi '2c97'
        echo "❗  No Ledger seen. Plug in Nano S Plus and press ENTER, or type 'q' to quit."
        read -l user
        if test "$user" = "q"
            echo "Aborted."
            return
        end
    end

    # 2) Unlock detection
    while not ledger-live listApps >/dev/null 2>&1
        echo "🔒  Ledger locked or not responding. Unlock & press ENTER, or type 'q' to quit."
        read -l user
        if test "$user" = "q"
            echo "Aborted."
            return
        end
    end

    # 3) Fetch installed apps via helper
    set apps (ledger_list_apps)
    if test (count $apps) -eq 0
        echo "ℹ️   No apps installed."
        return
    end

    # 4) Update each app
    echo "🔄  Updating installed apps…"
    for app in $apps
        echo "→  $app"
        ledger-live app --install $app
    end
    echo "✅  All apps updated."
end
