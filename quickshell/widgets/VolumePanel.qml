import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts 
import Quickshell 
import Quickshell.Io 

PanelWindow { 
    id: root 
    
    // Restoration of the missing signal for Bar.qml compatibility 
    signal volumeUpdate(int newVol)  
    
    visible: false 
    focusable: true 

    anchors { 
        top: true 
        right: true 
    } 

    // Offset to align with the [SOUND] tag in your bar 
    margins.top: 4 
    margins.right: 120  

    // Fixed dimensions to ensure the window doesn't collapse 
    implicitWidth: 280  
    implicitHeight: 120 
    color: "transparent" 

    property int volume: 0 

    Shortcut { sequence: "Escape"; onActivated: root.visible = false } 
    TapHandler { onTapped: root.visible = false } 

    onVisibleChanged: { 
        if (visible) { 
            glitchMovement.restart();  
            flickerAnim.start(); 
            getVol.running = true; 
            Quickshell.execDetached(["paplay", "--volume", "20000", "/home/magos/.config/quickshell/assets/glitchy1.wav"]); 
        } else { 
            flickerAnim.stop(); 
        } 
    } 

    Process { 
        id: getVol 
        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2 * 100}'"] 
        stdout: SplitParser { onRead: data => root.volume = parseInt(data.trim()) } 
    } 

    Item { 
        id: contentWrapper 
        anchors.fill: parent 
        opacity: root.visible ? 1.0 : 0.0 
        Behavior on opacity { NumberAnimation { duration: 150 }} 

        // Background Frame 
        Rectangle { 
            id: frame 
            anchors.fill: parent 
            anchors.margins: 4 
            color: "#03010a" 
            border.color: "#4a3570" 
            radius: 2 
        } 

        // CRT Scanline Overlay & Grid 
        Rectangle { 
            id: scanlineOverlay 
            anchors.fill: frame 
            z: 20 
            color: "transparent" 
            clip: true 
            opacity: 0.2  
            
            Rectangle { 
                width: parent.width; height: 20 
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
                    model: Math.max(1, frame.height / 3) 
                    Rectangle { width: frame.width; height: 1; color: "black"; opacity: 0.5 } 
                } 
            } 
        } 

        // Animations 
        SequentialAnimation { 
            id: glitchMovement; loops: 2 
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

        // Main Layout - Switched to ColumnLayout for better child sizing 
        ColumnLayout { 
            id: mainContent 
            anchors.fill: frame 
            anchors.margins: 14 
            spacing: 8 

            Text { 
                text: " > GAIN_CONTROL_ACCESS" 
                color: "#cba6f7" 
                font.family: "Iosevka Nerd Font Mono" 
                font.pixelSize: 10 
                Layout.alignment: Qt.AlignRight 
            } 

            Slider { 
                id: volSlider 
                Layout.fillWidth: true 
                Layout.preferredHeight: 20 // Added height so it's visible 
                from: 0; to: 100 
                value: root.volume 
                
                onMoved: { 
                    let val = Math.round(value) 
                    root.volumeUpdate(val)  
                    Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", (val / 100).toString()]) 
                } 

                background: Rectangle { 
                    height: 4 
                    anchors.centerIn: parent 
                    width: parent.width 
                    color: "#1a1826" 
                    Rectangle { 
                        width: volSlider.visualPosition * parent.width 
                        height: parent.height 
                        color: "#4a3570"  
                    } 
                } 

                handle: Rectangle { 
                    x: volSlider.visualPosition * (volSlider.width - width) 
                    anchors.verticalCenter: parent.verticalCenter 
                    width: 10; height: 16 
                    color: "#f5c2e7"  
                    border.color: "#cba6f7" 
                } 
            } 

            Text { 
                text: "VOL_LEVEL: [" + Math.round(volSlider.value) + "%]" 
                color: "#6b4f9e" 
                font.family: "Iosevka Nerd Font Mono" 
                font.pixelSize: 9 
                Layout.alignment: Qt.AlignRight 
            } 
        } 
    } 
}
