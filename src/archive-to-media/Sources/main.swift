// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import SwiftHelpers

helpersConfig.enablePrint = true
helpersConfig.enableSyslog = false

let BASE_PATH = "/Users/richard/msc/media"

func archiveFile(filePath: String) {
    let fileUrl = URL(fileURLWithPath: filePath)

    // Skip if file doesn't exist
    guard FileManager.default.fileExists(atPath: filePath) else {
        log("File does not exist: \(filePath)")
        return
    }

    // Get file attributes to extract date
    guard let attributes = try? FileManager.default.attributesOfItem(atPath: filePath) else {
        log("Could not get file attributes for: \(filePath)")
        return
    }

    let creationDate = attributes[.creationDate] as! Date
    let dateFormatter = DateFormatter()

    // Format date components
    dateFormatter.dateFormat = "yyyy"
    let year = dateFormatter.string(from: creationDate)

    dateFormatter.dateFormat = "yyyy-MM-dd"
    let dateFolder = dateFormatter.string(from: creationDate)

    // Construct target directory
    let targetDir = URL(fileURLWithPath: BASE_PATH)
        .appendingPathComponent(year)
        .appendingPathComponent(dateFolder)

    // Create target directory if it doesn't exist
    if !FileManager.default.fileExists(atPath: targetDir.path) {
        do {
            try FileManager.default.createDirectory(at: targetDir, withIntermediateDirectories: true)
        } catch {
            log("Failed to create directory: \(targetDir.path)")
            return
        }
    }

    let targetFile = targetDir.appendingPathComponent(fileUrl.lastPathComponent)

    // Check if file is already tagged as imported
    if checkIfSpotlightFinderTagExists(to: fileUrl, with: "IMPORTED") {
        let fileExists = FileManager.default.fileExists(atPath: targetFile.path)
        if fileExists {
            log("[Skipping] File tagged as imported, and dest file exists: \(fileUrl.path) -> \(targetFile.path)")
        } else {
            log("[Warning] File tagged as imported, but dest file does not exist: \(fileUrl.path) \(targetFile.path)")
        }
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
        },
        onSizeDifferent: {
            log("[Replacing] File size is different\n--\(fileUrl.path)\n->\(targetFile.path)")
            try! FileManager.default.trashItem(at: targetFile, resultingItemURL: nil)
            try! FileManager.default.copyItem(at: fileUrl, to: targetFile)
            addSpotlightFinderTag(to: targetFile, with: "Archived_File")
            addSpotlightFinderTag(to: fileUrl, with: "IMPORTED,Gray")
            addSpotlightFinderTag(to: targetDir, with: "Archived_Project")
        },
        onSame: {
            log("[Skipping] File size is the same\n--\(fileUrl.path)\n->\(targetFile.path)")
            addSpotlightFinderTag(to: targetFile, with: "Archived_File")
            addSpotlightFinderTag(to: fileUrl, with: "IMPORTED,Gray")
            addSpotlightFinderTag(to: targetDir, with: "Archived_Project")
        })
}

// Read input from stdin
while let line = readLine() {
    archiveFile(filePath: line.trimmingCharacters(in: .whitespacesAndNewlines))
}
