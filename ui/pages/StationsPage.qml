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
import Ubuntu.Components 1.3

Page {
    title: i18n.tr("Stations")
    head.foregroundColor: "white"
    anchors.fill: parent

    /* Signals */
    signal stationClicked(string stationToken)
    signal stationLongPressed(string stationToken)

    /* Aliases */
    property alias dataModel: stationListView.model


    /* White background for station list */
    Rectangle {
        anchors.fill: parent
        color: "#FFFFFF"
    }

    /* Station Listview */
    /*
    Note: See PandoraStationsModel.qml
    for a definition of what data fields
    are in each data model item.
    */
    UbuntuListView {
        id: stationListView
        anchors.fill: parent
        currentIndex: -1    /* Start with no station selected */

        delegate: ListItem {
            /* Background color */
            color: (index === stationListView.currentIndex) ? UbuntuColors.orange : "transparent"

            /* Station art */
            Image {
                id: stationArt
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
                height: parent.height
                width: height
                sourceSize {
                    height: stationArt.height
                    width: height
                }
                source: artUrl
                asynchronous: true
                fillMode: Image.PreserveAspectFit
            }

            /* Station name */
            Text {
                id: stationNameText
                anchors {
                    left: stationArt.right
                    leftMargin: units.gu(1)
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }

                text: stationName
                elide: Text.ElideRight
            }

            /* Click handling */
            onClicked: {
                stationListView.currentIndex = index;
                stationClicked(stationToken);
            }
        }

    }

}
