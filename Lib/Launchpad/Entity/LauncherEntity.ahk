class LauncherEntity extends AppEntityBase {
    dataSourcePath := "games"
    configPrefix := "Launcher"
    additionalManagedLauncherDefaults := Map()

    /**
    * Entity references
    */

    ManagedLauncher {
        get => this.children["ManagedLauncher"]
        set => this.children["ManagedLauncher"] := value
    }

    /**
    * CONFIGURATION PROPERTIES
    */

    ; The game's platform
    Platform {
        get => this.GetConfigValue("Platform", false)
        set => this.SetConfigValue("Platform", value, false)
    }

    ; The directory where the entity build artifact(s) will be saved.
    DestinationDir {
        get => this.GetConfigValue("DestinationDir", false)
        set => this.SetConfigValue("DestinationDir", value, false)
    }

    ; The icon file that the launcher will use. This can be one of several types of values:
    ; - The filename of an existing icon in the AssetsDir
    ; - The path of another icon file on the system, which will be copied to the AssetsDir if it doesn't already exist
    ; - The path of an .exe file on the system where the icon will be extracted from and saved to the assets directory if it doesn't already exist
    ; - "" (empty string) - Auto detection. See below.
    ; 
    ; Auto detection rules if IconSrc is not set:
    ; 1. Look for [Key].ico in the assets directory
    ; 2. If GameExe is an absolute path, use GameExe's path as the IconSrc
    ; 3. If GameExe is a filename, search for that filename in GameDirs and use its path as the IconSrc if found
    ; 3. Prompt for an icon during validation if the path is still not set
    IconSrc {
        get => this.GetConfigValue("IconSrc", false)
        set => this.SetConfigValue("IconSrc", value, false)
    }

    ; The name of the theme to render GUI windows in the launcher with.
    ThemeName {
        get => this.GetConfigValue("ThemeName", false)
        set => this.SetConfigValue("ThemeName", value, false)
    }

    ThemesDir {
        get => this.GetConfigValue("ThemesDir", false)
        set => this.SetConfigValue("ThemesDir", value, false)
    }

    ResourcesDir {
        get => this.GetConfigValue("ResourcesDir", false)
        set => this.SetConfigValue("ResourcesDir", value, false)
    }

    ShowProgress {
        get => this.GetConfigValue("ShowProgress", false)
        set => this.SetConfigValue("ShowProgress", value, false)
    }

    RunBefore {
        get => this.GetConfigValue("RunBefore", false)
        set => this.SetConfigValue("RunBefore", value, false)
    }

    CloseBefore {
        get => this.GetConfigValue("CloseBefore", false)
        set => this.SetConfigValue("CloseBefore", value, false)
    }

    RunAfter {
        get => this.GetConfigValue("RunAfter", false)
        set => this.SetConfigValue("RunAfter", value, false)
    }

    CloseAfter {
        get => this.GetConfigValue("CloseAfter", false)
        set => this.SetConfigValue("CloseAfter", value, false)
    }

    LogPath {
        get => this.GetConfigValue("LogPath", false)
        set => this.SetConfigValue("LogPath", value, false)
    }

    LoggingLevel {
        get => this.GetConfigValue("LoggingLevel", false)
        set => this.SetConfigValue("LoggingLevel", value, false)
    }

    EnableOverlay {
        get => this.GetConfigValue("EnableOverlay", false)
        set => this.SetConfigValue("EnableOverlay", value, false)
    }

    ForceOverlay {
        get => this.GetConfigValue("ForceOverlay", false)
        set => this.SetConfigValue("ForceOverlay", value, false)
    }

    OverlayHotkey {
        get => this.GetConfigValue("OverlayHotkey", false)
        set => this.SetConfigValue("OverlayHotkey", value, false)
    }

    OverlayWait {
        get => this.GetConfigValue("OverlayWait", false)
        set => this.SetConfigValue("OverlayWait", value, false)
    }

    IsBuilt {
        get => this.LauncherExists(false)
    }

    IsOutdated {
        get => !this.LauncherExists(false) or this.LauncherIsOutdated() 
    }

    __New(app, key, config, parentEntity := "", requiredConfigKeys := "") {
        super.__New(app, key, config, parentEntity, requiredConfigKeys)
        this.children["ManagedLauncher"] := ManagedLauncherEntity(app, key, config, this, "")
        this.entityData.SetAutoDetectedDefaults(this.AutoDetectValues())
        this.StoreOriginal(false, true)
    }

    /**
    * NEW METHODS
    */
    LauncherExists(checkSourceFile := false) {
        return (FileExist(this.GetLauncherFile(this.Key, checkSourceFile)) != "")
    }

    LauncherIsOutdated() {
        outdated := true

        filePath := this.GetLauncherFile(this.Key)

        if (filePath && FileExist(filePath)) {
            launcherVersion := FileGetVersion(this.GetLauncherFile(this.Key))

            if (launcherVersion && !this.app.Service("VersionChecker").VersionIsOutdated(this.app.Version, launcherVersion)) {
                outdated := false
            }

            configInfo := this.app.State.GetLauncherInfo(this.Key, "Config")
            buildInfo := this.app.State.GetLauncherInfo(this.Key, "Build")

            if (!buildInfo["Version"] || !buildInfo["Timestamp"]) {
                outdated := true
            } else {
                if (configInfo["Version"] && this.app.Service("VersionChecker").VersionIsOutdated(configInfo["Version"], buildInfo["Version"])) {
                    outdated := true
                } else if (configInfo["Timestamp"] && DateDiff(configInfo["Timestamp"], buildInfo["Timestamp"], "S") > 0) {
                    outdated := true
                }
            }
        }

        return outdated
    }

    GetLauncherFile(key, checkSourceFile := false) {
        gameDir := checkSourceFile ? this.app.Config["assets_dir"] : this.app.Config["destination_dir"]

        if (checkSourceFile) {
            gameDir .= "\" . key
        }

        ext := checkSourceFile ? ".ahk" : ".exe"
        return gameDir . "\" . key . ext
    }

    GetStatus() {
        status := "Missing"

        if (this.LauncherExists()) {
            status := this.IsOutdated ? "Outdated" : "Ready"
        }

        return status
    }

    /**
    * OVERRIDES
    */

    Validate() {
        validateResult := super.Validate()

        if (this.IconSrc == "" && !this.IconFileExists()) {
            validateResult["success"] := false
            validateREsult["invalidFields"].push("IconSrc")
        }

        ; TODO: Validate launcher entities here

        return ValidateResult
    }

    SaveModifiedData() {
        super.SaveModifiedData()
        this.app.State.SetLauncherConfigInfo(this.Key)
    }

    GetDataSourceItemKey() {
        if (!this.DataSourceItemKey) {
            dataSources := this.GetAllDataSources()

            for index, dataSource in dataSources {
                platform := this.Platform ? this.Platform : "None"
                apiPath := "lookup/" this.Key

                if (this.platform) {
                    apiPath .= "/" . this.Platform
                }
                
                dsData := dataSource.ReadJson(apiPath)

                if (dsData != "" && dsData.Has("id") && dsData["id"]) {
                    this.DataSourceItemKey := dsData["id"]
                    break
                }
            }
        }

        if (this.DataSourceItemKey) {
            return this.DataSourceItemKey
        } else {
            return ""
        }
    }

    IconFileExists() {
        iconSrc := this.IconSrc != "" ? this.IconSrc : this.GetAssetPath(this.Key . ".ico")
        return FileExist(iconSrc)
    }

    LaunchEditWindow(mode, owner := "", parent := "") {
        result := this.app.Config["use_advanced_launcher_editor"] ? "Advanced" : "Simple"

        ownerOrParent := ""

        if (parent) {
            ownerOrParent := parent
        } else if (owner) {
            ownerOrParent := owner
        }

        while (result == "Simple" || result == "Advanced") {
            form := result == "Advanced" ? "LauncherEditor" : "LauncherEditorSimple"
            result := this.app.Service("manager.gui").Dialog(Map(
                "type", form,
                "mode", mode,
                "child", !!(parent),
                "ownerOrParent", ownerOrParent
            ), this)
        }
        
        return result
    }

    MergeAdditionalDataSourceDefaults(defaults, dataSourceData) {
        launcherType := this.DetectLauncherType(defaults, dataSourceData)

        checkType := (launcherType == "") ? "Default" : launcherType
        if (dataSourceData.Has("Launchers") && dataSourceData["Launchers"].Has(checkType) && Type(dataSourceData["Launchers"][checkType]) == "Map") {
            this.additionalManagedLauncherDefaults := this.MergeFromObject(this.additionalManagedLauncherDefaults, dataSourceData["Launchers"][checkType], false)
            defaults := this.MergeFromObject(defaults, dataSourceData["Launchers"][checkType], true)
        }

        defaults["LauncherType"] := launcherType
        
        return defaults
    }

    DetectLauncherType(defaults, dataSourceData := "") {
        launcherType := ""

        if (this.UnmergedConfig.Has("LauncherType")) {
            launcherType := this.UnmergedConfig["LauncherType"]
        } else if (defaults.Has("LauncherType")) {
            launcherType := defaults["LauncherType"]
        }

        if (launcherType == "") {
            launcherType := "Default"
        }

        if (dataSourceData != "" && dataSourceData.Has("Launchers")) {
            launcherType := this.DereferenceKey(launcherType, dataSourceData["Launchers"])
        }

        return launcherType
    }

    AutoDetectValues() {
        detectedValues := super.AutoDetectValues()
        
        if (!detectedValues.Has("IconSrc")) {
            checkPath := this.AssetsDir . "\" . this.Key . ".ico"
            
            if (FileExist(checkPath)) {
                detectedValues["IconSrc"] := checkPath
            } else if (this.children.Has("ManagedLauncher") && this.ManagedLauncher.ManagedGame.GetConfigValue("Exe") != "") {
                detectedValues["IconSrc"] := this.ManagedLauncher.ManagedGame.LocateExe()
            } else {
                detectedValues["IconSrc"] := this.app.appDir . "\Resources\Graphics\Game.ico"
            }
        }

        defaultTheme := this.app.Config["default_launcher_theme"] ? 
            this.app.Config["default_launcher_theme"] : 
            this.app.Config["theme_name"]

        if (defaultTheme && this.app.Config["override_launcher_theme"]) {
            detectedValues["ThemeName"] := defaultTheme
        }

        return detectedValues
    }

    InitializeDefaults() {
        defaults := super.InitializeDefaults()
        defaults.Delete("DataSourceItemKey")
        
        defaults["CloseAfter"] := ""
        defaults["CloseBefore"] := ""
        defaults["DestinationDir"] := this.GetDefaultDestinationDir()
        defaults["EnableOverlay"] := false
        defaults["ForceOverlay"] := false
        defaults["LoggingLevel"] := this.app.Config["logging_level"]
        defaults["LogPath"] := this.app.tmpDir . "\Logs\" . this.Key . ".txt"
        defaults["OverlayHotkey"] := "^Tab"
        defaults["OverlayWait"] := 10
        defaults["ResourcesDir"] := this.app.appDir . "\Resources"
        defaults["RunAfter"] := ""
        defaults["RunBefore"] := ""
        defaults["ShowProgress"] := true
        defaults["ThemeName"] := this.app.Config["theme_name"]
        defaults["ThemesDir"] := this.app.appDir . "\Resources\Themes"

        return defaults
    }

    GetDefaultDestinationDir() {
        return this.app.Config["destination_dir"]
    }
}
