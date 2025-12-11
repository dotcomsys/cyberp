# CybeRp (Garry's Mod Cyberpunk RP Gamemode)

## Overview
- Cyberpunk-themed RP gamemode with persistence (SQLite by default).
- Core systems: players, jobs/factions, inventory, cyberware, UI, networking.
- State sync via net (deltas) and client state mirrors.

## Quick Start
1) Drop the `cyberp` folder into your `garrysmod/gamemodes/` directory.
2) Set the gamemode to `cyberp`.
3) Ensure SQLite is available (default for GMod).
4) Launch and use the console commands:
   - `cyberp_inventory_toggle`
   - `cyberp_cyberware_toggle`

## Key Console Commands
- `cyberp_inventory_toggle` — open/close inventory menu.
- `cyberp_cyberware_toggle` — open/close cyberware menu.

## Networking Notes
- Net strings defined in `gamemode/core/networking/sh_net_defs.lua`.
- Server pushes player/inventory/cyberware snapshots; clients keep `CybeRp.ClientState` in sync.

## Persistence
- Characters and inventories stored in SQLite tables `cyberp_characters` and `cyberp_inventories`.
- See `gamemode/core/database/` for bootstrap and store logic.

## Debugging
- Set `CybeRp.Config.Debug = true` (in `config/sh_config.lua`) to enable verbose prints.

## Configuration
- See `docs/CONFIG.md` for tunables (credits, taxes, cyberware limits, etc.).

## License
- Unsound Studios – see repository for license details if provided.


