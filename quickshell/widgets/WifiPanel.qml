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

    property var networks: []
    property string selectedSsid: ""
    property bool showingPasswordInput: false
    property bool isConnecting: false

    Shortcut { sequence: "Escape"; onActivated: root.visible = false }
    TapHandler { onTapped: root.visible = false }

    onVisibleChanged: {
        if (visible) {
            selectedSsid = ""; showingPasswordInput = false; isConnecting = false;
            glitchMovement.restart(); flickerAnim.start();
            Quickshell.execDetached(["paplay", "--volume", "20000", "/home/magos/.config/quickshell/assets/glitchy1.wav"]);
        } else {
            flickerAnim.stop();
        }
    }

    Process {
        id: scanner
        command: ["nmcli", "-t", "-f", "ssid,signal,security", "dev", "wifi", "list"]
        running: root.visible && !showingPasswordInput && !isConnecting
        stdout: SplitParser {
            onRead: data => {
                const lines = data.split("\n");
                let newNetworks = [];
                lines.forEach(line => {
                    const parts = line.split(":");
                    if (parts.length >= 2 && parts[0] !== "") {
                        newNetworks.push({ ssid: parts[0], signal: parseInt(parts[1]) || 0, secure: parts[2] !== "--" && parts[2] !== "" });
                    }
                });

                root.networks = newNetworks;
            }
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
                text: isConnecting ? " > ESTABLISHING_LINK" : " > SCANNING_NETWORKS"
                color: "#cba6f7"
                font.family: "Iosevka Nerd Font Mono"
                font.pixelSize: 10
                anchors.right: parent.right
            }

            Column {
                id: listColumn
                spacing: 6
                anchors.right: parent.right
                visible: !root.showingPasswordInput && !root.isConnecting

                Repeater {
                    model: root.networks
                    delegate: Item {
                        id: delegateItem
                        implicitWidth: netRow.implicitWidth
                        implicitHeight: netRow.implicitHeight
                        anchors.right: parent.right
                        property bool hovered: false
                        property string displayedSsid: ""
                        property int glyphIndex: 0
                        readonly property string glyphs: "ﾊﾐﾋｰｳｼﾅﾓﾆｻﾜﾂｵﾘｱﾎﾃﾏｹﾒｴｶｷﾑﾕﾗｾﾈｽﾀﾇﾍ"

                        Timer {
                            id: glitchTimer; interval: 60; repeat: true
                            running: root.visible
                            onTriggered: {
                                let ssid = modelData.ssid;
                                let result = "";
                                for (let i = 0; i < ssid.length; i++) {
                                    if (i < glyphIndex) result += ssid[i];
                                    else result += glyphs.charAt(Math.floor(Math.random() * glyphs.length));
                                }

                                displayedSsid = result;

                                if (glyphIndex < ssid.length) {
                                    glyphIndex++;
                                } else if (Math.random() > 0.94) {
                                    glyphIndex = Math.floor(Math.random() * ssid.length);
                                    Quickshell.execDetached(["paplay", "--volume", "20000", "/home/magos/.config/quickshell/assets/glitchy1.wav"]);
                                }
                            }
                        }

                        Row {
                            id: netRow
                            spacing: 12; layoutDirection: Qt.RightToLeft
                            Text {
                                text: "[" + modelData.signal + "%]"
                                color: hovered ? "#f5c2e7" : "#4a3570"
                                font.family: "Iosevka Nerd Font Mono"; font.pixelSize: 11
                            }

                            Text {
                                text: {
                                    let decoded = displayedSsid.substring(0, glyphIndex);
                                    let scrambled = displayedSsid.substring(glyphIndex);
                                    return "<font color='#6b4f9e'>" + decoded + "</font>" + "<font color='#f5c2e7'>" + scrambled + "</font>";
                                }

                                textFormat: Text.RichText
                                font.family: "Iosevka Nerd Font Mono"; font.pixelSize: 12
                                horizontalAlignment: Text.AlignRight
                            }

                            Text {
                                text: modelData.secure ? "󰖂" : "󰖩"
                                color: hovered ? "#f5c2e7" : "#4a3570"
                                font.family: "Iosevka Nerd Font Mono"; font.pixelSize: 12
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
                                root.selectedSsid = modelData.ssid;
                                if (modelData.secure) {
                                    root.showingPasswordInput = true;
                                    Quickshell.execDetached(["paplay", "/usr/share/sounds/freedesktop/stereo/dialog-warning.oga"]);
                                } else { 
                                    root.isConnecting = true; 
                                    Quickshell.execDetached(["paplay", "/usr/share/sounds/freedesktop/stereo/network-connectivity-established.oga"]);
                                    closeTimer.start(); 
                                }
                            }
                        }
                    }
                }
            }

            Column {
                visible: root.showingPasswordInput && !root.isConnecting
                spacing: 12
                anchors.right: parent.right
                opacity: visible ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 300 } }

                Text {
                    text: "DECRYPT_KEY_FOR: " + root.selectedSsid
                    color: "#f5c2e7"; font.family: "Iosevka Nerd Font Mono"; font.pixelSize: 10
                    anchors.right: parent.right
                }

                Rectangle {
                    width: 220; height: 28; color: "#0a0910"
                    border.color: passInput.activeFocus ? "#f5c2e7" : "#4a3570"
                    border.width: 1; anchors.right: parent.right
                    TextInput {
                        id: passInput
                        anchors.fill: parent; anchors.margins: 6
                        color: "#f5c2e7"; font.family: "Iosevka Nerd Font Mono"; font.pixelSize: 12
                        echoMode: TextInput.Password; passwordCharacter: "󰷛"; passwordMaskDelay: 500
                        onVisibleChanged: if (visible) { text = ""; forceActiveFocus(); }
                        onAccepted: {
                            const cleanPass = text.trim();
                            if (cleanPass !== "") {
                                root.isConnecting = true;
                                Quickshell.execDetached(["paplay", "/usr/share/sounds/freedesktop/stereo/message-new-instant.oga"]);
                                Quickshell.execDetached(["nmcli", "dev", "wifi", "connect", root.selectedSsid, "password", cleanPass]);
                                closeTimer.start();
                            }
                        }
                    }
                }

                Text {
                    text: "« PRESS EXECUTE_ENTER »"
                    color: "#4a3570"; font.family: "Iosevka Nerd Font Mono"; font.pixelSize: 9
                    anchors.right: parent.right
                }
            }

            Column {
                visible: root.isConnecting
                spacing: 8
                anchors.right: parent.right
                Text {
                    text: "LINK_ESTABLISHED: " + root.selectedSsid
                    color: "#f5c2e7"; font.family: "Iosevka Nerd Font Mono"; font.pixelSize: 11
                    anchors.right: parent.right
                }
                Text {
                    text: "RECEIVING_IP_ADDRESS..."
                    color: "#6b4f9e"; font.family: "Iosevka Nerd Font Mono"; font.pixelSize: 10
                    anchors.right: parent.right
                }
            }
        }
    }

    Timer { id: closeTimer; interval: 1500; onTriggered: root.visible = false }
}
