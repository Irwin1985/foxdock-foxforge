*==================================================================
* FoxforgeTools.prg: las tools del plugin «foxforge» para el agente.
*
* Heredan de IdeTool (plugins\foxagent\IdeTools.prg): el host, J(), Done(),
* los parámetros y el rol que pide cada una.
*
*   ide_foxforge_providers     los tipos de proyecto que hay (lee)
*   ide_foxforge_new_project   un proyecto nuevo (actúa: rol 10)
*
* Crear sin diálogo solo donde FoxForge tiene ese camino: el proveedor cli,
* con CliProvider.Create(nombre, carpeta), que es el que usa su selftest. Los
* demás (web, service, foxmenu) crean desde su formulario (NewProject); la
* tool lo abre JUSTO DESPUÉS de contestar, como ide_menu_command, y lo dice:
* no se inventa un camino sin diálogo que FoxForge no tenga.
*==================================================================

#DEFINE FF_NO_HOST "FoxDock is not mounted (after CLEAR ALL it sleeps until a FoxDock menu bar or key is pressed)"
#DEFINE FF_NOT_LOADED "FoxForge is not loaded in this IDE (FoxDock > FoxForge says why)."

DEFINE CLASS IdeFoxforgeTool AS IdeTool
	PROCEDURE Loaded
		LOCAL loP
		IF ISNULL(THIS.Host())
			RETURN .F.
		ENDIF
		loP = _screen.oFoxForge
		RETURN TYPE("_screen.oFoxForge") == "O" AND !ISNULL(loP)
	ENDPROC
ENDDEFINE


DEFINE CLASS IdeFoxforgeProvidersTool AS IdeFoxforgeTool
	ToolName = "ide_foxforge_providers"
	ToolDescription = "The kinds of project FoxForge can create in this IDE (its providers): each with its id (for " + ;
		"ide_foxforge_new_project), its name, whether it has a guide installed, and whether it can create without a " + ;
		"dialog (createsWithoutDialog: only cli; the others open their own form). Reads only."

	FUNCTION Run(toContext)
		LOCAL loJ, loD, loList, loReg, loProv, loV, lnI
		IF ISNULL(THIS.Host())
			RETURN THIS.Err(FF_NO_HOST)
		ENDIF
		IF !THIS.Loaded()
			RETURN THIS.Err(FF_NOT_LOADED)
		ENDIF
		loJ = THIS.J()
		loReg = _screen.oFoxForge.oProviders
		loList = loJ.MakeArray()
		FOR lnI = 1 TO loReg.Count()
			loProv = loReg.Item(lnI)
			loV = loJ.MakeObject()
			loJ.Put(loV, "id", loProv.cId)
			*-- Sin el \< de la tecla rápida: eso es del menú, no del nombre.
			loJ.Put(loV, "name", STRTRAN(loProv.GetDisplayName(), "\<", ""))
			loJ.Put(loV, "hasGuide", !EMPTY(loProv.GetGuidePath()))
			loJ.Put(loV, "createsWithoutDialog", loProv.cId == "cli")
			loList.Add(loV)
		ENDFOR
		loD = loJ.MakeObject()
		loJ.Put(loD, "foxforgeVersion", _screen.oFoxForge.cVersion)
		loJ.Put(loD, "count", loList.Count)
		loJ.Put(loD, "providers", loList)
		RETURN THIS.Done(loD)
	ENDFUNC
ENDDEFINE


DEFINE CLASS IdeFoxforgeNewProjectTool AS IdeFoxforgeTool
	ToolName = "ide_foxforge_new_project"
	lActsOnIde = .T.
	ToolDescription = "Creates a new project with one of FoxForge's providers (ide_foxforge_providers lists them). With " + ;
		"provider 'cli', 'folder' and 'name', it creates it without any dialog, in <folder>\<name>, returns that " + ;
		"folder and leaves the project open in the Project Manager, as FoxForge's menu does ('opened'; VFP then moves its " + ;
		"default folder there); it refuses if that folder already exists. Any other provider creates from its own form: the tool opens " + ;
		"it right AFTER this call returns (deferred: true) and does not fill it; read and drive it with FoxAgent's form tools."

	FUNCTION DefineParameters()
		THIS.AddParam("provider", "string", "The provider id, as ide_foxforge_providers gives it (cli, web...).", .T.)
		THIS.AddParam("folder", "string", "For cli: the folder where the project folder is created.", .F.)
		THIS.AddParam("name", "string", "For cli: the project name (its folder and its .pjx).", .F.)
	ENDFUNC

	FUNCTION Run(toContext)
		LOCAL loJ, loD, loProv, lcId, lcFolder, lcName, lcDir, loErr, lcFail, lcCmd
		IF ISNULL(THIS.Host())
			RETURN THIS.Err(FF_NO_HOST)
		ENDIF
		IF !THIS.Loaded()
			RETURN THIS.Err(FF_NOT_LOADED)
		ENDIF
		lcId = LOWER(THIS.PText(toContext, "provider"))
		loProv = _screen.oFoxForge.oProviders.Find(lcId)
		IF ISNULL(loProv)
			RETURN THIS.Err("FoxForge has no provider '" + lcId + "'. ide_foxforge_providers lists the ones there are.")
		ENDIF
		loJ = THIS.J()
		loD = loJ.MakeObject()
		loJ.Put(loD, "provider", lcId)
		IF lcId == "cli"
			lcFolder = THIS.PText(toContext, "folder")
			lcName = THIS.PText(toContext, "name")
			IF EMPTY(lcFolder) OR EMPTY(lcName)
				RETURN THIS.Err("For provider 'cli' both 'folder' and 'name' are required: the project goes in <folder>\<name>.")
			ENDIF
			IF !DIRECTORY(lcFolder, 1)
				RETURN THIS.Err("The folder " + lcFolder + " does not exist.")
			ENDIF
			IF !loProv.IsValidName(lcName)
				RETURN THIS.Err("'" + lcName + "' is not a valid name for a FoxForge CLI project.")
			ENDIF
			lcDir = ADDBS(ADDBS(lcFolder) + lcName)
			IF DIRECTORY(lcDir, 1)
				*-- FoxForge pregunta con un MESSAGEBOX si sigue; la tool no.
				RETURN THIS.Err(lcDir + " already exists: nothing was created. Choose another name or folder.")
			ENDIF
			lcFail = ""
			TRY
				lcDir = loProv.Create(lcName, lcFolder, .F.)
			CATCH TO loErr
				lcFail = TRANSFORM(loErr.ErrorNo) + " " + loErr.Message
			ENDTRY
			IF !EMPTY(lcFail)
				RETURN THIS.Err("FoxForge could not create the project: " + lcFail)
			ENDIF
			loJ.Put(loD, "created", lcDir)
			*-- Como desde su menú, FoxForge deja el proyecto abierto en el Project
			*-- Manager (y VFP lleva su directorio a la carpeta del proyecto).
			loJ.Put(loD, "opened", IIF(_VFP.Projects.Count > 0, _VFP.ActiveProject.Name, .NULL.))
			loJ.Put(loD, "deferred", .F.)
			_screen.oFoxDock.AgentDid("created the FoxForge CLI project " + lcName + " in " + lcDir)
			RETURN THIS.Done(loD)
		ENDIF
		*-- Los demás: su formulario, en diferido (IdeLaterTimer, IdeTools.prg).
		lcCmd = "_screen.oFoxForge.NewProject([" + lcId + "])"
		IF !PEMSTATUS(_screen, "tmrFoxDockLater", 5)
			_screen.AddObject("tmrFoxDockLater", "IdeLaterTimer")
		ENDIF
		_screen.tmrFoxDockLater.cCommand = lcCmd
		_screen.tmrFoxDockLater.Interval = 150
		_screen.tmrFoxDockLater.Enabled = .T.
		loJ.Put(loD, "created", .NULL.)
		loJ.Put(loD, "deferred", .T.)
		loJ.Put(loD, "note", "The " + lcId + " provider creates from its own form, which opens right after this answer. " + ;
			"It is not filled in: read and drive it with FoxAgent's list_open_forms and the form tools.")
		_screen.oFoxDock.AgentDid("opened FoxForge's new " + lcId + " project form")
		RETURN THIS.Done(loD)
	ENDFUNC
ENDDEFINE
