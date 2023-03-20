//
//  Utilities.swift
//  CowabungaJailed
//
//  Created by Rory Madden on 20/3/2023.
//

import Foundation

func shell(_ scriptURL: URL, arguments: [String] = [], workingDirectory: URL? = nil) throws {
    let task = Process()
    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe

    task.executableURL = URL(fileURLWithPath: "/bin/sh")
    let scriptArguments = arguments.joined(separator: " ")
    task.arguments = ["-c", "source \(scriptURL.path) \(scriptArguments)"]
    if let workingDirectory = workingDirectory {
        task.currentDirectoryURL = workingDirectory
    }
    
    try task.run()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    if let output = String(data: data, encoding: .utf8) {
        print(output)
    }
}

func printDirectoryTree(at path: URL, level: Int) {
    let fileManager = FileManager.default
    let prefix = String(repeating: "│   ", count: level > 0 ? level - 1 : 0) + (level > 0 ? "├── " : "")
    
    do {
        let contents = try fileManager.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: [])
        for url in contents {
            let isDirectory = (try? url.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory ?? false
            print(prefix + url.lastPathComponent)
            if isDirectory {
                printDirectoryTree(at: url, level: level + 1)
            }
        }
    } catch {
        print(error.localizedDescription)
    }
}

func copyFolderFromBundleToDocuments() {
    guard let docsFolderURL = Bundle.main.url(forResource: "Docs", withExtension: nil) else {
        fatalError("Unable to find Docs folder in app bundle")
    }

    let fileManager = FileManager.default
    guard let documentsURL = try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else { return }
    let destinationURL = documentsURL.appendingPathComponent("Docs")

    do {
        try fileManager.copyItem(at: docsFolderURL, to: destinationURL)
        print("Successfully copied Docs folder to Documents directory")
    } catch {
        print("Error copying Docs folder: \(error)")
    }
}

