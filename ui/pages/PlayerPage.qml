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
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3

import "../components"

Page {
    title: i18n.tr("Player")
    head.foregroundColor: "white"

    /* Signals */
    signal skipButtonPressed


    /* Aliases */


    /* Properties */
    property string currentAlbumArtUrl
    property string currentSongName
    property string currentSongAlbum
    property string currentSongArtist
//    property string currentStationName //TODO: Look into presenting the station name in this page
    property double playbackPercentage
    property bool isLandscapeMode: (width > (1.7 * height))

    states: [
        State {
            name: "landscape"
            when: isLandscapeMode

            /* Album art */
            AnchorChanges {
                target: albumArtContainer
                anchors {
                    top: parent.top
                    right: controlBlock.left
                    bottom: parent.bottom
                    left: parent.left
                }
            }

            /* Control block */
            PropertyChanges {
                target: controlBlock
                width: units.gu(35)
            }

            AnchorChanges {
                target: controlBlock
                anchors {
                    top: parent.top
                    right: parent.right
                    bottom: parent.bottom
                    left: undefined
                }
            }
        }
    ]

    /* Gray background for player page (in case a BlurredBackground isn't rendered) */
    Rectangle {
        anchors.fill: parent
        color: "#F0F0F0"
    }

    /* Blurred album art background */
    BlurredBackground {
        id: blurredBackground

        anchors.fill: parent

        art: currentAlbumArtUrl
        backgroundStrength: 0.5
    }

    /* Album art */
    Item {
        id: albumArtContainer

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: controlBlock.top
        }

        Image {
            id: albumArtImage

            width: Math.min((parent.width - units.gu(6)), (parent.height - units.gu(6)))
            height: width
            anchors.centerIn: parent

            source: currentAlbumArtUrl
        }
    }


    /* Controls block */
    Rectangle {
        id: controlBlock

        property double heightOfContents: (controlBar.height + songProgressBar.height + currentSongArtistLabel.height + currentSongAlbumLabel.height + currentSongNameLabel.height + units.gu(4))

        color: "Black"
        opacity: 0.85

        height: (units.gu(1) + heightOfContents)

        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        /* Song info */
        Label {
            id: currentSongNameLabel

            anchors {
                left: parent.left
                leftMargin: units.gu(2)
                bottom: currentSongAlbumLabel.top
                bottomMargin: units.gu(0.5)
            }

            text: currentSongName
            color: "White"
            fontSize: "medium"
        }

        Label {
            id: currentSongAlbumLabel

            anchors {
                left: parent.left
                leftMargin: units.gu(2)
                bottom: currentSongArtistLabel.top
                bottomMargin: units.gu(0.5)
            }

            text: (currentSongAlbum != "") ? "On \"" + currentSongAlbum + "\"" : ""
            color: "White"
            fontSize: "small"
        }

        Label {
            id: currentSongArtistLabel

            anchors {
                left: parent.left
                leftMargin: units.gu(2)
                bottom: songProgressBar.top
                bottomMargin: units.gu(1)
            }

            text: (currentSongArtist != "") ? "By " + currentSongArtist : ""
            color: "White"
            fontSize: "small"
        }

        /* Playback position */
        Label {
            id: playbackPositionLabel
            anchors {
                left: parent.left
                leftMargin: units.gu(0.5)
                verticalCenter: songProgressBar.verticalCenter
            }
            fontSize: "x-small"
            color: "#ffffff"
//            text: (audioSourceUrl != "") ? __durationToString(playbackPosition) : "0:00" //TODO: look into bringing this logic back
            text: __durationToString(playbackPosition)
        }

        /* Playback remaining */
        Label {
            id: playbackRemainingLabel
            anchors {
                right: parent.right
                rightMargin: units.gu(0.5)
                verticalCenter: songProgressBar.verticalCenter
            }
            fontSize: "x-small"
            color: "#ffffff"
//            text: (audioSourceUrl != "") ? "-" + __durationToString(playbackDuration - playbackPosition) : "0:00" //TODO: look into bringing this logic back
            text: __durationToString(playbackDuration - playbackPosition)
        }

        /* Progress bar */
        RectangleProgressBar {
            id: songProgressBar
            anchors {
                bottom: controlBar.top
                bottomMargin: units.gu(1)
                left: playbackPositionLabel.right
                leftMargin: units.gu(0.5)
                right: playbackRemainingLabel.left
                rightMargin: units.gu(0.5)
            }
            height: units.gu(0.5)

            percentageComplete: playbackPercentage
            backgroundColor: "#A0A0A0"
            progressColor: UbuntuColors.orange
        }

        /* Controls */
        Item {
            id: controlBar

            anchors {
                bottom: parent.bottom
                bottomMargin: units.gu(1)
                horizontalCenter: parent.horizontalCenter
            }

            height: units.gu(6)
            width: Math.min((parent.width - units.gu(4)), units.gu(40))

            Row {
                anchors.fill: parent
                spacing: ( ( width - ( playPauseButton.width + skipButton.width + thumbsUpButton.width + thumbsDownButton.width ) ) / 3 )

                /* Play / pause button */
                AbstractButton {
                    id: playPauseButton
                    height: parent.height
                    width: height

                    Icon {
                        id: playPauseIcon
                        anchors.fill: parent
                        name: (mainLayout.audioPlaying) ? "media-playback-pause" : "media-playback-start"
                    }

                    onClicked: (mainLayout.audioPlaying) ? pause() : play()
                }

                /* Skip button */
                AbstractButton {
                    id: skipButton
                    height: parent.height
                    width: height

                    Icon {
                        id: skipIcon
                        anchors.fill: parent
                        name: "media-skip-forward"
                    }

                    onClicked: nextTrack()
                }

                /* Thumbs up button */
                AbstractButton {
                    id: thumbsUpButton
                    height: parent.height
                    width: height

                    Icon {
                        id: thumbsUpIcon
                        anchors.fill: parent
                        name: "thumb-up"
                        color: ( currentSongRating > 0 ) ? "#FFFFFF" : "#808080"
                    }

                    onClicked: thumbsUp()
                }

                /* Thumbs down button */
                AbstractButton {
                    id: thumbsDownButton
                    height: parent.height
                    width: height

                    Icon {
                        id: thumbsDownIcon
                        anchors.fill: parent
                        name: "thumb-down"
                        color: ( currentSongRating < 0 ) ? "#FFFFFF" : "#808080"
                    }

                    onClicked: thumbsDown()
                }

            }
        }
    }

    /* Converts a duration in ms to a formated string ("minutes:seconds") */
    function __durationToString(duration) {
        var minutes = Math.floor((duration/1000) / 60);
        var seconds = Math.floor((duration/1000)) % 60;
        return minutes + ":" + (seconds<10 ? "0"+seconds : seconds);
    }

}
