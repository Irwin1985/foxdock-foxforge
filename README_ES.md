# foxdock-foxforge

El plugin `foxforge` de FoxDock, el sistema de plugins para el IDE de Visual FoxPro 9. Aloja FoxForge, el taller de proyectos de VFP, en el menú de FoxDock.

> También en inglés ([README.md](README.md)) y en alemán ([README_DE.md](README_DE.md)).

## Instalar

Hacen falta FoxDock y [FoxPack](https://irwinrodriguez.dev/products/foxpack).

- En FoxDock: **FoxDock > Plugins > Centro de plugins...**, **Disponibles**, elige `foxforge` y pulsa **Instalar**.
- Desde una consola: `foxpack plugin add foxforge`.

Si `foxforge` vino con tu instalador de FoxDock, el centro de plugins enseña sus versiones nuevas en **Actualizaciones**.

## El plugin `foxforge`

FoxForge, el taller de proyectos de VFP, se aloja en FoxDock: sus menús van en **FoxDock > FoxForge**,
y FoxDock le conecta FoxAgent. Ya no hay dos pads de menú ni dos conexiones del mismo IDE.

**Dónde lo busca**, en este orden:
1. la opción `foxforge.folder`;
2. el registro, con la carpeta que deja su instalador
   (`HKLM\SOFTWARE\irwinrodriguez.dev\FoxForge\InstallDir`);
3. `C:\Program Files (x86)\FoxForge`;
4. y, en un árbol de desarrollo, `..\FoxForge\` junto a la carpeta de FoxDock.

**Qué hace al arrancar el IDE.** Carga FoxForge con `DO FoxForge.APP WITH "hosted"`. FoxForge hace
lo de siempre (sus proveedores, su idioma) **menos** poner su pad de menú, conectar FoxAgent e instalar su
`ON SHUTDOWN`.

**El menú es el de FoxForge**, el mismo que tenía en su pad, y lo pinta FoxForge en el submenú que le da
FoxDock (`FillWith`):
- **Nuevo proyecto**, con una barra por tipo de proyecto;
- **Proyecto actual**, con las barras del tipo del proyecto que tengas abierto;
- **Refrescar menú**, **Idioma**, **Ayuda**, **Licencia de FoxCli** (si está el proveedor `cli`) y
  **Acerca de**.

Falta su barra de FoxAgent: de eso se encarga el plugin `foxagent`. Al abrir o cerrar un proyecto, el
menú se rehace solo.

**Lo que no hace.**
- **No arranca un FoxForge que no conozca el modo alojado.** El número de versión no lo dice: el FoxForge
  0.4.8 instalado el 16-10-2026 tampoco lo conoce. Un FoxForge así corre entero aunque se le pida
  `"hosted"`, y pone su propio pad. Por eso FoxDock busca antes la marca de ese modo dentro de su
  `FoxForge.APP`. Sin la marca, no lo ejecuta: la barra dice que es demasiado viejo para alojarlo, y el log
  dice cómo usarlo por su cuenta (`DO FoxForge.APP`) o que instales uno más nuevo.
- **Sin FoxForge**, la única barra dice `FoxForge: not installed`.
- **Sin FoxDock, FoxForge funciona como antes.** `foxforge.cmd` o `DO FoxForge.APP` sin parámetro ponen
  su pad y su FoxAgent, como siempre.
- **Mientras FoxDock lo aloja**, un `DO FoxForge.APP` sin parámetro se porta como alojado, para que no
  salgan dos pads. Lo sabe por `_screen.cFoxDockHostsFoxForge`, que vale `"1"` solo mientras este plugin
  aloja un FoxForge. **Con FoxDock en marcha pero sin alojar nada** (encontró uno viejo, por ejemplo), ese
  `DO` pone su pad, como sin FoxDock.

Para el agente hay dos tools, `ide_foxforge_providers` e `ide_foxforge_new_project`:
AGENT-TOOLS_ES.md § 6.

## Sobre este manual

Este texto es la sección sobre `foxforge` del manual de plugins de FoxDock. Las referencias a otras secciones (§) y a AGENT-TOOLS apuntan a los documentos que FoxDock instala en su carpeta `docs`.

## Licencia

MIT. Está en [LICENSE](LICENSE).
