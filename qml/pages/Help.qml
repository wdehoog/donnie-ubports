import Ergo 0.0
import QtQuick 2.7
import QtQuick.Controls 2.2

import "../components"

Page {
    id: aboutPage
    objectName: "HelpPage"


    header: PageHeader  {
        id: header
        title: i18n.tr("Help") 
    }

    ScrollView  {
        id: flick
        anchors.fill: parent

        Text {
            width: parent.width - 2*x
            x: app.paddingMedium
            y: app.paddingMedium
            wrapMode:wrap
            font.pixelSize: app.fontPixelSizeLarge
            text: "
Lists:<br>            
<ul>
  <li>Press and Hold to get context menu</li>
</ul>
<br>
Player Area:<br>
<ul>
  <li>Press on image to go to Player page</li>
  <li>Swipe Left/Right for Prev/Next</li>
</ul><br>
Discovery Page:<br>
<ul>
  <li>Press an item to view some of it's properties </li>
</ul>
"
        }
    }
}
