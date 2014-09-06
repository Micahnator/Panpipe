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
import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.Components.Popups 0.1 as Popups
import Ubuntu.Web 0.2

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
    signal newStationSearchQuery(string query)

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
    property string webviewURL
    property var stationSearchResultList

    property string selectedStationToken

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

    Action {
        id: logoutAction
        objectName: logoutAction
        iconSource: Qt.resolvedUrl("resources/icons/close.svg")
        text: i18n.tr("Logout")
        onTriggered: {
            /* show login dialog */
            PopupUtils.open(logoutDialog);
        }
    }
    Action {
        id: settingsAction
        iconSource: Qt.resolvedUrl("resources/icons/properties.svg")
        text: i18n.tr("Settings")
        onTriggered: {
            PopupUtils.open(settingsDialog)
        }
    }
    Action {
        id: sortAction
        iconSource: Qt.resolvedUrl("resources/icons/filter.svg")
        text: i18n.tr("Sort")
        onTriggered: {
            /* Show sorting options popup */
            PopupUtils.open(stationsPageContents.stationSortingPopup);
        }
    }
    Action {
        id: songMenuAction
        iconSource: Qt.resolvedUrl("resources/icons/navigation-menu.svg")
        text: i18n.tr("Song Menu")
        onTriggered: {
            playerPageContents.displaySongOptions();
        }
    }
    Action {
        id: stationManagementAction
        iconSource: Qt.resolvedUrl("resources/icons/add.svg")
        text: i18n.tr("Add/Remove")
        onTriggered: {
            pagestack.push(manageStationsPage)
        }
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
            onVisibleChanged: console.log("stations Page now visible")

            StationsPage {
                id: stationsPageContents
                anchors.fill: parent
            }

            head.actions: [sortAction, stationManagementAction, settingsAction, logoutAction]
        }

        Page {
            id: playerPage
            title: i18n.tr("Now Playing")
            visible: false

            PlayerPage {
                id: playerPageContents
                anchors.fill: parent
            }

            //head.actions: [logoutAction, settingsAction, songMenuAction]
            head.actions: [songMenuAction]
        }

        Page {
            id: webViewPage
            title: i18n.tr("Details")
            visible: false

            onVisibleChanged: {
                if(webViewPage.visible) {
                    webviewLoader.sourceComponent = webviewComponent
                } else {
                    webviewLoader.sourceComponent = undefined
                }
            }

            Loader {
                id: webviewLoader
                anchors.fill: parent

                onLoaded: {
                    item.url = webviewURL;
                }
            }

            head.actions: [
                Action {
                    iconSource: Qt.resolvedUrl("resources/icons/go-to.svg")
                    text: i18n.tr("In Browser")
                    onTriggered: {                 
                        /* show login dialog */
                        Qt.openUrlExternally(webviewURL);
                    }
                }
            ]
        }

        Page {
            id: manageStationsPage
            title: "Manage Stations"
            visible: false

            onVisibleChanged: {
                if(manageStationsPage.visible) {
                    manageStationsPageLoader.sourceComponent = manageStationsPageComponent
                } else {
                    manageStationsPageLoader.sourceComponent = undefined
                }
            }

            Loader {
                id: manageStationsPageLoader
                anchors.fill: parent

            }

            //head.actions: [logoutAction, settingsAction]
//            /* Toolbar */
//            tools: ToolbarItems {
//                id: manageStationsToolbar
//                ToolbarButton {
//                    objectName: logoutAction
//                    iconSource: Qt.resolvedUrl("resources/icons/close.svg")
//                    text: i18n.tr("Logout")
//                    onTriggered: {
//                        /* Hide toolbar */
//                        stationsToolbar.opened = false;

//                        /* show login dialog */
//                        PopupUtils.open(logoutDialog);
//                    }
//                }
//                ToolbarButton {
//                    iconSource: Qt.resolvedUrl("resources/icons/properties.svg")
//                    text: i18n.tr("Settings")
//                    onTriggered: {
//                        PopupUtils.open(settingsDialog);
//                    }
//                }
//                ToolbarButton {
//                    iconSource: Qt.resolvedUrl("resources/icons/add.svg")
//                    text: i18n.tr("Add/Remove")
//                    onTriggered: {
//                        PopupUtils.open(addStationsDialog);
//                    }
//                }
//            }
        }

        /* Station details page */
        Page {
            id: stationDetailsPage
            title: "Station Details"
            visible: false

            onVisibleChanged: {
                if(stationDetailsPage.visible) {
                    stationDetailsPageLoader.sourceComponent = stationDetailsPageComponent
                } else {
                    stationDetailsPageLoader.sourceComponent = undefined
                }
            }

            Loader {
                id: stationDetailsPageLoader
                anchors.fill: parent

                onLoaded: {
                    /* Connect the station management's flickable property to the listview */
                    stationDetailsPage.flickable = stationDetailsPageLoader.item.flickerable;
                }
            }
        }
    }

    /* Define the webview component */
    Component {
        id: webviewComponent

        WebView {}
    }

    /* Define the ManageStationsPage component */
    Component {
        id: manageStationsPageComponent

        ManageStationsPage {
            id: manageStationsPageContents
            anchors.fill: parent
        }
    }

    /* Define the StationDetailsPage component */
    Component {
        id: stationDetailsPageComponent

        StationDetailsPage {
            id: stationDetailsPageContents
            anchors.fill: parent
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

                /* Set active focus to the username form */
                usernameForm.forceActiveFocus();
            }

            /* Dialog destruction */
            Component.onDestruction: {
                /* Clear username auto-fill data */
                username_auto_fill = "";
            }

            TextField {
                id: usernameForm
                placeholderText: i18n.tr("Username")

                /* Place focus on password form when tab or enter is typed */
                KeyNavigation.tab: passwordForm
                onAccepted: {
                    passwordForm.focus = true;
                }
            }

            TextField {
                id: passwordForm
                placeholderText: i18n.tr("Password")
                echoMode: TextInput.Password

                /* Place focus back on the username form when tab is typed */
                KeyNavigation.tab: usernameForm

                /* Send the loginCredentialsProvided() signal when enter is pressed */
                onAccepted: {
                    loginButton.trigger()
                }
            }

            Button {
                id: loginButton
                text: i18n.tr("Login")
                color: "orange"

                onTriggered: {
                    //send data to controller
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
                color: UbuntuColors.darkGrey
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

    /* Add stations dialog */
    Component {
        id: addStationsDialog

        Popups.Dialog {
            id: addStationsScreen
            title: i18n.tr("Manage Stations")

            Component.onCompleted: {
                searchQueryForm.forceActiveFocus();
            }

            TextField {
                id: searchQueryForm
                placeholderText: i18n.tr("Song or Artist")

                onTextChanged: {
                    newStationSearchQuery(searchQueryForm.text);
                }
            }

            ListView {
                height: units.gu(40)
                model: stationSearchResultList

                delegate: ListItem.Empty {
                    //text: stationSearchResultList[index].artistName
                    Text {
                        anchors.centerIn: parent
                        text: stationSearchResultList[index].artistName
                        color: "white"
                    }
                }
            }

            /* Close dialog */
            Button {
                text: i18n.tr("Close")
                color: "gray"

                onClicked: {
                    PopupUtils.close(addStationsScreen)
                }
            }
        }
    }
}
