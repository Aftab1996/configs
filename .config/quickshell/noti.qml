
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "config.js" as Config

Scope {
    id: root

    property bool centerOpen: false

    ListModel {
        id: history
    }

    NotificationServer {
        id: server

        actionsSupported: true
        imageSupported: true
        bodySupported: true

        onNotification: n => {
            n.tracked = true

            history.insert(0, {
                summary: n.summary,
                body: n.body,
                appName: n.appName,
                urgency: n.urgency,
                time: Qt.formatDateTime(new Date(), "HH:mm")
            })
        }
    }

    IpcHandler {
        target: "notifications"

        function toggle(): void {
            root.centerOpen = !root.centerOpen
        }

        function show(): void {
            root.centerOpen = true
        }

        function hide(): void {
            root.centerOpen = false
        }
    }

    // Temporary notification popups
    PanelWindow {
        anchors {
            bottom: true
            right: true
        }

        margins {
            bottom: 20
            right: 20
        }

        implicitWidth: 300
        implicitHeight: Math.max(1, popupColumn.implicitHeight)
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore

        ColumnLayout {
            id: popupColumn
            width: parent.width
            spacing: 10

            Repeater {
                model: server.trackedNotifications

                delegate: Rectangle {
                    id: popupCard

                    required property var modelData

                    Layout.fillWidth: true
                    Layout.preferredHeight: popupContent.implicitHeight + 16

                    radius: 0 
                    color: Config.colors.crust

                    Timer {
                        interval: Config.notifications.timeout
                        running: popupCard.modelData.urgency
                                 !== NotificationUrgency.Critical
                        onTriggered: popupCard.modelData.dismiss()
                    }

                    RowLayout {
                        id: popupContent

                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 10

                        Image {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            Layout.alignment: Qt.AlignTop

                            source: popupCard.modelData.image !== ""
                                    ? popupCard.modelData.image
                                    : popupCard.modelData.appIcon

                            fillMode: Image.PreserveAspectFit
                            visible: source !== ""
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                Layout.fillWidth: true
                                text: popupCard.modelData.summary
                                font.family: Config.bar.fontFamily
                                font.pixelSize: Config.bar.fontSize*2
                                font.bold: true
                                color:  modelData.urgency === NotificationUrgency.Critical
                           ? Config.colors.peach
                           : Config.colors.sky
                                elide: Text.ElideRight
                                wrapMode: Text.WordWrap
                            }

                            Text {
                                Layout.fillWidth: true
                                text: popupCard.modelData.body
                                visible: text !== ""
                                font.family: Config.bar.fontFamily
                                font.pixelSize: Config.bar.fontSize+3 
                                color: Config.colors.subtext1
                                wrapMode: Text.WordWrap
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: popupCard.modelData.dismiss()
                    }
                }
            }
        }
    }

    // Notification history panel
    PanelWindow {
        id: historyPanel

        visible: root.centerOpen

        anchors {
            bottom: true
            right: true
        }

        margins {
            bottom: 20
            right: 20
        }

        implicitWidth: 320
        implicitHeight: Math.min(historyColumn.implicitHeight + 24, 600)

        color: "transparent"
        exclusionMode: ExclusionMode.Ignore

        Rectangle {
            anchors.fill: parent
            radius: 0
            color: Config.colors.base
            clip: true

            ColumnLayout {
                id: historyColumn

                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        Layout.fillWidth: true
                        text: "Notifications"
                        color: Config.colors.yellow
                        font.family: Config.bar.fontFamily
                        font.pixelSize: Config.bar.fontSize + 2
                    }

                    Text {
                        text: "Clear all"
                        visible: history.count > 0
                        color: Config.colors.yellow
                        font.family: Config.bar.fontFamily
                        font.pixelSize: Config.bar.fontSize

                        MouseArea {
                            anchors.fill: parent
                            onClicked: history.clear()
                        }
                    }
                }

                // IMPORTANT: use history, not server.trackedNotifications
                ListView {
                    id: historyList

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    implicitHeight: Math.min(contentHeight, 500)

                    clip: true
                    spacing: 8
                    model: history

                    delegate: Rectangle {
                        id: historyCard

                        required property string summary
                        required property string body
                        required property string appName
                        required property string time
                        required property int urgency

                        width: historyList.width
                        implicitHeight: historyCardColumn.implicitHeight + 16

                        radius: 0
                        color: urgency === NotificationUrgency.Critical
                               ? Config.colors.peach
                               : Config.colors.crust

                        ColumnLayout {
                            id: historyCardColumn

                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 4

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6

                                Text {
                                    Layout.fillWidth: true
                                    text: historyCard.summary
                                    font.family: Config.bar.fontFamily
                                    font.pixelSize: Config.bar.fontSize
                                    font.bold: true
                                    color: Config.colors.text
                                    elide: Text.ElideRight
                                }

                                Text {
                                    text: historyCard.time
                                    font.family: Config.bar.fontFamily
                                    font.pixelSize: Config.bar.fontSize - 3
                                    color: Config.colors.text
                                }

                                Text {
                                    text: "×"
                                    font.pixelSize: Config.bar.fontSize + 2
                                    color: Config.colors.text

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: history.remove(index)
                                    }
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                text: historyCard.body
                                visible: text !== ""
                                font.family: Config.fontFamily
                                font.pixelSize: Config.bar.fontSize - 2
                                color: Config.colors.subtext1
                                wrapMode: Text.WordWrap
                            }

                            Text {
                                Layout.fillWidth: true
                                text: historyCard.appName
                                visible: text !== ""
                                font.family: Config.fontFamily
                                font.pixelSize: Config.bar.fontSize - 2
                                color: Config.colors.subtext1
                            }
                        }
                    }
                }
            }
        }
    }
}

