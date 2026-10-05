![FormFreedom — One click. Leave form. Keep going.](assets/banner.svg)

# FormFreedom

**Automatic druid form cancellation for the WotLK 3.3.5 / 3.3.5a client.**

**1.0.0** · **Druid only** · **Standalone** · **ElvUI compatible**

Trying to take a flight, craft an item or summon a mount while shapeshifted? FormFreedom leaves form through your original click and continues supported actions—without making you write macros or manually cancel form first.

Works with Blizzard's UI, ElvUI-WotLK, and our compatible ConsolePortLK build. No ElvUI file edits, settings panel or extra controls.

## ✨ What it does

| Action | How FormFreedom helps |
| --- | --- |
| **Flight masters** | Click a reachable destination: leave form, then take the flight. |
| **Crafting** | Click **Create** or **Create All**: leave form and run the normal profession-button action, preserving the selected recipe and quantity. |
| **Mounts** | Use an identified mount on a supported action bar: leave a disallowed form before summoning. |
| **Fishing** | Use the Fishing ability on a supported action bar: leave a disallowed form before casting. |
| **Teleports** | Use an identified restricted teleport spell or item on a supported action bar: leave form when its spell rules require it. |
| **Warstorm Book of Powers** | Item **9017**: mount option **2** and Dalaran option **9** leave form before selection. Opening the book and other options retain their normal behavior. |

Mouse hover highlights and normal button interactions remain available. Crafting clicks deliberately leave form even when a particular recipe might permit casting in form.

## 🌿 How the logic works

### Blizzard's `autoUnshift` and FormFreedom

The client's built-in `autoUnshift` behavior already handles some actions. On the tested Warstorm setup, for example, the normal Hearthstone already leaves form without an addon workaround.

**FormFreedom does not enable, disable or change the `autoUnshift` setting.** It adds explicit cancellation to supported clicks that need it, using a secure `/cancelform [form]` action before continuing the original action.

### Spell rules, not a blanket “leave form” command

For action bars, FormFreedom uses a bundled reference of **WoW 3.3.5 spell/form restrictions**. It checks the current form against allowed/forbidden form masks, restrictions on shifted casting and mount information. It distinguishes stance-like forms from animal forms where the rules differ.

Form-changing abilities are excluded. It also avoids cancellation when leaving form cannot help an ability that requires a different form. Item spells are resolved by ID or an unambiguous localized name/rank; unknown custom spells and ambiguous matches are left unchanged.

Before redirecting a click, it checks that the bar slot still contains the classified action. It snapshots the original absolute slot so leaving form cannot accidentally select an ability from a different form page, then restores the button's ordinary state.

### One hardware click

WoW protects form cancellation. FormFreedom runs it through a secure button during your click—not through a background error listener that retries arbitrary actions.

For native menus, invisible secure helpers cover only the supported buttons. They preserve the original menu's appearance and hover behavior, cancel form, then continue the selected action. No macros need to be placed on your bars.

## 🧩 Compatibility

- **WotLK 3.3.5a**, Interface **30300**; druids only. Compatibility with **3.3.5** is expected but has not been separately tested.
- **Blizzard action bars**, including the bonus/form bar and four multibars.
- **ElvUI 3.3.5** (ElvUI-WotLK **6.09**) action bars. ElvUI is optional; its files remain untouched.
- **Our ConsolePortLK v160+ builds**, with the FormFreedom bridge. Keep FormFreedom enabled and toggle CPLK when switching between desktop and controller use.

Older CPLK v154–v159 builds contain duplicate form helpers and should not be combined with this release. The CPLK bridge is a development-build integration, not a claim that every upstream ConsolePort release supports it.

Successfully tested **entirely standalone**, **alongside ElvUI 3.3.5**, and **alongside ConsolePortLK** on **Warstorm**, using the **WotLK 3.3.5a client**. Other private servers, bar replacements and controller combinations are not exhaustively tested. This release targets neither retail WoW nor modern Classic clients.

## 📦 Installation

1. Open this repository's **Releases** and download **FormFreedom-1.0.0.zip**.
2. Extract **FormFreedom** into `World of Warcraft/Interface/AddOns/`.
3. Check that `Interface/AddOns/FormFreedom/FormFreedom.toc` exists.
4. Restart WoW and enable FormFreedom in the addon list.

No configuration or user-created macros required. Keep your existing SavedVariables; FormFreedom creates none.

Use the attached **FormFreedom-1.0.0.zip** release package for direct installation. It contains one `FormFreedom` folder, including the source and documentation. GitHub's automatically generated Source code archive may use a versioned outer folder; rename that extracted folder to `FormFreedom` before placing it in `Interface/AddOns/`.

## ⚠️ Coverage limits

- **Supported action bars are required** for the mount, Fishing and teleport integration. Generic bag, spellbook and mount-journal clicks are not covered.
- Mining by right-clicking ore, arbitrary quest/gossip options, toys and bandages are not universally handled.
- Book of Powers support uses Warstorm's specific item and option indices.
- Private-server restrictions can differ from the bundled stock reference. Unknown custom actions may need dedicated support.
- Menu helpers hide securely in combat; native menu behavior remains. Action-bar classification updates wait until combat ends, while existing entries still require a matching current action.
- Existing user macros are not rewritten. Encounter transformations cannot generally be removed by ordinary `/cancelform`.

FormFreedom handles supported click paths; it does not promise to intercept every “You are in shapeshift form” error in the game.

## 🔎 Found another blocked action?

If an action still displays **“You are in shapeshift form”** and your druid does not leave form, please open an issue so we can investigate adding support. Tell us what you clicked, your form and server, and include the **item number or spell ID** if possible.

With FormFreedom enabled, create this short capture macro:

```text
/ffreport
```

### How to test the report capture

After installing or updating FormFreedom, **restart WoW** so its report module loads. Keep your existing SavedVariables.

1. On your druid, enter **Cat, Bear or another shapeshift form**.
2. Type `/ffreport` in chat, or press the capture macro. You should see a message saying it is recording for **30 seconds**.
3. Within those 30 seconds, click a spell on your action bar, an item in your bag or a Book of Powers option.
4. Type `/ffreport` again, or press the macro again, to open the report immediately. Otherwise it opens when the recording timer expires.
5. Click inside the report text, press **Ctrl+A**, then **Ctrl+C**, and paste it into Notepad or your GitHub issue.

Check that the report identifies what you clicked and that copying works. **The action does not need to fail for this test.**

If you encounter **“You are in shapeshift form”**, check that the report opens automatically after a short delay and includes that error.

For Book of Powers or another item-based menu, start recording **before opening the item**, then click its option. This helps capture both the item and option index.

In your issue, tell us whether the window opened, what it recorded and whether you could copy the text. Paste the report and add a short explanation of the action and expected result.

The report can record standard action-bar, inventory, spell, crafting, gossip and taxi calls plus game error text. Some custom server actions expose no item/spell ID; describe those manually. Spell/recipe links can contain IDs even when a separate numeric ID is unavailable.

The capture is opt-in, local and limited to 30 seconds. It does not send reports, change bindings, cancel form or retry anything. This macro is only for reporting; ordinary addon use requires no macros.

## 🛠️ Feedback and development

Open an issue with your client/server, addon version, form, exact action and click path. Include Lua errors and item/spell IDs when available.

Addon Lua files and `FormFreedom.toc` are at the repository root. The `tests/` and `scripts/` folders contain development tools; WoW does not load them. Developers can run:

```sh
python3 scripts/check.py
python3 scripts/build_release.py
```

The mock harness requires Python 3 and Lua 5.3+ or `luatex`; addon source targets Lua 5.1. See [TESTING.md](TESTING.md), [CHANGELOG.md](CHANGELOG.md) and [CREDITS.md](CREDITS.md).

## License and credits

**Artistic License 2.0.** Upstream notices and modification provenance are preserved in [LICENSE.md](LICENSE.md) and [CREDITS.md](CREDITS.md). FormFreedom is independently named and is not an official ElvUI or ConsolePort release.
