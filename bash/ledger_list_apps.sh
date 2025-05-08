#!/usr/bin/env bash
# List installed Ledger apps by name

ledger_list_apps() {
  ledger-live listApps --format json \
    | sed -E "s/'/\"/g; s/([[:alnum:]_]+):/\"\1\":/g" \
    | jq -r '.[] .name'
}

ledger_list_apps
