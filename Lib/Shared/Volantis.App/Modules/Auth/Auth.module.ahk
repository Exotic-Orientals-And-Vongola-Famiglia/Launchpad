class AuthModule extends ModuleBase {
    GetDependencies() {
        return []
    }

    GetEventSubscribers() {
        subscribers := Map()
        subscribers[Events.APP_SERVICE_DEFINITIONS] := [ObjBindMethod(this, "DefineServices")]
        return subscribers
    }

    DefineServices(event, extra, eventName, hwnd) {
        event.DefineServices(Map(
            "auth_provider.launchpad_api", Map(
                "class", "LaunchpadApiAuthProvider",
                "arguments", [
                    AppRef(), 
                    ServiceRef("State")
                ]
            ),
            "Auth", Map(
                "class", "AuthService",
                "arguments", [
                    AppRef(), 
                    ServiceRef("auth_provider.launchpad_api"), 
                    ServiceRef("State")
                ]
            )
        ))
    }
}
