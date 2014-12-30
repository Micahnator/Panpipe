/*
Copyright (C) 2013-2014 Micah Losli <micah.losli@gmail.com>

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

import QtQuick 2.3

Item {
    id: stationModel

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
        "suppressVideoAds":true,
        "isQuickMix":true,
        "stationId":"3914377363925265",
        "stationDetailUrl":"https://www.pandora.com/login?target=%2Fstations%2Fa61985110ea3d6c6c8d8a9c038588b26425ba2910f7abf8b",
        "isShared":false,
        "dateCreated":{
            "date":8,
            "day":4,
            "hours":22,
            "minutes":44,
            "month":10,
            "nanos":241000000,
            "seconds":46,
            "time":1194590686241,
            "timezoneOffset":480,
            "year":107
        },
        "stationToken":"3914377363925265",
        "stationName":"QuickMix",
        "stationSharingUrl":"https://www.pandora.com/login?target=%2Fshare%2Fstation%2Fa61985110ea3d6c6c8d8a9c038588b26425ba2910f7abf8b",
        "requiresCleanAds":true,
        "allowRename":false,
        "allowAddMusic":false,
        "quickMixStationIds":[
            "339646069607180561",
            "339644480469281041"
        ],
        "allowDelete":false
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
