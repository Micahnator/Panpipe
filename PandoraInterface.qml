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

import "pandora.js" as Pandora
import "Song.js" as Song

Item {
    /* public properties */
    property bool connected

    property var userStations
    property int currentStationIndex
    property string currentStationId
    property string currentStationName

    property var playlistData
    property int playlistCurrentIndex

    /* Initialization operations */
    Component.onCompleted: {
        playlistCurrentIndex = 0;
        playlistData = []; //define playlistData as an array
    }

    /* public functions */
    function login(username, password) {
        if (username && password) {
            Pandora.connect(username, password, loginResponse);
        } else {
            viewComponent.requestCredentials();
        }
    }

    function retrieveStations() {
        Pandora.getUserStations(retrieveStationsResponse);
    }

    function setStation(stationIndex) {
        //update the station name
        currentStationIndex = stationIndex;
        currentStationName = userStations[currentStationIndex].stationName;

        //retrieve playlist data
        retrievePlaylist(currentStationIndex);
    }

    function loadNextSong() {
        //update location in the playlist
        playlistCurrentIndex = playlistCurrentIndex + 1;

        updateCurrentSongData();

        console.log("advancing to the next song!");

        //retrieve more songs for playlist if necessary
        if (playlistCurrentIndex >= (playlistData.length - 1)) {
            retrievePlaylist(currentStationIndex);
        }
    }

    function giveFeedback(favorable, trackToken) {
        /* Update data model */
        if(favorable) {
            playlistData[playlistCurrentIndex].songRating = 1;
        } else {
            playlistData[playlistCurrentIndex].songRating = -1;
        }

        /* Send the feedback to Pandora */
        Pandora.sendFeedback(favorable, trackToken, null);
    }

    /* private functions */
    function retrievePlaylist(stationIndex) {
        console.log("retrieving more songs!");
        Pandora.getStationPlaylist(stationIndex, retrievePlaylistResponse);
    }

    function updateCurrentSongData() {
        // update needed properties
//        currentSongName = playlistData[playlistCurrentIndex].songName;
//        currentSongAlbum = playlistData[playlistCurrentIndex].albumName;
//        currentSongArtist = playlistData[playlistCurrentIndex].artistName;
//        currentSongAudioUrl = playlistData[playlistCurrentIndex].audioUrl;
//        currentSongImageUrl = playlistData[playlistCurrentIndex].albumArtUrl;
//        currentSongToken = playlistData[playlistCurrentIndex].trackToken;
    }




    /* callback functions */
    function loginResponse(success) {
        if (success == true) {
            console.log("Login succeeded!");
            connected = true;
        } else {
            console.log("Login failed :/");
            viewComponent.requestCredentials();
            connected = false;
        }
    }

    function retrieveStationsResponse(stationList) {
        userStations = stationList; //later use sort property to arrange before assignment
    }

    function retrievePlaylistResponse(playlist) {
        var tempPlaylistArray = [];
        var playlistStationId;

        for (var i = 0; i < playlist.length; i++) {
            // make sure this item is a song and not an ad
            if (playlist[i].artistName) {
                var aSong = new Song.Song(playlist[i]);

                tempPlaylistArray.push(aSong);

                playlistStationId = playlist[i].stationId;
            }
        }

        if (playlistStationId == currentStationId) {
            // if retrieving playlist for current station, add to master playlist
            playlistData = playlistData.concat(tempPlaylistArray);
        } else {
            // if a new station is selected, start rebuilding the master playlist
            playlistData = tempPlaylistArray;
            playlistCurrentIndex = 0;
            currentStationId = playlistStationId;

            updateCurrentSongData();
        }
    }
}
