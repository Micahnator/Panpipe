/*
Copyright (C) 2015-2016 Micah Losli <micah.losli@gmail.com>

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

import "models"
import "pandora"
import "./AudioStream.js" as AudioStream

Item {
    /* Signals */
    signal loginSuccess(bool success)
    signal stationsUpdated()
    signal moreSongsRetrieved()
    signal serverError()

    signal freshPlaylistPopulated()

    /* Public methods */
    /*
    login(string username, string password)
    selectStation(string stationToken)
    setStationSortingMethodAlphabetical(bool setAlphabetical)
    nextSong()

    */

    /* Aliases */
    property alias connected: pandoraInterfaceComponent.connected
    property alias stationsData: userStationsData.model
    property alias stationSortMethod: userStationsData.sortMethod
    property alias playlistData: currentStationPlaylist.model

    property var currentSong: currentStationPlaylist.currentPlaylistItem
    property alias playlistAvailable: currentStationPlaylist.playlistDataAvailable

    property alias playlist: currentStationPlaylist.playlist

    /* Public properties */
    property bool loggingIn
    property bool loadingStations
    property bool loadingPlaylist
    property bool loading: loggingIn || loadingStations || loadingPlaylist

    property bool stationSelected
    property string currentStationId
    property string currentStationName

    property var currentSongItem
    property string currentSongArtist
    property string selectedAudioStream


    /* Pandora interface component */
    PandoraInterface {
        id: pandoraInterfaceComponent

        onLoginFailed: {
            loginSuccess(false);
        }

        onLoginSucceeded: {
            loginSuccess(true);
        }
    }

    /* User stations data */
    PandoraStationsModel {
        id: userStationsData

        pandoraInterface: pandoraInterfaceComponent

        onUpdated: {
            loadingStations = false;
            stationsUpdated();
        }

        onDataTimeout: {
            loadingStations = false;
        }

        onReceivedError: {
            loadingStations = false;
        }

    }

    /* Current station playlist data */
    PandoraPlaylistModel {
        id: currentStationPlaylist

        pandoraInterface: pandoraInterfaceComponent

        onUpdated: {
            moreSongsRetrieved();
            loadingPlaylist = false;
        }

    }

    /* Event handlers */
    onLoginSuccess: {
        loggingIn = false;
        if(success == true) {
            loadingStations = true;
            userStationsData.getStationData();
        }
    }


    /* Public method implementations */
    function login(username, password) {
        if(username && password && typeof(username) == "string" && typeof(password) == "string") {
            loggingIn = true;
            pandoraInterfaceComponent.login(username, password, null);
        }
    }

    function logout() {
        pandoraInterfaceComponent.logout();
        currentStationPlaylist.clearPlaylist();
        currentStationPlaylist.currentStationToken = "";
        userStationsData.clearStations();

    }

    function selectStation(stationToken) {
        if(stationToken !== currentStationPlaylist.currentStationToken){
            loadingPlaylist = true;
            currentStationPlaylist.currentStationToken = stationToken;  //also loads some songs
        }
    }

    function setStationSortingMethodAlphabetical(setAlphabetical) {
        if(typeof(setAlphabetical) == "bool") {
            if(setAlphabetical) {
                userStationsData.sortMethod = "alphabetical";
            }
            else {
                userStationsData.sortMethod = "date";
            }
        }
    }

    function nextSong() {
        if(currentStationPlaylist.currentStationToken !== "") {
            currentStationPlaylist.loadNextSong();
        }
    }

    function giveFeedback(favorable, trackToken) {
        /* Update data model */
        if(favorable) {
            currentStationPlaylist.currentPlaylistItem.songRating = 1;
        } else {
            currentStationPlaylist.currentPlaylistItem.songRating = -1;
        }

        /* Send the feedback to Pandora */
        pandoraInterfaceComponent.giveFeedback(favorable, trackToken, null);
    }

}
