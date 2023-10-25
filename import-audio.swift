/// This script has logic to read files from SD cards in /Volumes
/// and copy them to a destination directory.
///
/// Example usage:
/// $ ./custom-swift.sh import-audio.swift

// require ./helpers.swift
// exitWhenParentProcessExits()

let PROMPT_TO_EJECT = false
let SKIP_WRONG_DATES = true

// When true, ignores the default _MIX.wav files Tascam X8 creates
let IGNORE_TASCAM_MIX_FILES = false

enum AudioDeviceTypes: String {
  case tascamX8 = "TASCAM_X-8"
  case ZoomL8 = "Zoom_L-8"
  case ZoomL12 = "Zoom_L-12"
  case ZoomH4nPro = "H4n_Pro"
}

func detectAudioDeviceType(at url: URL) -> AudioDeviceTypes? {
  let contents = try! FileManager.default.contentsOfDirectory(
    at: url, includingPropertiesForKeys: nil, options: [])
  for fileUrl in contents {
    if !fileUrl.isDirectory {
      continue
    }
    let file = fileUrl.path
    if file.contains("SOUND") {
      return .tascamX8
    }
    if file.contains("PROJECT") {
      return .ZoomL8
    }
    if file.contains("FOLDER01") {
      return .ZoomL12
    }
    if file.contains("STEREO") {
      return .ZoomH4nPro
    }
  }
  return nil
}

func copyFileSmart(sourceURL fileUrl: URL, destURL destinationFileUrl: URL, tag: String) {
  // Copies a file if it doesn't exit and also creates necessary directories.
  // Adds macOS tags as well
  if !destinationFileUrl.deletingLastPathComponent().isDirectory {
    log("creating directory \(destinationFileUrl.deletingLastPathComponent().path)")
    try! FileManager.default.createDirectory(
      at: destinationFileUrl.deletingLastPathComponent(),
      withIntermediateDirectories: true,
      attributes: nil)
  }
  addSpotlightFinderTag(
    to: destinationFileUrl.deletingLastPathComponent(), with: "\(tag)_Project")

  // TODO see if I can use finder sync status
  // https://developer.apple.com/documentation/findersync/fifindersynccontroller/1501577-setbadgeidentifier

  runIfFileSizeIsDifferent(
    fileUrl, destinationFileUrl,
    onNotExists: {
      print("Does not exist. Copying\n--\(fileUrl.path)\n->\(destinationFileUrl.path)")
      try! FileManager.default.copyItem(at: fileUrl, to: destinationFileUrl)
      addSpotlightFinderTag(to: destinationFileUrl, with: "\(tag)_File")
      addSpotlightFinderTag(to: fileUrl, with: "IMPORTED,Gray")
      sleep(2)
    },
    onSizeDifferent: {
      print(
        "File size is different. Replacing. \n--\(fileUrl.path)\n->\(destinationFileUrl.path)")
      try! FileManager.default.trashItem(at: destinationFileUrl, resultingItemURL: nil)
      try! FileManager.default.copyItem(at: fileUrl, to: destinationFileUrl)
      addSpotlightFinderTag(to: destinationFileUrl, with: "\(tag)_File")
      addSpotlightFinderTag(to: fileUrl, with: "IMPORTED,Gray")
      sleep(2)
    },
    onSame: {
      print("File size is the same. Skipping")
      addSpotlightFinderTag(to: destinationFileUrl, with: "\(tag)_File")
      addSpotlightFinderTag(to: fileUrl, with: "IMPORTED,Gray")
      // sleep for 25ms
      usleep(25000)
    })
}

func tascamX8FileToDest(at url: URL, mediaPathUrl: URL = helpersConfig.mediaPathUrl) throws -> URL {
  // Parses the date from a file like, 230502_0013_5-6.wav
  // and returns a file url to {mediaPathUrl}/2023-05-02/230502_0013_5-6.wav
  let file = url.path
  let components = file.components(separatedBy: "/")
  let filename = components.last!
  let parts = filename.components(separatedBy: "_")
  let year = "20" + parts[0].subString(0, 1)
  let month = parts[0].subString(2, 3)
  let day = parts[0].subString(4, 5)
  let yearFolder = "\(year)"
  let dateFolder = "\(year)-\(month)-\(day)"
  let subFolder: String = filename.subString(0, 10)

  let destinationFolder =
    mediaPathUrl
    .appendingPathComponent(yearFolder)
    .appendingPathComponent(dateFolder)
    .appendingPathComponent(subFolder)
  let destinationFile = destinationFolder.appendingPathComponent(filename)

  // If year is less than 2023 throw an exception
  if SKIP_WRONG_DATES && Int(year) ?? 0 < 2023 {
    throw "Year is less than 2023"
  }

  if IGNORE_TASCAM_MIX_FILES && filename.contains("_MIX") {
    throw "Ignoring mix file"
  }

  return destinationFile
}

func tascamX8ImportFolder(at url: URL, mediaPathUrl: URL = helpersConfig.mediaPathUrl) {
  let folderContents = try! FileManager.default.contentsOfDirectory(
    at: url, includingPropertiesForKeys: nil, options: [])
  for fileUrl in folderContents {
    // Tascam X8 can have a directory tree so we need to recurse
    if fileUrl.isDirectory {
      tascamX8ImportFolder(at: fileUrl, mediaPathUrl: mediaPathUrl)
      continue
    }

    do {
      let destinationFileUrl = try tascamX8FileToDest(at: fileUrl, mediaPathUrl: mediaPathUrl)
      copyFileSmart(sourceURL: fileUrl, destURL: destinationFileUrl, tag: "TascamX8")
    } catch {
      log("Error processing file \(fileUrl.path). Likely the date is wrong")
    }
  }
}

func tascamX8Import(at url: URL) {
  // In the root folder of the volume there is a folder called "SOUND"
  // This folder can also have sub folders
  // Files are named like 230502_0013_5-6.wav, 230502_0013_3.wav, 230502_0013_MIX.wav etc
  // We group by the first part, eg "230502_0013" and move that to a folder
  // based on parsing the date in the filename (eg 230502_0013 -> 2023-05-02)
  // So for example, 230502_0013_5-6.wav will be copied to a folder called
  // 2023-05-02/230502_0013/230502_0013_5-6.wav
  // 230502_0013_3.wav will be copied to a folder called 2023-05-02/230502_0013/230502_0013_3.wav
  // 230502_0013_MIX.wav will be copied to a folder called 2023-05-02/230502_0013/230502_0013_MIX.wav
  let soundFolder = url.appendingPathComponent("SOUND")
  let soundFolderExists = FileManager.default.fileExists(atPath: soundFolder.path)
  if !soundFolderExists {
    print("no sound folder at \(soundFolder.path)")
    return
  }
  tascamX8ImportFolder(at: soundFolder)
}

func zoomLiveTrakFileToDest(at url: URL, mediaPathUrl: URL = helpersConfig.mediaPathUrl) throws
  -> URL
{
  // Parses the date from a file like, 230519_224102/TRACK01.WAV
  // and returns a file url to {mediaPathUrl}/2023-05-19/230519_224102/TRACK01.WAV
  let file = url.path
  print("file \(file)")
  let components = file.components(separatedBy: "/")
  let filename = components.last!
  let projectFolder = components[components.count - 2]
  print("filename \(filename)")
  print("projectFolder \(projectFolder)")
  let parts = projectFolder.components(separatedBy: "_")
  let year = "20" + parts[0].subString(0, 1)
  let month = parts[0].subString(2, 3)
  let day = parts[0].subString(4, 5)
  let yearFolder = "\(year)"
  let dateFolder = "\(year)-\(month)-\(day)"

  let destinationFile =
    mediaPathUrl
    .appendingPathComponent(yearFolder)
    .appendingPathComponent(dateFolder)
    .appendingPathComponent(projectFolder)
    .appendingPathComponent(filename)

  print("destinationFile \(destinationFile)")

  // If year is less than 2023 throw an exception
  if SKIP_WRONG_DATES && Int(year) ?? 0 < 2023 {
    throw "Year is less than 2023"
  }

  return destinationFile
}

func zoomLiveTrakImportFolder(at url: URL, mediaPathUrl: URL = helpersConfig.mediaPathUrl) {
  let folderContents = try! FileManager.default.contentsOfDirectory(
    at: url, includingPropertiesForKeys: nil, options: [])
  for fileUrl in folderContents {
    if fileUrl.isDirectory {
      zoomLiveTrakImportFolder(at: fileUrl, mediaPathUrl: mediaPathUrl)
      continue
    }
    do {
      let destinationFileUrl = try zoomLiveTrakFileToDest(at: fileUrl, mediaPathUrl: mediaPathUrl)
      copyFileSmart(sourceURL: fileUrl, destURL: destinationFileUrl, tag: "ZoomL8")
    } catch {
      log("Error processing file \(fileUrl.path). Likely the date is wrong")
    }
  }
}

func zoomL8Import(at url: URL) {
  let soundFolder = url.appendingPathComponent("PROJECT")
  let soundFolderExists = FileManager.default.fileExists(atPath: soundFolder.path)
  if !soundFolderExists {
    print("no sound folder at \(soundFolder.path)")
    return
  }
  zoomLiveTrakImportFolder(at: soundFolder)
}

var urls: [URL] = getMountedVolumes()

for url in urls {
  log("url \(url)")
  let audioDeviceType = detectAudioDeviceType(at: url)
  if audioDeviceType == nil {
    log("Skipping \(url.path)")
    continue
  }
  log("Detected \(audioDeviceType!) at \(url.path)")
  if audioDeviceType == .tascamX8 {
    tascamX8Import(at: url)
  } else if audioDeviceType == .ZoomL8 {
    log("Zoom L8")
    zoomL8Import(at: url)
  } else if audioDeviceType == .ZoomL12 {
    log("Zoom L12")
  } else if audioDeviceType == .ZoomH4nPro {
    log("Zoom H4n Pro")
  }

  if PROMPT_TO_EJECT {
    confirmUI(prompt: "Would you like to unmount \(url.path)?") {
      log("would unmount")
      umountVolume(at: url)
    }
  }
}
