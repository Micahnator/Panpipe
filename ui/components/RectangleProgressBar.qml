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

import QtQuick 2.4

Item {
    property double percentageComplete

    property color backgroundColor
    property color progressColor

    /* Progress bar */
    Rectangle {
        id: progressBase

        width: parent.width
        height: parent.height
        color: backgroundColor

        Rectangle {
            id: progressTracker

            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
            }
            height: parent.height
            width: (parent.width * percentageComplete)
            color: progressColor
        }
    }
}
