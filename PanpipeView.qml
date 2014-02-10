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
import Ubuntu.Components.Extras.Browser 0.1

/* View component for Panpipe */
Item {

    /* Signals */
    signal playPausePressed(bool playState)
    signal nextTrackPressed()
    signal thumbsUpPressed()
    signal thumbsDownPressed()
    signal stationSelected(string stationToken)
    signal loginCredentialsProvided(string username, string password)
    signal userLogout()
    signal sortPreferenceProvided(string preferredSort)

    /* Public properties */
    property var stationsList
    property var stationName
    property var playlist
    property int currentPlaylistIndex
    property bool playButtonState
    property bool audioPlaying
    property double playbackPercentage
    property int playbackPosition
    property int playbackDuration
    property string audioSourceUrl
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

    onStationSelected: {
        pagestack.push(playerPage);
        playerToolbar.opened = false;
    }

    onStationsListChanged: {
        stationsPageContents.updateStations();
    }

    /* View initialization */
    Component.onCompleted: {
        /* Initialize state */
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

    function updateInterface() {
        stationsPageContents.updateStations();
    }

    PageStack {
        id: pagestack
        Component.onCompleted: push(stationsPage)

        Page {
            id: stationsPage
            title: "Stations"
            anchors.fill: parent
            visible: false
            flickable: stationsPageContents.stationsListItem

            StationsPage {
                id: stationsPageContents
                anchors.fill: parent
            }

            /* Toolbar */
            tools: ToolbarItems {
                id: stationsToolbar
                ToolbarButton {
                    objectName: logoutAction
                    iconSource: Qt.resolvedUrl("resources/icons/close.svg")
                    text: i18n.tr("Logout")
                    onTriggered: {
                        /* Hide toolbar */
                        stationsToolbar.opened = false;

                        /* show login dialog */
                        PopupUtils.open(logoutDialog);
                    }
                }
                ToolbarButton {
                    iconSource: Qt.resolvedUrl("resources/icons/properties.svg")
                    text: i18n.tr("Settings")
                    onTriggered: {
                        PopupUtils.open(settingsDialog)
                    }
                }
                ToolbarButton {
                    iconSource: Qt.resolvedUrl("resources/icons/filter.svg")
                    text: i18n.tr("Sort")
                    onTriggered: {
                        /* Hide toolbar */
                        stationsToolbar.opened = false;

                        /* Show sorting options popup */
                        PopupUtils.open(stationsPageContents.stationSortingPopup);
                    }
                }
            }
        }

        Page {
            id: playerPage
            title: i18n.tr("Now Playing")
            visible: false

            PlayerPage {
                id: playerPageContents
                anchors.fill: parent
            }

            tools: ToolbarItems {
                id: playerToolbar

                ToolbarButton {
                    objectName: logoutAction
                    iconSource: Qt.resolvedUrl("resources/icons/close.svg")
                    text: i18n.tr("Logout")
                    onTriggered: {
                        /* Hide toolbar */
                        stationsToolbar.opened = false;

                        /* show login dialog */
                        PopupUtils.open(logoutDialog);
                    }
                }
                ToolbarButton {
                    iconSource: Qt.resolvedUrl("resources/icons/properties.svg")
                    text: i18n.tr("Settings")
                    onTriggered: {
                        PopupUtils.open(settingsDialog)
                    }
                }
                ToolbarButton {
                    iconSource: Qt.resolvedUrl("resources/icons/navigation-menu.svg")
                    text: i18n.tr("Song Menu")
                    onTriggered: {
                        playerPageContents.displaySongOptions();
                    }
                }
            }
        }

        Page {
            id: webViewPage
            visible: false

            onVisibleChanged: {
                webView.visible = webViewPage.visible
            }

            UbuntuWebView {
                id: webView
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: parent.height
                visible: false
            }

            /* Toolbar */
            tools: ToolbarItems {
                id: webViewToolbar
                ToolbarButton {
                    iconSource: Qt.resolvedUrl("resources/icons/go-to.svg")
                    text: i18n.tr("In Browser")
                    onTriggered: {
                        /* Hide toolbar */
                        webViewToolbar.opened = false;

                        /* show login dialog */
                        Qt.openUrlExternally(webView.url);
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
                    /* close dialog */
                    PopupUtils.close(logoutScreen)
                }
            }
        }
    }

    /* Application settings dialog */
    Component {
        id: settingsDialog

        Popups.Dialog {
            id: settingsScreen
            title: i18n.tr("There are no settings yet.")

            Button {
                text: i18n.tr("About")
                color: "orange"

                onClicked: {
                    /* close dialog */
                    PopupUtils.close(settingsScreen);

                    /* open new dialog */
                    PopupUtils.open(aboutDialog);
                }
            }

            Button {
                text: i18n.tr("Close")
                color: "gray"

                onClicked: {
                    /* close dialog */
                    PopupUtils.close(settingsScreen)
                }
            }
        }
    }

    /* About this app dialog */
    Component {
        id: aboutDialog

        Popups.Dialog {
            id: aboutScreen
            title: i18n.tr("Panpipe")

            Rectangle {
                height: width
                color: "transparent"
                Image {
                    source: Qt.resolvedUrl("panpipe-256.png")
                    anchors.fill: parent
                }
            }

            Label {
                text: i18n.tr("Panpipe is a Pandora Internet Radio client for Ubuntu, licensed under the GPLv3.")
                wrapMode: Text.WordWrap
                fontSize: "medium"
            }

            Button {
                text: i18n.tr("Panpipe Website")
                color: "orange"

                onClicked: {
                    /* close dialog */
                    PopupUtils.close(aboutScreen);

                    /* Open the Panpipe project website in the browser */
                    Qt.openUrlExternally("http://micahnator.github.io/Panpipe/");
                }
            }

            Button {
                text: i18n.tr("Close")
                color: "gray"

                onClicked: {
                    /* close dialog */
                    PopupUtils.close(aboutScreen)
                }
            }
        }
    }
}
