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
//    property string currentSongAudioUrl:_selectAudioUrl(currentSong)
    property string currentSongArtist
    property string selectedAudioStream

    /* Private properties */


    /* Initialization */
//    Component.onCompleted: {
//        selectedAudioStream = AudioStream.Streams.DFLT_MED;

//    }

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

//    onSelectedAudioStreamChanged: {
//        currentStationPlaylist.pandoraInterface.audioStreamString = selectedAudioStream;
//    }


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
//            playlistData[playlistCurrentIndex].songRating = 1;
            currentStationPlaylist.currentPlaylistItem.songRating = 1;
        } else {
//            playlistData[playlistCurrentIndex].songRating = -1;
            currentStationPlaylist.currentPlaylistItem.songRating = -1;
        }

        /* Send the feedback to Pandora */
//        Pandora.sendFeedback(favorable, trackToken, null);
        pandoraInterfaceComponent.giveFeedback(favorable, trackToken, null);
    }


    /* Private methods */
//    function _selectAudioUrl(currentSongObject) {
//        if(connected) {
//            var selectedUrl

//            switch(selectedAudioStream) {
//                case AudioStream.Streams.DFLT_LOW:
//                    console.log("Using low stream");
//                    selectedUrl = currentSongObject.audioUrlMap.lowQuality.audioUrl;
//                    break;
//                case AudioStream.Streams.DFLT_MED:
//                    console.log("Using medium stream");
//                    selectedUrl = currentSongObject.audioUrlMap.mediumQuality.audioUrl;
//                    break;
//                case AudioStream.Streams.DFLT_HI:
//                    console.log("Using hight stream");
//                    selectedUrl = currentSongObject.audioUrlMap.highQuality.audioUrl;
//                    break;
//                case AudioStream.Streams.AAC_MONO_40:
//                    console.log("Using AAC mono stream");
//                    selectedUrl = currentSongObject.audioUrlMap.extraUrls.aacMono;
//                    break;
//                case AudioStream.Streams.AAC_64:
//                    console.log("Using AAC 64 stream");
//                    selectedUrl = currentSongObject.audioUrlMap.extraUrls.aac64;
//                    break;
//                case AudioStream.Streams.AACP_32:
//                    console.log("Using AACP 32 stream");
//                    selectedUrl = currentSongObject.audioUrlMap.extraUrls.aacp32;
//                    break;
//                case AudioStream.Streams.AACP_64:
//                    console.log("Using AACP 64 stream");
//                    selectedUrl = currentSongObject.audioUrlMap.extraUrls.aacp64;
//                    break;
//                case AudioStream.Streams.AACP_ADTS_24:
//                    console.log("Using ADTS 24 stream");
//                    selectedUrl = currentSongObject.audioUrlMap.extraUrls.adts24;
//                    break;
//                case AudioStream.Streams.AACP_ADTS_32:
//                    console.log("Using ADTS 32 stream");
//                    selectedUrl = currentSongObject.audioUrlMap.extraUrls.adts32;
//                    break;
//                case AudioStream.Streams.AACP_ADTS_64:
//                    console.log("Using ADTS 64 stream");
//                    selectedUrl = currentSongObject.audioUrlMap.extraUrls.adts64;
//                    break;
//                case AudioStream.Streams.MP3_128:
//                    console.log("Using MP3 stream");
//                    selectedUrl = currentSongObject.audioUrlMap.extraUrls.mp3;
//                    break;
//                case AudioStream.Streams.WMA_32:
//                    console.log("Using WMA stream");
//                    selectedUrl = currentSongObject.audioUrlMap.extraUrls.wma;
//                    break;
//                default:
//                    console.log("Using default stream");
//                    selectedUrl = currentSongObject.audioUrlMap.lowQuality.audioUrl;
//                    break;
//            }
//        }
//        else {
//            console.log("Not connected, returning empty url");
//            return "";
//        }

//        return selectedUrl;
//    }

}
