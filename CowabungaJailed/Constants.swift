//
//  Constants.swift
//  CowabungaJailed
//
//  Created by Rory Madden on 22/3/2023.
//

import Foundation

let fm = FileManager.default
@usableFromInline let documentsDirectory = fm.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("com.leemin.CowabungaJailed")
