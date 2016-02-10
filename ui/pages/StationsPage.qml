/*
Copyright (C) 2015-2016 Micah Losli <micah.losli@gmail.com>

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

import "../components"

Page {
    title: i18n.tr("Stations")
    anchors.fill: parent

    /* Set header text to white */
    head.foregroundColor: "white"

    /* Signals */
    signal stationClicked(string stationToken)
    signal stationLongPressed(string stationToken)

    /* Aliases */
    property alias dataModel: stationListView.model

    /* Properties */
    property bool showBottomControl: ((audioPlayer.playlist.itemCount > 0) && (!playerPage.visible))


    /* Timer used for swipe detection */
    Timer {
        id: justSwiped
        interval: 1
    }

    /* Set a white background for stations list */
    Rectangle {
        anchors.fill: parent
        color: "#FFFFFF"
    }

    /* Station Listview */
    /*
    Note: See PandoraStationsModel.qml
    for a definition of what data fields
    are in each data model item.
    */
    ScrollView {
        anchors {
            top: parent.top
            right: parent.right
            bottom: (showBottomControl) ? nowPlayingBar.top : parent.bottom
            left: parent.left
        }

        UbuntuListView {
            id: stationListView

            anchors.fill: parent

            clip: true  /* Keep list items properly contained */

            currentIndex: -1    /* Start with no station selected */

            delegate: ListItem {
                /* Background color */
                color: (index === stationListView.currentIndex) ? UbuntuColors.orange : "transparent"

                /* Station art */
                Image {
                    id: stationArt
                    anchors {
                        left: parent.left
                        verticalCenter: parent.verticalCenter
                    }
                    height: parent.height
                    width: height
                    sourceSize {
                        height: 40
                        width: height
                    }
                    source: artUrl
                    asynchronous: true
                    fillMode: Image.PreserveAspectFit
                }

                /* Station name */
                Text {
                    id: stationNameText
                    anchors {
                        left: stationArt.right
                        leftMargin: units.gu(1)
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }

                    text: stationName
                    elide: Text.ElideRight
                }

                /* Click handling */
                onClicked: {
                    stationListView.currentIndex = index;
                    stationClicked(stationToken);
                }
            }

        }
    }

    /* Now playing info / controls */
    Item {
        id: nowPlayingBar

        width: parent.width
        height: units.gu(7)

        visible: showBottomControl

        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        /* Gray background for nowPlayingBar (to provide an opaque background) */
        Rectangle {
            anchors.fill: parent
            color: "#F0F0F0"
        }

        /* Blurred background version of current song art */
        BlurredBackground {
            id: blurredBackground

            anchors.fill: parent

            art: currentAlbumArtUrl
            backgroundStrength: 0.7
        }

        /* Black semi-transparent filter */
        Rectangle {
            anchors.fill: parent
            color: "black"
            opacity: 0.85
        }

        /* Current song art */
        Image {
            id: nowPlayingThumbnail

            height: parent.height
            width: height
            anchors {
                left: parent.left
                bottom: parent.bottom
            }
            fillMode: Image.PreserveAspectCrop
            source: currentAlbumArtUrl
        }

        /* Play / pause button */
        AbstractButton {
            id: nowPlayingPlayPause
            height: parent.height
            width: height

            anchors {
                right: parent.right
                bottom: parent.bottom
            }

            Icon {
                id: playPauseIcon
                anchors.fill: parent
                name: (mainLayout.audioPlaying) ? "media-playback-pause" : "media-playback-start"
            }

            onClicked: (mainLayout.audioPlaying) ? pause() : play()
        }

        Label {
            id: nowPlayingArtist

            anchors {
                left: nowPlayingThumbnail.right
                leftMargin: units.gu(1)
                right: nowPlayingPlayPause.left
                bottom: nowPlayingAlbum.top
            }

            text: currentSongName
            color: "white"
            fontSize: "medium"
            horizontalAlignment: Text.AlignLeft
            elide: Text.ElideRight
        }

        Label {
            id: nowPlayingAlbum

            anchors {
                left: nowPlayingThumbnail.right
                leftMargin: units.gu(1)
                right: nowPlayingPlayPause.left
                bottom: nowPlayingSong.top
            }

            text: "On \"" + currentSongAlbum + "\""
            color: "white"
            fontSize: "small"
            horizontalAlignment: Text.AlignLeft
            elide: Text.ElideRight
        }

        Label {
            id: nowPlayingSong

            anchors {
                left: nowPlayingThumbnail.right
                leftMargin: units.gu(1)
                right: nowPlayingPlayPause.left
                bottom: parent.bottom
                bottomMargin: units.gu(0.5)
            }

            text: "By " + currentSongArtist
            color: "white"
            fontSize: "small"
            horizontalAlignment: Text.AlignLeft
            elide: Text.ElideRight
        }

        SwipeArea {
            anchors {
                left: parent.left
                right: nowPlayingPlayPause.left
                bottom: parent.bottom
                top: parent.top
            }

            onSwipe: {
                /* Start timer that prevents onClicked() signal from doing anything */
                justSwiped.start();

                /* When swiped leftward, skip to the next track */
                if(direction == "left") {
                    nextTrack();
                }
            }

            onClicked: {
                if(!justSwiped.running) {
                    layout.addPageToNextColumn(stationsPage, playerPage);
                }
            }
        }

        /* Progress bar */
        RectangleProgressBar {
            id: songProgressBar
            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }
            height: units.gu(0.3)

            percentageComplete: playbackPercentage
            backgroundColor: UbuntuColors.coolGrey
            progressColor: UbuntuColors.orange
        }
    }

}
