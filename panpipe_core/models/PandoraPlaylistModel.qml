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
import QtMultimedia 5.6

import "../AudioStream.js" as AudioStream

Item {
    /* Signals */
    signal updated()
    signal receivedError()
    signal dataTimeout()

    /* Public methods */
    /*
    retrieveMoreSongs()
    clearPlaylist()
    getAnyPlaylistItem(index)
    loadNextSong()

    */

    /* Aliases */
    property alias model: model
    property alias count: model.count
    property alias playlist: playlist

    /* Public properties */
    property bool loading
    property var pandoraInterface   /* Must be bound to a PandoraInterface component */
    property int timeoutTime        /* Defaults to 10 seconds if not set */
    property var currentStationToken
    property string currentStationName
    property int currentPlaylistIndex: -1
    property var currentPlaylistItem: getAnyPlaylistItem(playlist.currentIndex)
    property bool playlistDataAvailable: false

    /* Private properties */
    property var _lastReceivedGoodData
    property date _currentDateTime: new Date()
    property int _PLAYLISTS_REQUESTED_NEW_STATION: 2
    property int _PLAYLISTS_REQUESTED_PERIODIC: 1
    property int _PLAYLIST_REQUEST_PERIOD: 30000
    property int _UNPLAYED_BUFFER_LIMIT: 20


    /* Initialization */
    Component.onCompleted: {
        loading = false;

        /* If timeoutTime is null, set it to a default of 10 seconds */
        if(!timeoutTime || 0 === timeoutTime) {
            timeoutTime = 10000;
        }
    }

    onCurrentStationTokenChanged: {
        if(currentStationToken !== "") {
            playlistDataAvailable = false;
            clearPlaylist();

            /* Fill up the playlist with songs */
            for(var i = 0; i < _PLAYLISTS_REQUESTED_NEW_STATION; i++) {
                retrieveMoreSongs();
            }
        }
    }

    /* Timer used to periodically build up the buffer of songs without requesting too many too fast */
    Timer {
        id: getMoreSongsTimer

        interval: _PLAYLIST_REQUEST_PERIOD
        repeat: true
        running: (playlist.itemCount > 0)

        onTriggered: {
            if(((playlist.itemCount - playlist.currentIndex) < _UNPLAYED_BUFFER_LIMIT)) {
                for(var i = 0; i < _PLAYLISTS_REQUESTED_PERIODIC; i++) {
                    retrieveMoreSongs();
                }
                console.log("The playlist now has ", playlist.itemCount, " items in it. Going to put ", (4* _PLAYLISTS_REQUESTED_PERIODIC), " more in.");
            }
        }
    }

    /* This playlist component allows the system to play music when app is suspended */
    Playlist {
        id: playlist
        playbackMode: Playlist.Sequential
    }

    /* Data modle used to store the playlist data for the current station */
    ListModel {
        id: model
    }

    /* Timer to watch for unresponsive playlist requests */
    Timer {
        id: requestResponseTimeout

        interval: timeoutTime
        repeat: false

        /* Handle data timeout */
        onTriggered: {
            dataTimeout();
            loading = false;
            console.log("Failed to receive request for playlist data inside timeout time of", timeoutTime / 1000, "seconds");
        }
    }


    /* Public functions */

    function retrieveMoreSongs() {
        function dataRetrieved(data) {
            requestResponseTimeout.stop();
            loading = false;

            if(data.stat == "ok") {
                console.log("Playlist data received!!!");
                _lastReceivedGoodData = data;

                /* Add received playlist data to the model */
                var playlistArray = data.result.items;

                if(model.count == 0) {
                    /* Don't reset index until model is updated */
                    var resetPlaylistIndex = true;
                }

                for ( var key in playlistArray ) {
                    var jo = playlistArray[key];

                    /* 'object-ify items in the additionalAudioUrl array */
                    if(jo.additionalAudioUrl) {
                        if(jo.additionalAudioUrl.constructor === Array) {
                            jo.audioUrlMap.extraUrls = {};
                            jo.audioUrlMap.extraUrls.aacMono = jo.additionalAudioUrl[0];
                            jo.audioUrlMap.extraUrls.aac64 = jo.additionalAudioUrl[1];
                            jo.audioUrlMap.extraUrls.aacp32 = jo.additionalAudioUrl[2];
                            jo.audioUrlMap.extraUrls.aacp64 = jo.additionalAudioUrl[3];
                            jo.audioUrlMap.extraUrls.adts24 = jo.additionalAudioUrl[4];
                            jo.audioUrlMap.extraUrls.adts32 = jo.additionalAudioUrl[5];
                            jo.audioUrlMap.extraUrls.adts64 = jo.additionalAudioUrl[6];
                            jo.audioUrlMap.extraUrls.mp3 = jo.additionalAudioUrl[7];
                            jo.audioUrlMap.extraUrls.wma = jo.additionalAudioUrl[8];
                        }
                    }

                    /* Only add songs to the playlist model */
                    if( jo.songName ) {
                        model.append(jo);
                        playlist.addItem(_selectAudioUrl(jo));
                        console.log(jo.songName);
                    }
                }

                if(resetPlaylistIndex) {
                    currentPlaylistIndex = 0;
                    freshPlaylistPopulated();
                }

                updated();
                playlistDataAvailable = true;
            }
            else {
                console.log("Playlist data retrieval failed");
                console.log("stat:", data.stat);
                console.log("checksum:", data.result.checksum);
                console.log("stations:", data.result);
                receivedError();
            }
        }

        requestResponseTimeout.start();
        loading = true;

        pandoraInterface.retrieveMoreSongs(currentStationToken, dataRetrieved);
    }


    function clearPlaylist() {
        model.clear();
        playlist.clear();
        currentPlaylistIndex = -1;
    }

    function getAnyPlaylistItem(index) {

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
            "additionalAudioUrl": [
                "",
            ],
        }

        if( index <= model.count && index >= 0 && model.count > 0 ) {
            return model.get(index);
        }
        else {
//            console.log("getAnyPlaylistItem returning an empty object");
            return default_song_json;
        }
    }

    function loadNextSong() {
        playlist.next();

        /* Retrieve more songs for playlist if necessary */
        if (currentPlaylistIndex >= (model.count - 1)) {
            retrieveMoreSongs();
        }
    }

    /* Private functions */

    function _selectAudioUrl(aSongObject) {

        var selectedUrl

        switch(selectedAudioStream) {
            case AudioStream.Streams.DFLT_LOW:
//                    console.log("Using low stream");
                selectedUrl = aSongObject.audioUrlMap.lowQuality.audioUrl;
                break;
            case AudioStream.Streams.DFLT_MED:
//                    console.log("Using medium stream");
                selectedUrl = aSongObject.audioUrlMap.mediumQuality.audioUrl;
                break;
            case AudioStream.Streams.DFLT_HI:
//                    console.log("Using hight stream");
                selectedUrl = aSongObject.audioUrlMap.highQuality.audioUrl;
                break;
            case AudioStream.Streams.AAC_MONO_40:
//                    console.log("Using AAC mono stream");
                selectedUrl = aSongObject.audioUrlMap.extraUrls.aacMono;
                break;
            case AudioStream.Streams.AAC_64:
//                    console.log("Using AAC 64 stream");
                selectedUrl = aSongObject.audioUrlMap.extraUrls.aac64;
                break;
            case AudioStream.Streams.AACP_32:
//                    console.log("Using AACP 32 stream");
                selectedUrl = aSongObject.audioUrlMap.extraUrls.aacp32;
                break;
            case AudioStream.Streams.AACP_64:
//                    console.log("Using AACP 64 stream");
                selectedUrl = aSongObject.audioUrlMap.extraUrls.aacp64;
                break;
            case AudioStream.Streams.AACP_ADTS_24:
//                    console.log("Using ADTS 24 stream");
                selectedUrl = aSongObject.audioUrlMap.extraUrls.adts24;
                break;
            case AudioStream.Streams.AACP_ADTS_32:
//                    console.log("Using ADTS 32 stream");
                selectedUrl = aSongObject.audioUrlMap.extraUrls.adts32;
                break;
            case AudioStream.Streams.AACP_ADTS_64:
//                    console.log("Using ADTS 64 stream");
                selectedUrl = aSongObject.audioUrlMap.extraUrls.adts64;
                break;
            case AudioStream.Streams.MP3_128:
//                    console.log("Using MP3 stream");
                selectedUrl = aSongObject.audioUrlMap.extraUrls.mp3;
                break;
            case AudioStream.Streams.WMA_32:
//                    console.log("Using WMA stream");
                selectedUrl = aSongObject.audioUrlMap.extraUrls.wma;
                break;
            default:
//                    console.log("Using default stream");
                selectedUrl = aSongObject.audioUrlMap.lowQuality.audioUrl;
                break;
        }

        return selectedUrl;
    }

    /*****************************************************
    Example playlist object

    {
         "stat": "ok",
         "result": {
             "items": [{
                 "trackToken": "40b892bc5376e695c2e5c2b347227b85af2761b6aa417f736d9a79319b8f4cb97c9695a5f9a9a32aa2abaed43571235c",
                 "artistName": "Cannabich, Christian",
                 "albumName": "London Mozart Players, Christian Cannabich: Symphonies",
                 "amazonAlbumUrl": "http://www.amazon.com/dp/B000GW8ATU/?tag=wwwpandoracom-20",
                 "songExplorerUrl": "http://www.pandora.com/xml/music/song/london-mozart-players/christian-cannabich-symphonies/2-andantino?explicit=false",
                 "albumArtUrl": "http://cont-sv5-2.pandora.com/images/public/amz/5/2/9/7/095115137925_500W_488H.jpg",
                 "artistDetailUrl": "http://www.pandora.com/christian-cannabich?...",
                 "audioUrlMap": {
                     "highQuality": {
                         "bitrate": "64",
                         "encoding": "aacplus",
                         "audioUrl": "http://audio-sjl-t1-2.pandora.com/access/166132182435087962.mp4?...",
                         "protocol": "http"
                     },
                     "mediumQuality": {
                         "bitrate": "64",
                         "encoding": "aacplus",
                         "audioUrl": "http://t1-2.cdn.pandora.com/access/4127124196771074419.mp4?...",
                         "protocol": "http"
                     },
                     "lowQuality": {
                         "bitrate": "32",
                         "encoding": "aacplus",
                         "audioUrl": "http://audio-sv5-t1-1.pandora.com/access/3464788359714661029.mp4?...",
                         "protocol": "http"
                     }
                 },
                 "itunesSongUrl": "http://click.linksynergy.com/fs-bin/stat?...",
                 "additionalAudioUrl": [
                     "http://t1-2.cdn.pandora.com/access/6705986462049243054.mp4?...",
                     "http://audio-sjl-t1-1.pandora.com/access/2473529637452270302.mp4?..."
                 ],
                 "amazonAlbumAsin": "B000GW8ATU",
                 "amazonAlbumDigitalAsin": "B003H37NN4",
                 "artistExplorerUrl": "http://www.pandora.com/xml/music/composer/christian-cannabich?explicit=false",
                 "songName": "Symphony In G Major",
                 "albumDetailUrl": "http://www.pandora.com/london-mozart-players/christian-cannabich-symphonies?...",
                 "songDetailUrl": "http://www.pandora.com/london-mozart-players/christian-cannabich-symphonies/2-andantino?...",
                 "stationId": "121193154444133035",
                 "songRating": 0,
                 "trackGain": "10.09",
                 "albumExplorerUrl": "http://www.pandora.com/xml/music/album/london-mozart-players/christian-cannabich-symphonies?explicit=false",
                 "allowFeedback": true,
                 "amazonSongDigitalAsin": "B003H39AGW",
                 "nowPlayingStationAdUrl": "http://ad.doubleclick.net/pfadx/pand.android/prod.nowplaying..."
             }, {
                 "adToken": "121193154444133035-none"
             },
             < 3 more songs >
             ]
         }
    }
    *****************************************************/

}
