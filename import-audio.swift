/// This script has logic to read files from SD cards in /Volumes
/// and copy them to a destination directory.

// require ./helpers.swift
// exitWhenParentProcessExits()

let PROMPT_TO_EJECT = false
let SKIP_WRONG_DATES = true

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

  return destinationFile
}

func tascamX8ImportFolder(at url: URL, mediaPathUrl: URL = helpersConfig.mediaPathUrl) {
  let folderContents = try! FileManager.default.contentsOfDirectory(
    at: url, includingPropertiesForKeys: nil, options: [])
  for fileUrl in folderContents {
    if fileUrl.isDirectory {
      tascamX8ImportFolder(at: fileUrl, mediaPathUrl: mediaPathUrl)
      continue
    }

    do {
      let destinationFileUrl = try tascamX8FileToDest(at: fileUrl, mediaPathUrl: mediaPathUrl)
      if !destinationFileUrl.deletingLastPathComponent().isDirectory {
        log("creating directory \(destinationFileUrl.deletingLastPathComponent().path)")
        try! FileManager.default.createDirectory(
          at: destinationFileUrl.deletingLastPathComponent(),
          withIntermediateDirectories: true,
          attributes: nil)
        addSpotlightFinderTag(
          to: destinationFileUrl.deletingLastPathComponent(), with: "TascamX8_Project")
      }

      runIfFileSizeIsDifferent(
        fileUrl, destinationFileUrl,
        onNotExists: {
          print("Does not exist. Copying\n--\(fileUrl.path)\n->\(destinationFileUrl.path)")
          try! FileManager.default.copyItem(at: fileUrl, to: destinationFileUrl)
          addSpotlightFinderTag(to: destinationFileUrl, with: "TascamX8_File")
          addSpotlightFinderTag(to: fileUrl, with: "IMPORTED,Gray")
          sleep(2)
        },
        onSizeDifferent: {
          print(
            "File size is different. Replacing. \n--\(fileUrl.path)\n->\(destinationFileUrl.path)")
          try! FileManager.default.trashItem(at: destinationFileUrl, resultingItemURL: nil)
          try! FileManager.default.copyItem(at: fileUrl, to: destinationFileUrl)
          addSpotlightFinderTag(to: destinationFileUrl, with: "TascamX8_File")
          addSpotlightFinderTag(to: fileUrl, with: "IMPORTED,Gray")
          sleep(2)
        })

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

var urls: [URL] = getMountedVolumes()

for url in urls {
  log("url \(url)")
  let components = url.pathComponents
  // if the volume is named X8, import it
  if components.count > 2
    && components[2] == "X8"
  {
    log("importing \(url)")
    tascamX8Import(at: url)
    if PROMPT_TO_EJECT {
      confirmUI(prompt: "Would you like to unmount \(url.path)?") {
        log("would unmount")
        umountVolume(at: url)
      }
    }
  }
}
