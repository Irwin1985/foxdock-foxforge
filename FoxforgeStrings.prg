*==================================================================
* FoxforgeStrings.prg: las cadenas del plugin foxforge, en inglés,
* español y alemán. Lo ejecuta el host al cargar el plugin (LoadPluginStrings),
* antes de su BuildMenu: una llamada toHost.AddString(<idioma>, <clave>, <texto>)
* por cadena. Las tres listas llevan las mismas claves, en el mismo orden; una que
* falte en español o alemán sale en inglés. {1} a {4}, los valores. \< marca la
* tecla de acceso. Los nombres propios (FoxDock, FoxAgent, VFP, GUID, JSON) no se
* traducen.
*==================================================================

LPARAMETERS toHost

*-- English
toHost.AddString("en", "foxforge.title", "FoxForge")
toHost.AddString("en", "foxforge.notInstalled", "FoxForge: not installed")
toHost.AddString("en", "foxforge.tooOld", "FoxForge {1}: too old to be hosted (see the log)")
toHost.AddString("en", "foxforge.notLoaded", "FoxForge: could not be loaded (see the log)")

*-- Español
toHost.AddString("es", "foxforge.title", "FoxForge")
toHost.AddString("es", "foxforge.notInstalled", "FoxForge: no instalado")
toHost.AddString("es", "foxforge.tooOld", "FoxForge {1}: demasiado viejo para alojarlo (mira el log)")
toHost.AddString("es", "foxforge.notLoaded", "FoxForge: no se pudo cargar (mira el log)")

*-- Deutsch
toHost.AddString("de", "foxforge.title", "FoxForge")
toHost.AddString("de", "foxforge.notInstalled", "FoxForge: nicht installiert")
toHost.AddString("de", "foxforge.tooOld", "FoxForge {1}: zu alt, um gehostet zu werden (siehe das Log)")
toHost.AddString("de", "foxforge.notLoaded", "FoxForge: konnte nicht geladen werden (siehe das Log)")
