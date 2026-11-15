import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: mainWindow
    width: 1920
    height: 1080
    color: "transparent"

    UserList {
        id: userList
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.margins: 20
        visible: !splashScreen.active
        enabled: !splashScreen.active

        KeyNavigation.tab: loginForm.splashButton
        KeyNavigation.backtab: loginForm.powerBtn

        onUserSelected: function(username, avatarPath) {
            loginForm.setUsername(username, avatarPath)
            loginForm.passwordInput.forceActiveFocus()
        }
    }

    LoginForm {
        id: loginForm
        visible: !splashScreen.active

        splashButton.KeyNavigation.tab: passwordInput
        splashButton.KeyNavigation.backtab: userList

        passwordInput.KeyNavigation.tab: powerBtn
        passwordInput.KeyNavigation.backtab: splashButton

        powerBtn.KeyNavigation.tab: userList
        powerBtn.KeyNavigation.backtab: passwordInput

        onLoginRequested: function(username, password) {
            // QtGreet backend handles authentication requests directly
            greeter.login(username, password)
        }
        onShowSplashRequested: {
            splashScreen.show()
        }
    }

    SplashScreen {
        id: splashScreen
        onDismissed: {
            userList.selectFirstUser()
            loginForm.passwordInput.forceActiveFocus()
        }
    }

    Component.onCompleted: {
        if (splashScreen.active) {
            splashScreen.forceActiveFocus()
        } else {
            userList.selectFirstUser()
            loginForm.passwordInput.forceActiveFocus()
        }
    }
}