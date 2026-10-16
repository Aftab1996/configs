import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import Quickshell.Networking
import Quickshell.Bluetooth
import Quickshell.Services.UPower
import Quickshell.Services.Pipewire
import "."
Variants{
  model: Quickshell.screens.filter(s => s.name === "eDP-1") 
  
  PanelWindow {
  id:bar
  color:"#303446"
  required property var modelData
  screen:modeldata

  height: 30
  anchors{
    top: true
    left: true
    right: true
  }
  Item{
  }

 Rectangle{
      color: "#303446"
      height: parent.height* 0.99
      
      width: bar.width * 0.95
      
      anchors.centerIn:parent


  RowLayout{
    spacing:300 
    anchors.centerIn:parent
anchors.verticalCenter: parent.verticalCenter


    Row {
      spacing:10
      
      Repeater{ 
        model: 10
        
    
      Rectangle{
        required property int index
        readonly property int workSpace: index+1
        readonly property bool isActive: Hyprland.focusedWorkspace?.id === workSpace
        
        anchors.verticalCenter: parent.verticalCenter

        height: isActive ? "10":"10"
        width: isActive ? "25":"10"
        color: isActive ? "#e78284":"#51576d"
        

        MouseArea{
          anchors.fill: parent
          onClicked: Hyprland.dispatch("workspace " + parent.workSpace)

        }

        
        
        
        


        
        

      }
    } 
    }
        
          /////////////
  Row{
  spacing: 1
      //Row1 
      //
SystemClock {
  id: clock
  precision: SystemClock.Seconds
}
Text {
  text: Qt.formatDateTime(clock.date, "hh:mm  yyyy.MM.dd")
  font{
    family: "JetBrains Mono"
    bold: true
    pixelSize: 12
  }
  color: "#8caaee"
}

  



      
      //row2 
    }
    ////////////
    Row{
      spacing: 20
      

      //row3
      //
      Text{
        PwObjectTracker{
    objects: [ Pipewire.defaultAudioSink]
  }

        text:"VOLUME"+ " "+ Math.round(Pipewire.defaultAudioSink.audio.volume * 100) + "%"
        color: "white"
        font{
          family:"JetBrains Mono"

        }

      }
     
    
    Text{
      text:"BATTERY" +  " "    + Math.round((UPower.displayDevice.percentage)*100) + "%"
      color: "#ef9f76"
       font{
          family: "JetBrains Mono"
          bold: true
          pixelSize: 12
        }
        
  




      }
      
      
      IdleInhibitor{
        window: bar
        enabled: false
        id: awake
     
      }

        Text {
          text:awake.enabled? "STUDY" : "SLEEP"
          color: "#ca9ee6"
          font{
            family: "JetBrains Mono"
            bold: true
            
          }

          }
          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: awake.enabled= !awake.enabled
          }

      
              
      
      Text {
    text: UPower.displayDevice.state === UPowerDeviceState.Charging
        ? "CHARGING"
        : "NOTCHARGING"
         font{
          family: "JetBrains Mono"
          bold: false
          pixelSize: 12
        }
        color:"#eebebe"
        

      }
        
       
  

  }
  

}
   } 
 } 
 }
 
