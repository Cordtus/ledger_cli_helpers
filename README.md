# Ledger CLI Helpers

Shell helpers for managing Ledger hardware wallets via `ledger-live` CLI.

## Prerequisites

- **ledger-live CLI**: `npm install -g @ledgerhq/live-cli`
- **jq**: JSON processor
- **node** (optional): Improves JSON parsing reliability

## Installation

### Bash

```bash
# Add to ~/.bashrc or ~/.bash_profile
source /path/to/ledger_cli_helpers/bash/ledger_helpers.sh
```

### Zsh

```zsh
# Add to ~/.zshrc
source /path/to/ledger_cli_helpers/zsh/ledger_helpers.zsh
```

### Fish

```fish
# Copy to fish functions directory
cp /path/to/ledger_cli_helpers/fish/ledger_helpers.fish ~/.config/fish/functions/
```

## Functions

| Function | Description |
|----------|-------------|
| `ledgerListApps` | List installed app names |
| `ledgerInstallApp <app> [app2...]` | Install/update apps |
| `ledgerUpdateApps` | Update all installed apps |
| `ledgerUpdateFirmware` | Check and update firmware |

## Examples

```bash
# List apps
ledgerListApps

# Install Bitcoin and Ethereum
ledgerInstallApp Bitcoin Ethereum

# Update all apps
ledgerUpdateApps

# Update firmware
ledgerUpdateFirmware
```

## Notes

- Device must be connected and unlocked on the dashboard
- Firmware updates wipe all apps (reinstall after)
- The `--to-my-own-risk` flag bypasses interactive prompts

## Troubleshooting

**ledger-live not found**: Ensure npm global bin is in PATH:
```bash
export PATH="$PATH:$(npm root -g)/../bin"
```

**Connection issues**: Make sure device is on dashboard (not in an app).

**Permission denied**: Add [udev rules for Ledger devices](https://support.ledger.com/article/115005165269-zd).
