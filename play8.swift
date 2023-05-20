/*
Script to play audio files simultaneously. Eg play stems of a song.

Example usage:
$ find /Users/richard/Desktop/msc/studio/Samples/Richard_Caceres/Casio-VL-Tone/Casio-VL-Tone/Tones -type f | /usr/bin/swift <(cat helpers.swift play8.swift)

This is wired to a QuickAction
/usr/bin/swift <(cat /Users/richard/Desktop/msc/scripts/helpers.swift /Users/richard/Desktop/msc/scripts/play8.swift)
*/

// Requires helpers.swift

import AVFoundation
import Foundation

var files = readFiles()

log("Playing \(files.count) files")

var players: [AVAudioPlayer] = []
var longestTime = 5.0
var timeOffset = 0.0

for file in files {
  log("file \(file)")
  if !file.lowercased().hasSuffix(".wav") && !file.lowercased().hasSuffix(".mp3") {
    continue
  }

  let url = URL(fileURLWithPath: file)
  var player: AVAudioPlayer?
  player = try AVAudioPlayer(contentsOf: url)
  if player != nil {
    player?.prepareToPlay()
    timeOffset = player!.deviceCurrentTime + 0.2
    players.append(player!)
    if player!.duration > longestTime {
      longestTime = player!.duration
    }

  }
}

for player in players {
  player.play(atTime: timeOffset)
}

Timer.scheduledTimer(withTimeInterval: longestTime, repeats: false) { _ in
  log("done")
  exit(0)
}

exitWhenParentProcessExits()

// This keeps the script running
RunLoop.main.run()
