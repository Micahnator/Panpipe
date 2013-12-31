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
import "components"

Item {
    /* Aliases */
    property alias stationsListItem: stationsView
    property alias stationSortingPopup: stationSortingMenu

    /* Private properties */
    property int _pressAndHoldIndex
    property string _currentSortMethod
    property int _pressIndex
    property bool _selectionMade

    Timer {
        id: delayStationSelected
        interval: 500
        onTriggered: stationSelected(_pressIndex)
    }

    Timer {
        id: justSwiped
        interval: 1
    }

    Component.onCompleted: {
        _currentSortMethod = startupPreferredStationSort;
        _selectionMade = false;
    }

    ListView {
        id: stationsView
        clip: true

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: (audioSourceUrl != "") ? nowPlayingBar.top : parent.bottom

        cacheBuffer: 1000

        highlight: highlightBlock

        Component.onCompleted: {
            currentIndex = -1;
        }

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
                stationsView.currentIndex = index;
                _selectionMade = true;
                _pressIndex = index;
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
                    playerToolbar.opened = false;
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

    /* Highligh object */
    Component {
         id: highlightBlock
         Rectangle {
             visible: _selectionMade
             width: units.gu(0.75); height: stationsView.currentItem.height
             color: UbuntuColors.orange
             y: stationsView.currentItem.y
             Behavior on y {
                 SmoothedAnimation {
                     duration: 300
                 }
             }
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
                    text: (_currentSortMethod == "by_date") ? "*By Date Created" : "By Date Created"
                    onClicked: {
                        hide();
                        __sortByCreatedDate();
                    }
                }
                ListItem.Standard {
                    text: (_currentSortMethod == "alphabetical") ? "*Alphabetically" : "Alphabetically"
                    onClicked: {
                        hide();
                        __sortAlphabetically();
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

    /* A function to trigger correct sorting of the stations list */
    function updateStationList() {
        if(_currentSortMethod == "alphabetical")
            {
            __sortAlphabetically();
            }
        else if(_currentSortMethod == "by_date")
            {
            __sortByCreatedDate();
            }
    }

    /* A string comparison function used to sort stations by station name */
    function __strcmp ( str1, str2 ) {
        // http://kevin.vanzonneveld.net
        // +   original by: Waldo Malqui Silva
        // +      input by: Steve Hilder
        // +   improved by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
        // +    revised by: gorthaur
        // *     example 1: strcmp( 'waldo', 'owald' );
        // *     returns 1: 1
        // *     example 2: strcmp( 'owald', 'waldo' );
        // *     returns 2: -1

        return ( ( str1 == str2 ) ? 0 : ( ( str1 > str2 ) ? 1 : -1 ) );
    }

    /* A comparison function used to sort stations by creation date */
    function __pandoraDateCompare(a, b) {
        var date_a = new Date(a.year, a.month, a.day, a.hours, a.minutes, a.seconds);
        var date_b = new Date(b.year, b.month, b.day, b.hours, b.minutes, b.seconds);

        return date_b.getTime() - date_a.getTime();
    }

    /* Function to place the "QuickMix" station back at the top of the station list */
    function __moveQuickMix(stationList) {
        var temp;
        for(var i = 0; i < stationList.length; i++) {
            if(stationList[i].stationName == "QuickMix") {
                temp = stationList[i];

                //now shift other items down
                for(var j = i; j > 0; j--) {
                    stationList[j] = stationList[(j - 1)];
                }

                stationList[0] = temp;
                break;
            }
        }
    }

    //Function to sort the stations list alphabetically
    function __sortAlphabetically() {
        var station_selected = (stationsView.currentIndex >= 0);

        //Get the station name of the currently selected station, if there is one
        if(station_selected) {
            var current_station_name = stationsList[stationsView.currentIndex]["stationName"];
        }

        stationsList.sort(function(a,b){return __strcmp(a.stationName, b.stationName)});
        __moveQuickMix(stationsList);
        stationsView.model = stationsList;
        sortPreferenceProvided("alphabetical");
        _currentSortMethod = "alphabetical";

        /* Re-set the stationView's current index so that it is still correct */
        if(station_selected) {
            for(var i = 0; i < stationsList.length; i++) {
                if(current_station_name === stationsList[i].stationName) {
                    stationsView.currentIndex = i;
                    break;
                }
            }
        }
    }

    /* Function to sort the stations by creation date */
    function __sortByCreatedDate() {
        var station_selected = (stationsView.currentIndex >= 0);

        /* Get the station name of the currently selected station, if there is one */
        if(station_selected) {
            var current_station_name = stationsList[stationsView.currentIndex]["stationName"];
        }

        stationsList.sort(function(a,b){return __pandoraDateCompare(a.dateCreated,b.dateCreated)});
        __moveQuickMix(stationsList);
        stationsView.model = stationsList;
        sortPreferenceProvided("by_date");
        _currentSortMethod = "by_date";

        /* Re-set the stationView's current index so that it is still correct */
        if(station_selected) {
            for(var i = 0; i < stationsList.length; i++) {
                if(current_station_name === stationsList[i].stationName) {
                    stationsView.currentIndex = i;
                    break;
                }
            }
        }
    }
}
