import QtQuick
import Quickshell

PanelWindow {
    id: crtRoot

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    exclusiveZone: 0
    focusable: false
    mask: Region {}
    color: "transparent"

    // scanlines
    Item {
        anchors.fill: parent

        Repeater {
            model: Math.floor(crtRoot.height / 3)
            Rectangle {
                width: crtRoot.width
                height: 1
                y: index * 3
                color: "#000000"
                opacity: 0.18
            }
        }
    }

    // sweep line
    Rectangle {
        width: parent.width
        height: 2
        opacity: 0.06
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 0.5; color: "#cba6f7" }
            GradientStop { position: 1.0; color: "transparent" }
        }
        NumberAnimation on y {
            from: -2
            to: crtRoot.height
            duration: 6000
            loops: Animation.Infinite
        }
    }

    // vignette
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#40000000" }
            GradientStop { position: 0.3; color: "transparent" }
            GradientStop { position: 0.7; color: "transparent" }
            GradientStop { position: 1.0; color: "#40000000" }
        }
    }

    // purple tint
    Rectangle {
        anchors.fill: parent
        color: "#cba6f7"
        opacity: 0.03
    }

    // glitch bar
    Rectangle {
        id: glitchBar
        width: parent.width
        height: 2
        color: "#f5c2e7"
        opacity: 0
        y: 0

        Timer {
            interval: 150
            running: true
            repeat: true
            onTriggered: {
                if (Math.random() > 0.92) {
                    glitchBar.y = Math.random() * crtRoot.height
                    glitchBar.opacity = Math.random() * 0.15
                    glitchBar.height = Math.random() * 3 + 1
                } else {
                    glitchBar.opacity = 0
                }
            }
        }
    }

    // noise slice
    Rectangle {
        id: noiseSlice
        height: 1
        color: "#cba6f7"
        opacity: 0
        x: 0

        Timer {
            interval: 80
            running: true
            repeat: true
            onTriggered: {
                if (Math.random() > 0.96) {
                    noiseSlice.y = Math.random() * crtRoot.height
                    noiseSlice.x = Math.random() * crtRoot.width * 0.3
                    noiseSlice.width = crtRoot.width * (0.2 + Math.random() * 0.5)
                    noiseSlice.opacity = Math.random() * 0.2
                } else {
                    noiseSlice.opacity *= 0.7
                }
            }
        }
    }
}
