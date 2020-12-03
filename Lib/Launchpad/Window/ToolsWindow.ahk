﻿class ToolsWindow extends LaunchpadGuiBase {
    positionAtMouseCursor := true
    nextPos := "xm"

    __New(app, owner := "", windowKey := "") {
        super.__New(app, "Tools", owner, windowKey)
    }

    Controls() {
        super.Controls()
        this.guiObj.BackColor := this.themeObj.GetColor("accentDark")
        this.AddToolButton("&Reload Launchers", "ReloadLaunchers")
        this.AddToolButton("&Clean Launchers", "CleanLaunchers")
        this.AddToolButton("&Validate Launchers", "ValidateLaunchers")
        this.AddToolButton("&Flush Cache", "FlushCache")
        this.AddToolButton("&Update Launchpad", "CheckForUpdates")
        this.AddToolButton("Update &Dependencies", "UpdateDependencies")
        this.AddToolButton("&Open Website", "OpenWebsite")
        this.AddToolButton("Provide &Feedback", "ProvideFeedback")
    }

    AddToolButton(buttonLabel, ctlName) {
        width := (this.windowSettings["contentWidth"] - this.margin) / 2

        buttonSize := this.themeObj.GetButtonSize("big")
        buttonH := (buttonSize.Has("h") and buttonSize["h"] != "auto") ? buttonSize["h"] : 40

        btn := this.guiObj.AddButton("v" . ctlName . " " . this.nextPos . " w" . width . " h" . buttonH, buttonLabel)
        btn.OnEvent("Click", "On" . ctlName)
        this.nextPos := this.nextPos == "xm" ? "x+m yp" : "xm"
    }

    OnReloadLaunchers(btn, info) {
        this.Close()
        this.app.Launchers.LoadLaunchers()
    }

    OnCleanLaunchers(btn, info) {
        this.Close()
        this.app.Builders.CleanLaunchers()
    }

    OnValidateLaunchers(btn, info) {
        this.Close()
        op := ValidateLaunchersOp.new(this.app)
        op.Run()
    }

    OnFlushCache(btn, info) {
        this.Close()
        this.app.Cache.FlushCaches()
    }

    OnUpdateDependencies(btn, info) {
        this.Close()
        this.app.Installers.UpdateDependencies()
    }

    OnClose(guiObj) {
        this.Close()
        super.OnClose(guiObj)
    }

    OnEscape(guiObj) {
        this.Close()
        super.OnEscape(guiObj)
    }

    OnCheckForUpdates(btn, info) {
        this.app.CheckForUpdates()
    }

    OnOpenWebsite(btn, info) {
        this.app.OpenWebsite()
    }

    OnProvideFeedback(btn, info) {
        this.app.ProvideFeedback()
    }
}