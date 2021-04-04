﻿/**
    This GUI edits a GameLauncher object.

    Modes:
      - "config" - Launcher configuration is being edited
      - "build" - Launcher is being built and requires information
*/

class EntityEditorBase extends FormGuiBase {
    entityObj := ""
    mode := "config" ; Options: config, build
    missingFields := Map()
    dataSource := ""
 
    __New(app, themeObj, windowKey, entityObj, title, mode := "config", owner := "", parent := "") {
        InvalidParameterException.CheckTypes("LauncherEditor", "entityObj", entityObj, "EntityBase", "mode", mode, "")
        this.entityObj := entityObj
        this.mode := mode
        super.__New(app, themeObj, windowKey, title, this.GetTextDefinition(), owner, parent, this.GetButtonsDefinition())
    }

    GetTextDefinition() {
        text := ""

        if (this.mode == "config") {
            text := "The details entered here will be saved to your Launchers file and used for all future builds."
        } else if (this.mode == "build") {
            text := "The details entered here will be used for this build only."
        }

        return text
    }

    GetButtonsDefinition() {
        buttonDefs := ""

        if (this.mode == "config") {
            buttonDefs := "*&Save|&Cancel"
        } else if (this.mode == "build") {
            buttonDefs := "*&Continue|&Skip"
        }

        return buttonDefs
    }

    GetTitle(title) {
        return super.GetTitle(this.entityObj.Key . " - " . title)
    }

    DefaultCheckbox(fieldKey, entity := "", addPrefix := false, includePrefixInCtlName := false) {
        if (entity == "") {
            entity := this.entityObj
        }

        return super.DefaultCheckbox(fieldKey, entity, addPrefix, includePrefixInCtlName)
    }

    Controls() {
        super.Controls()
    }

    AddEntityCtl(heading, fieldName, showDefaultCheckbox, params*) {
        return this.Add("EntityControl", "", heading, this.entityObj, fieldName, showDefaultCheckbox, params*)
    }

    AddTextBlock(field, settingName, showDefaultCheckbox := false, helpText := "", addPrefix := false, rows := 1, replaceWithNewline := "", entityObj := "") {
        if (entityObj == "") {
            entityObj := this.entityObj
        }
        
        this.AddHeading(settingName)
        checkW := 0
        disabledText := ""

        prefixedName := field
        if (addPrefix) {
            prefixedName := entityObj.configPrefix . field
        }

        if (showDefaultCheckbox) {
            ctl := this.DefaultCheckbox(field, entityObj, addPrefix)
            ctl.GetPos(,,checkW)
            checkW := checkW + this.margin
            disabledText := entityObj.UnmergedConfig.Has(prefixedName) ? "" : " Disabled"
        }
        
        fieldW := this.windowSettings["contentWidth"] - checkW
        pos := showDefaultCheckbox ? "x+m yp" : "xs y+m"
        val := entityObj.GetConfigValue(field, addPrefix)

        if (replaceWithNewline) {
            val := StrReplace(val, replaceWithNewline, "`n")
        }

        ctl := this.guiObj.AddEdit("v" . field . " " . pos . " w" . fieldW . disabledText . " r" . rows . " c" . this.themeObj.GetColor("editText"), val)
        ctl.OnEvent("Change", "On" . field . "Change")

        if (helpText) {
            ctl.ToolTip := helpText
        }

        return ctl
    }

    AddNumberBlock(field, settingName, showDefaultCheckbox := false, helpText := "", addPrefix := false) {
        ctl := this.AddTextBlock(field, settingName, showDefaultCheckbox, helpText, addPrefix)
        ctl.Opt("Number")
        return ctl
    }

    AddCheckBoxBlock(field, settingName, showDefaultCheckbox := false, helpText := "", addPrefix := false, entityObj := "") {
        if (entityObj == "") {
            entityObj := this.entityObj
        }

        checkW := 0
        disabledText := ""

        prefixedName := field
        if (addPrefix) {
            prefixedName := entityObj.configPrefix . field
        }

        if (showDefaultCheckbox) {
            ctl := this.DefaultCheckbox(field, entityObj, addPrefix)
            ctl.GetPos(,,checkW)
            checkW := checkW + this.margin
            disabledText := entityObj.UnmergedConfig.Has(prefixedName) ? "" : " Disabled"
        }

        checked := !!(entityObj.GetConfigValue(field, addPrefix))

        fieldW := this.windowSettings["contentWidth"] - checkW
        pos := showDefaultCheckbox ? "x+m yp" : "xs y+m"
        pos := pos . " h25" . disabledText
        ctl := this.AddCheckBox(settingName, field, checked, false, "On" . field . "Change", false, pos)

        if (helpText) {
            ctl.ToolTip := helpText
        }

        return ctl
    }

    Create() {
        super.Create()
        this.dataSource := this.app.DataSources.GetItem("api")
    }

    SetDefaultValue(fieldKey, useDefault := true, addPrefix := false, emptyDisplay := "", entityObj := "") {
        if (entityObj == "") {
            entityObj := this.entityObj
        }

        prefixedName := fieldKey
        if (addPrefix) {
            prefixedName := entityObj.configPrefix . prefixedName
        }

        if (useDefault) {
            entityObj.RevertToDefault(prefixedName)
            this.guiObj[fieldKey].Value := entityObj.Config[prefixedName] != "" ? entityObj.Config[prefixedName] : emptyDisplay
        } else {
            entityObj.UnmergedConfig[prefixedName] := entityObj.Config.Has(prefixedName) ? entityObj.Config[prefixedName] : ""
        }

        if (this.guiObj[fieldKey].Type != "Text") {
            this.guiObj[fieldKey].Enabled := !useDefault
        }
        
    }

    SetDefaultSelectValue(fieldKey, allItems, useDefault := true, addPrefix := false) {
        prefixedName := fieldKey
        if (addPrefix) {
            prefixedName := this.entityObj.configPrefix . prefixedName
        }

        if (useDefault) {
            this.entityObj.RevertToDefault(prefixedName)
            newVal := this.entityObj.Config[prefixedName]            
            index := 0


            for idx, val in allItems {
                if val == newVal {
                    index := idx
                }
            }

            if (index > 0) {
                this.guiObj[fieldKey].Value := index
            }
        } else {
            this.entityObj.UnmergedConfig[prefixedName] := this.entityObj.Config.Has(prefixedName) ? this.entityObj.Config[prefixedName] : ""
        }

        this.guiObj[fieldKey].Enabled := !useDefault
    }
}
