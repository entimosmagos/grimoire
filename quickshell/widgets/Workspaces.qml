import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

RowLayout {
    spacing: 0

    Repeater {
        model: Hyprland.workspaces

        Text {
            required property HyprlandWorkspace modelData
            text: " " + modelData.name + " "
            color: Hyprland.focusedMonitor && modelData.id === Hyprland.focusedMonitor.activeWorkspace.id ? "#cba6f7" : "#4a3570"
            font.family: "Iosevka Nerd Font Mono"
            font.pixelSize: 12
        }
    }
}
