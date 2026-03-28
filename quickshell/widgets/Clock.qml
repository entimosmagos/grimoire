import QtQuick
import Quickshell

Item {
    id: clockRoot
    implicitWidth: clockDisplay.implicitWidth
    implicitHeight: clockDisplay.implicitHeight

    property string hh: "00"
    property string mm: "00"
    property string ss: "00"
    property string displayHH: "00"
    property string displayMM: "00"
    property string displaySS: "00"

    function scramble(t) {
        let chars = "0123456789!@#$%^&*()_+"
        let result = ""
        for (let i = 0; i < t.length; i++) {
            result += chars.charAt(Math.floor(Math.random() * chars.length))
        }
        return result
    }

    function updateTime() {
        const now = new Date();
        let h = now.getHours() % 12;
        h = h ? h : 12;
        
        hh = h < 10 ? "0" + h : h.toString();
        mm = now.getMinutes() < 10 ? "0" + now.getMinutes() : now.getMinutes().toString();
        ss = now.getSeconds() < 10 ? "0" + now.getSeconds() : now.getSeconds().toString();

        if (now.getSeconds() % 10 === 0) {
            glitchTimer.start()
        } else if (!glitchTimer.running) {
            displayHH = hh; displayMM = mm; displaySS = ss;
        }
    }

    Timer {
        id: glitchTimer
        interval: 50
        repeat: true
        property int count: 0
        onTriggered: {
            if (count < 8) {
                displayHH = scramble(hh); displayMM = scramble(mm); displaySS = scramble(ss);
                count++
            } else {
                displayHH = hh; displayMM = mm; displaySS = ss;
                count = 0; stop()
            }
        }
    }

    Timer {
        interval: 1000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: updateTime()
    }

    Row {
        id: clockDisplay
        spacing: 0
        
        Text { text: "["; color: "#cba6f7"; font.family: "Iosevka Nerd Font Mono"; font.pixelSize: 12 }
        Text { text: displayHH; color: "#cba6f7"; font.family: "Iosevka Nerd Font Mono"; font.pixelSize: 12 }
        Text { text: ":"; color: "#cba6f7"; font.family: "Iosevka Nerd Font Mono"; font.pixelSize: 12 }
        Text { text: displayMM; color: "#cba6f7"; font.family: "Iosevka Nerd Font Mono"; font.pixelSize: 12 }
        Text { text: ":"; color: "#cba6f7"; font.family: "Iosevka Nerd Font Mono"; font.pixelSize: 12 }
        Text { text: displaySS; color: "#cba6f7"; font.family: "Iosevka Nerd Font Mono"; font.pixelSize: 12 }
        Text { text: "]"; color: "#cba6f7"; font.family: "Iosevka Nerd Font Mono"; font.pixelSize: 12 }
    }

    SequentialAnimation on opacity {
        loops: Animation.Infinite
        NumberAnimation { to: 0.8; duration: 50 }
        NumberAnimation { to: 1.0; duration: 30 }
        PauseAnimation { duration: 2500 }
    }
}
