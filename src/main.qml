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
        property url lastDirUrl: "file://home/ltinkl/Videos" // FIXME
    }

    Component.onDestruction: {
        settings.volume = player.volume
        settings.lastDirUrl = fileDialog.folder
    }

    ErrorDialog {
        id: errorDlg
    }

    MediaPlayer {
        id: player
        volume: settings.volume
        onStatusChanged: {
            if (status == MediaPlayer.Buffered) {
                if (!hasVideo) {
                    mainWindow.title = metaData.title + " - " + metaData.albumArtist + " - " + qsTr("Mediaman")
                } else {
                    mainWindow.title = Functions.filenameFromUrl(source.toString()) + " - " + qsTr("Mediaman")
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
        tooltip: qsTr("Open File")
        iconName: "document-open"
        shortcut: StandardKey.Open
        onTriggered: fileDialog.open()
    }

    Action {
        id: quitAction
        text: qsTr("&Quit")
        tooltip: qsTr("Exit application")
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
        tooltip: player.muted ? qsTr("Audio muted, click to unmute") : qsTr("Mute audio")
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
        visible: mainWindow.visibility != Window.FullScreen
        RowLayout {
            anchors.fill: parent
            Label {
                id: messageLabel
                text: Functions.mediaStatus2String(player.status)
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
        nameFilters: [ qsTr("Media files (*.avi *.mkv *.mp4 *.mp3 *.ogg *.flac *.wav)"), qsTr("All files (*)") ]
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

    function toggleFullscreen() {
        if (mainWindow.visibility == Window.FullScreen)
            mainWindow.visibility = Window.Windowed
        else {
            mainWindow.visibility = Window.FullScreen
            playerRect.forceActiveFocus()
        }
    }
}
