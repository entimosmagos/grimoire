import Quickshell
import Quickshell.Io
import "widgets"

ShellRoot {
    id: root
    property bool crtEnabled: true

    IpcHandler {
        target: "toggleCRT"
        function handle() {
            root.crtEnabled = !root.crtEnabled
        }
    }

    Bar {}

    Variants {
        model: Quickshell.screens
        CRTOverlay {
            required property var modelData
            visible: root.crtEnabled
        }
    }
}
