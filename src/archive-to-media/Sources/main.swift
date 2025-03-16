// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import SwiftHelpers
import AppKit

// Initialize NSApplication
NSApplication.shared.setActivationPolicy(.accessory)
let app = NSApplication.shared
app.activate(ignoringOtherApps: true)

helpersConfig.enablePrint = true
helpersConfig.enableSyslog = false

let BASE_PATH = "/Users/richard/msc/media"
var lastProcessedFolder: URL? = nil
var filesImported = 0
var filesSkipped = 0

func archiveFile(filePath: String) {
    let fileUrl = URL(fileURLWithPath: filePath)

    // Skip if file doesn't exist
    guard FileManager.default.fileExists(atPath: filePath) else {
        log("File does not exist: \(filePath)")
        filesSkipped += 1
        return
    }

    // Get file attributes to extract date
    guard let attributes = try? FileManager.default.attributesOfItem(atPath: filePath) else {
        log("Could not get file attributes for: \(filePath)")
        filesSkipped += 1
        return
    }

    let modificationDate = attributes[.modificationDate] as! Date
    let dateFormatter = DateFormatter()

    // Format date components
    dateFormatter.dateFormat = "yyyy"
    let year = dateFormatter.string(from: modificationDate)

    dateFormatter.dateFormat = "yyyy-MM-dd"
    let dateFolder = dateFormatter.string(from: modificationDate)

    // Construct target directory
    let targetDir = URL(fileURLWithPath: BASE_PATH)
        .appendingPathComponent(year)
        .appendingPathComponent(dateFolder)

    log("Target directory: \(targetDir.path)")

    // Create target directory if it doesn't exist
    if !FileManager.default.fileExists(atPath: targetDir.path) {
        do {
            try FileManager.default.createDirectory(at: targetDir, withIntermediateDirectories: true)
            log("Created directory: \(targetDir.path)")
        } catch {
            log("Failed to create directory: \(targetDir.path)")
            return
        }
    }

    let targetFile = targetDir.appendingPathComponent(fileUrl.lastPathComponent)
    log("Target file: \(targetFile.path)")

    // Check if file is already tagged as imported
    if checkIfSpotlightFinderTagExists(to: fileUrl, with: "IMPORTED") {
        let fileExists = FileManager.default.fileExists(atPath: targetFile.path)
        if fileExists {
            log("[Skipping] File tagged as imported, and dest file exists: \(fileUrl.path) -> \(targetFile.path)")
        } else {
            log("[Warning] File tagged as imported, but dest file does not exist: \(fileUrl.path) \(targetFile.path)")
        }
        filesSkipped += 1
        return
    }

    // Copy file if needed
    runIfFileSizeIsDifferent(
        fileUrl, targetFile,
        onNotExists: {
            log("[Copying] Does not exist\n--\(fileUrl.path)\n->\(targetFile.path)")
            try! FileManager.default.copyItem(at: fileUrl, to: targetFile)
            addSpotlightFinderTag(to: targetFile, with: "Archived_File")
            addSpotlightFinderTag(to: fileUrl, with: "IMPORTED,Gray")
            addSpotlightFinderTag(to: targetDir, with: "Archived_Project")
            lastProcessedFolder = targetDir
            filesImported += 1
        },
        onSizeDifferent: {
            log("[Replacing] File size is different\n--\(fileUrl.path)\n->\(targetFile.path)")
            try! FileManager.default.trashItem(at: targetFile, resultingItemURL: nil)
            try! FileManager.default.copyItem(at: fileUrl, to: targetFile)
            addSpotlightFinderTag(to: targetFile, with: "Archived_File")
            addSpotlightFinderTag(to: fileUrl, with: "IMPORTED,Gray")
            addSpotlightFinderTag(to: targetDir, with: "Archived_Project")
            lastProcessedFolder = targetDir
            filesImported += 1
        },
        onSame: {
            log("[Skipping] File size is the same\n--\(fileUrl.path)\n->\(targetFile.path)")
            addSpotlightFinderTag(to: targetFile, with: "Archived_File")
            addSpotlightFinderTag(to: fileUrl, with: "IMPORTED,Gray")
            addSpotlightFinderTag(to: targetDir, with: "Archived_Project")
            lastProcessedFolder = targetDir
            filesSkipped += 1
        })
}

// Read input from stdin
while let line = readLine() {
    archiveFile(filePath: line.trimmingCharacters(in: .whitespacesAndNewlines))
}

// Always print summary to terminal
log("\n=== Archive Complete ===")
log(filesImported == 1 ? "1 file imported" : "\(filesImported) files imported")
log(filesSkipped == 1 ? "1 file skipped" : "\(filesSkipped) files skipped")

// Check if GUI should be disabled
let shouldDisableGUI = ProcessInfo.processInfo.environment["SCRIPTS_DISABLE_GUI_IN_SHELL"] == "true"

if !shouldDisableGUI {
    // Show dialog
    let alert = NSAlert()
    alert.messageText = "Archive Complete"

    let importedText = filesImported == 1 ? "1 file imported" : "\(filesImported) files imported"
    let skippedText = filesSkipped == 1 ? "1 file skipped" : "\(filesSkipped) files skipped"
    alert.informativeText = "\(importedText)\n\(skippedText)"

    if let lastFolder = lastProcessedFolder {
        alert.informativeText += "\n\nWould you like to open the destination folder?"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Open Folder")
        alert.addButton(withTitle: "Close")

        if alert.runModal() == .alertFirstButtonReturn {
            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: lastFolder.path)
        }
    } else {
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        _ = alert.runModal()
    }
}
