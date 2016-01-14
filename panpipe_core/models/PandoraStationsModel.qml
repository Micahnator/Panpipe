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

Item {
    /* Signals */
    signal updated()
    signal receivedError()
    signal dataTimeout()

    /* Aliases */
    property alias model: model
    property alias count: model.count

    /* Public properties */
    property bool loading
    property var pandoraInterface   //Must be bound to a PandoraInterface component
    property string sortMethod      //Supported Options: "alphabetical", "date"
    property string jsonCopy
    property int timeoutTime
    property var quickMixStationIds //Array of station Ids in the QuickMix

    /* Private properties */
    property var stationArray
    property var lastReceivedGoodData


    /* Initialization */
    Component.onCompleted: {
        loading = false;

        /* If sortMethod string is empty, assign it to "date" by default */
        if(!sortMethod || 0 === sortMethod.length) {
            sortMethod = "date";
        }

        /* If timeoutTime is nil, set it to a default of 10 seconds */
        if(!timeoutTime || 0 === timeoutTime) {
            timeoutTime = 10000;
        }
    }

    ListModel {
        id: model
    }

    Timer {
        id: requestResponseTimeout

        interval: timeoutTime
        repeat: false

        /* Handle data timeout */
        onTriggered: {
            dataTimeout();
            console.log("Failed to receive request for station data inside timeout time of", timeoutTime / 1000, "seconds");
        }
    }

    /* Event handlers */
    onSortMethodChanged: {
        sortStations();
    }


    /* Public functions */

    function getStationData() {
        function dataRetrieved(data) {
            requestResponseTimeout.stop();
            if(data.stat == "ok") {
                jsonCopy = JSON.stringify(data);
                lastReceivedGoodData = data;
                stationArray = data.result.stations;
                sortStations(); //listmodel is updated after sorting is completed
            } else {
                console.log("station retrieval failed!");
                console.log("stat:", data.stat);
                console.log("checksum:", data.result.checksum);
                console.log("stations:", data.result);
                receivedError();
            }
        }

        requestResponseTimeout.start();
        pandoraInterface.retrieveStations(dataRetrieved);
    }

    function sortStations() {
        switch(sortMethod) {
            case "alphabetical":
                sortStationsAlphabetically();
                break;
            case "date":
                sortStationsByDate();
                break;
            default:
                sortStationsByDate();
                break;
        }

        updateModel();
    }

    /*****************************************************
    Example station object appended to the ListModel

    {
        "suppressVideoAds": false,
        "stationId": "404958383414849005",
        "allowAddMusic": true,
        "dateCreated": {
            "date": 26,
            "day": 6,
            "hours": 5,
            "minutes": 58,
            "month": 1,
            "nanos": 490000000,
            "seconds": 18,
            "time": 1298728698490,
            "timezoneOffset": 480,
            "year": 111
        },
        "stationDetailUrl": "https://www.pandora.com/login?target=%2Fstations%2Fecfe5435b97670bc785084a124264b5bd77f841a33b02f68",
        "artUrl": "http://cont-sv5-1.pandora.com/images/public/amz/9/4/9/7/602517487949_500W_498H.jpg",
        "requiresCleanAds": false,
        "stationToken": "404958383414849005",
        "stationName": "Bring Me Wine Radio",
        "music": {
            "songs": [{
                "artistName": "Wallis Bird",
                "dateCreated": {
                    "date": 26,
                    "day": 6,
                    "hours": 5,
                    "minutes": 58,
                    "month": 1,
                    "nanos": 490000000,
                    "seconds": 18,
                    "time": 1298728698490,
                    "timezoneOffset": 480,
                    "year": 111
                },
                "seedId": "461226891693665773",
                "songName": "Bring Me Wine"
            }],
            "artists": []
        },
        "isShared": false,
        "allowDelete": true,
        "genre": ["Rock"],
        "isQuickMix": false,
        "allowRename": true,
        "stationSharingUrl": "https://www.pandora.com/login?target=%2Fshare%2Fstation%2Fecfe5435b97670bc785084a124264b5bd77f841a33b02f68",
        "feedback": {
            "thumbsDown": [{
                "isPositive": false,
                "artistName": "Xavier Rudd",
                "feedbackId": "4789217787505683949",
                "dateCreated": {
                    "date": 2,
                    "day": 3,
                    "hours": 8,
                    "minutes": 27,
                    "month": 4,
                    "nanos": 869000000,
                    "seconds": 35,
                    "time": 1335972455869,
                    "timezoneOffset": 420,
                    "year": 112
                },
                "songName": "Where Do We Fit"
            }],
            "thumbsUp": [{
                "isPositive": true,
                "artistName": "Masha Qrella",
                "feedbackId": "3631100575061519853",
                "dateCreated": {
                    "date": 16,
                    "day": 3,
                    "hours": 10,
                    "minutes": 54,
                    "month": 10,
                    "nanos": 426000000,
                    "seconds": 54,
                    "time": 1321469694426,
                    "timezoneOffset": 480,
                    "year": 111
                },
                "songName": "Don't Stop The Dance"
            }]
        }
    }
    *****************************************************/

    function updateModel() {
        model.clear();
        for ( var key in stationArray ) {
            var jo = stationArray[key];
            model.append(jo);
            if (jo.isQuickMix) {
                quickMixStationIds = jo.quickMixStationIds;
            }
        }

        /* Send the updated signal */
        updated();
    }

    function clearStations() {
        model.clear();
    }

    /* Private functions */

    function sortStationsAlphabetically() {
        stationArray.sort(function(a,b){return __strcmp(a.stationName, b.stationName)});
        __moveQuickMix(stationArray);
    }

    function sortStationsByDate() {
        stationArray.sort(function(a,b){return __pandoraDateCompare(a.dateCreated, b.dateCreated)});
        __moveQuickMix(stationArray);
    }

    /* Helper functions */

    /* Function to place the "QuickMix" station back at the top of the station list */
    function __moveQuickMix(stationList) {
        var temp;
        for(var i = 0; i < stationList.length; i++) {
            if(stationList[i].stationName == "QuickMix") {
                temp = stationList[i];

                //now shift other items down
                for(var j = i; j > 0; j--) {
                    stationList[j] = stationList[(j - 1)];
                }

                stationList[0] = temp;
                break;
            }
        }
    }

    /* A function to compare station creation times */
    function __pandoraDateCompare(a, b) {
        return ( ( a.time == b.time ) ? 0 : ( ( a.time > b.time ) ? -1 : 1 ) );
    }

    /* A string comparison function used to sort stations by station name */
    function __strcmp ( str1, str2 ) {
        // http://kevin.vanzonneveld.net
        // +   original by: Waldo Malqui Silva
        // +      input by: Steve Hilder
        // +   improved by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
        // +    revised by: gorthaur
        // *     example 1: strcmp( 'waldo', 'owald' );
        // *     returns 1: 1
        // *     example 2: strcmp( 'owald', 'waldo' );
        // *     returns 2: -1

        return ( ( str1 == str2 ) ? 0 : ( ( str1 > str2 ) ? 1 : -1 ) );
    }
}
