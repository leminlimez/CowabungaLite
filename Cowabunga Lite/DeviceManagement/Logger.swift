//
//  Logger.swift
//  CowabungaJailed
//
//  Created by Lauren Woo on 21/4/2023.
//

import Foundation

@objc class Logger: NSObject, ObservableObject {
    @objc static let shared = Logger()
    
    @Published var logText = ""

    @objc func logMe(_ message: String) {
        print(message)
        logText += "\(message)\n"
    }
}


