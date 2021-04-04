class SelectControl extends GuiControlBase {
    selectOptions := []
    btnCtl := ""

    CreateControl(value, selectOptions, handler := "", helpText := "", buttonText := "", buttonHandler := "", buttonOpts := "") {
        super.CreateControl()
        this.selectOptions := selectOptions
        
        buttonW := buttonText ? (this.guiObj.themeObj.CalculateTextWidth(buttonText) + this.guiObj.margin*2) : 0

        opts := this.options.Clone()
        w := this.GetOption(opts, "w")

        if (w) {
            w := SubStr(w, 2)
        } else {
            w := this.guiObj.windowSettings["contentWidth"]
        }

        if (buttonW) {
            w -= (buttonW + this.guiObj.margin)
        }
        this.SetOption(opts, "w", w)

        fieldW := w
        index := this.GetItemIndex(value)
        opts := this.SetDefaultOptions(opts, ["w" . fieldW, "Choose" . index, "c" . this.guiObj.themeObj.GetColor("editText")])
        ctl := this.guiObj.guiObj.AddDDL(this.GetOptionsString(opts), this.selectOptions)
        this.ctl := ctl

        if (handler) {
            ctl.OnEvent("Change", handler)
        }

        if (helpText) {
            ctl.ToolTip := helpText
        }

        if (buttonText) {
            opts := this.SetDefaultOptions(buttonOpts, "x+m yp w" . buttonW . " h25")
            this.btnCtl := this.guiObj.Add("ButtonControl", this.GetOptionsString(opts), buttonText, buttonHandler)
        }

        return this.ctl
    }

    GetItemIndex(value) {
        index := 0

        for idx, val in this.selectOptions {
            if (value == val) {
                index := idx
                break
            }
        }

        return index
    }

    SetText(text, isIndex := false) {
        index := 0

        if (isIndex) {
            index := text
        } else {
            index := this.GetItemIndex(text)
        }

        if (index) {
            this.ctl.Value := index
        }
    }
}
