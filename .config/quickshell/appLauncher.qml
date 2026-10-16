import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io

PanelWindow {
    id: root

    // Wayland layer shell configuration
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "#99000000" // Dim translucent backdrop

    // Theme Colors (Tokyo Night)
    readonly property color bgDark: "#1a1b26"
    readonly property color bgPanel: "#24283b"
    readonly property color bgHover: "#2f354f"
    readonly property color bgSelected: "#3d59a1"
    readonly property color textPrimary: "#c0caf5"
    readonly property color textSecondary: "#7982a9"
    readonly property color textMuted: "#565f89"
    readonly property color accentBlue: "#7aa2f7"
    readonly property color accentPurple: "#bb9af7"
    readonly property color accentCyan: "#7dcfff"
    readonly property color accentGreen: "#9ece6a"
    readonly property color borderColor: "#414868"

    property string selectedCategory: "All"
    property int selectedIndex: 0
    property var categoriesList: ["All", "Development", "Internet", "Media", "System", "Utilities", "Office", "Graphics", "Games"]

    // Filtered application list
    readonly property var allApps: {
        let list = [];
        if (DesktopEntries && DesktopEntries.applications) {
            for (let i = 0; i < DesktopEntries.applications.values.length; i++) {
                let app = DesktopEntries.applications.values[i];
                if (app && !app.noDisplay && app.name) {
                    list.push(app);
                }
            }
            list.sort((a, b) => a.name.localeCompare(b.name));
        }
        return list;
    }

    readonly property var filteredApps: {
        let q = searchField.text.trim().toLowerCase();
        let cat = selectedCategory;

        return allApps.filter(app => {
            // Category filter
            if (cat !== "All") {
                let cats = (app.categories || []).map(c => c.toLowerCase());
                if (!cats.some(c => c.includes(cat.toLowerCase()))) {
                    return false;
                }
            }

            // Search query filter
            if (!q) return true;

            let nameMatch = (app.name || "").toLowerCase().includes(q);
            let genericMatch = (app.genericName || "").toLowerCase().includes(q);
            let commentMatch = (app.comment || "").toLowerCase().includes(q);
            let idMatch = (app.id || "").toLowerCase().includes(q);
            let execMatch = (app.execString || "").toLowerCase().includes(q);

            return nameMatch || genericMatch || commentMatch || idMatch || execMatch;
        });
    }

    function launchSelected() {
        if (filteredApps.length > 0) {
            let idx = Math.max(0, Math.min(selectedIndex, filteredApps.length - 1));
            let app = filteredApps[idx];
            if (app) {
                app.execute();
                Qt.quit();
            }
        } else if (searchField.text.trim().length > 0) {
            // Fallback: run typed text directly
            Quickshell.execDetached(["sh", "-c", searchField.text.trim()]);
            Qt.quit();
        }
    }

    function closeLauncher() {
        Qt.quit();
    }

    // Dismiss on clicking backdrop
    MouseArea {
        anchors.fill: parent
        onClicked: root.closeLauncher()
    }

    // Main Launcher Modal Card
    Rectangle {
        id: modalCard
        width: Math.min(760, parent.width - 40)
        height: Math.min(620, parent.height - 60)
        anchors.centerIn: parent

        color: root.bgDark
        radius: 18
        border.color: root.borderColor
        border.width: 1

        // Consume clicks inside modal
        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16

            // Header & Search Bar
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Rectangle {
                    Layout.fillWidth: true
                    height: 52
                    radius: 12
                    color: root.bgPanel
                    border.color: searchField.activeFocus ? root.accentBlue : root.borderColor
                    border.width: searchField.activeFocus ? 2 : 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        spacing: 12

                        Text {
                            text: "🔍"
                            font.pixelSize: 18
                            color: root.accentBlue
                        }

                        TextInput {
                            id: searchField
                            Layout.fillWidth: true
                            color: root.textPrimary
                            font.pixelSize: 16
                            font.family: "JetBrains Mono, Roboto, sans-serif"
                            focus: true
                            clip: true

                            Text {
                                text: "Search applications or type command..."
                                color: root.textMuted
                                font.pixelSize: 16
                                font.family: searchField.font.family
                                visible: !searchField.text && !searchField.activeFocus
                            }

                            onTextChanged: {
                                root.selectedIndex = 0;
                            }

                            Keys.onPressed: event => {
                                if (event.key === Qt.Key_Escape) {
                                    root.closeLauncher();
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                    root.launchSelected();
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Down) {
                                    if (root.selectedIndex < root.filteredApps.length - 1) {
                                        root.selectedIndex++;
                                        appsListView.positionViewAtIndex(root.selectedIndex, ListView.Contain);
                                    }
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Up) {
                                    if (root.selectedIndex > 0) {
                                        root.selectedIndex--;
                                        appsListView.positionViewAtIndex(root.selectedIndex, ListView.Contain);
                                    }
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_PageDown) {
                                    root.selectedIndex = Math.min(root.filteredApps.length - 1, root.selectedIndex + 5);
                                    appsListView.positionViewAtIndex(root.selectedIndex, ListView.Contain);
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_PageUp) {
                                    root.selectedIndex = Math.max(0, root.selectedIndex - 5);
                                    appsListView.positionViewAtIndex(root.selectedIndex, ListView.Contain);
                                    event.accepted = true;
                                }
                            }
                        }

                        // Clear Button
                        Rectangle {
                            width: 24
                            height: 24
                            radius: 12
                            color: clearMouse.containsMouse ? root.bgHover : "transparent"
                            visible: searchField.text.length > 0

                            Text {
                                anchors.centerIn: parent
                                text: "✕"
                                color: root.textSecondary
                                font.pixelSize: 12
                            }

                            MouseArea {
                                id: clearMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    searchField.text = "";
                                    searchField.forceActiveFocus();
                                }
                            }
                        }
                    }
                }
            }

            // Category Filter Pills
            ScrollView {
                Layout.fillWidth: true
                Layout.preferredHeight: 34
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                ScrollBar.vertical.policy: ScrollBar.AlwaysOff

                Row {
                    spacing: 8

                    Repeater {
                        model: root.categoriesList

                        Rectangle {
                            id: catChip
                            required property string modelData
                            height: 32
                            width: catText.implicitWidth + 24
                            radius: 8
                            color: root.selectedCategory === modelData ? root.accentBlue : (chipMouse.containsMouse ? root.bgHover : root.bgPanel)
                            border.color: root.selectedCategory === modelData ? root.accentBlue : root.borderColor
                            border.width: 1

                            Text {
                                id: catText
                                anchors.centerIn: parent
                                text: catChip.modelData
                                color: root.selectedCategory === catChip.modelData ? root.bgDark : root.textPrimary
                                font.pixelSize: 13
                                font.bold: root.selectedCategory === catChip.modelData
                            }

                            MouseArea {
                                id: chipMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    root.selectedCategory = catChip.modelData;
                                    root.selectedIndex = 0;
                                    searchField.forceActiveFocus();
                                }
                            }
                        }
                    }
                }
            }

            // Divider Line
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: root.borderColor
            }

            // Applications List View
            ListView {
                id: appsListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 6
                model: root.filteredApps

                currentIndex: root.selectedIndex

                delegate: Rectangle {
                    id: appItem
                    required property var modelData
                    required property int index

                    width: appsListView.width
                    height: 56
                    radius: 10
                    color: index === root.selectedIndex ? root.bgSelected : (itemMouse.containsMouse ? root.bgHover : "transparent")
                    border.color: index === root.selectedIndex ? root.accentBlue : "transparent"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 14

                        // App Icon
                        Image {
                            width: 36
                            height: 36
                            sourceSize.width: 36
                            sourceSize.height: 36
                            source: Quickshell.iconPath(appItem.modelData.icon || "application-x-executable", true) || ""
                            fillMode: Image.PreserveAspectFit

                            // Fallback generic icon if image fails
                            Rectangle {
                                anchors.fill: parent
                                radius: 8
                                color: root.bgPanel
                                visible: parent.status !== Image.Ready

                                Text {
                                    anchors.centerIn: parent
                                    text: "🚀"
                                    font.pixelSize: 18
                                }
                            }
                        }

                        // App Title & Description
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: appItem.modelData.name || "Unknown App"
                                color: index === root.selectedIndex ? "#ffffff" : root.textPrimary
                                font.pixelSize: 15
                                font.bold: true
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            Text {
                                text: appItem.modelData.genericName || appItem.modelData.comment || appItem.modelData.id || ""
                                color: index === root.selectedIndex ? root.textPrimary : root.textSecondary
                                font.pixelSize: 12
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                                visible: text.length > 0
                            }
                        }

                        // Category Pill Tag
                        Rectangle {
                            height: 22
                            width: categoryLabel.implicitWidth + 14
                            radius: 6
                            color: root.bgPanel
                            border.color: root.borderColor
                            border.width: 1
                            visible: (appItem.modelData.categories && appItem.modelData.categories.length > 0)

                            Text {
                                id: categoryLabel
                                anchors.centerIn: parent
                                text: (appItem.modelData.categories && appItem.modelData.categories.length > 0) ? appItem.modelData.categories[0] : ""
                                color: root.accentCyan
                                font.pixelSize: 11
                            }
                        }
                    }

                    MouseArea {
                        id: itemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: {
                            root.selectedIndex = appItem.index;
                        }
                        onClicked: {
                            root.selectedIndex = appItem.index;
                            root.launchSelected();
                        }
                    }
                }

                // Empty state message
                Item {
                    anchors.fill: parent
                    visible: root.filteredApps.length === 0

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "🔍"
                            font.pixelSize: 32
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "No applications found"
                            color: root.textSecondary
                            font.pixelSize: 16
                            font.bold: true
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: searchField.text ? "Press Enter to run as shell command" : "Try searching something else"
                            color: root.textMuted
                            font.pixelSize: 13
                        }
                    }
                }
            }

            // Bottom Status & Key Hints Bar
            Rectangle {
                Layout.fillWidth: true
                height: 32
                color: "transparent"

                RowLayout {
                    anchors.fill: parent

                    Text {
                        text: `${root.filteredApps.length} application${root.filteredApps.length === 1 ? '' : 's'}`
                        color: root.textMuted
                        font.pixelSize: 12
                    }

                    Item { Layout.fillWidth: true }

                    Row {
                        spacing: 12

                        Text {
                            text: "↑/↓ Navigate"
                            color: root.textMuted
                            font.pixelSize: 12
                        }

                        Text {
                            text: "↵ Launch"
                            color: root.accentGreen
                            font.pixelSize: 12
                            font.bold: true
                        }

                        Text {
                            text: "Esc Close"
                            color: root.textMuted
                            font.pixelSize: 12
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        searchField.forceActiveFocus();
    }
}
