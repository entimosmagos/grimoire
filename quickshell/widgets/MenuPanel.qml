import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

PanelWindow {
    id: root
    visible: false
    focusable: true

    anchors {
        top: true
        right: true
    }

    margins.top: 4
    margins.right: 8

    implicitWidth: mainContent.implicitWidth + 40 
    implicitHeight: mainContent.implicitHeight + 40
    color: "transparent"

    property var items: [
        { full: "REBOOT",    cmd: ["systemctl", "reboot"] },
        { full: "POWEROFF", cmd: ["systemctl", "poweroff"] },
        { full: "LOGOUT",   cmd: ["hyprctl", "dispatch", "exit"] }
    ]

    Shortcut { sequence: "Escape"; onActivated: root.visible = false }
    TapHandler { onTapped: root.visible = false }

    onVisibleChanged: {
        if (visible) {
            glitchMovement.restart(); 
            flickerAnim.start();
            Quickshell.execDetached(["paplay", "--volume", "20000", "/home/magos/.config/quickshell/assets/glitchy1.wav"]);
        } else {
            flickerAnim.stop();
        }
    }

    Item {
        id: contentWrapper
        anchors.fill: parent
        opacity: root.visible ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 150 }}

        Rectangle {
            id: scanlineOverlay
            anchors.fill: frame
            z: 20
            color: "transparent"
            clip: true
            opacity: 0.3 
            
            Rectangle {
                width: parent.width
                height: 20
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.5; color: "#f5c2e7" } 
                    GradientStop { position: 1.0; color: "transparent" }
                }
                NumberAnimation on y {
                    from: -20; to: frame.height; duration: 3000; loops: Animation.Infinite
                }
            }

            Column {
                anchors.fill: parent
                Repeater {
                    model: frame.height / 3
                    Rectangle { width: frame.width; height: 1; color: "black"; opacity: 0.5 }
                }
            }
        }

        SequentialAnimation {
            id: glitchMovement
            loops: 2
            NumberAnimation { target: contentWrapper; property: "x"; to: 3; duration: 30 }
            NumberAnimation { target: contentWrapper; property: "x"; to: -3; duration: 30 }
            NumberAnimation { target: contentWrapper; property: "x"; to: 0; duration: 30 }
        }

        SequentialAnimation {
            id: flickerAnim; loops: Animation.Infinite
            NumberAnimation { target: contentWrapper; property: "opacity"; to: 0.85; duration: 40 }
            NumberAnimation { target: contentWrapper; property: "opacity"; to: 1.0; duration: 20 }
            PauseAnimation { duration: 1500 }
        }

        Rectangle {
            id: frame
            anchors.fill: mainContent
            anchors.margins: -10
            color: "#03010a"
            border.color: "#4a3570"
            radius: 2
        }

        Column {
            id: mainContent
            anchors.centerIn: parent
            spacing: 12

            Text {
                text: " > SYSTEM_TERMINATION"
                color: "#cba6f7"
                font.family: "Iosevka Nerd Font Mono"
                font.pixelSize: 10
                anchors.right: parent.right
            }

            Column {
                spacing: 8
                anchors.right: parent.right

                Repeater {
                    model: root.items
                    delegate: Item {
                        id: delegateItem
                        implicitWidth: menuRow.implicitWidth
                        implicitHeight: menuRow.implicitHeight
                        anchors.right: parent.right
                        property bool hovered: false
                        property string displayedLabel: ""
                        property int glyphIndex: 0
                        readonly property string glyphs: "ﾊﾐﾋｰｳｼﾅﾓﾆｻﾜﾂｵﾘｱﾎﾃﾏｹﾒｴｶｷﾑﾕﾗｾﾈｽﾀﾇﾍ" 

                        Timer {
                            id: glitchTimer; interval: 60; repeat: true
                            running: root.visible
                            onTriggered: {
                                let label = modelData.full;
                                let result = "";
                                for (let i = 0; i < label.length; i++) {
                                    if (i < glyphIndex) result += label[i];
                                    else result += glyphs.charAt(Math.floor(Math.random() * glyphs.length));
                                }
                                displayedLabel = result;

                                if (glyphIndex < label.length) {
                                    glyphIndex++;
                                } else if (Math.random() > 0.94) { 
                                    glyphIndex = Math.floor(Math.random() * label.length);
                                    Quickshell.execDetached(["paplay", "--volume", "20000", "/home/magos/.config/quickshell/assets/glitchy1.wav"]);
                                }
                            }
                        }

                        Connections {
                            target: root
                            function onVisibleChanged() { if (!root.visible) { displayedLabel = ""; glyphIndex = 0; } }
                        }

                        Row {
                            id: menuRow
                            spacing: 12; layoutDirection: Qt.RightToLeft
                            Text {
                                text: {
                                    let decoded = displayedLabel.substring(0, glyphIndex);
                                    let scrambled = displayedLabel.substring(glyphIndex);
                                    return "<font color='#6b4f9e'>" + decoded + "</font>" + 
                                           "<font color='#f5c2e7'>" + scrambled + "</font>";
                                }
                                textFormat: Text.RichText
                                font.family: "Iosevka Nerd Font Mono"; font.pixelSize: 13
                                horizontalAlignment: Text.AlignRight
                            }
                            Text {
                                text: "«"
                                color: hovered ? "#f5c2e7" : "#4a3570"
                                font.family: "Iosevka Nerd Font Mono"; font.pixelSize: 13
                            }
                        }

                        MouseArea {
                            anchors.fill: parent; hoverEnabled: true
                            onEntered: {
                                parent.hovered = true;
                                Quickshell.execDetached(["paplay", "--volume", "18000", "/home/magos/.config/quickshell/assets/glitchselect.wav"]);
                            }
                            onExited: parent.hovered = false
                            onClicked: { 
                                Quickshell.execDetached(["paplay", "--volume", "18000", "/home/magos/.config/quickshell/assets/glitchselect.wav"]);
                                Quickshell.execDetached(modelData.cmd);
                            }
                        }
                    }
                }
            }
        }
    }
}
