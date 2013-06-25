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

Item {
    /* public properties */
    property bool connected

    property string currentSongName
    property string currentSongAlbum
    property string currentSongArtist
    property string currentSongAudioUrl
    property string currentSongImageUrl

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
    function login() {
        Pandora.connect("panache.player@gmail.com", "PanacheMusic", loginResponse);
    }

    function retrieveStations() {
        Pandora.getUserStations(retrieveStationsResponse);
    }

    function setStation(stationIndex) {
        // update the station name
        currentStationIndex = stationIndex;
        currentStationName = userStations[currentStationIndex].stationName;

        // retrieve playlist data
        retrievePlaylist(currentStationIndex);
    }

    /* private functions */
    function retrievePlaylist(stationIndex) {
        Pandora.getStationPlaylist(stationIndex, retrievePlaylistResponse);
    }




    /* callback functions */
    function loginResponse(success) {
        if (success == true) {
            console.log("Login succeeded!");
            connected = true;
        } else {
            console.log("Login failed :/");
        }
    }

    function retrieveStationsResponse(stationList) {
        userStations = stationList; //later use sort property to arrange before assignment
        //console.log(JSON.stringify(stationList));
    }

    function retrievePlaylistResponse(playlist) {
        var tempPlaylistArray = [];

        for (var i = 0; i < playlist.length; i++) {
            // make sure this item is a song and not an ad
            if (playlist[i].artistName) {
                var tempSongObject = {};

                tempSongObject.artistName = playlist[i].artistName;
                tempSongObject.albumName = playlist[i].albumName;
                tempSongObject.songName = playlist[i].songName;
                tempSongObject.albumArtUrl = playlist[i].albumArtUrl;
                tempSongObject.audioUrl = playlist[i].audioUrlMap.highQuality.audioUrl;

                tempPlaylistArray.push(tempSongObject);
            }
        }

        playlistData = playlistData.concat(tempPlaylistArray);
        //playlistData = tempPlaylistArray;

        //temporary
        //currentSongData = playlist[playlistIndex];
        currentSongName = playlistData[playlistCurrentIndex].songName;
        currentSongAlbum = playlistData[playlistCurrentIndex].albumName;
        currentSongArtist = playlistData[playlistCurrentIndex].artistName;
        currentSongImageUrl = playlistData[playlistCurrentIndex].albumArtUrl;
    }
}
