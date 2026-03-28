import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

PanelWindow {
    id: barWindow
    anchors { top: true; left: true; right: true }
    implicitHeight: 32
    color: "#03010a"

    WifiPanel { id: wifiPanel; visible: false }
    MenuPanel { id: menuWindow; visible: false }
    
    VolumePanel {
        id: volumePanel
        visible: false
        onVolumeUpdate: (val) => sysInfo.currentVol = val.toString()
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 0

        Item {
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            Layout.fillHeight: true
            RowLayout {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                Workspaces {}
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            Layout.fillHeight: true
            Clock { anchors.centerIn: parent }
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            Layout.fillHeight: true
            RowLayout {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 16
                SystemInfo {
                    id: sysInfo
                    onNetworkClicked: wifiPanel.visible = !wifiPanel.visible
                    onVolumeClicked: volumePanel.visible = !volumePanel.visible
                }
                Text {
                    text: "[EXIT]"
                    color: "#cba6f7"
                    font.family: "Iosevka Nerd Font Mono"
                    font.pixelSize: 12
                    Layout.alignment: Qt.AlignVCenter
                    MouseArea {
                        anchors.fill: parent
                        onClicked: menuWindow.visible = !menuWindow.visible
                    }
                }
            }
        }
    }
}
