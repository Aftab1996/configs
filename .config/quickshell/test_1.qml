import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import QtQuick.Controls
import "/home/tipu/.config/quickshell/config.js" as Config 

PanelWindow{

  height: 500
  width: 500
  color: Config.colors.mantle
  visible:true
  exclusionMode:ExclusionMode.Ignore
  WlrLayershell.keyboardFocus:WlrKeyboardFocus.Exlcusive
  WlrLayershell.layer:WlrLayer.Top

  ListView{
    anchors.fill:parent
    model:DesktopEntries.applications.values
    clip:true
    spacing: 10
    anchors.margins: 50
   
    
    delegate:Text{
      
        text:modelData.name
        required property var modelData
        font{
          family:Config.bar.fontFamily
          pixelSize:mouseArea.containsMouse? Config.bar.fontSize * 3 : Config.bar.fontSize * 2
        }
        color:mouseArea.containsMouse? Config.colors.sky : Config.colors.subtext1

        MouseArea{
          id: mouseArea 
          anchors.fill:parent
          hoverEnabled: true
          cursorShape:Qt.PointingHandCursor
          onClicked:{
            modelData.execute()
            root.visible =false
          }

        }
      }
    
  }
}
