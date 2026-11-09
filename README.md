# foxdock-foxforge

The `foxforge` plugin of FoxDock, the plugin system for the Visual FoxPro 9 IDE. Hosts FoxForge, the VFP project workshop, in the FoxDock menu.

> Also in Spanish ([README_ES.md](README_ES.md)) and German ([README_DE.md](README_DE.md)).

## Install

You need FoxDock and [FoxPack](https://irwinrodriguez.dev/products/foxpack).

- In FoxDock: **FoxDock > Plugins > Plugin center...**, **Available**, choose `foxforge` and press **Install**.
- From a console: `foxpack plugin add foxforge`.

If `foxforge` came with your FoxDock installer, the plugin center shows its new versions in **Updates**.

## The `foxforge` plugin

FoxForge, the VFP project workshop, is hosted in FoxDock: its menus go in **FoxDock > FoxForge**, and
FoxDock connects FoxAgent for it. There are no longer two menu pads or two connections from the same
IDE.

**Where it looks for it**, in this order:
1. the `foxforge.folder` option;
2. the registry, with the folder its installer leaves
   (`HKLM\SOFTWARE\irwinrodriguez.dev\FoxForge\InstallDir`);
3. `C:\Program Files (x86)\FoxForge`;
4. and, on a development tree, `..\FoxForge\` next to the FoxDock folder.

**What it does when the IDE starts.** It loads FoxForge with `DO FoxForge.APP WITH "hosted"`. FoxForge
does what it always does (its providers, its language) **except** adding its menu pad, connecting
FoxAgent and installing its `ON SHUTDOWN`.

**The menu is FoxForge's**, the same one it had on its pad, and FoxForge draws it in the submenu FoxDock
gives it (`FillWith`):
- **New project**, with one bar per project type;
- **Current project**, with the bars of the type of the project you have open;
- **Refresh menu**, **Language**, **Help**, **FoxCli licence** (if the `cli` provider is there) and
  **About**.

Its FoxAgent bar is missing: the `foxagent` plugin takes care of that. When a project opens or closes,
the menu is rebuilt by itself.

**What it does not do.**
- **It does not start a FoxForge that does not know the hosted mode.** The version number does not tell:
  the FoxForge 0.4.8 installed on 16-10-2026 does not know it either. A FoxForge like that runs fully even
  when asked for `"hosted"`, and adds its own pad. So FoxDock first looks for the mark of that mode inside
  its `FoxForge.APP`. Without the mark, it does not run it: the bar says it is too old to be hosted, and
  the log says how to use it on its own (`DO FoxForge.APP`) or to install a newer one.
- **Without FoxForge**, the only bar says `FoxForge: not installed`.
- **Without FoxDock, FoxForge works as before.** `foxforge.cmd` or `DO FoxForge.APP` with no parameter
  add its pad and its FoxAgent, as always.
- **While FoxDock hosts it**, a `DO FoxForge.APP` with no parameter behaves as hosted, so that there are
  not two pads. It knows from `_screen.cFoxDockHostsFoxForge`, which is `"1"` only while this plugin
  hosts a FoxForge. **With FoxDock running but hosting nothing** (it found an old one, for example), that
  `DO` adds its pad, as without FoxDock.

For the agent there are two tools, `ide_foxforge_providers` and `ide_foxforge_new_project`:
AGENT-TOOLS_EN.md § 6.

## About this manual

This text is the section about `foxforge` of the FoxDock plugin manual. The references to other sections (§) and to AGENT-TOOLS point to the documents FoxDock installs in its `docs` folder.

## License

MIT. See [LICENSE](LICENSE).
