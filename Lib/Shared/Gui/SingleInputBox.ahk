class SingleInputBox extends DialogBox {
    defaultValue := ""
    isPassword := false

    __New(title, themeObj, text, defaultValue := "", owner := "", isPassword := false) {
        InvalidParameterException.CheckTypes("SingleInputBox", "defaultValue", defaultValue, "")
        this.defaultValue := defaultValue
        this.isPassword := isPassword
        super.__New(title, themeObj, text, owner, "*&OK|&Cancel")
    }

    Controls() {
        super.Controls()
        this.guiObj.AddEdit("x" . this.margin . " w" . this.windowSettings["contentWidth"] . " -VScroll vDialogEdit" . (this.isPassword ? " Password" : ""), this.defaultValue)
    }

    ProcessResult(result) {
        value := this.guiObj["DialogEdit"].Value
        result := (result == "OK") ? value : ""
        return super.ProcessResult(result)
    }
}