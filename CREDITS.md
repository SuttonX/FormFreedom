# Credits and source provenance

FormFreedom is an independently named standalone adaptation developed for Christopher Sutton. The form-helper and restriction-classifier modules were adapted from our ConsolePortLK development changes. ConsolePort's upstream Artistic License 2.0 and copyright notices are preserved in LICENSE.md. Upstream copyright holders named there: Sebastian Lindfors (2015) and Leandro Araujo Viana (2025). Standalone adaptations: Christopher Sutton, 2026.

No ElvUI library is bundled and no base ElvUI file is modified. This is not an official ElvUI or ConsolePort product.

## References inspected

- [ElvUI-WotLK](https://github.com/ElvUI-WotLK/ElvUI), release6.09, commit `8c0ac9d`. Action-button lifecycle and naming were inspected to support it externally.
- [WoW3.3.5 interface files](https://github.com/wowgaming/3.3.5-interface-files), commit `d0339b17b0221db76e6acd2dc2915d224a5b62ca`. Secure wrappers, action buttons and native gossip/taxi behavior.
- [AzerothCore](https://github.com/azerothcore/azerothcore-wotlk), commit `c1a9220363374dbbcce2f93a70a758916684c5dd`. Server spell/form and mount restriction logic.
- [Public TrinityCore3.3.5 data](https://github.com/Torrer/TrinityCore-3.3.5-data), commit `ac753a9b849e578ce2295d15125c8eb17e1b22c0`. Spell.dbc/SpellShapeshiftForm.dbc-derived restriction facts. The data is not a copy of the tester's exact client/server records; private-server rules may differ. No DBC binaries are distributed in this addon.
- [CancelFormForCrafting](https://github.com/AndreWaehlisch/CancelFormForCrafting), commit `d4842dfd826f312550351b690dbc106a1696c336`. Secure crafting-click workaround reference. Its modern Classic code was not copied wholesale.
- User-supplied TaxiUnshift1.0.0 by Chairface, TBC Classic Interface20505/20506. Reachable-node overlays and route-hover priming informed the approach. Its modern timers, templates, announcements and error clearing were not copied.

The implementation differs from the upstream ConsolePort package in standalone initialization, external Blizzard/ElvUI button wrappers, isolated names, druid gating and shared CPLK integration. The package is named FormFreedom to distinguish these modifications.
