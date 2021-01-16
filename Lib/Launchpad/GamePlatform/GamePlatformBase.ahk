class GamePlatformBase {
    app := ""
    installDir := ""
    exePath := ""
    uninstallCmd := ""
    installedVersion := ""
    latestVersion := ""
    libraryDirs := []
    launcherType := "Default"
    gameType := "Default"
    displayName := ""

    __New(app, installDir := "", exePath := "", installedVersion := "", uninstallCmd := "", libraryDirs := "") {
        this.app := app
        this.installDir := installDir
        this.exePath := exePath
        this.installedVersion := installedVersion
        this.uninstallCmd := ""

        if (libraryDirs != "") {
            if (Type(libraryDirs) == "String") {
                libraryDirs := [libraryDirs]
            }

            this.libraryDirs := libraryDirs
        }
    }

    LibraryDirExists(dir) {
        exists := false

        if (this.libraryDirs) {
            for index, key in this.libraryDirs {
                if (key == dir) {
                    exists := true
                    break
                }
            }
        }
        
        return exists
    }

    GetLibraryDirs() {
        return this.libraryDirs
    }

    GetInstallDir() {
        return this.installDir
    }

    GetExePath() {
        return this.exePath
    }

    GetUninstallCmd() {
        return this.uninstallCmd
    }

    OpenDir() {
        installDir := this.GetInstallDir()

        if (installDir) {
            Run(installDir)
        }
    }

    Run() {
        exePath := this.GetExePath()

        if (exePath) {
            Run(exePath)
        }
    }

    IsInstalled() {
        exePath := this.GetExePath()
        return (exePath && FileExist(exePath))
    }

    NeedsUpdate() {
        return this.VersionIsOutdated(this.GetLatestVersion(), this.GetInstalledVersion())
    }

    VersionIsOutdated(latestVersion, installedVersion) {
        splitLatestVersion := StrSplit(latestVersion, ".")
        splitInstalledVersion := StrSplit(installedVersion, ".")

        for (index, numPart in splitInstalledVersion) {
            latestVersionPart := splitLatestVersion.Has(index) ? splitLatestVersion[index] : 0

            if ((latestVersionPart + 0) > (numPart + 0)) {
                return true
            } else if ((latestVersionPart + 0) < (numPart + 0)) {
                return false
            } 
        }

        return false
    }

    GetInstalledVersion() {
        if (!this.installedVersion) {
            this.installedVersion := this.LookupInstalledVersion()
        }

        return this.installedVersion
    }

    GetLatestVersion() {
        if (!this.latestVersion) {
            this.latestVerison := this.LookupLatestVersion()
        }

        return this.latestVersion
    }

    LookupInstalledVersion() {
        return ""
    }

    LookupLatestVersion() {
        return ""
    }

    Update() {  
        if (this.NeedsUpdate()) {
            this.Install()
        }
    }

    Install() {

    }

    Uninstall() {
        if (this.uninstallCmd) {
            result := MsgBox("Are you sure you want to uninstall " . this.displayName . "?", "Uninstall " . this.displayName, "YesNo")
        
            if (result == "Yes") {
                RunWait(this.uninstallCmd)
            }
        }
    }

    ExeIsValid(exeName, fullPath) {
        filterExes := []
        filterExes.Push("UnityCrashHandler64.exe")
        filterExes.Push("UnityCrashHandler.exe")
        filterExes.Push("OriginThinSetup.exe")
        filterExes.Push("vc_redist.x64.exe")
        filterExes.Push("vc_redist.x86.exe")
        filterExes.Push("vcredist_x86.exe")
        filterExes.Push("vcredist_x64.exe")
        filterExes.Push("overlayinjector.exe")
        filterExes.Push("Cleanup.exe")
        filterExes.Push("Touchup.exe")
        filterExes.Push("ActivationUI.exe")
        filterExes.Push("DXSETUP.exe")
        filterExes.Push("BlizzardBrowser.exe")

        valid := !InStr(fullPath, "\__Installer\")

        if (valid) {
            for index, exe in filterExes {
                if A_LoopFileName == exe {
                    valid := false
                    break
                }
            }
        }

        return valid
    }

    DetectInstalledGames() {
        games := []

        for index, dir in this.GetLibraryDirs() {
            Loop Files dir . "\*", "D" {
                key := A_LoopFileName
                installDir := A_LoopFileFullPath
                possibleExes := []
                exeName := ""

                Loop Files installDir . "\*.exe", "R" {
                    if (this.ExeIsValid(A_LoopFileName, A_LoopFileFullPath)) {
                        possibleExes.Push(A_LoopFileFullPath)
                    }
                }

                if (possibleExes.Length == 1) {
                    exeName := possibleExes[1]
                }

                launcherSpecificId := key
                games.Push(DetectedGame.new(key, this, this.launcherType, this.gameType, installDir, exeName, launcherSpecificId, possibleExes))
            }
        }

        return games
    }
}
