/*
Copyright (C) 2014 Micah Losli <micah.losli@gmail.com>

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
import Ubuntu.Components 0.1
import QtGraphicalEffects 1.0
import Ubuntu.Components.Popups 0.1 as Popups
import Ubuntu.Components.ListItems 0.1 as ListItem
import "components"

Item {
    /* Private properties */
    property var stationToDelete
    property int indexToDelete
    property string feedbackDescription


    Component.onCompleted: {
        /* Get station details */
        pandoraModel.getUserStation(viewComponent.selectedStationToken);

        stationDetailsPage.flickable = flickerable;
    }

    JSONListModel {
        id: seedsModel
        json: JSON.stringify(pandoraModel.stationDetails.music.songs.concat(pandoraModel.stationDetails.music.artists));
    }

    JSONListModel {
        id: thumbsUpModel
        json: JSON.stringify(pandoraModel.stationDetails.feedback.thumbsUp)
    }

    JSONListModel {
        id: thumbsDownModel
        json: JSON.stringify(pandoraModel.stationDetails.feedback.thumbsDown)
    }

    Flickable {
        id: flickerable
        clip: true
        anchors.fill: parent
        contentHeight: myColumn.childrenRect.height + units.gu(4)
        interactive: true

        Column {
            id: myColumn
            anchors.fill: parent

            /* Station Artwork */
            UbuntuShape {
                id: stationArt
                anchors {
                    top: parent.top
                    topMargin: units.gu(2)
                    left: parent.left
                    leftMargin: units.gu(2)
                }

                width: units.gu(20)
                height: width

                image: Image {
                    anchors.fill: parent
                    source: pandoraModel.stationDetails.artUrl
                }
            }

            /* Station name label */
            Label {
                id: stationLabel
                text: pandoraModel.stationDetails.stationName

                elide: Text.ElideRight
                fontSize: "large"
                horizontalAlignment: Text.AlignLeft

                anchors {
                    top: stationArt.bottom
                    topMargin: units.gu(2)
                    left: parent.left
                    leftMargin: units.gu(1)
                    right: parent.right
                    rightMargin: units.gu(1)
                }
            }

            /* Station seeds */
            Label {
                id: seedsLabel
                text: "Seeds:"
                color: "white"
                fontSize: "large"
                elide: Text.ElideRight

                anchors {
                    top: stationLabel.bottom
                    topMargin: units.gu(2)
                    left: parent.left
                    leftMargin: units.gu(1)
                }
            }

            /* Add seeds button */
            Image {
                id: addSeedsButton
                source: "resources/icons/add.svg"

                anchors {
                    top: seedsLabel.top
                    bottom: seedsLabel.bottom
                    right: parent.right
                    rightMargin: units.gu(2)
                }
                height: seedsLabel.height
                width: height
            }
            ColorOverlay {
                anchors.fill: addSeedsButton
                source: addSeedsButton
                color: seedsLabel.color
            }
            MouseArea {
                anchors.fill: addSeedsButton

                onClicked: {
                    PopupUtils.open(addSeedsDialog);
                }
            }

            Column {
                id: seedsListColumn
                anchors.top: seedsLabel.bottom
                anchors.topMargin: units.gu(1)
                width: parent.width
                Repeater {
                    id: seedsList
                    model: seedsModel.model
                    Rectangle {
                        height: seedLabel.height + units.gu(1)
                        width: parent.width
                        color: "transparent"
                        Label {
                            id: seedLabel
                            anchors {
                                left: parent.left
                                leftMargin: units.gu(2)
                                verticalCenter: parent.verticalCenter
                            }

                            text: model.artistName
                            color: "white"
                            fontSize: "medium"
                            elide: Text.ElideRight
                        }

                        /* delete seed button */
                        Image {
                            id: deleteSeedButton
                            height: parent.height - units.gu(0.5)
                            width: height

                            anchors {
                                verticalCenter: parent.verticalCenter
                                right: parent.right
                                rightMargin: units.gu(2)
                            }

                            source: "resources/icons/clear-search.svg"
                            visible: false
                        }
                        ColorOverlay {
                            anchors.fill: deleteSeedButton
                            source: deleteSeedButton
                            color: UbuntuColors.orange
                        }
                        MouseArea {
                            anchors.fill: deleteSeedButton

                            onClicked: {
                                stationToDelete = model;
                                indexToDelete = index;
                                PopupUtils.open(deleteSeedDialog);
                            }
                        }
                    }
                }
            }

            /* Thumbs Up Feedback */
            Label {
                id: thumbsUpFeedbackLabel
                text: "Thumbs Up:"
                color: "white"
                visible: thumbsUpModel.count > 0
                fontSize: "large"
                elide: Text.ElideRight

                anchors {
                    top: seedsListColumn.bottom
                    topMargin: units.gu(2)
                    left: parent.left
                    leftMargin: units.gu(1)
                }
            }

            Column {
                id: thumbsUpColumn
                anchors.top: thumbsUpFeedbackLabel.bottom
                anchors.topMargin: units.gu(1)
                width: parent.width
                visible: thumbsUpModel.count > 0
                Repeater {
                    id: thumbsUpList
                    model: thumbsUpModel.model
                    Rectangle {
                        height: thumbsUpLabel.height + units.gu(1)
                        width: parent.width
                        color: "transparent"

                        Label {
                            id: thumbsUpLabel
                            anchors {
                                left: parent.left
                                leftMargin: units.gu(2)
                                verticalCenter: parent.verticalCenter
                                right: deleteFeedbackButton.left
                                rightMargin: units.gu(2)
                            }

                            text: model.songName + " by " + model.artistName
                            color: "white"
                            fontSize: "medium"
                            elide: Text.ElideRight
                        }

                        /* delete feedback button */
                        Image {
                            id: deleteFeedbackButton
                            height: parent.height - units.gu(0.5)
                            width: height

                            anchors {
                                verticalCenter: parent.verticalCenter
                                right: parent.right
                                rightMargin: units.gu(2)
                            }

                            source: "resources/icons/clear-search.svg"
                            visible: false
                        }
                        ColorOverlay {
                            anchors.fill: deleteFeedbackButton
                            source: deleteFeedbackButton
                            color: UbuntuColors.orange
                        }
                        MouseArea {
                            anchors.fill: deleteFeedbackButton

                            onClicked: {
                                stationToDelete = model;
                                indexToDelete = index;
                                PopupUtils.open(deleteFeedbackDialog);
                            }
                        }
                    }
                }
            }

            /* Thumbs Down Feedback */
            Label {
                id: thumbsDownFeedbackLabel
                text: "Thumbs Down:"
                color: "white"
                visible: thumbsUpModel.count > 0
                fontSize: "large"
                elide: Text.ElideRight

                anchors {
                    top: thumbsUpColumn.bottom
                    topMargin: units.gu(2)
                    left: parent.left
                    leftMargin: units.gu(1)
                }
            }

            Column {
                id: thumbsDownColumn
                anchors.top: thumbsDownFeedbackLabel.bottom
                anchors.topMargin: units.gu(1)
                width: parent.width
                visible: thumbsUpModel.count > 0
                Repeater {
                    id: thumbsDownList
                    model: thumbsDownModel.model
                    Rectangle {
                        height: thumbsDownLabel.height + units.gu(1)
                        width: parent.width
                        color: "transparent"

                        Label {
                            id: thumbsDownLabel
                            anchors {
                                left: parent.left
                                leftMargin: units.gu(2)
                                verticalCenter: parent.verticalCenter
                                right: deleteNegativeFeedbackButton.left
                                rightMargin: units.gu(2)
                            }

                            text: model.songName + " by " + model.artistName
                            color: "white"
                            fontSize: "medium"
                            elide: Text.ElideRight
                        }

                        /* delete feedback button */
                        Image {
                            id: deleteNegativeFeedbackButton
                            height: parent.height - units.gu(0.5)
                            width: height

                            anchors {
                                verticalCenter: parent.verticalCenter
                                right: parent.right
                                rightMargin: units.gu(2)
                            }

                            source: "resources/icons/clear-search.svg"
                            visible: false
                        }
                        ColorOverlay {
                            anchors.fill: deleteNegativeFeedbackButton
                            source: deleteNegativeFeedbackButton
                            color: UbuntuColors.orange//thumbsDownLabel.color
                        }
                        MouseArea {
                            anchors.fill: deleteNegativeFeedbackButton

                            onClicked: {
                                stationToDelete = model;
                                indexToDelete = index;
                                PopupUtils.open(deleteFeedbackDialog);
                            }
                        }
                    }
                }
            }
        }
    }

    /* Define the delete seed confirmation dialog */
    Component {
        id: deleteSeedDialog

        Popups.Dialog {
            id: deleteSeedScreen

            Component.onCompleted: {
                feedbackDescription = "";
                if (stationToDelete.songName) {
                    feedbackDescription = stationToDelete.songName + " by ";
                }

                feedbackDescription += stationToDelete.artistName;
            }

            title: i18n.tr("Delete Seed?")

            Label {
                text: "Are you sure you want to delete " + feedbackDescription + " as a seed?"
                wrapMode: Text.WordWrap
                fontSize: "large"
            }

            Button {
                text: i18n.tr("Delete")
                color: "orange"

                onClicked: {
                    /* Delete the seed as requested */
                    pandoraModel.removeMusicSeed(stationToDelete.seedId);

                    /* Remove the item from the list */
                    seedsModel.model.remove(indexToDelete);

                    /* Close dialog */
                    PopupUtils.close(deleteSeedScreen)
                }
            }

            Button {
                text: i18n.tr("Cancel")
                color: "gray"

                onClicked: {
                    /* close dialog */
                    PopupUtils.close(deleteSeedScreen)
                }
            }
        }
    }




    /* Define the delete feedback confirmation dialog */
    Component {
        id: deleteFeedbackDialog

        Popups.Dialog {
            id: deleteFeedbackScreen

            Component.onCompleted: {
                if(stationToDelete.isPositive) {
                    feedbackDescription = "a thumbs up rating for ";
                } else {
                    feedbackDescription = "a thumbs down rating for ";
                }

                feedbackDescription += stationToDelete.songName + " by " + stationToDelete.artistName;
            }

            title: i18n.tr("Delete Feedback?")

            Label {
                text: "Are you sure you want to delete " + feedbackDescription + "?"
                wrapMode: Text.WordWrap
                fontSize: "large"
            }

            Button {
                text: i18n.tr("Delete")
                color: "orange"

                onClicked: {
                    /* Delete the feedback as requested */
                    pandoraModel.deleteUserFeedback(stationToDelete.feedbackId);

                    /* Remove the item from the list */
                    if(stationToDelete.isPositive) {
                        thumbsUpModel.model.remove(indexToDelete);
                    } else if(stationToDelete.isPositive === false) {
                        thumbsDownModel.model.remove(indexToDelete);
                    }

                    /* Close dialog */
                    PopupUtils.close(deleteFeedbackScreen)
                }
            }

            Button {
                text: i18n.tr("Cancel")
                color: "gray"

                onClicked: {
                    /* Close dialog */
                    PopupUtils.close(deleteFeedbackScreen)
                }
            }
        }
    }

    /* Search for new station seeds component */
    Component {
        id: addSeedsDialog

        Popups.DefaultSheet {
            id: addSeedsScreen

            Component.onCompleted: {
                searchDataModel.model.clear();
                pandoraModel.stationSearchResults = {};
                searchQueryForm.forceActiveFocus();
            }

            Component.onDestruction: {
                searchDataModel.model.clear();
                searchQueryForm.text = "";
            }

            TextField {
                id: searchQueryForm
                placeholderText: i18n.tr("Search by Artist or Song")
                color: "black"

                anchors {
                    top: parent.top
                    topMargin: units.gu(2)
                    left: parent.left
                    leftMargin: units.gu(2)
                    right: parent.right
                    rightMargin: units.gu(2)
                }

                onTextChanged: {
                    if( text === "" ) {
                        searchDataModel.model.clear();
                    } else {
                        newStationSearchQuery(searchQueryForm.text);
                    }
                }
            }

            JSONListModel {
                id: searchDataModel

                json: JSON.stringify(pandoraModel.stationSearchResults)
            }

            ListView {
                id: searchResultListView

                model: searchDataModel.model

                clip: true

                section.property: "matchType"
                section.delegate: ListItem.Empty {
                    Rectangle {
                        anchors.fill: parent
                        color: "orange"

                        Label {
                            text: section
                            color: "black"

                            anchors {
                                left: parent.left
                                leftMargin: units.gu(1)
                                right: parent.right
                                rightMargin: units.gu(1)
                                top: parent.top
                                topMargin:units.gu(2)
                            }
                        }
                    }
                }

                anchors {
                    top: searchQueryForm.bottom
                    topMargin: units.gu(2)
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }

                delegate: ListItem.Empty {

                    Label {
                        id: searchResultText
                        text: (model.matchType === "Songs") ? model.songName + " by " + model.artistName : model.artistName
                        color: "black"
                        fontSize: "medium"
                        elide: Text.ElideRight

                        anchors {
                            left: parent.left
                            leftMargin: units.gu(2)
                            right: parent.right
                            rightMargin: units.gu(1)
                            top: parent.top
                            topMargin:units.gu(2)
                        }
                    }

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            pandoraModel.addMusicSeed(model.musicToken, viewComponent.selectedStationToken);
                            PopupUtils.close(addSeedsScreen);
                        }
                    }
                }
            }
        }
    }
}
