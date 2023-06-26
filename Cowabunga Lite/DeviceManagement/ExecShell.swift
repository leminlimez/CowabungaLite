//
//  ExecShell.swift
//  CowabungaJailed
//
//  Created by Lauren Woo on 21/4/2023.
//

import Foundation

func shell(_ scriptURL: URL, arguments: [String] = [], workingDirectory: URL? = nil) throws {
    let task = Process()
    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe

    task.executableURL = URL(fileURLWithPath: "/bin/sh")
    let scriptArguments = arguments.joined(separator: " ")
    // testing fix here
    task.arguments = ["-c", "source \"\(scriptURL.path)\" \(scriptArguments)"]
    if let workingDirectory = workingDirectory {
        task.currentDirectoryURL = workingDirectory
    }
    
    try task.run()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    if let output = String(data: data, encoding: .utf8) {
        Logger.shared.logMe(output)
    }
}

func execute(_ execURL: URL, arguments: [String] = [], workingDirectory: URL? = nil) throws {
    let task = Process()
    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe
    
    let bundlePath = Bundle.main.bundlePath
    let frameworksPath = (bundlePath as NSString).appendingPathComponent("Contents/Frameworks")
    #if !CLI
    let environment = ["DYLD_LIBRARY_PATH": frameworksPath]
    task.environment = environment
    #endif

    task.executableURL = execURL
    task.arguments = arguments
    if let workingDirectory = workingDirectory {
        task.currentDirectoryURL = workingDirectory
    }
    
    try task.run()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    if let output = String(data: data, encoding: .utf8) {
        Logger.shared.logMe(output)
    }
}

func execute2(_ execURL: URL, arguments: [String] = [], workingDirectory: URL? = nil) throws -> String {
    let task = Process()
    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe
    
    let bundlePath = Bundle.main.bundlePath
    let frameworksPath = (bundlePath as NSString).appendingPathComponent("Contents/Frameworks")
    #if !CLI
    let environment = ["DYLD_LIBRARY_PATH": frameworksPath]
    task.environment = environment
    #endif

    task.executableURL = execURL
    task.arguments = arguments
    if let workingDirectory = workingDirectory {
        task.currentDirectoryURL = workingDirectory
    }
    
    try task.run()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    if let output = String(data: data, encoding: .utf8) {
        return output
    }
    return ""
}

func executeWIN(_ execURL: URL, arguments: [String] = [], workingDirectory: URL? = nil) throws -> String {
    let task = Process()
    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe
    
    let bundlePath = Bundle.main.bundlePath
    let frameworksPath = (bundlePath as NSString).appendingPathComponent("Contents/Frameworks")
    // let environment = ["DYLD_LIBRARY_PATH": frameworksPath]
    // task.environment = environment

    task.executableURL = execURL
    task.arguments = arguments
    if let workingDirectory = workingDirectory {
        task.currentDirectoryURL = workingDirectory
    }
    
    try task.run()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    if let output = String(data: data, encoding: .utf8) {
        let output2 = output.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\r", with: "")
        return output2
    }
    return ""
}
