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

import QtQuick 2.0

import "../pandora.js" as Pandora

Item {
    id: baseModel
//    property string source: ""
    property string json: ""
//    property int status: XMLHttpRequest.UNSENT

    property ListModel model: ListModel { id: model }
    property alias count: model.count

    property bool loading: false

    signal updated()

//    onSourceChanged: {
//        loading = true
//        var xhr = new XMLHttpRequest;
//        xhr.open("GET", source);
//        xhr.onreadystatechange = function() {
//            status = xhr.readyState;
//            if (xhr.readyState == XMLHttpRequest.DONE && xhr.status == 200)
//                json = xhr.responseText;
//        }
//        xhr.send();
//    }

    onJsonChanged: {
        if ( json != "" ) {
            updateJSONModel();
            updated();
            loading = false
        }
    }

    function getData() {
        function dataRetrieved() {
            json = Pandora.userStationsString;
        }

        Pandora.getUserStations(dataRetrieved);
    }

    function updateJSONModel() {
        model.clear();

        //var objectArray = JSON.parse(json).results;
        var objectArray = JSON.parse(json).result.stations;
        for ( var key in objectArray ) {
            var jo = objectArray[key];
            model.append(jo);
//            model.append({
//                'name': jo.name,
//                'id': jo.id,
//                'thumb_url': thumbnail_url(jo.profile_path, "person")
//            });
        }
    }

//    function thumbnail_url(thumb_path, type) {
//        if (thumb_path)
//            return "http://d3gtl9l2a4fn1j.cloudfront.net/t/p/" + "w185/" + thumb_path;
//        else if (type !== "person")
//            return Qt.resolvedUrl("../graphics/no-poster.jpg");
//        else if (type === "person")
//            return Qt.resolvedUrl("../graphics/no-passport.png");
//    }
}
