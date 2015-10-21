/*
Copyright (C) 2013-2015 Micah Losli <micah.losli@gmail.com>

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
import QtMultimedia 5.4
import Ubuntu.Components 1.3
//import Ubuntu.Unity.Action 1.0 as UnityActions
import "storage.js" as Storage
//import "pandora"
//import "models"
import "panpipe_core"
import "ui"

import "./panpipe_core/AudioStream.js" as AudioStream

MainView {
    /* objectName for functional testing purposes (autopilot-qt5) */
    objectName: "mainView"
    id: root
    
    /* Note! applicationName needs to match the .desktop filename */
    applicationName: "com.ubuntu.developer.mlosli.panpipe"
    
    /* 
     This property enables the application to change orientation 
     when the device is rotated. The default is false.
    */
    automaticOrientation: false
    
    width: units.gu(50)
    height: units.gu(80)

//    useDeprecatedToolbar: false

    /* Suru colors */
    //headerColor: "#343C60"
    //backgroundColor: "#24248F"
    //footerColor: "#8896D5"

//    headerColor: "#FF0000"
//    backgroundColor: "#1A1A80"
//    footerColor: "#FFFFFF"

    backgroundColor: "#193366"

    /* Properties */
    property string pandoraUsername: Storage.getSetting("pandora_username");
    property string pandoraPassword: Storage.getSetting("pandora_password");
    property string startupPreferredStationSort

    property string _lastAttemptedUsername

//    property alias pandoraInterface: pandoraInterface
//    property alias stationsModel: stationsModel

    /* Startup operations */
    Component.onCompleted: {
        /* Initialize the storage database */
        Storage.initialize();

        /* Get the last used station sort method */
        startupPreferredStationSort = Storage.getSetting("station_sort_method");

        /* Apply the selected audio format */
        pandoraBackend.selectedAudioStream = AudioStream.Streams.MP3_128;   //Use MP3 for now, as default streams crash on Micah's Laptop

        /* If login credentials are available, attempt to use them to login */
        if(("Unknown" == pandoraUsername) || ("Unknown" == pandoraPassword)) {
            viewComponent.requestCredentials();
        } else {
            //pandoraInterface.login(pandoraUsername, pandoraPassword);
            pandoraBackend.login(pandoraUsername, pandoraPassword);
        }
    }


//    Action {
//        id: logoutAction
//        text: i18n.tr("Logout")
//        onTriggered: {
//            viewComponent.confirmLogout();
//        }
//    }

//    actions: [logoutAction]

    PanpipeCore {
        id: pandoraBackend

//        onLoginSuccess: {
//            if(success) {
//                console.log("Micah, we logged in!");
//            }
//            else
//            {
//                console.log("Micah, we aren't there yet.");
//            }
//        }

        onStationsUpdated: {
            console.log("Micah, we got stations!");

            console.log(stationsData);
//            selectStation(stationsData.get(0).stationToken);
        }

        onPlaylistDataChanged: {
            console.log("Micah, we received some playlist data!");
        }

        onPlaylistAvailableChanged: {
            if(playlistAvailable === true) {
//                audioPlayer.source = pandoraBackend.currentSong.audioUrlMap.lowQuality.audioUrl;
//                audioPlayer.source = "http://www.liberliber.it/mediateca/musica/m/mozart/abendempfindung_k_523/gw/mp3/mozart_k_523_gw_01.mp3";
//                audioPlayer.source = "./5516897872547443989.mp4";
//                audioPlayer.source = pandoraBackend.currentSong.additionalAudioUrl;
                audioPlayer.play();
            }
        }

    }

    /* Manage Pandora activity */
//    PandoraInterface {
//        id: pandoraInterface

//        onConnectedChanged: {
//            /* If connection was successful, retrieve the station list */
//            if (pandoraInterface.connected == true) {
//                stationsModel.getStationData();
//            }
//        }

//        onLoginFailed: {
//            viewComponent.requestCredentials();
//        }
//    }

    /* Centralised data model of user stations */
//    PandoraStationsModel {
//        id: stationsModel
//        pandoraInterface: pandoraInterface

//        Component.onCompleted: {
//            sortMethod = "alphabetical";
//        }

//        //
//        onUpdated: {
//            playlistModel.currentStationToken = model.get(0).stationToken;
//        }
//    }

    //Testing: Centralised data model of playlist data */
//    PandoraPlaylistModel {
//        id: playlistModel
//        pandoraInterface: pandoraInterface

//        onCurrentStationTokenChanged: {
//            retrieveMoreSongs();
//        }
//    }
    
    /* Audio component */
    Audio {
        id: audioPlayer
//        source: pandoraInterface.playlistData[pandoraInterface.playlistCurrentIndex].audioUrlMap.mediumQuality.audioUrl
//        source: pandoraBackend.currentSong.audioUrlMap.mediumQuality.audioUrl
        source: pandoraBackend.currentSongAudioUrl

        onStatusChanged: {
            switch (audioPlayer.status) {
            case Audio.Loaded:
                audioPlayer.play();
                break;
            case Audio.EndOfMedia:
//                pandoraInterface.loadNextSong();
                pandoraBackend.nextSong();
                audioPlayer.play();
                break;
            }
        }

//        onSourceChanged: {
//            audioPlayer.play();
//        }

        onError: {
            console.log("Audio element error:");
            console.log(audioPlayer.error);
            console.log(audioPlayer.errorString);

            /* Play next song */
            audioPlayer.stop();
            pandoraInterface.loadNextSong();
            audioPlayer.play();
        }

        onAvailabilityChanged: {
            console.log("availability:");
            console.log(audioPlayer.availability);
        }
    }

    /* View for Panpipe */
    PanpipeView {
        anchors.fill: parent


        /* Data binding */
        stationData: pandoraBackend.stationsData

        /* Event handling */
        onStationSelected: {
            pandoraBackend.selectStation(stationToken);
        }
    }

//    PanpipeView {
//        id: viewComponent
//        anchors.fill: parent

//        /* Bindings to pandoraInterface */
//        stationsList: pandoraInterface.userStations
//        stationName: i18n.tr(pandoraInterface.currentStationName)
//        playlist: pandoraInterface.playlistData
//        currentPlaylistIndex: pandoraInterface.playlistCurrentIndex
//        stationSearchResultList: pandoraInterface.stationSearchResults

//        /* Bindings to audioPlayer */
//        audioPlaying: (audioPlayer.playbackState == Audio.PlayingState)
//        playbackPercentage: (audioPlayer.position / audioPlayer.duration)
//        playbackPosition: audioPlayer.position
//        playbackDuration: audioPlayer.duration
//        audioSourceUrl: audioPlayer.source

//        /* Signal handlers */
//        onPlayPausePressed: {
//            if (playState == true) {
//                console.log("playing");
//                audioPlayer.play();
//            } else {
//                console.log("pausing");
//                audioPlayer.pause();
//            }
//        }

//        onNextTrackPressed: {
//            console.log("next track requested");
//            audioPlayer.stop();
//            pandoraInterface.loadNextSong();
//            audioPlayer.play();
//        }

//        onThumbsUpPressed: {
//            console.log("thumbs up");
//            pandoraInterface.giveFeedback(true, pandoraInterface.playlistData[pandoraInterface.playlistCurrentIndex].trackToken);
//        }

//        onThumbsDownPressed: {
//            console.log("thumbs down");
//            pandoraInterface.giveFeedback(false, pandoraInterface.playlistData[pandoraInterface.playlistCurrentIndex].trackToken);

//            /* Skip thumbs-down song */
//            audioPlayer.stop();
//            pandoraInterface.loadNextSong();
//            audioPlayer.play();
//        }

//        onStationSelected: {
//            /* Request playlist for selected station */
//            pandoraInterface.setStation(stationToken)
//        }

//        onLoginCredentialsProvided: {
//            /* Perform login */
//            _lastAttemptedUsername = username
//            pandoraInterface.login(username, password);

//            /* Store login credientials */
//            Storage.setSetting("pandora_username", username);
//            Storage.setSetting("pandora_password", password);
//        }

//        onUserLogout: {
//            logout();
//        }

//        onSortPreferenceProvided: {
//            /* Store the user's preferred station sort method */
//            Storage.setSetting("station_sort_method", preferredSort);
//        }

//        onNewStationSearchQuery: {
//            pandoraInterface.searchForMusic(query);
//        }

//    }




    /* Action functions */
    function logout() {
        /* Clear audio component */
        audioPlayer.stop();

        /* Clear pandora interface */
        pandoraInterface.logout();

        /* Clear the UI */
        viewComponent.updateInterface();

        /* Clear login credentials */
        Storage.setSetting("pandora_username", "Unknown");
        Storage.setSetting("pandora_password", "Unknown");

        /* Request login credentials */
        viewComponent.requestCredentials(_lastAttemptedUsername);
    }
}
