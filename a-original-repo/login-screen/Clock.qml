import QtQuick
import QtQuick.Controls

Rectangle {
    id: clockRoot
    width: 200
    height: 60
    color: "transparent"
    
    property string timeFormat: "hh:mm:ss"
    property bool showSeconds: true
    property string textColor: "white"
    property int fontSize: 24
    
    Timer {
        id: clockTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            updateTime()
        }
    }
    
    Text {
        id: clockText
        anchors.centerIn: parent
        text: ""
        color: clockRoot.textColor
        font.pixelSize: clockRoot.fontSize
        font.family: "Monospace"
        font.bold: true
        style: Text.Outline
        styleColor: "black"
    }
    
    function updateTime() {
        var now = new Date()
        var hours = now.getHours()
        var minutes = now.getMinutes()
        var seconds = now.getSeconds()
        
        var timeString = ""
        
        if (clockRoot.timeFormat === "hh:mm:ss") {
            timeString = String(hours).padStart(2, '0') + ":" + String(minutes).padStart(2, '0') + ":" + String(seconds).padStart(2, '0')
        } else if (clockRoot.timeFormat === "hh:mm") {
            timeString = String(hours).padStart(2, '0') + ":" + String(minutes).padStart(2, '0')
        }
        else if (clockRoot.timeFormat === "hh:mm:ss AP") {
            var ampm = hours >= 12 ? 'PM' : 'AM'
            hours = hours % 12
            hours = hours ? hours : 12
            timeString = String(hours).padStart(2, '0') + ":" + String(minutes).padStart(2, '0') + ":" + String(seconds).padStart(2, '0') + " " + ampm
        }
        
        clockText.text = timeString
    }
    
    Component.onCompleted: {
        updateTime()
    }
}
