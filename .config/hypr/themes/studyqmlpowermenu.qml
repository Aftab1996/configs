
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io

PanelWindow {
    id: root

    width: 600
    height: 600
    color: "#414559"

    RowLayout {
        anchors.centerIn: parent
        spacing: 12

        Button {
            id: logoutButton
            text: "logout"

            contentItem: Text {
                text: logoutButton.text
                color: "#232634"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                implicitWidth: 80
                implicitHeight: 40
                radius: 6
                color: "#8caaee"
            }

            onClicked: {
                // e.g., Quickshell.exec(["hyprctl", "dispatch", "exit"])
            }
        }

        Button {
            id: helloButton
            text: "hello"

            contentItem: Text {
                text: helloButton.text
                color: "#c6d0f5"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                implicitWidth: 80
                implicitHeight: 40
                radius: 6
                color: "#51576d"
            }

            onClicked: {
                console.log("Hello clicked!")
            }
        }
    }
}
