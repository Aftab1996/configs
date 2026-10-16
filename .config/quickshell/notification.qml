import Quickshell 
import Quickshell.Wayland
import Quickshell.Services.Notifications
import QtQuick 
import QtQuick.Layouts
import Quickshell.Io 
import "config.js" as Config 

Scope{
  id: root
  property bool centerOpen: false
  ListModel{ id: history }

  NotificationServer{
    id: server 
        actionsSupported:true 
    imageSupported:true 
    bodySupported:true
    onNotification: n =>{ n.tracked =true
    history.insert(0,{
      summary: n.summary,
      body: n.body,
      appName: n.appName,
      urgency:n.urgency,
      time: Qt.formatDateTime(new date(),"HH:mm")
    })



  }//ntracked
}
IpcHandler{
  target: "notifications"
  function toggle(): void {root.centerOpen = !root.centerOpen}
  function show(): void {root.centerOpen=true}
  function hide(): void{root.centerOpen =false}
}
PanelWindow{
    anchors{
      bottom:true
      right:true 
    }
    margins{
      bottom:20
      right: 20
    }
    implicitWidth:200
    implicitHeight: Math.max(1,column.implicitHeight)
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    ColumnLayout{
      id:column
      width: parent.width 
      spacing: 10 
      Repeater{
        model:server.trackedNotifications
        delegate:Rectangle {
          id:card 
          Timer{
            running: card.modelData.urgency !== NotificationUrgency.Critical 
            interval:Config.notifications.timeout 
            onTriggered: card.modelData.dismiss()

          }
          required property var modelData
          //Layout.preferredHeight: 40
          Layout.fillWidth:true
          Layout.preferredHeight: layout.implicitHeight + 20
          color:modelData.urgency === NotificationUrgency.Critical 
          ? Config.colors.peach : Config.colors.crust  

          RowLayout{
            id:layout 
            anchors.fill:parent
            anchors.margins:2
            spacing:12 

            Image{
              Layout.preferredHeight:20
              Layout.preferredWidth: 20
              Layout.alignment:Qt.AlignTop 
              fillMode:Source.toString() !== ""

              source:card.modelData.image || card.modelData.appIcon ||""
            }//image 
           ColumnLayout{
             Layout.fillWidth:true
             spacing : 5
             Text{
               Layout.fillWidth:true
               text: card.modelData.summary
               font.family:Config.fontFamily 
               font.pixelSize : Config.bar.fontSize
               font.bold:true
               color:Config.colors.text 
               elide:Text.ElideRight
             }//summarytext
              Text{
                Layout.fillWidth:true
                visible:text !== ""
               text: card.modelData.body 
               font.family:Config.fontFamily 
               font.pixelSize : Config.bar.fontSize - 2
               font.bold:true
               color:Config.colors.subtext1 
               wrapMode: Text.WordWrap
             }
           }
         }//rowlayoutservertextsummarybody 
         MouseArea{
           anchors.fill:parent
           onClicked:card.modelData.dismiss()
         }

        }//rectangle.id.card 
      }//reapterid.card
      
    }//server's clumn layouts


  }

//--------------------------------------------------------------------------------------//orginal//
  //notificationpanel//  
  PanelWindow{
    
    visible:root.centerOpen
    anchors{
      bottom:true
      right:true 
    }
    margins{
      bottom:20
      right: 20
    }
    implicitWidth:200
    implicitHeight: centerCol.implicitHeight + 25
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    Rectangle{
      
      anchors.fill:parent
      
      color:Config.colors.base  

    ColumnLayout{
      id:centerCol 
      anchors.fill:parent 
      anchors.margins: 12
       
      spacing: 10 

      RowLayout{
        Layout.fillWidth:true
        Text{
          Layout.fillWidth: true
          text:"notifications"
          color:Config.colors.yellow
          font.family:Config.bar.fontFamily
          font.pixelSize:Config.bar.fontSize + 2

        }
        Text{
          text:"clear all"
          visible:history.count > 0 
          color:Config.colors.yellow
          font.family:Config.bar.fontFamily
          font.pixelSize:Config.bar.fontSize + -1 
          MouseArea{
            anchors.fill:parent
            onClicked:history.clear()
          }

        }
      }
      
    
    Repeater{
        model:server.trackedNotifications
        delegate:Rectangle {
          id:card 
         
          required property var modelData
          Layout.preferredHeight: 40
          Layout.fillWidth:true
          Layout.preferredHeight: layout.implicitHeight + 20
          color:modelData.urgency === NotificationUrgency.Critical 
          ? Config.colors.peach : Config.colors.crust 
          ColumnLayout{

            id: cardCol 
            anchors.fill:parent
            anchors.margins:8
            spacing:2

          RowLayout{
            Layout.fillWidth:true 
            spacing:6 
            
            Text{
               Layout.fillWidth:true
               text: card.modelData.summary
               font.family:Config.fontFamily 
               font.pixelSize : Config.bar.fontSize
               font.bold:true
               color:Config.colors.text 
               elide:Text.ElideRight
             }
           
             Text{
               text:model.time 
               color: Config.colors.text
               font.family:Config.fontFamily 
               font.pixelSize : Config.bar.fontSize -3

             }
             Text{
               text: "x"
               color: Config.colors.text
               font.family:Config.fontFamily 
               font.pixelSize : Config.bar.fontSize -3
               MouseArea{
                 anchors.fill:parent 
                 onClicked:history.remove(index)
               }


             }
           }
              Text{
                Layout.fillWidth:true
                visible:text !== ""
               text: card.modelData.body 
               font.family:Config.fontFamily 
               font.pixelSize : Config.bar.fontSize - 2
               font.bold:true
               color:Config.colors.subtext1 
               wrapMode: Text.WordWrap
             }
             Text{
             visible:model.appName!==""
             text:model.appName
             font.family:Config.fontFamily 
             font.pixelSize : Config.bar.fontSize - 2
            font.bold:true
            color:Config.colors.subtext1
          }
         }
         }
       }//rowlayoutservertextsummarybody 
     
     }//rectangle.id.card 
   }
  }//base of panel
}

  //card of NotificationServer

//scopelast line

