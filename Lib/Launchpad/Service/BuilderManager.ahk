class BuilderManager extends AppComponentServiceBase {
    defaultBuilderKey := "ahk"

    SetItem(key, builderObj, makeDefault := false) {
        if (makeDefault) {
            this.defaultBuilderKey := key
        }

        return super.SetItem(key, builderObj)
    }

    BuildLaunchers(launcherGames := "", updateExisting := false, owner := "", builder := "") {
        if (launcherGames == "") {
            launcherGames := this.app.Launchers.Launchers
        }

        builder := this._GetBuilderObject(builder)
        operation := BuildLaunchersOp.new(this.app, launcherGames, builder, updateExisting, owner)
        return operation.Run()
    }

    CleanLaunchers(launcherGames := "", owner := "", builder := "") {
        if (launcherGames == "") {
            launcherGames := this.app.Launchers.Launchers
        }

        builder := this._GetBuilderObject(builder)
        operation := CleanLaunchersOp.new(this.app, launcherGames, builder, owner)
        return operation.Run()
    }

    _GetBuilderObject(builder) {
        if (builder == "") {
            builder := this.defaultBuilderKey
        }

        if (!IsObject(builder)) {
            builder := this.GetItem(builder)
        }

        return builder
    }
}
