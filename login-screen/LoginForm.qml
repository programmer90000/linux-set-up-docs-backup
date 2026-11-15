import QtQuick
import QtQuick.Controls

Rectangle {
    id: fullScreenRoot
    anchors.fill: parent
    color: "transparent"

    z: -2

    property string selectedUsername: ""
    property string selectedAvatarPath: ""
    property alias passwordInput: passwordField
    property alias powerBtn: powerBtn
    property alias splashButton: showSplashButton

    signal loginRequested(string username, string password)
    signal showSplashRequested()

    onSelectedUsernameChanged: {
        passwordField.text = ""
    }

    Image {
        id: formBackground
        anchors.fill: parent
        source: Qt.resolvedUrl("splash_background.png")
        fillMode: Image.PreserveAspectCrop
        z: -1

        Rectangle {
            anchors.fill: parent
            color: "#80000000"
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
        z: 1

        Clock {
            id: loginClock
            width: 400
            height: 48
            textColor: "white"
            fontSize: 48
            timeFormat: "hh:mm:ss"
        }

        Text {
            id: dateText
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
                    dateText.text = Qt.formatDateTime(new Date(), "ddd dd/MM/yyyy")
                }
            }
        }
    }

    Button {
        id: showSplashButton
        width: 48
        height: 48
        anchors {
            top: parent.top
            left: parent.left
            margins: 20
        }
        z: 2

        activeFocusOnTab: true

        Image {
            anchors.centerIn: parent
            source: Qt.resolvedUrl("assets/back_arrow_icon.png")
            width: 24
            height: 24
            fillMode: Image.PreserveAspectFit
        }

        background: Rectangle {
            radius: 24
            color: showSplashButton.pressed ? "#3a6ea5" : (showSplashButton.hovered ? "#2a2a2a" : "#1e1e1e")
            border.color: showSplashButton.activeFocus ? "#ffffff" : "#3a3a3a"
            border.width: showSplashButton.activeFocus ? 2 : 1
        }

        ToolTip {
            visible: parent.hovered
            text: "Show Splash Screen"
            delay: 500
            background: Rectangle {
                color: "#1e1e1e"
                radius: 4
            }
            contentItem: Text {
                text: parent.text
                color: "white"
            }
        }

        onClicked: {
            showSplashRequested()
        }

        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                showSplashRequested()
                event.accepted = true
            }
        }
    }

    Column {
        id: loginContent
        spacing: 15
        width: 300
        anchors.centerIn: parent

        Item {
            id: avatarContainer
            width: 80
            height: 80
            anchors.horizontalCenter: parent.horizontalCenter

            Image {
                id: avatarImage
                anchors.fill: parent
                source: fullScreenRoot.selectedAvatarPath || ""
                fillMode: Image.PreserveAspectFit
                visible: false
                cache: false

                onStatusChanged: {
                    if (status === Image.Ready) {
                        visible = true
                        fallbackRect.visible = false
                    } else if (status === Image.Error) {
                        visible = false
                        fallbackRect.visible = true
                    }
                }
            }

            Rectangle {
                id: fallbackRect
                anchors.fill: parent
                radius: 40
                color: "#3a6ea5"
                visible: true

                Text {
                    anchors.centerIn: parent
                    text: fullScreenRoot.selectedUsername !== "" ? fullScreenRoot.selectedUsername.charAt(0).toUpperCase() : "?"
                    color: "white"
                    font.pixelSize: 36
                    font.bold: true
                }
            }
        }

        Item { height: 5 }

        Text {
            id: usernameLabel
            width: parent.width
            text: fullScreenRoot.selectedUsername !== "" ? fullScreenRoot.selectedUsername : "Select a user"
            font.pixelSize: 14
            font.bold: fullScreenRoot.selectedUsername !== ""
            color: fullScreenRoot.selectedUsername !== "" ? "#3a6ea5" : "#999999"
            horizontalAlignment: Text.AlignHCenter
        }

        Item { height: 10 }

        TextField {
            id: passwordField
            width: parent.width
            height: 45
            placeholderText: "Password"
            echoMode: TextField.NoEcho
            font.pixelSize: 16
            activeFocusOnTab: true
            enabled: fullScreenRoot.selectedUsername !== ""

            background: Rectangle {
                color: fullScreenRoot.selectedUsername !== "" ? "white" : "#f0f0f0"
                radius: 5
                border.color: passwordField.activeFocus ? "#3a6ea5" : (fullScreenRoot.selectedUsername !== "" ? "#cccccc" : "#e0e0e0")
                border.width: passwordField.activeFocus ? 2 : 1
            }

            onAccepted: {
                if (fullScreenRoot.selectedUsername !== "" && passwordField.text !== "") {
                    fullScreenRoot.loginRequested(fullScreenRoot.selectedUsername, passwordField.text)
                }
            }
        }
    }

    PowerButton {
        id: powerBtn
        anchors {
            bottom: parent.bottom
            right: parent.right
            margins: 20
        }
        z: 2
    }

    function setUsername(username, avatarPath) {
        fullScreenRoot.selectedUsername = username

        if (avatarPath && avatarPath !== "") {
            fullScreenRoot.selectedAvatarPath = avatarPath
        } else {
            fullScreenRoot.selectedAvatarPath = "/etc/qtgreet/" + username + "/profile-picture.png"
        }

        avatarImage.visible = false
        fallbackRect.visible = true

        avatarImage.source = ""
        avatarImage.source = fullScreenRoot.selectedAvatarPath

        passwordField.text = ""
        passwordField.forceActiveFocus()
    }
}