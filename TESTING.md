# Validation and coverage

## 1.1.0 confirmed in-game results

On 2026-10-22 the maintainer confirmed leaving Ghost Wolf when speaking to a flight master and dismounting when mounted. Book of Powers Dalaran use also succeeded from Ghost Wolf and while mounted. The maintainer then clarified that opening Book of Powers itself removed the mount/form, including druid forms and Ghost Wolf, before selecting a destination. The source excludes item 9017 from proactive action-bar classification and targets only menu options 2/9; the new native error fallback does not cancel forms. The cause of opening-time cancellation was not isolated with FormFreedom disabled. The maintainer accepted that observed behavior and requested publication without further investigation.

The maintainer declined repeated testing of previously confirmed druid behavior. Existing druid results remain historical passes; they are not claimed as a new 1.1.0 runtime regression matrix. Mounted spell/item use, crafting, gathering-error fallback, mounted combat/tracking and other class/input combinations were not separately confirmed in game for this release. All eight mock suites pass.

## 1.1.0 mounted-action support

All eight mock suites pass. Mounted tests cover stock mounted-use flags, allowed tracking and mounted combat, numeric/localized item-spell resolution and ambiguity, unknown actions, secure grounded dismounts, humanoid/stance preservation, stale identities, right clicks, combat deferral and taxi/flying exclusions. Menu tests cover mounted all-class crafting and reachable taxi destinations without cancelling non-druid/shaman stances. Native fallback tests exercise localized mounted errors with the original 3.3.5 first-argument payload, flight-map opening, unrelated/nil/modern payloads, ground/taxi/combat exclusions, re-entrant events and a modified-client failure disabling native fallback after one attempt. Diagnostics now include mount/flying/taxi context and any native fallback error. These are mocks rather than proof of protected in-game execution.

Test grounded mounted spell and item actions on a non-druid/shaman; check mounted tracking/jousting remains native. Test Create/Create All, a reachable taxi route and Book options 2/9. Check Ghost Wolf and druid Prowl/Growl, ElvUI/CPLK input, normal unmounted behavior, /ffreport and combat deferral. Flying-mount and taxi behavior should remain native. Test a mounted ore/herb interaction or another path that returns a localized mounted error; the fallback should dismount outside combat, with another click needed if the original action failed. World-object gathering and arbitrary gossip remain outside guaranteed one-click coverage.

## Shaman Ghost Wolf support

The Shaman test checks initialization on all playable classes, limits form handling to druids and shamans, resolves localized Ghost Wolf to bundled form 16, and classifies restricted spells, mounts and Fishing without intercepting Ghost Wolf or unknown actions. It also executes the shared ElvUI secure wrapper against the resulting Ghost Wolf attributes and verifies humanoid behavior stays native. Existing druid/action/menu/diagnostic suites remain required.

On a shaman, verify error-free login, entering and manually leaving Ghost Wolf, a restricted spell and mount/Fishing on the action bar, crafting Create/Create All, flight-master and Warstorm Book of Powers options 2/9 if available, combat behavior, and /ffreport capture. Test ElvUI and ConsolePortLK-Enhanced where used. Recheck druid Prowl and Growl. The confirmed-results section above records the Shaman runtime evidence; mock tests do not add runtime confirmations.

## 1.0.3 report window

On 2026-10-13 the maintainer confirmed the diagnostic report-window fix working in game using 1.0.3-test1 after being asked to check error-free opening, scrolling and copying. Release 1.0.3 retains that tested window change and the 1.0.2 Prowl fix. All five mock suites pass, with the diagnostic mock rejecting unnamed UIPanelScrollFrameTemplate frames.

## 1.0.2 spell-action classification

On 2026-10-13 the maintainer confirmed Prowl working in Cat Form through both ElvUI and ConsolePortLK-Enhanced using 1.0.2-test2. The original ElvUI report identified absolute action slot 73, spellbook index 89, global spell ID 5215, and Cat Form index 3 changing to Humanoid with “Must be in Cat Form.” The corrected ConsolePort report identified slot 84 with the same index/global ID and remained in Cat Form. The reason ConsolePort avoided the original failure was not established.

Release 1.0.2 retains the test2 gameplay code. All five mock suites pass, including the exact reported index/ID collision, Growl and unknown-spell preservation, missing-ID safety without spellbook lookups, and stale global-ID rejection. Growl preservation in the mocks is not a new in-game Bear Form test; a fresh mount/Fishing or exhaustive per-action regression pass was not separately reported for this fix. The first test build introduced an invalid spellbook lookup and was withdrawn; that lookup is absent from test2 and the release.

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
