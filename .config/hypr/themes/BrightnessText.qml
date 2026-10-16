import QtQuick
import Quickshell
import Quickshell.Wayland 
import Quickshell.Io


FloatingWindow{
  implicitWidth: 200
  implicitHeight: 200
  color:"black"

  property int a:0
  property int b:0
  property int result:Math.round(a/b * 100)

  Text{
    id:brightness 
    color:"white"
    font.pixelSize:24
    anchors.centerIn:parent
    text: "BRIGHTNESS" + (result) + "%"
  }
  Process{
    id:current
    command:["brightnessctl", "g"]
    stdout:StdioCollector{
      onStreamFinished:a = this.text 
    }
  }
  Process{
    id:max
    command:["brightnessctl", "m"]
    stdout:StdioCollector{
      onStreamFinished:b = this.text 
    }
    
    
  }
  Timer{
      interval: 2000
      running:true 
      repeat: true 
      triggeredOnStart:true 
      onTriggered:{
        current.running = true ; max.running = true 
      } 
    }





  }
