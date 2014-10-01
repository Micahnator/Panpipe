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
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0 as ListItem
import Ubuntu.Components.Popups 0.1 as Popups
import "components"
import "models"

Item {
    /* Aliases */
    property alias stationsListItem: stationsView
    property alias stationSortingPopup: stationSortingMenu

    /* Public properties */
    property string sortMethod

    /* Private properties */
    property int _pressAndHoldIndex
    property int _pressIndex
    property bool _selectionMade
    property string _currentStationToken

    Timer {
        id: delayStationSelected
        interval: 500
        onTriggered: stationSelected(stationsView.model[_pressIndex].stationToken)
    }

    Timer {
        id: justSwiped
        interval: 1
    }

    Component.onCompleted: {
        _selectionMade = false;
    }

    onSortMethodChanged: {
        updateStationSort(sortMethod);
    }

    Connections {
        target: pandoraModel

//        onStationsLoaded: {
//            if(!sortMethod) {
//                sortMethod = startupPreferredStationSort;
//            } else {
//                updateStationSort(sortMethod);
//            }
//        }
//        onLoginSuccess: {
//            stationsModel.getData();
//        }
        onConnectedChanged: {
            /* If connection was successful, retrieve the station list */
            if (pandoraModel.connected == true) {
                //pandoraModel.retrieveStations();
                stationsModel.getData();
            }
        }
    }

//    function updateStations() {
//        updateStationSort(sortMethod);
//    }

//    function updateStationSort(method) {
//        //Update the view model
//        stationsView.model = (method === "by_date") ? pandoraModel.userStationsByDate : pandoraModel.userStationsAlphabetical;

//        //Update the currently selected index
//        stationsView.currentIndex = __findStationIndexFromToken(_currentStationToken, stationsView.model);
//    }

    StationModel {
        id: stationsModel
    }

    UbuntuListView {
        id: stationsView
        clip: true

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: (audioSourceUrl != "") ? nowPlayingBar.top : parent.bottom

        cacheBuffer: 1000

        Component.onCompleted: {
            currentIndex = -1;
        }

        model: stationsModel

//        onModelChanged: {
//            if( model.length == 0 ) {
//                currentIndex = -1;
//                _currentStationToken = "";
//            }
//        }

        delegate: ListItem.Standard {
            text: stationsView.model[index]["stationName"];

            iconSource: stationsView.model[index]["artUrl"]
            fallbackIconSource: Qt.resolvedUrl("resources/icons/help.svg")
            iconFrame: false

            // Current station indicator
            Rectangle {
                id: currentStationHighlight

                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    left: parent.left
                }

                width: units.gu(0.75)
                color: (stationsView.currentIndex == index) ? UbuntuColors.orange : "transparent"
            }

            onClicked: {
                stationsView.currentIndex = index;
                _selectionMade = true;
                _pressIndex = index;
                _currentStationToken = stationsView.model[index].stationToken;
                delayStationSelected.start();
            }

            onPressAndHold: {
                _pressAndHoldIndex = index;
                PopupUtils.open(stationOptions)
            }
        }
    }

    Scrollbar {
        flickableItem: stationsView
        align: Qt.AlignTrailing
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
                source: (playButtonState) ? Qt.resolvedUrl("resources/icons/media-playback-pause.svg") : Qt.resolvedUrl("./resources/icons/media-playback-start.svg")
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
                    nextTrackPressed();
                }
            }

            onClicked: {
                if(!justSwiped.running) {
                    pagestack.push(playerPage);
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

    /* Stations menu popover */
    Component {
        id: stationSortingMenu

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
                    text: (sortMethod == "by_date") ? "*By Date Created" : "By Date Created"
                    onClicked: {
                        hide();
                        sortPreferenceProvided("by_date");
                        sortMethod = "by_date";
                    }
                }
                ListItem.Standard {
                    text: (sortMethod == "alphabetical") ? "*Alphabetically" : "Alphabetically"
                    onClicked: {
                        hide();
                        sortPreferenceProvided("alphabetical");
                        sortMethod = "alphabetical";
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
                        webviewURL = stationsView.model[_pressAndHoldIndex]["stationDetailUrl"]
                        pagestack.push(webViewPage);

                    }
                }
                ListItem.Standard {
                    text: "Share Station"
                    onClicked: {
                        hide();
                        webviewURL = stationsView.model[_pressAndHoldIndex]["stationSharingUrl"]
                        pagestack.push(webViewPage);
                    }
                }
            }
        }
    }

    /*
        Helper Functions
    */

    /* A function to identify the index of the station in the list, given a stationToken */
    function __findStationIndexFromToken(stationToken, stationList) {
        for(var i = 0; i < stationList.length; i++) {
            if( stationToken === stationList[i].stationToken ) {
                return i;
            }
        }

        //If token not found, return negative one
        return -1;
    }
}
