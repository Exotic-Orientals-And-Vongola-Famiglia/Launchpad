class BethesdaModule extends ModuleBase {
    GetDependencies() {
        return []
    }

    GetSubscribers() {
        subscribers := Map()
        subscribers[LaunchpadEvents.PLATFORMS_DEFINE] := [ObjBindMethod(this, "DefinePlatform")]
        return subscribers
    }

    DefinePlatform(event, extra, eventName, hwnd) {
        event.Define("Bethesda", "BethesdaPlatform")
    }
}
