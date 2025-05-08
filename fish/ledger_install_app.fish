function ledger_install_app
    if test (count $argv) -eq 0
        echo "Usage: ledger_install_app <app1> [app2 …]"
        return 1
    end

    # 1) USB detection
    while not lsusb | grep -qi '2c97'
        echo "❗  Plug in your Nano S Plus and press ENTER, or type 'q' to quit."
        read -l user
        if test "$user" = "q"
            echo "Aborted."
            return
        end
    end

    # 2) Unlock detection
    while not ledger-live listApps >/dev/null 2>&1
        echo "🔒  Unlock your device and press ENTER, or type 'q' to quit."
        read -l user
        if test "$user" = "q"
            echo "Aborted."
            return
        end
    end

    # 3) Install/update each specified app
    for app in $argv
        echo "→  Installing/updating $app…"
        ledger-live app --install $app
    end
    echo "✅  Done."
end
