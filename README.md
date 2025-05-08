# Ledger Live Helper Scripts

Helpers to simplify common device tasks using the [ledger-live](https://github.com/LedgerHQ/ledger-live) SDK (firmware updates, app installs/updates).

## Installation

### FISH shell

1. Clone or copy the `functions` directory into your shell config:

   ```bash
   mkdir -p ~/.config/ledger-live-helpers
   cp -r functions/* ~/.config/ledger-live-helpers/
   ```
2. Add your Fish functions directory to your `PATH`:

   ```bash
   export PATH="$HOME/.config/ledger-live-helpers:$PATH"
   ```
3. Reload your shell:

   ```bash
   exec fish
   ```

---

## Scripts Included

### Common USB & Unlock Polling Logic

All helpers include two pre-check loops:

1. **USB detection**: waits for a Ledger device to be plugged in. By default this looks for vendor ID `0x2c97`, but you can customize it by setting the environment variable `LEDGER_USB_VID` to match your device’s vendor ID. To discover your device’s vendor ID, run:

   ```bash
   lsusb | grep -i ledger
   ```

   **Configure permanently**

   * **Bash**:

     ```bash
     echo 'export LEDGER_USB_VID=<your_vendor_id>' >> ~/.bashrc
     source ~/.bashrc
     ```
   * **Fish**:

     ```fish
     set -Ux LEDGER_USB_VID <your_vendor_id>
     ```

2. **Unlock detection**: waits for the device to be unlocked (`ledger-live listApps` succeeds)

At each prompt you can press `ENTER` to retry or type `q` to abort.

---

## Fish Functions

* `ledger_list_apps.fish`
* `ledger_update_firmware.fish`
* `ledger_update_apps.fish`
* `ledger_install_app.fish`

Place them in `~/.config/fish/functions/` so Fish autoloads them. Example:

```fish
ledger_update_firmware
ledger_update_apps
ledger_install_app Bitcoin Ethereum
```

---

## Bash Scripts

These can be used as standalone scripts. They require:

* Bash shell (`bash`)
* `lsusb` (from `usbutils`)
* `jq` for JSON parsing
* `ledger-live` CLI in your `PATH`

### Available scripts

* `ledger_list_apps.sh`
* `ledger_update_firmware.sh`
* `ledger_update_apps.sh`
* `ledger_install_app.sh`

### Setup

1. Create a directory for your helper scripts and copy them in:

   ```bash
   mkdir -p ~/.config/ledger-live-helpers
   cp bash/*.sh ~/.config/ledger-live-helpers/
   ```
2. Make the scripts executable:

   ```bash
   chmod +x ~/.config/ledger-live-helpers/*.sh
   ```
3. Ensure the directory is in your `PATH`. Add this to `~/.bashrc` or `~/.profile`:

   ```bash
   export PATH="$HOME/.config/ledger-live-helpers:$PATH"
   ```
4. Reload your shell:

   ```bash
   source ~/.bashrc
   ```
