class LoadBackupsOp extends BulkOperationBase {
    backupsConfigObj := ""
    progressTitle := "Loading Backups"
    progressText := "Please wait while your backups are processed."
    successMessage := "Loaded {n} backup(s) successfully."
    failedMessage := "{n} backup(s) could not be loaded due to errors."

    __New(app, backupsConfigObj := "", owner := "") {
        if (backupsConfigObj == "") {
            backupsConfigObj := app.Service("manager.backup").GetConfig()
        }

        InvalidParameterException.CheckTypes("LoadBackupsOp", "backupsConfigObj", backupsConfigObj, "ConfigBase")
        this.backupsConfigObj := backupsConfigObj
        super.__New(app, owner)
    }

    RunAction() {
        this.backupsConfigObj.LoadConfig()

        if (this.useProgress) {
            this.progress.SetRange(0, this.backupsConfigObj.Count)
        }

        factory := this.app.Service("EntityFactory")

        for key, config in this.backupsConfigObj {
            this.StartItem(key, key)
            requiredKeys := ""
            this.results[key] := factory.CreateEntity("BackupEntity", key, config, "", requiredKeys)
            this.FinishItem(key, true, key . ": Loaded successfully.")
        }
    }
}
