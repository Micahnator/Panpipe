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
import Ubuntu.Components.Popups 1.3 as Popups

import "pages"
import "../panpipe_core/AudioStream.js" as AudioStream

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

    signal loginCredentialsProvided(string username, string password)
    signal userLogout()

    signal streamSelected(string streamEnum)

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

    property string username_auto_fill


    Action {
        id: logoutAction
        iconName: "close"
        text: i18n.tr("Logout")
        onTriggered: {
            /* Confirm the user wants to logout */
            PopupUtils.open(logoutDialog);
        }
    }

    Action {
        id: openSettingsAction
        iconName: "settings"
        text: i18n.tr("Settings")
        onTriggered: {
            /* Confirm the user wants to logout */
            PopupUtils.open(settingsDialog);
        }
    }

    AdaptivePageLayout {
        id: layout
        anchors.fill: parent
        primaryPage: stationsPage

        StationsPage {
            id: stationsPage

            head.actions: [openSettingsAction, logoutAction]

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
           title: i18n.tr("Panpipe Settings")

//           property string selectedAudioEnum

           /* Audio stream type / quality settings */
           ListModel {
               id: audioStreamsModel
//               ListElement { name: "Low"; value: AudioStream.Streams.DFLT_LOW }
//               ListElement { name: "Medium"; value: AudioStream.Streams.DFLT_MED }
//               ListElement { name: "High"; value: AudioStream.Streams.DFLT_HI }
//               ListElement { name: "AAC Mono"; value: AudioStream.Streams.AAC_MONO_40 }
//               ListElement { name: "AAC"; value: AudioStream.Streams.AAC_64 }
//               ListElement { name: "AAC+ 32"; value: AudioStream.Streams.AACP_32 }
//               ListElement { name: "AAC+ 64"; value: AudioStream.Streams.AACP_64 }
//               ListElement { name: "AAC+ ADTS 24"; value: AudioStream.Streams.AACP_ADTS_24 }
//               ListElement { name: "AAC+ ADTS 32"; value: AudioStream.Streams.AACP_ADTS_32 }
//               ListElement { name: "AAC+ ADTS 64"; value: AudioStream.Streams.AACP_ADTS_64 }
//               ListElement { name: "MP3 128"; value: AudioStream.Streams.MP3_128 }
//               ListElement { name: "WMA 32"; value: AudioStream.Streams.WMA_32 }

               ListElement { name: "Low"; value: "LOW" }
               ListElement { name: "Medium"; value: "MED" }
               ListElement { name: "High"; value: "HI" }
               ListElement { name: "AAC Mono"; value: "HTTP_40_AAC_MONO" }
               ListElement { name: "AAC"; value: "HTTP_64_AAC" }
               ListElement { name: "AAC+ 32"; value: "HTTP_32_AACPLUS" }
               ListElement { name: "AAC+ 64"; value: "HTTP_64_AACPLUS" }
               ListElement { name: "AAC+ ADTS 24"; value: "HTTP_24_AACPLUS_ADTS" }
               ListElement { name: "AAC+ ADTS 32"; value: "HTTP_32_AACPLUS_ADTS" }
               ListElement { name: "AAC+ ADTS 64"; value: "HTTP_64_AACPLUS_ADTS" }
               ListElement { name: "MP3 128"; value: "HTTP_128_MP3" }
               ListElement { name: "WMA 32"; value: "HTTP_32_WMA" }
            }

            Component {
                id: selectorDelegate
                OptionSelectorDelegate { text: name }
            }

            OptionSelector {
                id: audioStreamSelector
                text: i18n.tr("Select Audio Quality")

                model: audioStreamsModel
                delegate: selectorDelegate

                Component.onCompleted: {
                    for(var i = 0; i < model.count; i++) {
                        if(model.get(i).value === selectedStream) {
                            selectedIndex = i;
                        }
                    }
                }

                onDelegateClicked: {
                    if(audioStreamsModel.get(index).value !== selectedStream) {
                        streamSelected(audioStreamsModel.get(index).value);
                    }
//                    selectedAudioEnum = audioStreamsModel.get(index).value;
                }
            }

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
                   /* Write settings changes */
//                   streamSelected(selectedAudioEnum);

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
                   source: Qt.resolvedUrl("../panpipe-256.png")
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


    /* Public functions */

    function requestCredentials(username) {
        /* If given, populate auto fill value */
        if(username) {
            username_auto_fill = username;
        }

        /* show login dialog */
        PopupUtils.open(loginDialog);
    }

    function clearView() {

    }

}
