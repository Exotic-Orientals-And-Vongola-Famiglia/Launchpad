class DialogBox extends FormGuiBase {
    windowOptions := "+AlwaysOnTop"
    isDialog := true

    __New(title, themeObj, text := "", owner := "", btns := "*&Yes|&No") {
        super.__New(title, themeObj, text, owner, "", btns)
    }
}