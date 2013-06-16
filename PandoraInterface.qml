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

    property string currentSongAudioUrl
    property string currentSongImageUrl

    property var userStations


    /* public functions */
    function login() {
        Pandora.connect("panache.player@gmail.com", "PanacheMusic", loginResponse);
    }

    function retrieveStations() {
        Pandora.getUserStations(retrieveStationsResponse);
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
        console.log(JSON.stringify(stationList));
    }
}
