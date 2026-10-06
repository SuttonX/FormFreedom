# Changelog

## 1.0.1 — 2026-10-06

- Fix secure frame-reference access for the WotLK wrapper execution environment.
- Guard missing controller pages and detached parents; accept numeric-string pages.
- Clear stale controller redirects when menu source frames are replaced.
- Report the installed version dynamically in diagnostics.


## 1.0.0 — 2026-10-05

Initial standalone release:

- Automatic form cancellation for supported flight-master, crafting and action-bar interactions.
- Warstorm Book of Powers mount and Dalaran options.
- Blizzard and ElvUI-WotLK action-bar support without modifying their files.
- Native mouse hover highlighting and stable click helpers.
- Current action fingerprints and absolute-slot snapshots to avoid redirecting a stale action.
- Original button attributes and current ElvUI page state restored after use.
- Druid-only operation and optional integration with ConsolePortLK v160+.

The tester confirmed that the 0.1.0-test1 code worked both standalone and with ElvUI. The rc1 precursor removed automatic stand-down and adds optional CPLK bar reconciliation, so FormFreedom can own form handling while CPLK is toggled. Paired CPLK v160 removes its duplicate helpers and routes controller menu clicks to FormFreedom. The tester subsequently confirmed standalone FormFreedom and CPLK coexistence working on 2026-10-05.

- Opt-in `/ffreport` capture for reporting additional blocked actions; copyable local report, no automatic submission.
