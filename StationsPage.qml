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

Item {
    /* Aliases */
    property alias stationsListItem: stationsView

    /* Private properties */
    property int _pressAndHoldIndex

    ListView {
        id: stationsView
        clip: true

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: (audioSourceUrl != "") ? nowPlayingBar.top : parent.bottom

        cacheBuffer: 1000
        model: stationsList

        delegate: ListItem.Standard {
            text: stationsView.model[index]["stationName"];
            icon: Image {
                source: stationsView.model[index]["artUrl"]
                sourceSize.height: 40
                sourceSize.width: 40
                height: 40
                width: height
                fillMode: Image.PreserveAspectFit
                anchors.verticalCenter: parent.verticalCenter
            }

            onClicked: {
                stationSelected(index);
            }

            onPressAndHold: {
                _pressAndHoldIndex = index;
                PopupUtils.open(stationOptions)
            }
        }
    }

    Rectangle {
        id: nowPlayingBar

        width: parent.width
        height: units.gu(8)

        color: UbuntuColors.coolGrey

        visible: (audioSourceUrl != "") ? true : false

        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        CrossFadeImage {
            id: nowPlayingThumbnail

            height: parent.height
            width: height
            anchors {
                left: parent.left
                bottom: parent.bottom
            }

            fadeDuration: 1000
            fillMode: Image.PreserveAspectCrop
            source: playlist[currentPlaylistIndex].albumArtUrl
        }

        /* Play / Pause button */
        Item {
            id: nowPlayingPlayPause

            height: parent.height
            width: height
            anchors {
                right: parent.right
                bottom: parent.bottom
            }

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

        Label {
            id: nowPlayingArtist

            anchors {
                left: nowPlayingThumbnail.right
                leftMargin: units.gu(1)
                right: nowPlayingPlayPause.left
                bottom: nowPlayingAlbum.top
            }

            text: playlist[currentPlaylistIndex].artistName
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

            text: playlist[currentPlaylistIndex].albumName
            fontSize: "medium"
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

            text: playlist[currentPlaylistIndex].songName
            fontSize: "large"
            horizontalAlignment: Text.AlignLeft
            elide: Text.ElideRight
        }

        MouseArea {
            anchors {
                left: parent.left
                right: nowPlayingPlayPause.left
                bottom: parent.bottom
                top: parent.top
            }

            onClicked: {
                pagestack.push(playerPage);
                playerToolbar.opened = false;
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

    /* Station options popover */
    Component {
        id: stationOptions

        Popups.Popover {
            id: popover

            autoClose: true

            Column {
                id: containerLayout
                anchors {
                    left: parent.left
                    right: parent.right
                }
                ListItem.Header { text: "Station Options" }
                ListItem.Standard {
                    text: "Station Details"
                    onClicked: {
                        hide();
                        webView.url = stationsView.model[_pressAndHoldIndex]["stationDetailUrl"]
                        pagestack.push(webViewPage);

                    }
                }
                ListItem.Standard {
                    text: "Share Station"
                    onClicked: {
                        hide();
                        webView.url = stationsView.model[_pressAndHoldIndex]["stationSharingUrl"]
                        pagestack.push(webViewPage);
                    }
                }
            }
        }
    }
}
