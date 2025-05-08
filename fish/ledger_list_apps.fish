function ledger_list_apps
    # Return a list of installed app names (requires unlocked device)
    ledger-live listApps \
        | sed -E "s/'/\"/g; s/([[:alnum:]_]+):/\"\1\":/g" \
        | jq -r '.[] .name'
end
