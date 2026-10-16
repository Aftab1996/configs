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
  height: 30
  width : 1000
  visible: true



  anchors{
    top:true
    
    
  }
  color: "transparent"

  Rectangle{
    id: mainBar 
    height: hiddenBar.height/1.2
    width: hiddenBar.width/1.1
    anchors.centerIn:parent
    radius:5
   
  
  Row {
    spacing: 200
    anchors.centerIn:parent
  Rectangle{
    id:left1 
    color: "black"
     anchors.verticalCenter:parent.verticalCenter
    height: 20
    width: 200
    radius:3

    SystemClock {
  id: clock
  precision: SystemClock.Seconds
}
Row{
  spacing: 10
  anchors.centerIn:parent
  


Text {
  text: Qt.formatDateTime(clock.date, "hh:mm")
  color: "white"
  
  font{
    family:Poppins
    bold:true
  }
}
Rectangle{
  id: battery
  Text{
    text:UPowerDevice
    color: "white"
  }
}



}


     
  
  }
  Rectangle{
    id:center1 
    color: "black"
    anchors.verticalCenter:parent.verticalCenter
    height: 20
    width: 100
    radius:3
  }

Rectangle{
    id:right1 
    color: "black"
    anchors.verticalCenter:parent.verticalCenter
    height: 20
    width: 100
    radius: 3
  }


}
}



  /////////////////////////last bracket//////////////////////////////////
}


