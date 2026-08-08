import QtQuick
import QtQuick.Controls

Rectangle {
    id: splashScreen
    anchors.fill: parent
    color: "transparent"
    z: 1000
    
    property bool active: true
    
    signal dismissed()
    
    Image {
        id: backgroundImage
        anchors.fill: parent
        source: Qt.resolvedUrl("splash_background.png")
        fillMode: Image.PreserveAspectCrop
        z: -1  // Ensure it stays behind the transparent overlay
        
        Rectangle {
            anchors.fill: parent
            color: "#80000000"  // Semi-transparent dark overlay
            z: 1
        }
    }
    
    Column {
        id: timeDateContainer
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            topMargin: 50
        }
        spacing: 10
        z: 2
        
        Clock {
            id: splashClock
            width: 400
            height: 48
            textColor: "white"
            fontSize: 48
            timeFormat: "hh:mm:ss"
        }
        
        Text {
            id: splashDateText
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(new Date(), "ddd dd/MM/yyyy")
            color: "white"
            font.pixelSize: 20
            font.family: "Sans"
            style: Text.Outline
            styleColor: "black"
            
            Timer {
                interval: 60000
                running: true
                repeat: true
                onTriggered: {
                    splashDateText.text = Qt.formatDateTime(new Date(), "ddd dd/MM/yyyy")
                }
            }
        }
    }
    
    MouseArea {
        anchors.fill: parent
        onClicked: dismiss()
    }
    
    focus: true
    Keys.onPressed: {
        dismiss()
        event.accepted = true
    }
    
    function dismiss() {
        if (!active) return
        active = false
        visible = false
        dismissed()
    }
    
    function show() {
        active = true
        visible = true
        // Refresh the date/time display
        splashClock.updateTime()
        splashDateText.text = Qt.formatDateTime(new Date(), "ddd dd/MM/yyyy")
        forceActiveFocus()
    }
    
    Component.onCompleted: {
        forceActiveFocus()
        console.log("Splash screen ready")
    }
}
