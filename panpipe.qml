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
import QtMultimedia 5.0
import Ubuntu.Components 0.1

import "storage.js" as Storage

MainView {
    /* objectName for functional testing purposes (autopilot-qt5) */
    objectName: "mainView"
    
    /* Note! applicationName needs to match the .desktop filename */
    applicationName: "panpipe"
    
    /* 
     This property enables the application to change orientation 
     when the device is rotated. The default is false.
    */
    automaticOrientation: false
    
    width: units.gu(50)
    height: units.gu(80)

    /* Suru colors */
    headerColor: "#343C60"
    backgroundColor: "#6A69A2"
    footerColor: "#8896D5"

    /* Properties */
    property string pandoraUsername
    property string pandoraPassword

    /* Startup operations */
    Component.onCompleted: {
        /* Initialize the storage database */
        Storage.initialize();

        pandoraUsername = Storage.getSetting("pandora_username");
        pandoraPassword = Storage.getSetting("pandora_password");

        if(("Unknown" == pandoraUsername) || ("Unknown" == pandoraPassword)) {
            viewComponent.requestCredentials();
        } else {
            pandoraModel.login(pandoraUsername, pandoraPassword);
        }
    }

    /* HUD actions */
    Action {
        id: logoutAction
        text: i18n.tr("Logout")
        keywords: i18n.tr("Logout")
        onTriggered: {
            //logout();
            viewComponent.confirmLogout();
        }
    }

    actions: [logoutAction]



    /* Manage Pandora activity */
    PandoraInterface {
        id: pandoraModel

        onConnectedChanged: {
            /* If connection was successful, retrieve the station list */
            if (pandoraModel.connected == true) {
                pandoraModel.retrieveStations();
            }
        }

        onLoginFailed: {
            viewComponent.requestCredentials(givenUsername);
        }
    }
    
    /* Audio component */
    Audio {
        id: audioPlayer
        source: pandoraModel.playlistData[pandoraModel.playlistCurrentIndex].audioUrlMap.mediumQuality.audioUrl

        onStatusChanged: {
            switch (audioPlayer.status) {
            case Audio.Loaded:
                audioPlayer.play();
                break;
            case Audio.EndOfMedia:
                pandoraModel.loadNextSong();
                audioPlayer.play();
                break;
            }
        }

        onError: {
            console.log("Audio element error:");
            console.log(audioPlayer.error);
            console.log(audioPlayer.errorString);

            /* Play next song */
            audioPlayer.stop();
            pandoraModel.loadNextSong();
            audioPlayer.play();
        }

        onAvailabilityChanged: {
            console.log("availability:");
            console.log(audioPlayer.availability);
        }
    }

    /* View for Panpipe */
    PanpipeView {
        id: viewComponent
        anchors.fill: parent

        /* Bindings to PandoraInterface */
        stationsList: pandoraModel.userStations
        stationName: i18n.tr(pandoraModel.currentStationName)
        playlist: pandoraModel.playlistData
        currentPlaylistIndex: pandoraModel.playlistCurrentIndex

        /* Bindings to audioPlayer */
        audioPlaying: (audioPlayer.playbackState == Audio.PlayingState)
        playbackPercentage: (audioPlayer.position / audioPlayer.duration)
        playbackPosition: audioPlayer.position
        playbackDuration: audioPlayer.duration

        /* Signal handlers */
        onPlayPausePressed: {
            if (playState == true) {
                console.log("playing");
                audioPlayer.play();
            } else {
                console.log("pausing");
                audioPlayer.pause();
            }
        }

        onNextTrackPressed: {
            console.log("next track requested");
            audioPlayer.stop();
            pandoraModel.loadNextSong();
            audioPlayer.play();
        }

        onThumbsUpPressed: {
            console.log("thumbs up");
            pandoraModel.giveFeedback(true, pandoraModel.playlistData[pandoraModel.playlistCurrentIndex].trackToken);
        }

        onThumbsDownPressed: {
            console.log("thumbs down");
            pandoraModel.giveFeedback(false, pandoraModel.playlistData[pandoraModel.playlistCurrentIndex].trackToken);

            /* Skip thumbs-down song */
            audioPlayer.stop();
            pandoraModel.loadNextSong();
            audioPlayer.play();
        }

        onStationSelected: {
            console.log("Station number " + stationIndex + " selected.");

            /* Request playlist for selected station */
            pandoraModel.setStation(stationIndex);
        }

        onLoginCredentialsProvided: {
            /* Perform login */
            pandoraModel.login(username, password);

            /* Store login credientials */
            Storage.setSetting("pandora_username", username);
            Storage.setSetting("pandora_password", password);

        }

        onUserLogout: {
            logout();
        }

    }

    /* Action functions */
    function logout() {
        /* Clear audio component */
        audioPlayer.stop();

        /* Clear pandora interface */
        pandoraModel.logout();

        /* Clear login credentials */
        Storage.setSetting("pandora_username", "Unknown");
        Storage.setSetting("pandora_password", "Unknown");

        /* Request login credentials */
        viewComponent.requestCredentials();
    }
}
