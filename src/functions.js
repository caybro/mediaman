function mediaStatus2String(status) {
    switch(status) {
    case MediaPlayer.NoMedia:
        return qsTr("No media loaded.");
    case MediaPlayer.Loading:
        return qsTr("Loading media.");
    case MediaPlayer.Loaded:
        return qsTr("Media loaded.");
    case MediaPlayer.Buffering:
        return qsTr("Buffering...");
    case MediaPlayer.Stalled:
        return qsTr("Stalled, playback interrupted");
    case MediaPlayer.Buffered:
        return qsTr("Media buffered.");
    case MediaPlayer.EndOfMedia:
        return qsTr("End of media reached.");
    case MediaPlayer.InvalidMedia:
        return qsTr("Invalid media, cannot be played.");
    case MediaPlayer.UnknownStatus:
    default:
        return qsTr("Unknown status...");
    }
}

function posDuration2String(pos, duration) {
    var posDate = new Date(null);
    posDate.setMilliseconds(pos);
    var durDate = new Date(null);
    durDate.setMilliseconds(duration);
    return posDate.toISOString().substr(11, 8) + "/" + durDate.toISOString().substr(11, 8);
}

function filenameFromUrl(url) {
    return url.substring(url.lastIndexOf('/')+1, url.lastIndexOf('.'));
}
