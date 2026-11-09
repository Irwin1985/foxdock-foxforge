*==================================================================
* FoxforgePlugin.prg: el plugin «foxforge» de FoxDock.
*
* FoxForge, el taller de proyectos, entra en FoxDock como plugin. Por su
* cuenta pone su propio pad («FoxForge») y conecta FoxAgent; alojado, de
* las dos cosas se encarga FoxDock:
*
*   - FoxForge se carga con DO FoxForge.APP WITH "hosted" (ffmain.prg): hace
*     todo lo de siempre (Shell, idioma, proveedores, _screen.oFoxForge)
*     menos su pad, su FoxAgent y su ON SHUTDOWN.
*   - Sus barras van en el submenú «FoxForge» de FoxDock. Las pone el propio
*     FoxForge (MenuBuilder.BuildInto) en el popup que le da FoxDock
*     (FillWith): «Current project» lo rellena el proveedor del
*     proyecto abierto con sus DEFINE BAR, y eso no cabe en barras que sean
*     métodos de un plugin.
*   - OnProjectOpen / OnProjectClose rehacen el menú, porque «Current project»
*     depende del .pjx abierto.
*
* Dónde está FoxForge: la opción foxforge.folder; si no, el registro
* (HKLM\SOFTWARE\irwinrodriguez.dev\FoxForge\InstallDir, el de su
* instalador); si no, C:\Program Files (x86)\FoxForge; si no, ..\FoxForge\
* desde la raíz de este repo (desarrollo). Sin FoxForge, el plugin carga igual
* y su submenú tiene una sola barra, apagada: «FoxForge: not installed». Las
* pruebas ponen FOXDOCK_FOXFORGE_FOLDER (detrás de la opción) para no cargar el
* FoxForge de la máquina en las que no son de foxforge.
*
* Un FoxForge que no conoce el modo alojado (0.4.7 y anteriores) NO se
* arranca: con "hosted" corre entero, pone su pad y solo después VFP da el
* error 1238. Se mira antes si su .APP lleva el literal
* FOXFORGE-HOSTED-MODE-1 de ffmain.prg; si no, la barra dice que es
* demasiado viejo para alojarlo, y el log cómo usarlo por su cuenta.
*
* nOrder 980: detrás de history (970), para no cambiar el orden de los menús
* que van antes.
*==================================================================

#DEFINE FF_HOSTED_MARK "FOXFORGE-HOSTED-MODE-1"

DEFINE CLASS FoxforgePlugin AS PluginBase
	cId = "foxforge"
	cTitle = "FoxForge"
	nOrder = 970
	cVersion = "0.1.1"
	lWantsIdle = .T.

	cFolder = ""
	cFolderFrom = ""
	cFoxForgeVersion = ""
	lLoaded = .F.
	lTooOld = .F.
	cLastError = ""

	*-- Se busca y se carga al montar: cHome lo pone el host después de Init.
	PROCEDURE OnHostReady
		LOCAL lcApp, loErr
		This.FindFolder()
		This.lLoaded = .F.
		This.lTooOld = .F.
		This.cLastError = ""
		This.SetHostsFlag("")
		IF EMPTY(This.cFolder)
			This.oHost.Log("foxforge: not installed (" + This.cFolderFrom + "); its menu says so")
			RETURN .T.
		ENDIF
		lcApp = This.cFolder + "FoxForge.APP"
		This.cFoxForgeVersion = IIF(FILE(This.cFolder + "VERSION"), ALLTRIM(CHRTRAN(FILETOSTR(This.cFolder + "VERSION"), CHR(13) + CHR(10), "")), "?")
		*-- Un FoxForge sin el modo alojado (0.4.7 y anteriores) corre entero con
		*-- "hosted", pone su pad y solo después da el error 1238: no se
		*-- arranca. El modo lo anuncia un literal de ffmain.prg dentro del .APP.
		IF !(FF_HOSTED_MARK $ FILETOSTR(lcApp))
			This.lTooOld = .T.
			This.oHost.LogWarn("foxforge: FoxForge " + This.cFoxForgeVersion + " in " + This.cFolder + " cannot be hosted (it is older " + ;
				"than FoxForge's hosted mode), so FoxDock does not run it: it would put its own menu pad. Run it on its own " + ;
				"(DO FoxForge.APP) or install a newer FoxForge.")
			This.oHost.RefreshMenu()
			RETURN .T.
		ENDIF
		*-- La red de ffmain.prg mira esto: solo con FoxDock alojando.
		This.SetHostsFlag("1")
		TRY
			*-- En una variable: DO (método()) da el error 31.
			DO (lcApp) WITH "hosted"
			This.lLoaded = TYPE("_screen.oFoxForge") == "O" AND !ISNULL(_screen.oFoxForge)
			IF !This.lLoaded
				This.cLastError = "FoxForge.APP ran but _screen.oFoxForge is not an object"
			ENDIF
		CATCH TO loErr
			This.cLastError = TRANSFORM(loErr.ErrorNo) + " " + loErr.Message
		ENDTRY
		IF This.lLoaded
			This.oHost.Log("foxforge: loaded " + lcApp + " (hosted; found by " + This.cFolderFrom + "), " + ;
				TRANSFORM(This.ProviderCount()) + " provider(s)")
			This.ReRegisterAgentTools()
		ELSE
			This.SetHostsFlag("")
			This.oHost.LogWarn("foxforge: " + lcApp + " could not be loaded: " + This.cLastError)
		ENDIF
		This.oHost.RefreshMenu()
		RETURN .T.
	ENDPROC

	*-- _screen.cFoxDockHostsFoxForge: "1" mientras este plugin aloja un FoxForge.
	*-- Es la red de ffmain.prg (un DO FoxForge.APP sin parámetro, con FoxDock
	*-- alojando, se comporta como alojado). Texto: sobrevive a CLEAR ALL, como
	*-- el FoxForge que sigue cargado.
	PROCEDURE SetHostsFlag
		LPARAMETERS tcValue
		IF !PEMSTATUS(_screen, "cFoxDockHostsFoxForge", 5)
			_screen.AddProperty("cFoxDockHostsFoxForge", "")
		ENDIF
		_screen.cFoxDockHostsFoxForge = tcValue
	ENDPROC

	*-- Al cerrar el IDE y al desmontar FoxDock («unload» llama a Shutdown).
	PROCEDURE OnShutdown
		This.SetHostsFlag("")
		RETURN .T.
	ENDPROC

	*-- foxagent (nOrder 960) conecta y registra las tools de todos en SU
	*-- OnHostReady, antes de que este (980) cargue FoxForge, y las nuestras aún
	*-- no estaban (el agente recibiría «tool not found»). Se le pide
	*-- que registre otra vez (RegisterAll empieza por ClearTools).
	PROCEDURE ReRegisterAgentTools
		LOCAL loA, loErr
		loA = This.oHost.PluginById("foxagent")
		IF VARTYPE(loA) # "O" OR ISNULL(loA) OR !loA.lConnected
			RETURN
		ENDIF
		TRY
			loA.RegisterAll()
			This.oHost.Log("foxforge: FoxAgent tools registered again with FoxForge's: " + TRANSFORM(loA.nTools) + " tool(s)")
		CATCH TO loErr
			This.oHost.LogWarn("foxforge: registering the FoxAgent tools again failed: " + loErr.Message)
		ENDTRY
	ENDPROC

	PROCEDURE FindFolder
		LOCAL lcDir, loShell, loErr
		This.cFolder = ""
		lcDir = TRANSFORM(This.oHost.Options.Get(This.cId, "folder", ""))
		This.cFolderFrom = "option foxforge.folder"
		*-- Las pruebas ponen FOXDOCK_FOXFORGE_FOLDER para que los tests
		*-- que no son de foxforge no carguen el FoxForge de la máquina.
		IF EMPTY(lcDir) AND !EMPTY(GETENV("FOXDOCK_FOXFORGE_FOLDER"))
			lcDir = GETENV("FOXDOCK_FOXFORGE_FOLDER")
			This.cFolderFrom = "FOXDOCK_FOXFORGE_FOLDER"
		ENDIF
		IF !EMPTY(lcDir)
			*-- Si la opción está, manda aunque no exista (las pruebas la inventan).
			This.cFolder = IIF(FILE(ADDBS(lcDir) + "FoxForge.APP"), ADDBS(lcDir), "")
			RETURN
		ENDIF
		TRY
			loShell = CREATEOBJECT("WScript.Shell")
			lcDir = loShell.RegRead("HKLM\SOFTWARE\irwinrodriguez.dev\FoxForge\InstallDir")
		CATCH TO loErr
			lcDir = ""
		ENDTRY
		IF !EMPTY(lcDir) AND FILE(ADDBS(lcDir) + "FoxForge.APP")
			This.cFolderFrom = "the registry (HKLM\SOFTWARE\irwinrodriguez.dev\FoxForge\InstallDir)"
			This.cFolder = ADDBS(lcDir)
			RETURN
		ENDIF
		lcDir = ADDBS(GETENV("ProgramFiles(x86)")) + "FoxForge\"
		IF FILE(lcDir + "FoxForge.APP")
			This.cFolderFrom = "Program Files (x86)"
			This.cFolder = lcDir
			RETURN
		ENDIF
		*-- Desarrollo: ..\FoxForge\ junto a la raíz de este repo
		*-- (cHome es <repo>\plugins\foxforge\).
		lcDir = ADDBS(JUSTPATH(JUSTPATH(JUSTPATH(JUSTPATH(This.cHome))))) + "FoxForge\"
		IF !EMPTY(This.cHome) AND FILE(lcDir + "FoxForge.APP")
			This.cFolderFrom = "the development tree (" + lcDir + ")"
			This.cFolder = lcDir
			RETURN
		ENDIF
		This.cFolderFrom = "not in the option, the registry, Program Files (x86) nor the development tree"
	ENDPROC

	PROCEDURE ProviderCount
		IF !This.lLoaded
			RETURN 0
		ENDIF
		RETURN _screen.oFoxForge.oProviders.Count()
	ENDPROC

	*-- El submenú es de FoxForge entero (FillWith).
	PROCEDURE BuildMenu
		LPARAMETERS toMenu
		*-- El título y la barra de «no está», en el idioma de
		*-- FoxDock (FoxforgeStrings.prg). FoxForge alojado lleva su propio idioma.
		This.cTitle = This.oHost.Translate("foxforge.title")
		toMenu.FillWith("FillMenu")
	ENDPROC

	PROCEDURE FillMenu
		LPARAMETERS tcPopup
		LOCAL lcCmd
		IF !This.lLoaded
			lcCmd = "DEFINE BAR 1 OF " + tcPopup + " PROMPT [" + ;
				CHRTRAN(ICASE(EMPTY(This.cFolder), This.oHost.Translate("foxforge.notInstalled"), ;
					This.lTooOld, This.oHost.Translate("foxforge.tooOld", This.cFoxForgeVersion), ;
					This.oHost.Translate("foxforge.notLoaded")), "[]", "()") + ;
				"] SKIP FOR .T."
			&lcCmd
			RETURN
		ENDIF
		*-- Sin la barra de FoxAgent: aquí FoxAgent lo conecta FoxDock.
		_screen.oFoxForge.oMenu.BuildInto(tcPopup, .F.)
	ENDPROC

	*-- «Current project» depende del .pjx abierto.
	PROCEDURE OnProjectOpen
		LPARAMETERS toProject
		IF This.lLoaded
			This.oHost.RefreshMenu()
		ENDIF
		RETURN .T.
	ENDPROC

	PROCEDURE OnProjectClose
		LPARAMETERS tcName
		IF This.lLoaded
			This.oHost.RefreshMenu()
		ENDIF
		RETURN .T.
	ENDPROC

	*-- Las tools del agente (FoxforgeTools.prg; heredan de IdeTool, así que
	*-- solo con IdeTools.prg en SET PROCEDURE, como las de history).
	PROCEDURE GetAgentTools
		LPARAMETERS toTools
		IF !This.lLoaded OR !("\IDETOOLS." $ UPPER(SET("PROCEDURE")))
			RETURN 0
		ENDIF
		This.EnsureProcedures()
		toTools.Add(CREATEOBJECT("IdeFoxforgeProvidersTool"))
		toTools.Add(CREATEOBJECT("IdeFoxforgeNewProjectTool"))
		RETURN 2
	ENDPROC

	PROCEDURE OnIdle
		This.EnsureProcedures()
	ENDPROC

	PROCEDURE EnsureProcedures
		LOCAL lcTools, loErr
		lcTools = This.CodeFile("FoxforgeTools.prg")
		IF !EMPTY(This.cHome) AND !("\FOXFORGETOOLS." $ UPPER(SET("PROCEDURE"))) AND FILE(lcTools)
			TRY
				SET PROCEDURE TO (lcTools) ADDITIVE
			CATCH TO loErr
				This.oHost.LogWarn("foxforge: " + lcTools + " not loaded: " + loErr.Message)
			ENDTRY
		ENDIF
	ENDPROC
ENDDEFINE
