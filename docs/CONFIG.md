# CybeRp Configuration Guide

## Core (`gamemode/config/sh_config.lua`)
- `StartingCredits` — credits granted to new characters (default 500).
- `CyberwareLimit` — max installed cyberware modules (default 8).
- `InventorySlots` — base inventory slots (default 32).
- `MaxWeight` — placeholder for weight system (default 50).
- `Debug` — enable verbose debug prints (false recommended in production).
- `PaycheckInterval` — seconds between salary ticks (default 300).
- `PaycheckBase` — base salary; jobs can override (default 50).
- `SalesTax` — sales tax rate (default 0.08).
- `IncomeTax` — income tax rate (default 0.05).
- `VendorBuyMult` — NPC buy multiplier (default 0.50).
- `VendorSellMult` — NPC sell multiplier (default 1.10).

## Jobs (`gamemode/config/sh_jobs.lua`)
- Define job entries with `id`, `name`, `desc`, `startingCredits`, `faction`, `loadout`.
- Optional: `requiresFaction`, `blockedWeapons`, `blockedCyberware`.

## Factions (`gamemode/config/sh_factions.lua`)
- Define faction `id`, `name`, `desc`.

## Items (`gamemode/config/sh_items.lua`)
- Each item: `id`, `name`, `desc`, `type`, `weight`, `price`.

## Cyberware (`gamemode/config/sh_cyberware.lua`)
- Each module: `id`, `name`, `desc`, `slot` (HEAD/ARMS/LEGS/TORSO/NEURAL), `passive` (bool), `cooldown` (optional), and stat modifiers (e.g., `staminaMaxBonus`, `regenMult`, `drainMult`, `armorBonus`).

## Economy (`gamemode/config/sh_economy.lua`)
- `startingCredits`, `salesTax`, `incomeTax`, `vendorBuyMultiplier`, `vendorSellMultiplier`, `npcPrices` table.

## Networking
- Net strings in `gamemode/core/networking/sh_net_defs.lua`.
- Debug prints gated by `CybeRp.Config.Debug`.

## Persistence
- SQLite tables `cyberp_characters`, `cyberp_inventories` via `gamemode/core/database/`.


