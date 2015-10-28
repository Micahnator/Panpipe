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
    title: i18n.tr("Player")
    head.foregroundColor: "white"
    anchors.fill: parent

    /* Signals */
    signal skipButtonPressed


    /* Aliases */


    /* Properties */
    property string currentAlbumArtUrl
    property string currentSongName
    property string currentSongAlbum
    property string currentSongArtist



    /* Gray background for player page */
    Rectangle {
        anchors.fill: parent
        color: "#F0F0F0"
    }

    /* Album art */
    Image {
        id: albumArtImage

        width: units.gu(20)
        height: units.gu(20)
        anchors {
            top: parent.top
            topMargin: units.gu(5)
            horizontalCenter: parent.horizontalCenter
        }

        source: currentAlbumArtUrl
    }

    //temp
    Button {
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: units.gu(5)
            right: parent.right
            rightMargin: units.gu(5)
        }

        onClicked: {
            skipButtonPressed();
        }
    }

    /* Song info */
    Label {
        id: currentSongNameLabel

        anchors {
            left: parent.left
            leftMargin: units.gu(2)
            bottom: currentSongAlbumLabel.top
            bottomMargin: units.gu(2)
        }

        text: currentSongName
    }

    Label {
        id: currentSongAlbumLabel

        anchors {
            left: parent.left
            leftMargin: units.gu(2)
            bottom: currentSongArtistLabel.top
            bottomMargin: units.gu(2)
        }

        text: currentSongAlbum
    }

    Label {
        id: currentSongArtistLabel

        anchors {
            left: parent.left
            leftMargin: units.gu(2)
            bottom:parent.bottom
            bottomMargin: units.gu(2)
        }

        text: currentSongArtist
    }
}
