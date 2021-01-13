class ProtoConfig extends FileConfig {
    config := Map()
    primaryConfigKey := "Database"
    protoFile := ""

    __New(app, configPath, protoFile, autoLoad := true) {
        this.protoFile := protoFile
        super.__New(app, configPath, "", autoLoad)
    }

    LoadConfig() {
        if (this.configPath == "") {
            this.app.Notifications.Error("Config file path not provided.")
            return this
        }

        if (FileExist(this.configPath)) {
            data := ProtobufData.new()
            this.config := data.FromFile(this.configPath, this.primaryConfigKey, this.protoFile)
        }
        
        return super.LoadConfig()
    }

    SaveConfig() {
        this.app.Notifications.Error("Protobuf file saving is not yet implemented.")
        return this
    }

    CountItems() {
        count := 0
        
        for key, value in this.config {
            count++
        }

        return count
    }

    ; Performs a deep clone of the JSON map
    Clone() {
        newEntity := super.Clone()
        newEntity.config := this.config.Clone()
        newEntity := this.CloneChildMaps(newEntity)
    }

    CloneChildMaps(parentMap) {
        for key, child in parentMap {
            if (Type(child) == "Map") {
                parentMap[key] := this.CloneChildMaps(child)
            }
        }

        return parentMap
    }
}
