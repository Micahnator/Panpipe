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

.import "Blowfish.js" as Blowfish

/* Private values */
/* Constants */
var HTTPS_ENTRY_POINT = "https://tuner.pandora.com/services/json/";
var HTTP_ENTRY_POINT = "http://tuner.pandora.com/services/json/";
var DECODE_KEY = "R=U!LH$O2B#";
var ENCODE_KEY = "6#26FRL$ZWD";

var CRYPTO_MODE = {};
CRYPTO_MODE.outputType = Blowfish.crypto.outputTypes.Hex;
CRYPTO_MODE.cipherMode = Blowfish.crypto.cipherModes.ECB;


/* Global variables */

/* Variables needed to maintain connection */
var partnerResponse = {};
var userResponse = {};
var currentSyncTime = 0;
var timeOffset = 0;
var thisDate = new Date();

/* Data from Pandora */
var userStations = {};
var userStationsString = "";
var currentStation = {};
var currentPlaylist = {};
var currentPlaylistIndex = 0;
var musicSearchResult = {};

/* Helpful state variables */
var connected = false;

/* Asynchronous Send Function */
function transceive(httpMethod, url, method, data, encrypt, callback) {
    var xhr = new XMLHttpRequest;

    /* Add url parameters */
    method = "&method=" + method;
    var urlParameters = "";

    /* partner id */
    if (partnerResponse.partnerId)
    {
        urlParameters = urlParameters + "&partner_id=" + partnerResponse.partnerId;
    }
    /* user id */
    if (userResponse.userId)
    {
        urlParameters = urlParameters + "&user_id=" + userResponse.userId;
    }
    /* authorization token */
    if (userResponse.userAuthToken)
    {
        urlParameters = urlParameters + "&auth_token=" + encodeURIComponent(userResponse.userAuthToken);

    }
    else if (partnerResponse.partnerAuthToken)
    {
        urlParameters = urlParameters + "&auth_token=" + encodeURIComponent(partnerResponse.partnerAuthToken);
    }

    /* Trim off beginning '&' */
    if (urlParameters == "")
    {
        method = method.substring(1);
    }
    else
    {
        urlParameters = urlParameters.substring(1);
    }

    /* Put together the full path */
    var fullUrl = url + "?" + urlParameters + method;

    /* Add sync time and an auth token whenever possible */
    var currentTime = thisDate.getTime();
    currentTime = parseInt(currentTime / 1000);
    data["syncTime"] = currentTime;

    if (userResponse.userAuthToken) {
        data["userAuthToken"] = userResponse.userAuthToken;
    } else if (partnerResponse.partnerAuthToken) {
        data["partnerAuthToken"] = partnerResponse.partnerAuthToken;
    }

    /* Stringify the data */
    data = JSON.stringify(data);

    /* Encrypt the data if appropriate */
    if (encrypt) {
        data = Blowfish.crypto.Blowfish.encrypt(data, ENCODE_KEY, CRYPTO_MODE);
    }

    /* Open the object */
    xhr.open(httpMethod, fullUrl);

    /* Handle state changes */
    xhr.onreadystatechange = function() {
        if (xhr.readyState == XMLHttpRequest.DONE)
        {
            /* Run the callback if there is one */
            if (callback)
            {
                //var responseObject = JSON.parse(xhr.responseText);
                //callback(responseObject);
                callback(xhr.responseText)
            }
        }
    }

    if (data && (httpMethod == "POST"))
    {
        /* log if the data is not a string */
        if (typeof data != "string")
        {
            console.log("data is not in string format!");
        }

        xhr.send(data);
    }
    else
    {
        xhr.send();
    }
}

/* Function to log user in to Pandora */
function connect(username, password, callback) {

    var connectRequest = {
        "username": "android",
        "password": "AC7IBG09A3DTSYM4R41UJWL07VLN8JI7",
        "deviceModel": "android-generic",
        "version": "5"
    };

    var userRequest = {
        "username": username,
        "password": password,
        "loginType": "user",
        "includeAdAttributes": true,
    };

    /* re-initialize */
    partnerResponse = {};
    userResponse = {};

    console.log("Pandora.connect ran");

    function partnerLogin() {
        transceive("POST",
                   HTTPS_ENTRY_POINT,
                   "auth.partnerLogin",
                   connectRequest,
                   false,
                   userLogin);

    }

    function userLogin(dataString) {
        /* Store away everything that needs to be kept for later */
        var data = JSON.parse(dataString)
        partnerResponse = data.result;

        /* Ensure success */
        if(data.stat != "ok") {
            callback(false);
            return;
        }

        /* Do user login */
        transceive("POST",
                   HTTPS_ENTRY_POINT,
                   "auth.userLogin",
                   userRequest,
                   true,
                   receiveUserResponse);
    }

    function receiveUserResponse(dataString) {
        /* Store away everything that needs to be kept for later */
        var data = JSON.parse(dataString)
        userResponse = data.result;

        /* Ensure success */
        if(data.stat != "ok") {
            callback(false);
            return;
        }

        /* If the function made it this far, login was successful */
        connected = true;
        if (callback) {
            callback(data);
        }
    }

    /* Start login process */
    partnerLogin();
}

/* Function to get list of user's stations */
function getUserStations(callback) {

    function requestStations() {
        /* Station request */
        var stationsRequest = {
            "includeStationArtUrl": true,
        }

        /* Request stations */
        transceive("POST",
                   HTTP_ENTRY_POINT,
                   "user.getStationList",
                   stationsRequest,
                   true,
                   receiveStationsResponse);
    }

    function receiveStationsResponse(dataString) {
        /* Store away everything that needs to be kept for later */
        //userStationsString = JSON.stringify(data);
        userStationsString = dataString;
        var data = JSON.parse(dataString);
        //userStations = data.result.stations;

        /* Ensure success */
//        if(data.stat != "ok") {
//            callback(false);
//            return;
//        }
        /* Return the list of stations */
        //callback(userStations);
        if (callback) {
            callback(data);
        }
    }
    requestStations();
}

/* Function to get data on selected station */
function getStation(stationToken, callback) {

    function requestStation() {
        /* Station request */
        var stationRequest = {
            "stationToken": stationToken,
            "includeExtendedAttributes": true,
        }

        /* Request stations */
        transceive("POST",
                   HTTP_ENTRY_POINT,
                   "station.getStation",
                   stationRequest,
                   true,
                   receiveStationResponse);
    }

    function receiveStationResponse(dataString) {
        /* Store away everything that needs to be kept for later */
        //currentStation = data.result;
        var data = JSON.parse(dataString);

        /* Ensure success */
//        if(data.stat != "ok") {
//            console.log(data);
//            callback(false);
//            return;
//        }
        if (callback) {
            callback(data);
        }
    }
    requestStation();
}

/* Function to get the playlist of the selected station */
//function getStationPlaylist(stationToken, additionalAudioFormat, callback) {
function getStationPlaylist(stationToken, callback) {

    function requestStationPlaylist() {

        /* Station request */
        var stationPlaylistRequest;
//        if(-1 !== additionalAudioFormat.search("HTTP")) {

//            /* Also request all available additional audio url options */
//            stationPlaylistRequest = {
//                "stationToken": stationToken,
////                "additionalAudioUrl": additionalAudioFormat,
//                "additionalAudioUrl": "HTTP_40_AAC_MONO,HTTP_64_AAC,HTTP_32_AACPLUS,HTTP_64_AACPLUS,HTTP_24_AACPLUS_ADTS,HTTP_32_AACPLUS_ADTS,HTTP_64_AACPLUS_ADTS,HTTP_128_MP3,HTTP_32_WMA",
//            }
//        } else {
//            stationPlaylistRequest = {
//                "stationToken": stationToken,
//            }
//        }
        /* Also request all available additional audio url options */
        stationPlaylistRequest = {
            "stationToken": stationToken,
            "additionalAudioUrl": "HTTP_40_AAC_MONO,HTTP_64_AAC,HTTP_32_AACPLUS,HTTP_64_AACPLUS,HTTP_24_AACPLUS_ADTS,HTTP_32_AACPLUS_ADTS,HTTP_64_AACPLUS_ADTS,HTTP_128_MP3,HTTP_32_WMA",
        }

        /* Request stations */
        transceive("POST",
                   HTTP_ENTRY_POINT,
                   "station.getPlaylist",
                   stationPlaylistRequest,
                   true,
                   receiveStationPlaylistResponse);
    }

    function receiveStationPlaylistResponse(dataString) {
        /* Store away everything that needs to be kept for later */
        //currentPlaylist = data.result.items;
        var data = JSON.parse(dataString);

        /* Ensure success */
//        if(data.stat != "ok") {
//            console.log("Playlist retrieval failed. Status: " + data.stat);
//            console.log(JSON.stringify(data));
//            callback(false);
//            return;
//        }
//        else {
//            console.log("Playlist successfully retrieved.");
//        }
        if (callback) {
            callback(data);
        }
    }
    requestStationPlaylist();
}

/* Function to give feedback */
function sendFeedback(favorable, trackToken, callback) {

    function sendTheFeedback() {
        var feedback = {
            "trackToken": trackToken,
            "isPositive": favorable,
        }

        transceive("POST",
                   HTTP_ENTRY_POINT,
                   "station.addFeedback",
                   feedback,
                   true,
                   receiveFeedbackResponse);
    }

    function receiveFeedbackResponse(dataString) {
        var data = JSON.parse(dataString);

        if (callback) {
            callback(data);
        }
    }

    console.log("Sending favorable: ", favorable, " feedback.");
    sendTheFeedback();
}

//function retrieveSendFeedbackResponse(data) {
//    console.log("feedback response:");
//    console.log(JSON.stringify(data));
//}

/* Function to search available music */
function searchMusic(queryString, callback) {

    function searchMusicRequest() {
        var search = {
            "searchText": queryString
        }

        transceive("POST",
                   HTTP_ENTRY_POINT,
                   "music.search",
                   search,
                   true,
                   searchMusicResponse);
    }

    function searchMusicResponse(dataString) {
        //musicSearchResult = data.result;
        var data = JSON.parse(dataString);

        /* Ensure success */
//        if(data.stat != "ok") {
//            console.log("Music search failed. Status: " + data.stat);
//            console.log(JSON.stringify(data));
//            callback(false);
//            return;
//        }

        callback(data);
    }

    searchMusicRequest();
}

/* Function to set the stations included in the QuickMix */
function setQuickMix(stationIds, callback) {

    function setQuickMixRequest() {
        var stationIdList = {
            "quickMixStationIds": stationIds
        }

        transceive("POST",
                   HTTP_ENTRY_POINT,
                   "user.setQuickMix",
                   stationIdList,
                   true,
                   setQuickMixResponse);
    }

    function setQuickMixResponse(dataString) {
        var data = JSON.parse(dataString);
        /* Ensure success */
//        if(data.stat != "ok") {
//            console.log("QuickMix update failed. Status: " + data.stat);
//            console.log(JSON.stringify(data));
//            callback(false);
//            return;
//        }

        callback(data);
    }

    setQuickMixRequest();
}

/* Function to create a new user station */
function newStation(musicToken, callback) {

    function newStationRequest() {
        var request = {
            "musicToken": musicToken
        }

        transceive("POST",
                   HTTP_ENTRY_POINT,
                   "station.createStation",
                   request,
                   true,
                   newStationResponse);
    }

    function newStationResponse(dataString) {
        var data = JSON.parse(dataString);
//        console.log(data);
//        if(data.stat != "ok") {
//            console.log("Create station operation failed. Status: " + data.stat);
//            console.log(JSON.stringify(data));
//            callback(false);
//            return;
//        }

        callback(data);
    }

    newStationRequest();
}

/* Function to delete a user station */
function deleteStation(stationToken, callback) {

    function deleteStationRequest() {
        var request = {
            "stationToken": stationToken
        }

        transceive("POST",
                   HTTP_ENTRY_POINT,
                   "station.deleteStation",
                   request,
                   true,
                   deleteStationResponse);
    }

    function deleteStationResponse(dataString) {
        var data = JSON.parse(dataString);
//        console.log(data);
//        /* Ensure success */
//        if(data.stat != "ok") {
//            console.log("Delete station operation failed. Status: " + data.stat);
//            console.log(JSON.stringify(data));
//            callback(false);
//            return;
//        }

        callback(data);
    }

    deleteStationRequest();
}

/* Function to delete user feedback */
function deleteFeedback(feedbackId, callback) {

    function deleteFeedbackRequest() {
        var request = {
            "feedbackId": feedbackId
        }

        transceive("POST",
                   HTTP_ENTRY_POINT,
                   "station.deleteFeedback",
                   request,
                   true,
                   deleteFeedbackResponse);
    }

    function deleteFeedbackResponse(dataString) {
        var data = JSON.parse(dataString);
//        /* Ensure success */
//        if(data.stat != "ok") {
//            console.log("Delete feedback operation failed. Status: " + data.stat);
//            console.log(JSON.stringify(data));
//            callback(false);
//            return;
//        }

        callback(data);
    }

    deleteFeedbackRequest();
}

/* Function to delete a music seed */
function deleteSeed(seedId, callback) {

    function deleteSeedRequest() {
        var request = {
            "seedId": seedId
        }

        transceive("POST",
                   HTTP_ENTRY_POINT,
                   "station.deleteMusic",
                   request,
                   true,
                   deleteSeedResponse);
    }

    function deleteSeedResponse(dataString) {
        var data = JSON.parse(dataString);
//        /* Ensure success */
//        if(data.stat != "ok") {
//            console.log("Delete seed operation failed. Status: " + data.stat);
//            console.log(JSON.stringify(data));
//            callback(false);
//            return;
//        }

        callback(data);
    }

    deleteSeedRequest();
}

/* Function to add a seed to a station */
function addSeed(musicToken, stationToken, callback) {

    function addSeedRequest() {
        var request = {
            "musicToken": musicToken,
            "stationToken": stationToken,
        }

        transceive("POST",
                   HTTP_ENTRY_POINT,
                   "station.addMusic",
                   request,
                   true,
                   addSeedResponse);
    }

    function addSeedResponse(dataString) {
        var data = JSON.parse(dataString);
//        /* Ensure success */
//        if(data.stat != "ok") {
//            console.log("Add seed to station operation failed. Status: " + data.stat);
//            console.log(JSON.stringify(data));
//            callback(false);
//            return;
//        }

        if(callback !== null) {
            callback(data);
        }
    }

    addSeedRequest();
}
