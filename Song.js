.pragma library

/* Individual song object */
function Song(json_song) {
    /* Fundamentals */
    this.trackToken = json_song.trackToken;
    this.artistName = json_song.artistName;
    this.albumName = json_song.albumName;
    this.albumArtUrl = json_song.albumArtUrl;
    this.songName = json_song.songName;
    this.songRating = json_song.songRating;

    /* Audio data */
    this.audioUrlMap = {};
    this.audioUrlMap.highQuality = {};
    this.audioUrlMap.mediumQuality = {};
    this.audioUrlMap.lowQuality = {};

    this.audioUrlMap.highQuality.bitrate = json_song.audioUrlMap.highQuality.bitrate;
    this.audioUrlMap.highQuality.encoding = json_song.audioUrlMap.highQuality.encoding;
    this.audioUrlMap.highQuality.audioUrl = json_song.audioUrlMap.highQuality.audioUrl;
    this.audioUrlMap.highQuality.protocol = json_song.audioUrlMap.highQuality.protocol;

    this.audioUrlMap.mediumQuality.bitrate = json_song.audioUrlMap.highQuality.bitrate;
    this.audioUrlMap.mediumQuality.encoding = json_song.audioUrlMap.highQuality.encoding;
    this.audioUrlMap.mediumQuality.audioUrl = json_song.audioUrlMap.highQuality.audioUrl;
    this.audioUrlMap.mediumQuality.protocol = json_song.audioUrlMap.highQuality.protocol;

    this.audioUrlMap.lowQuality.bitrate = json_song.audioUrlMap.highQuality.bitrate;
    this.audioUrlMap.lowQuality.encoding = json_song.audioUrlMap.highQuality.encoding;
    this.audioUrlMap.lowQuality.audioUrl = json_song.audioUrlMap.highQuality.audioUrl;
    this.audioUrlMap.lowQuality.protocol = json_song.audioUrlMap.highQuality.protocol;

    /* Station data */
    this.stationId = json_song.stationId;
}
