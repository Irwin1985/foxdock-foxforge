# foxdock-foxforge

Das Plugin `foxforge` für FoxDock, das Plugin-System für die IDE von Visual FoxPro 9. Bindet FoxForge, die Projektwerkstatt für VFP, in das FoxDock-Menü ein.

> Auch auf Englisch ([README.md](README.md)) und Spanisch ([README_ES.md](README_ES.md)).

## Installieren

Sie brauchen FoxDock und [FoxPack](https://irwinrodriguez.dev/products/foxpack).

- In FoxDock: **FoxDock > Plugins > Plugin-Center...**, **Verfügbar**, `foxforge` auswählen und **Installieren** drücken.
- Von der Konsole: `foxpack plugin add foxforge`.

Wenn `foxforge` mit Ihrem FoxDock-Installer kam, zeigt das Plugin-Center seine neuen Versionen unter **Aktualisierungen**.

## Das Plugin `foxforge`

FoxForge, die Projektwerkstatt für VFP, wird in FoxDock gehostet: Seine Menüs stehen in
**FoxDock > FoxForge**, und FoxDock verbindet FoxAgent für es. Es gibt nicht mehr zwei Menütitel oder zwei
Verbindungen aus derselben IDE.

**Wo es danach sucht**, in dieser Reihenfolge:
1. die Option `foxforge.folder`;
2. die Registrierung, mit dem Ordner, den sein Installationsprogramm hinterlegt
   (`HKLM\SOFTWARE\irwinrodriguez.dev\FoxForge\InstallDir`);
3. `C:\Program Files (x86)\FoxForge`;
4. und, in einem Entwicklungsbaum, `..\FoxForge\` neben dem FoxDock-Ordner.

**Was es beim Start der IDE tut.** Es lädt FoxForge mit `DO FoxForge.APP WITH "hosted"`. FoxForge tut,
was es immer tut (seine Provider, seine Sprache), **außer** seinen Menütitel anzulegen, FoxAgent zu
verbinden und sein `ON SHUTDOWN` einzurichten.

**Das Menü ist das von FoxForge**, dasselbe, das es auf seinem Menütitel hatte, und FoxForge zeichnet es
in das Untermenü, das FoxDock ihm gibt (`FillWith`):
- **New project**, mit einem Menüpunkt pro Projekttyp;
- **Current project**, mit den Menüpunkten des Typs des Projekts, das Sie offen haben;
- **Refresh menu**, **Sprache**, **Help**, **FoxCli licence** (wenn der Provider `cli` da ist) und
  **About**.

Sein Menüpunkt für FoxAgent fehlt: Darum kümmert sich das Plugin `foxagent`. Wenn sich ein Projekt öffnet
oder schließt, baut sich das Menü von selbst neu auf.

**Was es nicht tut.**
- **Es startet kein FoxForge, das den gehosteten Modus nicht kennt.** Die Versionsnummer verrät das
  nicht: Auch das am 16.10.2026 installierte FoxForge 0.4.8 kennt ihn nicht. Ein solches FoxForge läuft
  vollständig, auch wenn es mit `"hosted"` aufgerufen wird, und legt seinen eigenen Menütitel an. Darum
  sucht FoxDock zuerst in seiner `FoxForge.APP` nach dem Kennzeichen dieses Modus. Ohne das Kennzeichen
  führt es sie nicht aus: Der Menüpunkt meldet, dass es zu alt ist, um gehostet zu werden, und das
  Protokoll sagt, wie Sie es für sich allein benutzen (`DO FoxForge.APP`) oder ein neueres installieren.
- **Ohne FoxForge** steht auf dem einzigen Menüpunkt `FoxForge: not installed`.
- **Ohne FoxDock funktioniert FoxForge wie bisher.** `foxforge.cmd` oder `DO FoxForge.APP` ohne Parameter
  legen seinen Menütitel und seinen FoxAgent an, wie immer.
- **Solange FoxDock es hostet**, verhält sich ein `DO FoxForge.APP` ohne Parameter wie gehostet, damit es
  nicht zwei Menütitel gibt. Es erkennt das an `_screen.cFoxDockHostsFoxForge`, das nur `"1"` ist,
  solange dieses Plugin ein FoxForge hostet. **Wenn FoxDock läuft, aber nichts hostet** (es hat zum
  Beispiel ein altes gefunden), legt dieses `DO` seinen Menütitel an, wie ohne FoxDock.

Für den Agenten gibt es zwei Tools, `ide_foxforge_providers` und `ide_foxforge_new_project`:
AGENT-TOOLS_DE.md § 6.

## Über dieses Handbuch

Dieser Text ist der Abschnitt über `foxforge` aus dem Plugin-Handbuch von FoxDock. Die Verweise auf andere Abschnitte (§) und auf AGENT-TOOLS zeigen auf die Dokumente, die FoxDock in seinem Ordner `docs` installiert.

## Lizenz

MIT. Siehe [LICENSE](LICENSE).
