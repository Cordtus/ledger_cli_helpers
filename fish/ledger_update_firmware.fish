function ledger_update_firmware
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

    # 3) Firmware update
    echo "🔄  Starting firmware update…"
    ledger-live firmwareUpdate --to-my-own-risk
    if test $status -eq 0
        echo "✅  Firmware update completed."
    else
        echo "❗  Firmware update failed (exit code $status)."
    end
end
