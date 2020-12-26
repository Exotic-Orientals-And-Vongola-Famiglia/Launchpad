﻿/**
    This GUI edits a GameLauncher object.

    Modes:
      - "config" - Launcher configuration is being edited
      - "build" - Launcher is being built and requires information
*/

class EntityEditorBase extends LaunchpadFormGuiBase {
    entityObj := ""
    mode := "config" ; Options: config, build
    missingFields := Map()
    dataSource := ""
 
    __New(app, entityObj, title, mode := "config", windowKey := "", owner := "", parent := "") {
        InvalidParameterException.CheckTypes("LauncherEditor", "entityObj", entityObj, "EntityBase", "mode", mode, "")
        this.entityObj := entityObj
        this.mode := mode

        if (windowKey == "") {
            windowKey := "EntityEditor"
        }

        if (owner == "") {
            owner := "MainWindow"
        }

        super.__New(app, title, this.GetTextDefinition(), windowKey, owner, parent, this.GetButtonsDefinition())
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

    DefaultCheckbox(fieldKey, entity := "") {
        if (entity == "") {
            entity := this.entityObj
        }

        checkedText := !entity.UnmergedConfig.Has(fieldKey) ? " Checked" : ""
        ctl := this.guiObj.AddCheckBox("vDefault" . fieldKey . " xs h25 y+m" . checkedText, "Default")
        ctl.OnEvent("Click", "OnDefault" . fieldKey)
        return ctl
    }

    Controls() {
        super.Controls()
    }

    AddComboBox(heading, field, currentValue, allItems, helpText := "") {
        this.AddHeading(heading)
        ctl := this.guiObj.AddComboBox("v" . field . " xs y+m w" . this.windowSettings["contentWidth"], allItems)
        ctl.Text := currentValue
        ctl.OnEvent("Change", "On" . field . "Change")

        if (helpText) {
            this.AddHelpText(helpText)
        }
    }

    AddEntityTypeSelect(heading, field, currentValue, allItems, buttonName := "", helpText := "") {
        ctl := this.AddSelect(heading, field, currentValue,  allItems)
        buttonW := 150

        if (buttonName) {
            this.AddButton("v" . buttonName . " x+m yp w" . buttonW . " h25", "Manage", "On" . buttonName)
        }

        if (helpText) {
            this.AddHelpText(helpText)
        }

        return ctl
    }

    AddSelect(heading, field, currentValue, allItems, helpText := "") {
        this.AddHeading(heading)
        buttonW := 150
        ;ctl := this.DefaultCheckbox("GameType", this.entityObj.ManagedLauncher.ManagedGame)
        ;ctl.GetPos(,,checkW)
        fieldW := this.windowSettings["contentWidth"] - buttonW - this.margin
        chosen := this.GetItemIndex(allItems, currentValue)
        ctl := this.guiObj.AddDDL("v" . field . " xs y+m Choose" . chosen . " w" . fieldW, allItems)
        ctl.OnEvent("Change", "On" . field . "Change")

        if (helpText) {
            this.AddHelpText(helpText)
        }
    }

    AddTextBlock(field, settingName, showDefaultCheckbox := false, helpText := "") {
        this.AddHeading(settingName)
        checkW := 0
        disabledText := ""

        if (showDefaultCheckbox) {
            ctl := this.DefaultCheckbox(field)
            ctl.GetPos(,,checkW)
            checkW := checkW + this.margin
            disabledText := this.entityObj.UnmergedConfig.Has(field) ? "" : " Disabled"
        }
        
        fieldW := this.windowSettings["contentWidth"] - checkW
        ctl := this.guiObj.AddEdit("v" . field . " x+m yp w" . fieldW . disabledText, this.entityObj.Config[field])
        ctl.OnEvent("Change", "On" . field . "Change")

        if (helpText) {
            this.AddHelpText(helpTExt)
        }

        return ctl
    }

    AddLocationBlock(heading, settingName, extraButton := "", showOpen := true, showDefaultCheckbox := false) {
        this.AddHeading(heading)
        location := this.entityObj.HasConfigValue(settingName, false, false) ? this.entityObj.GetConfigValue(settingName, false) : "Not set"
        checkW := 0
        disabledText := ""

        if (showDefaultCheckbox) {
            ctl := this.DefaultCheckbox(settingName)
            ctl.GetPos(,,checkW)
            checkW := checkW + this.margin
            disabledText := this.entityObj.UnmergedConfig.Has(settingName) ? "" : " Hidden"
        }

        fieldW := this.windowSettings["contentWidth"] - checkW
        locationPos := checkW ? "x+m yp" : "xs y+m"
        this.AddLocationText(location, settingName, locationPos)

        buttonSize := this.themeObj.GetButtonSize("s", true)
        buttonDims := ""
        
        if (buttonSize.Has("h") and buttonSize["h"] != "auto") {
            buttonDims .= " h" . buttonSize["h"]
        }

        if (buttonSize.Has("w") and buttonSize["w"] != "auto") {
            buttonDims .= " w" . buttonSize["w"]
        }

        btn := this.AddButton("xs y+m" . buttonDims . " vChange" . settingName . disabledText, "Change")

        if (showOpen) {
            btn := this.AddButton("x+m yp" . buttonDims . " vOpen" . settingName . disabledText, "Open")
        }

        if (extraButton != "") {
            btn := this.AddButton("x+m yp" . buttonDims . " v" . extraButton . settingName . disabledText, extraButton)
        }
    }

    AddLocationText(locationText, ctlName, position := "xs y+m") {
        ;this.guiObj.SetFont("Bold")
        this.guiObj.AddText("v" . ctlName . " " . position . " w" . this.windowSettings["contentWidth"] . " +0x200 c" . this.themeObj.GetColor("accentDark"), locationText)
        ;this.guiObj.SetFont()
    }

    Create() {
        super.Create()
        this.dataSource := this.app.DataSources.GetItem("api")
    }

    SetDefaultValue(fieldKey, useDefault := true) {
        if (useDefault) {
            this.entityObj.RevertToDefault(fieldKey)
            this.guiObj[fieldKey].Value := this.entityObj.Config[fieldKey]
        } else {
            this.entityObj.UnmergedConfig[fieldKey] := this.entityObj.Config.Has(fieldKey) ? this.entityObj.Config[fieldKey] : ""
        }

        this.guiObj[fieldKey].Enabled := !useDefault
    }
}
