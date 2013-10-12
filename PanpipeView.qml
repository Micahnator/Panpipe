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
    property alias stationsList: stationsView.model
    property alias stationName: stationLabel.text

    /* Signals */
    signal playPausePressed(bool playState)
    signal nextTrackPressed()
    signal thumbsUpPressed()
    signal thumbsDownPressed()
    signal stationSelected(int stationIndex)
    signal loginCredentialsProvided(string username, string password)
    signal userLogout()

    /* Public properties */
    property var playlist
    property int currentPlaylistIndex

    property bool playButtonState
    property bool audioPlaying

    property double playbackPercentage
    property int playbackPosition
    property int playbackDuration

    property string username_auto_fill

    /* Private properties */
    property int _temp_song_thumbs_up

    /* Private constants */
    property int _STATIONS_TAB_INDEX: 0
    property int _PLAYER_TAB_INDEX: 1

    /* State change handlers */
    onPlayButtonStateChanged: {
        playPausePressed(playButtonState);
    }

    onAudioPlayingChanged: {
        playButtonState = audioPlaying;
    }

    onCurrentPlaylistIndexChanged: {
        _temp_song_thumbs_up = 0;
    }


    /* View initialization */
    Component.onCompleted: {
        playButtonState = false;
    }

    /* Public functions */
    function requestCredentials(username) {
        /* If given, populate auto fill value */
        if(username) {
            username_auto_fill = username;
        }

        /* show login dialog */
        PopupUtils.open(loginDialog);
    }

    function confirmLogout() {
        PopupUtils.open(logoutDialog);
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
                flickable: stationsView

                ListView {
                    id: stationsView
                    clip: true
                    anchors.fill: parent
                    cacheBuffer: 1000

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
                            tabs.selectedTabIndex = _PLAYER_TAB_INDEX;
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

                /* Toolbar */
                tools: ToolbarItems {
                    id: stationsToolbar
                    ToolbarButton {
                        objectName: logoutAction
                        iconSource: "./resources/icons/close.svg"
                        text: i18n.tr("Logout")
                        onTriggered: {
                            /* Hide toolbar */
                            stationsToolbar.opened = false;

                            /* show login dialog */
                            PopupUtils.open(logoutDialog);
                        }
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
                        topMargin: units.gu(1)
                        horizontalCenter: parent.horizontalCenter
                    }
                    width: (parent.width - units.gu(4))
                    elide: Text.ElideRight
                    fontSize: "large"
                    horizontalAlignment: Text.AlignLeft
                }

                /* Album artwork */
                Rectangle {
                    id: albumArt
                    anchors {
                        top: stationLabel.bottom
                        topMargin: units.gu(2)
                        horizontalCenter: parent.horizontalCenter
                    }
                    width: Math.min( (parent.width - units.gu(2)), (Math.abs(stationLabel.y - songLabel.y) - (stationLabel.height + songLabel.height + playbackRemainingLabel.height)) )
                    height: albumArt.width

                    CrossFadeImage {
                        id: currentArt
                        anchors.fill: parent
                        source: playlist[currentPlaylistIndex].albumArtUrl
                        fadeDuration: 1000
                        fillMode: Image.PreserveAspectCrop
                    }

                    Image {
                        id: songRatingArt
                        anchors {
                            bottom: parent.bottom
                            right: parent.right
                        }
                        width: parent.width / 8
                        height: width
                        source: ((playlist[currentPlaylistIndex].songRating == 1) || (_temp_song_thumbs_up == 1)) ? "./resources/icons/favorite-selected.svg" : ""
                    }
                }


                /* Progress bar */
                Rectangle {
                    id: progressBase
                    anchors {
                        top: albumArt.bottom
                        left: albumArt.left
                        right: albumArt.right
                    }
                    height: units.gu(0.5)
                    color: UbuntuColors.coolGrey

                    Rectangle {
                        id: progressTracker
                        anchors {
                            top: parent.top
                            bottom: parent.bottom
                            left: parent.left
                        }
                        height: parent.height
                        width: (parent.width * playbackPercentage)
                        color: UbuntuColors.orange
                    }
                }

                /* Playback position */
                Label {
                    id: playbackPositionLabel
                    anchors {
                        top: progressBase.bottom
                        left: progressBase.left
                    }
                    fontSize: "small"
                    text: (audioPlayer.source != "") ? __durationToString(playbackPosition) : "0:00"
                }

                /* Playback remaining */
                Label {
                    id: playbackRemainingLabel
                    anchors {
                        top: progressBase.bottom
                        right: progressBase.right
                    }
                    fontSize: "small"
                    text: (audioPlayer.source != "") ? "-" + __durationToString(playbackDuration - playbackPosition) : "0:00"
                }

                /* Song name */
                Label {
                    id: songLabel
                    anchors {
                        bottom: artistLabel.top
                        horizontalCenter: parent.horizontalCenter
                    }
                    width: (parent.width - units.gu(4))
                    elide: Text.ElideRight
                    fontSize: "large"
                    horizontalAlignment: Text.AlignHCenter
                    text: i18n.tr(playlist[currentPlaylistIndex].songName)
                }

                /* Artist name */
                Label {
                    id: artistLabel
                    anchors {
                        bottom: albumLabel.top
                        horizontalCenter: parent.horizontalCenter
                    }
                    width: (parent.width - units.gu(4))
                    elide: Text.ElideRight
                    fontSize: "medium"
                    horizontalAlignment: Text.AlignHCenter
                    text: (playlist[currentPlaylistIndex].artistName != "") ? i18n.tr("By " + playlist[currentPlaylistIndex].artistName) : i18n.tr("")
                }


                /* Album name */
                Label {
                    id: albumLabel
                    anchors {
                        bottom: controlBar.top
                        bottomMargin: units.gu(1)
                        horizontalCenter: parent.horizontalCenter
                    }
                    width: (parent.width - units.gu(4))
                    elide: Text.ElideRight
                    fontSize: "medium"
                    horizontalAlignment: Text.AlignHCenter
                    text: (playlist[currentPlaylistIndex].albumName != "") ? i18n.tr("On " + playlist[currentPlaylistIndex].albumName) : i18n.tr("")
                }


                UbuntuShape {
                    id: controlBar
                    anchors {
                        bottom: parent.bottom
                        bottomMargin: units.gu(1)
                        horizontalCenter: parent.horizontalCenter
                    }
                    width: {
                        if(parent.width > units.gu(40)) {
                            parent.width - units.gu(12)
                        } else {
                            parent.width - units.gu(4)
                        }
                    }
                    height: Math.min(units.gu(8), (width / 4) )
                    color: headerColor
                    radius: "medium"

                    Row {
                        anchors.fill: parent

                        /* Note: units.gu(32) is the combined width of the buttons */
                        spacing: Math.max( ((parent.width - units.gu(32)) / 3), 0 )

                        height: parent.height

                        /* Play / Pause button */
                        Item {
                            id: playPause
                            height: parent.height
                            width: parent.height

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
                        Item {
                            id: nextTrack
                            height: parent.height
                            width: parent.height

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
                        Item {
                            id: thumbsUp
                            height: parent.height
                            width: parent.height

                            Image {
                                source: "./resources/icons/arrow-up.svg"
                                anchors.fill: parent
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    if(playlist[currentPlaylistIndex].songRating != 1) {
                                        thumbsUpPressed();
                                        _temp_song_thumbs_up = 1;
                                    }
                                }
                            }
                        }

                        /* Thumbs down button */
                        Item {
                            id: thumbsDown
                            height: parent.height
                            width: parent.height

                            Image {
                                source: "./resources/icons/arrow-down.svg"
                                anchors.fill: parent

                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    if(playlist[currentPlaylistIndex].songRating != -1) {
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

    /* Define login credential dialog */
    Component {
        id: loginDialog

        Popups.Dialog {
            id: loginScreen
            title: i18n.tr("Enter login credentials")
            text: i18n.tr("Enter Pandora username and password.")

            /* Dialog initialization */
            Component.onCompleted: {
                if("" !== username_auto_fill) {
                    usernameForm.text = username_auto_fill;
                }
            }

            /* Dialog destruction */
            Component.onDestruction: {
                /* Clear username auto-fill data */
                username_auto_fill = "";
            }

            TextField {
                id: usernameForm
                placeholderText: i18n.tr("Username")
            }

            TextField {
                id: passwordForm
                placeholderText: i18n.tr("Password")
                echoMode: TextInput.Password
            }

            Button {
                text: i18n.tr("Login")
                color: "orange"

                onClicked: {
                    //send data to view
                    loginCredentialsProvided(usernameForm.text, passwordForm.text);

                    //close dialog
                    PopupUtils.close(loginScreen)
                }
            }
        }
    }

    /* Define logout confirmation dialog */
    Component {
        id: logoutDialog

        Popups.Dialog {
            id: logoutScreen
            title: i18n.tr("Are you sure you want to logout?")

            Button {
                text: i18n.tr("Logout")
                color: "orange"

                onClicked: {
                    //Tell the controller that logout is requested
                    userLogout();

                    //close dialog
                    PopupUtils.close(logoutScreen)
                }
            }

            Button {
                text: i18n.tr("Cancel")
                color: "gray"

                onClicked: {
                    //close dialog
                    PopupUtils.close(logoutScreen)
                }
            }
        }
    }

    // Converts an duration in ms to a formated string ("minutes:seconds")
    function __durationToString(duration) {
        var minutes = Math.floor((duration/1000) / 60);
        var seconds = Math.floor((duration/1000)) % 60;
        return minutes + ":" + (seconds<10 ? "0"+seconds : seconds);
    }

}
