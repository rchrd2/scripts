/*
Example usage
$ ls | swift <(cat helpers.swift hello.swift)
$ ls | swift <(cat helpers.swift hello.swift) ~/msc/media/2023/2023-05-15/2023-05-15\ -\ test\ rc\ 202\ as\ mic\ input.mxprj
*/

// import Foundation

// Longer way
// var filePaths = readFiles()

// for filePath in filePaths {
//     print(">>> \(filePath)")
// }

// Alternative way
_ = readFiles().map { log(">>> \($0)") }

print("done")
