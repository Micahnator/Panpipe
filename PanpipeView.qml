/*
Copyright (C) 2013 Micah Losli <micah.losli@gmail.com>

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

import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.Components.Popups 0.1 as Popups

/* Tabbed view component for Panpipe */
Item {
    /* Aliases */
    property alias data: stationsView.model
    property alias songName: songLabel.text
    property alias albumName: albumLabel.text
    property alias stationName: stationLabel.text
    property alias songArt: currentArt.source;

    property alias position: trackProgress.value

    /* Signals */
    signal playPausePressed(bool playState)
    signal nextTrackPressed()
    signal thumbsUpPressed()
    signal thumbsDownPressed()
    signal stationSelected(int stationIndex)

    /* Public properties */
    property bool playButtonState

    property bool audioPlaying

    /* Private properties */

    /* State change handlers */
    onPlayButtonStateChanged: {
        playPausePressed(playButtonState);
    }

    onAudioPlayingChanged: {
        playButtonState = audioPlaying;
    }


    /* View initialization */
    Component.onCompleted: {
        playButtonState = false;
    }

    Tabs {
        id: tabs
        anchors.fill: parent

        Tab {
            objectName: "stationsTab"
            id: stations
            title: i18n.tr("Stations")

            /* Tab content begins here */
            page: Page {
                id: stationsPage

                Column {
                    anchors.fill: parent

                    ListView {
                        id: stationsView
                        clip: true
                        anchors.fill: parent

                        delegate: ListItem.Standard {
                            text: stationsView.model[index]["stationName"];
                            icon: stationsView.model[index]["artUrl"];

                            onClicked: {
                                stationSelected(index);
                            }
                        }
                    }
                }


                /* Stations menu popover */
                Component {
                    id: stationsMenu

                    Popups.Popover {
                        id: popover

                        autoClose: true

                        Column {
                            id: containerLayout
                            anchors {
                                left: parent.left
                                top: parent.top
                                right: parent.right
                            }
                            ListItem.Header { text: "Sort stations" }
                            ListItem.Standard {
                                text: "By Date"
                                icon: Qt.resolvedUrl("./resources/icons/torch-off.svg")
                                onClicked: {
                                    hide()
                                }
                            }
                            ListItem.Standard {
                                text: "Alphabetically"
                                icon: Qt.resolvedUrl("./resources/icons/torch-on.svg")
                                onClicked: {
                                    hide()
                                }
                            }
                        }
                    }
                }

                /* Bottom Toolbar */
                tools: ToolbarActions {
                    id: toolbar

                    Action {
                        id: sortStationsAction
                        objectName: "action"

                        iconSource: Qt.resolvedUrl("./resources/icons/filter.svg")
                        text: i18n.tr("Sort")

                        onTriggered: {
                            PopupUtils.open(stationsMenu, caller)
                        }
                    }

                    Action {
                        id: addStationAction
                        objectName: "action"

                        iconSource: Qt.resolvedUrl("./resources/icons/add.svg")
                        text: i18n.tr("New Station")
                    }
                }
            }
        }

        /* Second tab begins here */
        Tab {
            objectName: "playingTab"
            id: nowPlaying
            title: i18n.tr("Now Playing")
            page: Page {
                id: playerPage

                /* Station name */
                Label {
                    id: stationLabel
                    objectName: "label"

                    anchors {
                        top: parent.top
                        left: parent.left
                        topMargin: units.gu(1)
                        leftMargin: units.gu(2)
                    }

                    fontSize: "large"
                    text: i18n.tr("? Radio.")
                }

                /* Song name */
                Label {
                    id: songLabel

                    anchors {
                        top: stationLabel.bottom
                        left: parent.left
                        leftMargin: units.gu(2)
                    }

                    fontSize: "medium"
                    text: i18n.tr("Hey Mama!")
                }

                /* Album name */
                Label {
                    id: albumLabel

                    anchors {
                        top: songLabel.bottom
                        left: parent.left
                        leftMargin: units.gu(2)
                    }

                    fontSize: "medium"
                    text: i18n.tr("Young Love")
                }

                /* Album artwork */
                UbuntuShape {
                    id: albumArt

                    anchors {
                        top: albumLabel.bottom
                        topMargin: units.gu(2)
                        horizontalCenter: parent.horizontalCenter
                        bottom: controlBar.top
                        bottomMargin: units.gu(3)
                    }

                    width: Math.min( height, (parent.width - units.gu(5)) )
                    color: "white"
                    radius: "medium"

                    image: Image {
                        id: currentArt
                        asynchronous: true

                        onProgressChanged: {
                            console.log("load progress: " + currentArt.progress);
                        }
                    }
                }

                ProgressBar {
                    id: trackProgress

                    anchors {
                        top: albumArt.bottom
                        horizontalCenter: albumArt.horizontalCenter
                        left: albumArt.left
                        right: albumArt.right
                    }

                    minimumValue: 0
                    maximumValue: 100
                    value: 50
                }


                UbuntuShape {
                    id: controlBar
                    anchors {
                        bottom: parent.bottom
                        bottomMargin: units.gu(3)
                        horizontalCenter: parent.horizontalCenter
                    }
                    width: parent.width - units.gu(20)
                    height: Math.min(units.gu(8), (width / 4) )
                    color: "white"
                    radius: "medium"

                    Row {
                        anchors.fill: controlBar

                        //note: units.gu(32) is the combined width of the buttons
                        spacing: Math.max( ((parent.width - units.gu(32)) / 3), 0 )

                        height: parent.height

                        /* Play / Pause button */
                        Rectangle {
                            id: playPause
                            height: parent.height
                            width: parent.height
                            color: "transparent"

                            Image {
                                source: (playButtonState) ? "./resources/icons/media-playback-pause.svg" : "./resources/icons/media-playback-start.svg"
                                sourceSize.width: parent.width
                                sourceSize.height: parent.height
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    playButtonState = !playButtonState;
                                }
                            }


                        }

                        /* Next track button */
                        Rectangle {
                            id: nextTrack
                            height: parent.height
                            width: parent.height
                            color: "transparent"

                            Image {
                                source: "./resources/icons/media-skip-forward.svg"
                                sourceSize.width: parent.width
                                sourceSize.height: parent.height
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    nextTrackPressed();
                                }
                            }
                        }

                        /* Thumbs up button */
                        Rectangle {
                            id: thumbsUp
                            height: parent.height
                            width: parent.height
                            color: "transparent"

                            Text {
                                anchors.fill: parent
                                wrapMode: Text.Wrap
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                text: "Thumbs Up"
                                color: "black"
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    thumbsUpPressed();
                                }
                            }
                        }

                        /* Thumbs down button */
                        Rectangle {
                            id: thumbsDown
                            height: parent.height
                            width: parent.height
                            color: "transparent"

                            Text {
                                anchors.fill: parent
                                wrapMode: Text.Wrap
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                text: "Thumbs Down"
                                color: "black"
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    thumbsDownPressed();
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
