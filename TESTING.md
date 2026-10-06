# Validation and coverage

## 1.0.1 reliability fixes

The owner-based secure-handler correction was confirmed in game by the tester. Additional page/parent/menu-source guards pass all five mock suites. On 2026-10-06 the maintainer reported no FormFreedom issues after installing this expanded audit build alongside the other updated addons and testing profile switching. This overall pass does not establish exhaustive per-action coverage. Secure-handler mocks distinguish the execution-only control handle from the owner frame.

With a druid, test stock/ElvUI action bars and ConsolePort bars, bonus pages and shapeshift transitions, supported travel/crafting/menu actions, combat deferral and right-click behavior. Confirm ordinary actions retain their original behavior. Run /ffreport if a supported shifted action fails; its version should match the TOC.


## Runtime evidence

On 2026-10-05, the tester reported that FormFreedom 0.1.0-test1 worked both entirely by itself and alongside ElvUI. Testing took place on Warstorm with a WoW3.3.5a client. The report was an overall pass, not an exhaustive per-form, per-recipe, per-item or per-keybinding matrix.

The parent ConsolePortLK implementation had separately confirmed Book of Powers mount/Dalaran, reachable flight destinations and crafting through mouse and controller selection. Mouse highlight and modifier reconciliation subsequently passed. These are provenance results; they do not constitute separate controller support testing for standalone FormFreedom.

The rc1 precursor changed coexistence and optional CPLK bar reconciliation. The initial standalone/ElvUI pass remains historical evidence; the tester subsequently confirmed the shared CPLK setup working. Release 1.0.0 preserves the rc1 gameplay Lua code; it adds a separate opt-in diagnostics module.

## Automated checks

The supplied harness checks:

- Addon syntax and extracted secure-wrapper snippets.
- Stock, bonus/form and ElvUI absolute action-slot selection.
- Action fingerprints; stale actions, right clicks and cursor editing remain native.
- Restoring original macro attributes and current ElvUI state after a click.
- Selfcast flags and combat deferral.
- Restriction data/localized item-spell lookup and form-ability exclusion.
- Book context/options, unrelated gossip exclusion and reachable-only taxi helpers.
- Original crafting callback after form-change cleanup; disabled buttons untouched.
- Stable helper display across repeated updates and mouse-hover cleanup.

Tests simulate APIs; they do not prove in-game protected execution or taint behavior. The test runtime is Lua5.3+, while the addon targets Lua5.1.

## Useful checks for subsequent changes

Use a druid and verify book2/9, flight destination, Create/CreateAll, mount/Fishing/restricted teleport on a supported bar, native humanoid behavior and mouse highlights. Check form switching, dragging, normal keybinds, modifier selfcast and form-page changes. Test with ElvUI enabled and disabled. Check combat deferral without altering unsupported menu behavior. Broader controller/WoWpadX auditing belongs to the separate ConsolePortLK project; its source audit does not replace a hardware test matrix.

The rc1 action tests also cover CPLK header routing, page-relative controller presses and release exclusion. The menu tests cover delayed CPLK modifier reconciliation. The shared setup subsequently passed the tester’s in-game check; this is not exhaustive testing of every controller family or mapper profile.

On 2026-10-05, the tester pasted an in-game /ffreport capture identifying Book of Powers item 9017, gossip option 2 and Cat Form to Humanoid transition, with ElvUI loaded and ConsolePortBar absent. This confirms action capture, report display and copying. Gossip label text was unavailable; item and option IDs were captured. Automatic opening on a new shapeshift error has not been separately confirmed.

The tester also explicitly confirmed Fishing from Cat Form successfully unshifted. These runtime checks passed before publication.
