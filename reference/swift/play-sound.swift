/*
Example usage:
$ find /Users/richard/Desktop/msc/studio/Samples/Richard_Caceres/Casio-VL-Tone/Casio-VL-Tone/Tones -type f | swift play-sound.swift
*/

import AVFoundation
import Foundation
import os.log

public func readFiles() -> [String] {
  var filePaths: [String] = []
  if isatty(STDIN_FILENO) == 0 {
    print("Reading stdin")
    while let line = readLine(strippingNewline: true) {
      filePaths.append(line)
    }
  }
  print("Reading argv")
  for arg in CommandLine.arguments[1...] {
    filePaths.append(arg)
  }

  return filePaths
}

func playSound(url: URL) -> AVAudioPlayer? {
  // guard let path = Bundle.main.path(forResource: "beep", ofType:"mp3") else {
  //     return }
  // let url = URL(fileURLWithPath: path)

  do {
    // Note something is not allowing the players to play in parallel
    var player: AVAudioPlayer?
    player = try AVAudioPlayer(contentsOf: url)
    if player != nil {
      print("playing \(url)")
      player?.play()
      Thread.sleep(forTimeInterval: player?.duration ?? 0.0)
    }
    return player

  } catch let error {
    print("error for \(url)")
    print(error.localizedDescription)
  }
  return nil
}

var files = readFiles()
if files.count == 0 {
  files.append(
    "/Users/richard/Desktop/msc/studio/Samples/Richard_Caceres/Casio-VL-Tone/Casio-VL-Tone/Tones/01-Piano-High.wav"
  )
}

print("Playing \(files.count) files")
// files.forEach {
//   _ = playSound(url: URL(fileURLWithPath: $0))
// }

var players: [AVAudioPlayer] = []

for file in files {
  let url = URL(fileURLWithPath: file)
  var player: AVAudioPlayer?
  player = try AVAudioPlayer(contentsOf: url)
  if player != nil {
    players.append(player!)

    // Thread.sleep(forTimeInterval: player?.duration ?? 0.0)
  }
}

for player in players {
  player.play()
}

sleep(5)

print("done")
