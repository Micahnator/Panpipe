/*
Copyright (C) 2015 Micah Losli <micah.losli@gmail.com>

This file is part of Panpipe.

Panpipe is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Panpipe is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Panpipe.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.4
import Ubuntu.Components 1.3

import "pages"

//import Ubuntu.Colors

Item {
    id: mainLayout

    /* Signals */
    signal stationSelected(string stationToken)
    signal nextTrack()
    signal play()
    signal pause()
    signal thumbsUp()
    signal thumbsDown()

    /* Aliases */
    property alias stationData: stationsPage.dataModel

    property alias currentAlbumArtUrl: playerPage.currentAlbumArtUrl
    property alias currentSongName: playerPage.currentSongName
    property alias currentSongAlbum: playerPage.currentSongAlbum
    property alias currentSongArtist: playerPage.currentSongArtist

//    property alias currentStationName: playerPage.currentStationName

    property alias playbackPercentage: playerPage.playbackPercentage

    property bool audioPlaying
    property int playbackPosition
    property int playbackDuration
    property string audioSourceUrl
    property int currentSongRating

    AdaptivePageLayout {
        id: layout
        anchors.fill: parent
        primaryPage: stationsPage

        StationsPage {
            id: stationsPage

            /* Event handling */
            onStationClicked: {
                stationSelected(stationToken);
                playerPageTransitionDelayTimer.start();
            }
            Timer {
                id: playerPageTransitionDelayTimer
                interval: 500
                repeat: false

                onTriggered: {
                    layout.addPageToNextColumn(stationsPage, playerPage);
                }
            }
        }

        PlayerPage {
            id: playerPage

//            onSkipButtonPressed: {
//                nextTrack();
//            }
        }

    }

//    anchors.centerIn: parent
//    anchors.fill: parent

//    PageStack {
//        id: mainStack

////        anchors.fill: parent
//        anchors {
//            fill: undefined
//            left: parent.left
//            right: parent.right
//            top: parent.top
//            bottom: parent.bottom
//        }


//        Component.onCompleted: push(stationsView)

//        StationsPage {
//            id: stationsView
//            anchors.fill: parent
//        }


//        PlayerPage {
//            id: playerView
//        }
//    }


//    AdaptivePageLayout {
//        id: layout
//        anchors.fill: parent
//        primaryPage: rootPage

//        Page {
//            id: rootPage
//            title: i18n.tr("Root page")

//            Column {
//                anchors {
//                    top: parent.top
//                    left: parent.left
//                    margins: units.gu(1)
//                }
//                spacing: units.gu(1)

//                Button {
//                    text: "Add page left"
//                    onClicked: layout.addPageToCurrentColumn(rootPage, leftPage)
//                }
//                Button {
//                    text: "Add page right"
//                    onClicked: layout.addPageToNextColumn(rootPage, rightPage)
//                }
//                Button {
//                    text: "Add sections page right"
//                    onClicked: layout.addPageToNextColumn(rootPage, sectionsPage)
//                }
//            }
//        }

//        Page {
//            id: leftPage
//            title: i18n.tr("First column")

//            Rectangle {
//                anchors {
//                    fill: parent
//                    margins: units.gu(2)
//                }
//                color: UbuntuColors.orange

//                Button {
//                    anchors.centerIn: parent
//                    text: "right"
//                    onTriggered: layout.addPageToNextColumn(leftPage, rightPage)
//                }
//            }
//        }

//        Page {
//            id: rightPage
//            title: i18n.tr("Second column")

//            Rectangle {
//                anchors {
//                    fill: parent
//                    margins: units.gu(2)
//                }
//                color: UbuntuColors.green

//                Button {
//                    anchors.centerIn: parent
//                    text: "Another page!"
//                    onTriggered: layout.addPageToCurrentColumn(rightPage, sectionsPage)
//                }
//            }
//        }

//        Page {
//            id: sectionsPage
//            title: i18n.tr("Page with sections")
//            head.sections.model: [i18n.tr("one"), i18n.tr("two"), i18n.tr("three")]

//            Rectangle {
//                anchors {
//                    fill: parent
//                    margins: units.gu(2)
//                }
//                color: UbuntuColors.blue
//            }
//        }
//    }


}
