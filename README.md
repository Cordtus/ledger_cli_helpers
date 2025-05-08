# Ledger Live Helper Scripts

Helpers to simplify common Ledger device tasks using the [ledger-live](https://github.com/LedgerHQ/ledger-live) CLI (firmware updates, app installs/updates).

---

## Prerequisites (both Bash & Fish)

* **CLI**: `ledger-live` in your `$PATH`
* **Utilities**: `lsusb` (from `usbutils`), `jq`
* **Shell**: Bash (≥ 4.0) or Fish (≥ 3.0)

---

## Installation

> **Download or clone** this repository to a local directory. For example:
>
> ```bash
> git clone https://github.com/your-repo/ledger-live-helpers.git ~/ledger-live-helpers
> cd ~/ledger-live-helpers
> ```

### Bash

### Bash

Copy the Bash scripts into a folder in your `PATH` (e.g. `~/bin`), make them executable, and reload your shell:

```bash
mkdir -p ~/bin
cp bash/*.sh ~/bin/
chmod +x ~/bin/*.sh
# reload your shell or run:
source ~/.bashrc
```

### Fish

Copy the Fish functions into your Fish functions directory and restart Fish:

```bash
mkdir -p ~/.config/fish/functions
cp fish/*.fish ~/.config/fish/functions/
exec fish
```
