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
import QtMultimedia 5.0
import Ubuntu.Components 0.1

MainView {
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"
    
    // Note! applicationName needs to match the .desktop filename 
    applicationName: "Panpipe"
    
    /* 
     This property enables the application to change orientation 
     when the device is rotated. The default is false.
    */
    automaticOrientation: false
    
    width: units.gu(60)
    height: units.gu(80)

    /* Startup operations */
    Component.onCompleted: {
        //pandoraModel.login();
    }

    /* Manage Pandora activity */
    PandoraInterface {
        id: pandoraModel

        onConnectedChanged: {
            /* If connection was successful, retrieve the station list */
            if (pandoraModel.connected == true) {
                pandoraModel.retrieveStations();
            }
        }

    }
    
    /* Audio component */
    Audio {
        id: audioPlayer
    }

    /* View for Panpipe */
    PanpipeView {
        id: viewComponent
        anchors.fill: parent

        /* Bindings to PandoraInterface */
        data: pandoraModel.userStations

        /* Interface state change handlers */
        onPlayButtonStateChanged: {
            if (viewComponent.playButtonState == true) {
                console.log("playing");
            } else {
                console.log("pausing");
            }
        }

    }
}
