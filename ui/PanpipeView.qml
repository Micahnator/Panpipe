import QtQuick 2.4
import Ubuntu.Components 1.3

import "pages"

//import Ubuntu.Colors

//PageStack {
//    id: mainStack


//}

Item {
    id: mainLayout

//    AdaptivePageLayout {
//        id: adaptiveLayout
//        anchors.fill: parent

////        primaryPage: Qt.resolvedUrl("StationsPage.qml")
//        primaryPage: testPage


////        StationsPage {
////            id: stationsListPage
////        }

//        Page {
//            id: testPage

//            title: "Test Page"

//            Rectangle {
//                anchors.verticalCenter: parent.verticalCenter
//                anchors.horizontalCenter: parent.horizontalCenter
//                width: units.gu(5)
//                height: width
//                color: "Red"
//            }
//        }
//    }






//    AdaptivePageLayout {
//            id: layout
//            anchors.fill: parent
//            primaryPage: rootPage

//            Page {
//                id: rootPage
//                title: i18n.tr("Root page")

//                Column {
//                    anchors {
//                        top: parent.top
//                        left: parent.left
//                        margins: units.gu(1)
//                    }
//                    spacing: units.gu(1)

//                    Button {
//                        text: "Add page left"
//                        onClicked: layout.addPageToCurrentColumn(rootPage, leftPage)
//                    }
//                    Button {
//                        text: "Add page right"
//                        onClicked: layout.addPageToNextColumn(rootPage, rightPage)
//                    }
//                    Button {
//                        text: "Add sections page right"
//                        onClicked: layout.addPageToNextColumn(rootPage, sectionsPage)
//                    }
//                }
//            }

//            Page {
//                id: leftPage
//                title: i18n.tr("First column")

//                Rectangle {
//                    anchors {
//                        fill: parent
//                        margins: units.gu(2)
//                    }
//                    color: UbuntuColors.orange

//                    Button {
//                        anchors.centerIn: parent
//                        text: "right"
//                        onTriggered: layout.addPageToNextColumn(leftPage, rightPage)
//                    }
//                }
//            }

//            Page {
//                id: rightPage
//                title: i18n.tr("Second column")

//                Rectangle {
//                    anchors {
//                        fill: parent
//                        margins: units.gu(2)
//                    }
//                    color: UbuntuColors.green

//                    Button {
//                        anchors.centerIn: parent
//                        text: "Another page!"
//                        onTriggered: layout.addPageToCurrentColumn(rightPage, sectionsPage)
//                    }
//                }
//            }

//            Page {
//                id: sectionsPage
//                title: i18n.tr("Page with sections")
//                head.sections.model: [i18n.tr("one"), i18n.tr("two"), i18n.tr("three")]

//                Rectangle {
//                    anchors {
//                        fill: parent
//                        margins: units.gu(2)
//                    }
//                    color: UbuntuColors.blue
//                }
//            }
//        }

}
