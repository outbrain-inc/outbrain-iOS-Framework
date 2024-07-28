//
//  Extensions.swift
//  demo
//
//  Created by Leonid Lemesev on 25/07/2024.
//

import Foundation
import SwiftUI


extension Color {
    init(hex: Int, opacity: Double = 1.0) {
        let red = Double((hex & 0xff0000) >> 16) / 255.0
        let green = Double((hex & 0xff00) >> 8) / 255.0
        let blue = Double((hex & 0xff) >> 0) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
    
    static var outbrainOrange: Color = Color(hex: 0xEE7205)
}
