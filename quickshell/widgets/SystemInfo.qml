import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

RowLayout {
    id: sysInfoRoot
    signal networkClicked
    signal volumeClicked
    spacing: 15
    Layout.alignment: Qt.AlignVCenter

    // Global Status Properties
    property string currentVol: "0"
    property bool isMuted: false
    property int batteryLevel: 100
    property bool isCharging: false
    property string ssid: ""
    
    // Emergency Condition Checks
    property bool isBatteryLow: batteryLevel <= 15 && !isCharging
    property bool isOffline: ssid === ""
    property bool inEmergencyState: isMuted || isBatteryLow || isOffline

    // Standard calm flicker (only if everything is fine)
    SequentialAnimation on opacity {
        running: !inEmergencyState
        loops: Animation.Infinite
        NumberAnimation { to: 0.9; duration: 40 }
        NumberAnimation { to: 1.0; duration: 20 }
        PauseAnimation { duration: 3000 }
    }

    // Aggressive alert flicker for any Emergency state
    SequentialAnimation on opacity {
        running: inEmergencyState
        loops: Animation.Infinite
        NumberAnimation { to: 0.4; duration: 50 }
        NumberAnimation { to: 1.0; duration: 50 }
    }

    Text {
        id: networkText
        // Red alert if no link is detected
        color: isOffline ? "#ff5555" : "#cba6f7"
        text: isOffline ? "[NO LINK]" : "[LINK " + ssid + "]"
        font.family: "Iosevka Nerd Font Mono"
        font.pixelSize: 12
        Layout.alignment: Qt.AlignVCenter
        
        MouseArea { 
            anchors.fill: parent; 
            onClicked: networkClicked() 
        }
    }

    Text {
        id: batteryText
        color: isBatteryLow ? "#ff5555" : "#cba6f7"
        text: "[VITAL " + batteryLevel + (isCharging ? "+" : "") + "]"
        font.family: "Iosevka Nerd Font Mono"
        font.pixelSize: 12
        Layout.alignment: Qt.AlignVCenter
    }

    Text {
        id: volumeText
        text: isMuted ? "[MUTED]" : "[SOUND " + currentVol + "%]" 
        color: isMuted ? "#ff5555" : "#cba6f7"
        font.family: "Iosevka Nerd Font Mono"
        font.pixelSize: 12
        Layout.alignment: Qt.AlignVCenter
        
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton
            onClicked: (mouse) => {
                if (mouse.button === Qt.LeftButton) volumeClicked()
                if (mouse.button === Qt.MiddleButton) {
                    Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"])
                }
            }
            onWheel: (wheel) => {
                if (wheel.angleDelta.y > 0) {
                    Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%+"])
                } else {
                    Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%-"])
                }
            }
        }
    }

    // VOLUME & MUTE LISTENER
    Process {
        id: volListener
        command: ["sh", "-c", "pactl subscribe | grep --line-buffered \"Event 'change' on sink\" | while read line; do wpctl get-volume @DEFAULT_AUDIO_SINK@; done"]
        running: true
        stdout: SplitParser { 
            onRead: data => {
                let raw = data.trim()
                isMuted = raw.includes("[MUTED]")
                let match = raw.match(/[0-9.]+/);
                if (match) currentVol = Math.round(parseFloat(match[0]) * 100).toString()
            }
        }
    }

    // Initial fetch for volume
    Process {
        id: initVol
        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@"]
        running: true
        stdout: SplitParser { 
            onRead: data => {
                let raw = data.trim()
                isMuted = raw.includes("[MUTED]")
                let match = raw.match(/[0-9.]+/);
                if (match) currentVol = Math.round(parseFloat(match[0]) * 100).toString()
            }
        }
    }

    // BATTERY LISTENER
    Process {
        id: battery
        command: ["sh", "-c", "echo \"$(( ($(cat /sys/class/power_supply/BAT0/capacity) + $(cat /sys/class/power_supply/BAT1/capacity)) / 2 ))|$(cat /sys/class/power_supply/AC/online)\""]
        running: true
        stdout: SplitParser { 
            onRead: data => {
                let parts = data.trim().split("|")
                batteryLevel = parseInt(parts[0])
                isCharging = parts[1] === "1"
            }
        }
    }

    // NETWORK LISTENER
    Process {
        id: network
        command: ["sh", "-c", "nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2"]
        running: true
        stdout: SplitParser { 
            onRead: data => {
                ssid = data.trim() 
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            battery.running = false; battery.running = true
            network.running = false; network.running = true
        }
    }
}
