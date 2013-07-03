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

MainView {
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"
    
    // Note! applicationName needs to match the .desktop filename 
    applicationName: "Panpipe"
    
    /* 
     This property enables the application to change orientation 
     when the device is rotated. The default is false.
    */
    automaticOrientation: false
    
    width: units.gu(60)
    height: units.gu(80)

    /* Startup operations */
    Component.onCompleted: {
        pandoraModel.login();
    }

    /* Manage Pandora activity */
    PandoraInterface {
        id: pandoraModel

        onConnectedChanged: {
            /* If connection was successful, retrieve the station list */
            if (pandoraModel.connected == true) {
                pandoraModel.retrieveStations();
            }
        }
    }
    
    /* Audio component */
    Audio {
        id: audioPlayer
        source: pandoraModel.currentSongAudioUrl

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

            //play next song
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
        data: pandoraModel.userStations
        songName: pandoraModel.currentSongName
        albumName: pandoraModel.currentSongAlbum
        songArt: pandoraModel.currentSongImageUrl
        stationName: pandoraModel.currentStationName

        /* Bindings to audioPlayer */
        audioPlaying: (audioPlayer.playbackState == Audio.PlayingState)
        position: ((audioPlayer.position / audioPlayer.duration) * 100)

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
        }

        onThumbsDownPressed: {
            console.log("thumbs down");
        }

        onStationSelected: {
            console.log("Station number " + stationIndex + " selected.");

            // Request playlist for selected station
            pandoraModel.setStation(stationIndex);
        }
    }
}
