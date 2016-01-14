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

    backgroundColor: "#193366"

    /* Properties */
    property string pandoraUsername: Storage.getSetting("pandora_username");
    property string pandoraPassword: Storage.getSetting("pandora_password");
    property string startupPreferredStationSort

    property string _lastAttemptedUsername

    /* Startup operations */
    Component.onCompleted: {
        /* Initialize the storage database */
//        Storage.initialize();

        /* Get the last used station sort method */
//        startupPreferredStationSort = Storage.getSetting("station_sort_method");

        /* Apply the selected audio format */
        pandoraBackend.selectedAudioStream = AudioStream.Streams.MP3_128;   //Use MP3 for now, as default streams crash on Micah's Laptop

        /* If login credentials are available, attempt to use them to login */
        pandoraBackend.login("mlosli@yahoo.com", "gonavy");
//        if(("Unknown" == pandoraUsername) || ("Unknown" == pandoraPassword)) {
//            viewComponent.requestCredentials();
//        } else {
//            //pandoraInterface.login(pandoraUsername, pandoraPassword);
//            pandoraBackend.login(pandoraUsername, pandoraPassword);
//        }
    }

    /* This delay in starting audio playback avoid audio glitchiness at beginning of track */
    Timer {
        id: playDelayTimer

        interval: 100
        repeat: false

        onTriggered: {
            audioPlayer.play();
        }
    }

    PanpipeCore {
        id: pandoraBackend

        onStationsUpdated: {
            console.log("Micah, we got stations!");

            console.log(stationsData);
        }

        onPlaylistDataChanged: {
            console.log("Micah, we received some playlist data!");
        }
    }
    
    /* Audio component */
    Audio {
        id: audioPlayer
        source: pandoraBackend.currentSongAudioUrl

        onStatusChanged: {
            switch (audioPlayer.status) {
            case Audio.Loaded:
                playDelayTimer.start();
                break;
            case Audio.EndOfMedia:
                pandoraBackend.nextSong();
                playDelayTimer.start();
                break;
            }
        }

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

        /*
        Note: See PandoraPlaylsitModel.qml
        for a definition of what data fields
        are in the currentSong object.
        */
        currentAlbumArtUrl: pandoraBackend.currentSong.albumArtUrl
        currentSongName: pandoraBackend.currentSong.songName
        currentSongAlbum: pandoraBackend.currentSong.albumName
        currentSongArtist: pandoraBackend.currentSong.artistName

        playbackPercentage: (audioPlayer.position / audioPlayer.duration)

        audioPlaying: (audioPlayer.playbackState === Audio.PlayingState)
        playbackPosition: audioPlayer.position
        playbackDuration: audioPlayer.duration
        audioSourceUrl: audioPlayer.source

        currentSongRating: pandoraBackend.currentSong.songRating

        /* Event handling */
        onStationSelected: {
            pandoraBackend.selectStation(stationToken);
        }

        onPlay: {
            audioPlayer.play();
        }

        onPause: {
            audioPlayer.pause();
        }

        onNextTrack: {
            pandoraBackend.nextSong();
        }

        onThumbsUp: {
            pandoraBackend.giveFeedback(true, pandoraBackend.currentSong.trackToken)
        }

        onThumbsDown: {
            pandoraBackend.giveFeedback(false, pandoraBackend.currentSong.trackToken)
            pandoraBackend.nextSong();
        }
    }

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
