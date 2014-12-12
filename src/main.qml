import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtMultimedia 5.0
import Qt.labs.settings 1.0

import "qrc:/functions.js" as Functions
import "qrc:/"

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 640
    height: 480

    Settings {
        id: settings
        // save window size and position
        property alias x: mainWindow.x
        property alias y: mainWindow.y
        property alias width: mainWindow.width
        property alias height: mainWindow.height
        // save volume
        property real volume: 0.5
        // save last directory
        property url lastDirUrl: moviesPath
    }

    Component.onDestruction: {
        settings.volume = player.volume
        settings.lastDirUrl = fileDialog.folder
    }

    SystemPalette {
        id: palette
    }

    ErrorDialog {
        id: errorDlg
    }

    Timer {
        id: messageTimer
        interval: 3000 // 3 seconds
        onTriggered: messageLabel.text = player.source
    }

    MediaPlayer {
        id: player
        autoPlay: playUrl != ""
        source: playUrl
        volume: settings.volume
        onStatusChanged: {
            messageLabel.text=Functions.mediaStatus2String(player.status)
            messageTimer.start()

            if (status == MediaPlayer.Buffered) {
                if (!hasVideo && metaData !== undefined) {
                    mainWindow.title = metaData.title.trim() + " - " + metaData.albumArtist.trim() +
                            " (" + metaData.albumTitle.trim() + ") — " + qsTr("Mediaman")
                } else {
                    mainWindow.title = Functions.filenameFromUrl(source.toString()) + " — " + qsTr("Mediaman")
                }
            } else {
                mainWindow.title = qsTr("Mediaman")
            }
        }
        onError: {
            // display error dialog
            console.error("MP error:" + error)
            errorDlg.errorText = errorString
            errorDlg.open()
        }
    }

    Action {
        id: openAction
        text: qsTr("&Open")
        tooltip: qsTr("Open File") + " (" + shortcut + ")"
        iconName: "document-open"
        shortcut: StandardKey.Open
        onTriggered: fileDialog.open()
    }

    Action {
        id: quitAction
        text: qsTr("&Quit")
        tooltip: qsTr("Exit Application") + " (" + shortcut + ")"
        iconName: "application-exit"
        shortcut: StandardKey.Quit
        onTriggered: Qt.quit();
    }

    Action {
        id: playAction
        text: player.playbackState == MediaPlayer.PlayingState ? qsTr("P&ause") : qsTr("P&lay")
        iconName: player.playbackState == MediaPlayer.PlayingState ? "media-playback-pause" : "media-playback-start"
        shortcut: Qt.Key_MediaPlay
        enabled: player.status > MediaPlayer.Loading && player.status < MediaPlayer.InvalidMedia
        onTriggered: player.playbackState == MediaPlayer.PlayingState ? player.pause() : player.play()
    }

    Action {
        id: stopAction
        text: qsTr("&Stop")
        iconName: "media-playback-stop"
        shortcut: Qt.Key_MediaStop
        enabled: player.playbackState == MediaPlayer.PlayingState
        onTriggered: player.stop()
    }

    Action {
        id: muteAction
        text: qsTr("&Mute")
        tooltip: player.muted ? qsTr("Audio muted, click to unmute") + " (" + shortcut + ")"
                              : qsTr("Mute audio") + " (" + shortcut + ")"
        iconName: player.muted ? "audio-volume-muted" : "player-volume"
        shortcut: "Ctrl+M"
        onTriggered: player.muted = !player.muted
        checkable: true
        checked: player.muted
        enabled: player.hasAudio
    }

    Action {
        id: fullscreenAction
        text: qsTr("View &Fullscreen")
        tooltip: text.replace('&', '') + " (" + shortcut + ")"
        iconName: "view-fullscreen"
        shortcut: "F11"
        checkable: true
        checked: mainWindow.visibility == Window.FullScreen
        onTriggered: toggleFullscreen()
        enabled: player.hasVideo
    }

//    menuBar: MenuBar {
//        //visible: mainWindow.visibility == Window.Windowed
//        Menu {
//            id: fileMenu
//            title: qsTr("&File")
//            MenuItem {
//                action: openAction
//            }
//            MenuSeparator {}
//            MenuItem {
//                action: quitAction
//            }
//        }
//        Menu {
//            id: playMenu
//            title: qsTr("&Playback")
//            MenuItem {
//                action: playAction
//            }
//            MenuItem {
//                action: stopAction
//            }
//            MenuSeparator {}
//            MenuItem {
//                action: muteAction
//            }
//            MenuSeparator {}
//            MenuItem {
//                action: fullscreenAction
//            }
//        }
//    }

    toolBar: ToolBar {
        visible: mainWindow.visibility != Window.FullScreen
        RowLayout {
            anchors.fill: parent
            ToolButton {
                action: openAction
            }
            ToolButton {
                action: playAction
            }
            ToolButton {
                action: stopAction
            }
            Item { Layout.preferredWidth: 20 }
            Label {
                text: qsTr("Position:")
            }
            Slider {
                id: positionSlider
                enabled: player.seekable
                maximumValue: player.duration / 1000
                __handlePos: player.position / 1000
                onValueChanged: {
                    player.seek(value * 1000)
                }
                Layout.fillWidth: true
            }
            Item { Layout.preferredWidth: 20 }
            Label {
                text: qsTr("Volume:")
            }
            Slider {
                id: volumeSlider
                enabled: player.hasAudio
                __handlePos: player.volume
                onValueChanged: {
                    player.volume = value
                }
                Layout.fillWidth: true
                Layout.maximumWidth: 100
            }
            ToolButton {
                action: muteAction
            }
            ToolButton {
                action: fullscreenAction
            }
        }
    }

    statusBar: StatusBar {
        id: statusBar
        visible: !fullscreenAction.checked
        RowLayout {
            anchors.fill: parent
            Label {
                id: messageLabel
                elide: Text.ElideMiddle
                width: statusBar.width - posLabel.width
                text: player.source
            }
            Label {
                id: posLabel
                text: Functions.posDuration2String(player.position, player.duration)
                visible: playAction.enabled
                Layout.alignment: Qt.AlignRight
            }
        }
    }

    FileDialog {
        id: fileDialog
        title: qsTr("Choose a File to Open")
        selectExisting: true
        selectMultiple: false
        modality: Qt.NonModal
        folder: settings.lastDirUrl
        nameFilters: [ qsTr("Media files") + " (*.avi *.mkv *.mp4 *.wmv *.ogv *.mp3 *.ogg *.oga *.flac *.wma *.wav)",
            qsTr("All files") + " (*)" ]
        onAccepted: {
            var url = fileDialog.fileUrl
            //console.log("You chose: " + url)
            player.source = url
            player.play()
        }
    }

    Rectangle {
        id: playerRect
        color: "black"
        anchors.fill: parent
        activeFocusOnTab: true
        focus: true
        MouseArea {
            anchors.fill: parent
            cursorShape: mainWindow.visibility == Window.FullScreen ? Qt.BlankCursor : Qt.ArrowCursor
            onDoubleClicked: {
                fullscreenAction.trigger()
            }
            VideoOutput {
                id: video
                anchors.fill: parent
                source: player
                visible: player.playbackState != MediaPlayer.StoppedState
                enabled: player.hasVideo
            }
        }
        Keys.onPressed: {
            if (event.key == Qt.Key_Escape && mainWindow.visibility == Window.FullScreen) { // escape fullscreen
                mainWindow.visibility = Window.Windowed;
            } else if (event.key == Qt.Key_Space) { // play/pause
                playAction.trigger();
            }
        }
    }

    Text {
        id: welcomeText
        anchors.centerIn: parent
        visible: player.status == MediaPlayer.NoMedia
        color: palette.highlight
        text: qsTr("<h1>Welcome to Mediaman %1</h1>No media loaded.<br>Press %2 to open some...")
          .arg(Qt.application.version).arg(openAction.shortcut) +
          "<br><br><br><br>" + "(c) 2014 Lukáš Tinkl &lt;<a href='mailto:lukas@kde.org'>lukas@kde.org</a>&gt;";
        onLinkActivated: {
            Qt.openUrlExternally(link)
        }
    }

    Text {
        id: osd
        anchors.right: parent.right
        anchors.top: parent.top
        color: palette.highlight
        font {
            pointSize: 18
            capitalization: Font.AllUppercase
        }

        text: {
            if (player.playbackState == MediaPlayer.PausedState)
                return qsTr("Paused");
            else if (player.muted)
                return qsTr("Muted");
            else
                return ""
        }

        visible: player.playbackState == MediaPlayer.PausedState || player.muted
    }

    Text {
        id: infoOsd
        anchors.top: parent.top
        anchors.left: parent.left
        color: palette.highlight
        visible: false //osd.visible // FIXME
        text: {
            var meta = player.metaData;
            if (player.hasVideo) {
                return "Resolution: " + meta.resolution + "<br>" +
                        "Framerate: " + meta.videoFrameRate + "<br>" +
                        "Bitrate: " + meta.videoBitRate + " b/s<br>" +
                        "Codec: " + meta.videoCodec + "<br>";
            } else if (player.hasAudio) {
                return "Track: " + meta.trackNumber + "<br>" +
                        "Audio codec: " + meta.audioCodec + "<br>" +
                        "Bitrate: " + meta.audioBitRate + " b/s<br>" +
                        "Sample rate: " + meta.sampleRate + " Hz<br>" +
                        "Year: " + meta.year + "<br>" +
                        "Genre: " + meta.lyrics;
            }
            return ""
        }
    }

    function toggleFullscreen() {
        if (mainWindow.visibility == Window.FullScreen)
            mainWindow.visibility = Window.Windowed
        else {
            mainWindow.visibility = Window.FullScreen
            playerRect.forceActiveFocus()
        }
    }
}
