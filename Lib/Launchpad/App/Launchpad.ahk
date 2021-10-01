﻿class Launchpad extends AppBase {
    customTrayMenu := true
    detectGames := false

    GetServiceDefinitions(config) {
        services := super.GetServiceDefinitions(config)

        if (!services.Has("BackupManager") || !services["BackupManager"]) {
            services["BackupManager"] := Map(
                "class", "BackupManager",
                "arguments", [AppRef(), this.Config.BackupsFile]
            )
        }

        if (!services.Has("datasource.api") || !services["datasource.api"]) {
            services["datasource.api"] := Map(
                "class", "ApiDataSource",
                "arguments", [AppRef(), ServiceRef("CacheManager"), "api", this.Config.ApiEndpoint]
            )
        }

        if (!services.Has("DataSourceManager") || !services["DataSourceManager"]) {
            services["DataSourceManager"] := Map(
                "class", "DataSourceManager",
                "arguments", [ServiceRef("EventManager")]
            )
        }

        if (!services["DataSourceManager"].Has("calls")) {
            services["DataSourceManager"]["calls"] := []
        }

        services["DataSourceManager"]["calls"].Push(Map(
            "method", "SetItem", 
            "arguments", ["api", ServiceRef("datasource.api"), true]
        ))

        if (!services.Has("builder.ahk_launcher") || !services["builder.ahk_launcher"]) {
            services["builder.ahk_launcher"] := Map(
                "class", "AhkLauncherBuilder",
                "arguments", [AppRef(), ServiceRef("Notifier")]
            )
        }

        if (!services.Has("BuilderManager") || !services["BuilderManager"]) {
            services["BuilderManager"] := Map(
                "class", "BuilderManager",
                "arguments", AppRef(),
            )
        }

        if (!services["BuilderManager"].Has("calls")) {
            services["BuilderManager"]["calls"] := []
        }

        services["BuilderManager"]["calls"].Push(Map(
            "method", "SetItem", 
            "arguments", ["ahk", ServiceRef("builder.ahk_launcher"), true]
        ))

        if (!services.Has("LauncherManager") || !services["LauncherManager"]) {
            services["LauncherManager"] := Map(
                "class", "LauncherManager",
                "arguments", AppRef()
            )
        }

        if (!services.Has("PlatformManager") || !services["PlatformManager"]) {
            services["PlatformManager"] := Map(
                "class", "PlatformManager",
                "arguments", AppRef()
            )
        }

        if (!services.Has("installer.launchpad_update") || !services["installer.launchpad_update"]) {
            services["installer.launchpad_update"] := Map(
                "class", "LaunchpadUpdate",
                "arguments", [this.Version, this.State, ServiceRef("CacheManager"), "file", this.tmpDir]
            )
        }

        if (!services.Has("installer.dependencies") || !services["installer.dependencies"]) {
            services["installer.dependencies"] := Map(
                "class", "DependencyInstaller",
                "arguments", [this.Version, this.State, ServiceRef("CacheManager"), "file", [], this.tmpDir]
            )
        }

        if (!services["InstallerManager"].Has("calls")) {
            services["InstallerManager"]["calls"] := []
        }

        services["InstallerManager"]["calls"].Push(Map(
            "method", "SetItem",
            "arguments", ["LaunchpadUpdate", ServiceRef("installer.launchpad_update")]
        ))

        services["InstallerManager"]["calls"].Push(Map(
            "method", "SetItem",
            "arguments", ["Dependencies", ServiceRef("installer.dependencies")]
        ))

        return services
    }

    GetCaches() {
        caches := super.GetCaches()
        caches["file"] := FileCache(this, CacheState(this, this.Config.CacheDir . "\File.json"), this.Config.CacheDir . "\File")
        caches["api"] := FileCache(this, CacheState(this, this.Config.CacheDir . "\API.json"), this.Config.CacheDir . "\API")
        return caches
    }

    GetDefaultModules(config) {
        modules := super.GetDefaultModules(config)
        modules["Bethesda"] := "Bethesda"
        modules["Blizzard"] := "Blizzard"
        modules["Epic"] := "Epic"
        modules["Origin"] := "Origin"
        modules["Riot"] := "Riot"
        modules["Steam"] := "Steam"
        return modules
    }

    CheckForUpdates(notify := true) {
        updateAvailable := false

        if (this.Version != "{{VERSION}}") {
            dataSource := this.Service("DataSourceManager").GetItem("api")
            releaseInfoStr := dataSource.ReadItem("release-info")

            if (releaseInfoStr) {
                data := JsonData()
                releaseInfo := data.FromString(&releaseInfoStr)

                if (releaseInfo && releaseInfo["data"].Has("version") && releaseInfo["data"]["version"] && this.Service("VersionChecker").VersionIsOutdated(releaseInfo["data"]["version"], this.Version)) {
                    updateAvailable := true
                    this.Service("GuiManager").Dialog("UpdateAvailableWindow", releaseInfo)
                }
            }
        }

        if (!updateAvailable && notify) {
            this.Service("Notifier").Info("You're running the latest version of Launchpad. Shiny!")
        }
    }

    UpdateIncludes() {
        this.RunAhkScript(this.appDir . "\Scripts\UpdateIncludes.ahk")
        this.RestartApp()
    }

    BuildApp() {
        this.RunAhkScript(this.appDir . "\Scripts\Build.ahk")
    }

    RunAhkScript(scriptPath) {
        SplitPath(scriptPath, &scriptDir)
        ahkExe := this.appDir . "\Vendor\AutoHotKey\AutoHotkey" . (A_Is64bitOS ? "64" : "32") . ".exe"

        if (FileExist(ahkExe) && FileExist(scriptPath)) {
            RunWait(ahkExe . " " . scriptPath, scriptDir)
        } else {
            throw AppException("Could not run AHK script")
        }
    }

    SetTrayMenuItems(menuItems) {
        menuItems := super.SetTrayMenuItems(menuItems)

        if (!A_IsCompiled) {
            menuItems.Push("")
            menuItems.Push(Map("label", "Build Launchpad", "name", "BuildApp"))
            menuItems.Push(Map("label", "Update Includes", "name", "UpdateIncludes"))
        }

        return menuItems
    }

    HandleTrayMenuClick(result) {
        result := super.HandleTrayMenuClick(result)

        if (result == "BuildApp") {
            this.BuildApp()
        } else if (result == "UpdateIncludes") {
            this.UpdateIncludes()
        }

        return result
    }

    InitializeApp(config) {
        super.InitializeApp(config)
        this.Service("InstallerManager").SetupInstallers()
        this.Service("InstallerManager").InstallRequirements()
    }

    RunApp(config) {
        if (this.Config.ApiAutoLogin) {
            this.Service("Auth").Login()
        }
        
        super.RunApp(config)
        
        this.Service("PlatformManager").LoadComponents(this.Config.PlatformsFile)
        this.Service("LauncherManager").LoadComponents(this.Config.LauncherFile)
        this.Service("BackupManager").LoadComponents()

        this.OpenApp()

        if (this.detectGames) {
            this.Service("PlatformManager").DetectGames()
        }
    }

    InitialSetup(config) {
        super.InitialSetup(config)
        result := this.Service("GuiManager").Form("SetupWindow")

        if (result == "Exit") {
            this.ExitApp()
        } else if (result == "Detect") {
            this.detectGames := true
        }
    }

    UpdateStatusIndicators() {
        if (this.Service("GuiManager").WindowExists("MainWindow")) {
            this.Service("GuiManager").GetWindow("MainWindow").UpdateStatusIndicator()
        }
    }

    ExitApp() {
        if (this.Config.CleanLaunchersOnExit) {
            this.Service("BuilderManager").CleanLaunchers()
        }

        if (this.Config.FlushCacheOnExit) {
            this.Service("CacheManager").FlushCaches(false)
        }

        super.ExitApp()
    }

    OpenWebsite() {
        Run("https://launchpad.games")
    }

    ProvideFeedback() {
        this.Service("GuiManager").Dialog("FeedbackWindow")
    }

    RestartApp() {
        if (this.Service("GuiManager")) {
            window := this.Service("GuiManager").GetWindow("MainWindow")

            if (window) {
                this.Service("GuiManager").StoreWindowState(window)
            }
        }

        super.RestartApp()
    }
}
