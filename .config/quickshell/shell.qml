import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Bluetooth
import Quickshell.Services.UPower
import Quickshell.Services.Pipewire
import Quickshell.Networking





PanelWindow {
    id: hiddenBar

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: 40
    color: "transparent"
    visible: true

    RowLayout {
        anchors.centerIn: parent
        spacing: 10

        // Left Small Bar
        Rectangle {
            width: 150

            height: hiddenBar.height/1.2
            radius: 100
            color: "#303446"
            Row{
              anchors.centerIn:parent
              spacing: 5
              Repeater {
                 

              
              model:5
              Rectangle{
                required property int index
                readonly property int wsId: index+1
                readonly property bool isActive: Hyprland.focusedWorkspace?.id ===wsId
               anchors.verticalCenter: parent.verticalCenter 
                required property var modelData 
              
              height: isActive ? "12":"10"
              radius: 100
              color: isActive? "#b7bdf8":"#5b6078"
              width: isActive? "40":"10"

              Behavior on width{
                NumberAnimation{

                  duration:500 
                  easing.type:Easing.OutCubic
                }
              }
              Behavior on height{
                NumberAnimation{
                  duration: 20
                  easing.type:Easing.OutCubic
                }
              }
              MouseArea{
                anchors.fill:parent
                onClicked: {
                  Hyprland.dispatch("workspace " + parent.wsId)
                }
              }
            }
          }
        }
      }

        // Main Bar
        Rectangle {
            id: bar

            width: 600
            height: hiddenBar.height / 1.2
            radius: 100
            color: "#414559"

            RowLayout {
                anchors.centerIn: parent
                spacing: 55

                //sound&brightness
                Rectangle{
                  
                  width: 100
                  height : bar.height /1.5
                  radius: 100
                  color: "#7c7f93"
                  Row{
                    id: soundRow
                    anchors.centerIn:parent
                    spacing: 10
                    Rectangle{
                      width: 40 
                      height: 20
                      radius: 100 
                      color :"#303446"
                       clip: true
                      
                      Row{
                       
                        Rectangle{
                          id: vol
                          width: 20 
                          height: 20 
                          color: "#7287fd"
                          radius: 100
                          Text{
                            text: " 󰓃 "
                            clip: true
                            color: "#303446"
                            font{family: "Symbols Nerd Font"}
                            anchors.centerIn: parent

                          } 
                          MouseArea{
                            anchors.fill: parent
                            onWheel: (wheel) => {if (wheel.angleDelta.y > 10) {
                              vol.width += 1
                            }
                            else{
                              vol.width -= 1
                            }
                            vol.width = Math.max(20, Math.min(vol.width, 40))
                            
 
                          }

                          }
                          
                        }
                      }
                    }
                    Rectangle{
                      width: 40 
                      height: 20
                      radius: 100
                      color : "#303446"
                    }

                  }

                }

                // Clock
                Rectangle {
                    width: 140
                    height: bar.height / 1.5
                    radius: 100
                    color: "#303446"

                    SystemClock{
                      id: clock
                      precision: SystemClock.Seconds
                    }
                    Row{ 
                      spacing : 10
                      anchors.centerIn:parent
                    Rectangle {
                     height: 20 
                     width : 20 
                     radius : 100
                     color: "#4c4f69"
                    Text{
                      text: Qt.formatDateTime(clock.date, "hh")
                      anchors.centerIn: parent
                      color:"#dc8a78"
                      font{
                        bold:true;family:"Poppins";pixelSize:12
                        
                      }
                    }
                  }
                     Rectangle {
                     height: 20 
                     width :  20 
                     radius : 100
                     color: "#4c4f69"
                    Text{
                      text: Qt.formatDateTime(clock.date, "mm")
                      anchors.centerIn:parent
                     color: "#dc8a78" 
                    font{
                      bold:true;family:"Poppins"; pixelSize:12
                    }
                  }
                }
                Rectangle{
                  height: 20 
                  width: 70
                  radius: 100
                  color: "#babbf1"
                  
                    Text{
                      text: Qt.formatDateTime(clock.date, "dd MMM")
                      anchors.centerIn:parent
                      font{
                        bold:true;family:"Poppins";pixelSize:12
                      }
                    }
                  
                }
              }

              }

                  

                // System Tray Section
                Rectangle {
                    id: tray

                    width: 110
                    height: bar.height / 1.5
                    radius: 100

                    color: "#303446"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 5
                        anchors.rightMargin: 5

                        spacing: 8

                        // Battery
                        Rectangle {
                            id: batShell

                            property bool hovered: false

                            width: hovered ? 50 : 40
                            height: 20
                            radius: 100

                            color: "transparent"

                            border {
                                width: 1.5
                                color: "#838ba7"
                            }

                            Behavior on width {
                                NumberAnimation {
                                    duration: 100
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true

                                onEntered: batShell.hovered = true
                                onExited: batShell.hovered = false
                            }

                            Rectangle {
                                id: batFill

                                anchors {
                                    left: parent.left
                                    top: parent.top
                                    bottom: parent.bottom
                                    margins: 4
                                }

                                width: (batShell.width - 8)
                                       * UPower.displayDevice.percentage

                                radius: 100

                                color: {
                                    if (UPower.displayDevice.percentage < 0.2)
                                        return "#d20f39"

                                    if (UPower.displayDevice.percentage < 0.4)
                                        return "#fe640b"

                                    if (UPower.displayDevice.percentage < 0.6)
                                        return "#7dc4e4"

                                    return "#91d7e3"
                                }
                            }

                            Text {
                                anchors.centerIn: batFill

                                visible: batShell.hovered
                                opacity: batShell.hovered ? 1 : 0

                                color: "black"

                                text: Math.round(
                                    UPower.displayDevice.percentage * 100
                                ) + "%"

                                font {
                                    family: "JetBrains Mono"
                                    pixelSize: 8
                                    bold: true
                                }

                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: 150
                                    }
                                }
                              }
                              property bool charging:
                              UPower.displayDevice.state===UPowerDeviceState.Charging
                              onChargingChanged: {
                                if(charging){
                                  crazy.restart()
                                }else{
                                  crazy.stop()
                                  batShell.rotation =0
                                }
                              } 
                              RotationAnimation{
                                id: crazy
                                target:batShell
                                property:"rotation"
                                running:charging
                                loops: Animation.Infinite
                                duration: 5000
                                from: 0  
                                to: 360
                                
                                 
                               

                              }
                            }
                          

                        // Network
                        Rectangle {
                            width: 20
                            height: 20
                            radius: 100

                            color: "#b8c0e0"

                            Text {
                                anchors.centerIn: parent

                                text: ""

                                font {
                                    family: "Material Symbols Rounded"
                                    pixelSize: 10
                                }
                            }
                        }

                        // Bluetooth
                        Rectangle {
                            width: 20
                            height: 20
                            radius: 100

                            color: "#494d64"

                            Text {
                              anchors.centerIn: parent
                               color:"#cad3f5"
                               font {
                                    family: "Material Symbols";
                                    pixelSize: 12;
                                   
                                }

                                
                                text: {
                                 

                                  
                                    if (!Bluetooth.defaultAdaptor)
                                        return "󰂯"

                                    return Bluetooth.defaultAdaptor.powered
                                           ? "󰂯"
                                           : "󰂲"
                                }
                            }
                        }
                    }
                }

                // Power Button
                Rectangle {
                    id: powerButton

                    width: 25 
                    height: 25 
                    radius: 100

                    color: "#303446"

                    Text {
                        anchors.centerIn: parent

                        text: " "
                        color: "#ef9f76"

                        font {
                            family: "fontAwesome"
                            pixelSize: 10
                            bold: true
                        }
                      }


                }
            }
        }
    }
}
