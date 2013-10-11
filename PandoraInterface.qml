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
    /* Signals */
    signal loginFailed(string givenUsername)

    /* public properties */
    property bool connected

    property var userStations
    property int currentStationIndex
    property string currentStationId
    property string currentStationName

    property var playlistData
    property int playlistCurrentIndex

    /* Private properties */
    property string _lastAttemptedUsername

    /* Initialization operations */
    Component.onCompleted: {
        playlistCurrentIndex = 0;
        playlistData = []; /* Define playlistData as an array */
    }

    /*
        Public functions
    */
    function login(username, password) {
        _lastAttemptedUsername = username;
        if (username && password) {
            Pandora.connect(username, password, loginResponse);

            playlistCurrentIndex = 0;
            playlistData = []; /* Define playlistData as an array */

        } else {
            loginFailed(_lastAttemptedUsername);
        }
    }

    function logout() {

        playlistData = []; /* Define playlistData as an array */

        var default_song_json = {
            "artistName": "",
            "albumName": "",
            "songName": "",
            "albumArtUrl": "./resources/images/cover_default.png",
            "songRating": 0,
            "audioUrlMap": {
                "highQuality": {
                    "bitrate": "",
                    "encoding": "",
                    "audioUrl": "",
                    "protocol": "",
                },
                "mediumQuality": {
                    "bitrate": "",
                    "encoding": "",
                    "audioUrl": "",
                    "protocol": "",
                },
                "lowQuality": {
                    "bitrate": "",
                    "encoding": "",
                    "audioUrl": "",
                    "protocol": "",
                },
            },
            "stationId": "",
        }

        playlistData[0] = new Song.Song(default_song_json);

        playlistCurrentIndex = 0;

        userStations = null;
        currentStationIndex = 0;
        currentStationId = "";
        currentStationName = "";

        Pandora.partnerResponse = {};
        Pandora.userResponse = {};
        Pandora.userStations = {};

        connected = false;
    }

    function retrieveStations() {
        Pandora.getUserStations(retrieveStationsResponse);
    }

    function setStation(stationIndex) {
        /* Update the station name */
        currentStationIndex = stationIndex;
        currentStationName = userStations[currentStationIndex].stationName;

        /* Retrieve playlist data */
        retrievePlaylist(currentStationIndex);
    }

    function loadNextSong() {
        /* Update location in the playlist */
        playlistCurrentIndex = playlistCurrentIndex + 1;
        console.log("advancing to the next song!");

        /* Retrieve more songs for playlist if necessary */
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

    /*
        Private functions
    */
    function retrievePlaylist(stationIndex) {
        console.log("retrieving more songs!");
        Pandora.getStationPlaylist(stationIndex, retrievePlaylistResponse);
    }

    /*
        Callback functions
    */
    function loginResponse(success) {
        if (success == true) {
            console.log("Login succeeded!");
            connected = true;
        } else {
            console.log("Login failed :/");
            loginFailed(_lastAttemptedUsername);
            connected = false;
        }
    }

    function retrieveStationsResponse(stationList) {
        userStations = stationList; // Later use sort property to arrange before assignment
    }

    function retrievePlaylistResponse(playlist) {
        var tempPlaylistArray = [];
        var playlistStationId;

        for (var i = 0; i < playlist.length; i++) {
            /* Make sure this item is a song and not an ad */
            if (playlist[i].artistName) {
                var aSong = new Song.Song(playlist[i]);

                tempPlaylistArray.push(aSong);

                playlistStationId = playlist[i].stationId;
            }
        }

        if (playlistStationId == currentStationId) {
            /* If retrieving playlist for current station, add to master playlist */
            playlistData = playlistData.concat(tempPlaylistArray);
        } else {
            /* If a new station is selected, start rebuilding the master playlist */
            playlistData = tempPlaylistArray;
            playlistCurrentIndex = 0;
            currentStationId = playlistStationId;
        }
    }
}
