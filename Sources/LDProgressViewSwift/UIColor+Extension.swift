//
//  UIColor+Extension.swift
//  Realibox
//
//  Created by 伍小华 on 2018/7/25.
//  Copyright © 2018年 伍小华. All rights reserved.
//

import UIKit

extension UIColor {
    /// Creates a UIColor instance from red, green, blue, and alpha values.
    ///
    /// - Parameters:
    ///   - red: The red component (0-255).
    ///   - green: The green component (0-255).
    ///   - blue: The blue component (0-255).
    ///   - alpha: The alpha component (0-1).
    /// - Returns: The UIColor instance created from the given components.
    class func RGBA(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat) -> UIColor {
        return UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
    }
    
    /// Creates a UIColor instance from red, green, and blue values with full opacity.
    ///
    /// - Parameters:
    ///   - red: The red component (0-255).
    ///   - green: The green component (0-255).
    ///   - blue: The blue component (0-255).
    /// - Returns: The UIColor instance created from the given components.
    class func RGB(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat) -> UIColor {
        return self.RGBA(red, green, blue, 1.0)
    }
    
    /// Creates a UIColor instance from a hex value.
    ///
    /// - Parameter hexValue: The hex value representing the color.
    /// - Returns: The UIColor instance created from the hex value.
    class func hex(_ hexValue: Int) -> UIColor {
        return self.RGB(CGFloat((hexValue & 0xFF0000) >> 16), CGFloat((hexValue & 0xFF00) >> 8), CGFloat(hexValue & 0xFF))
    }
    
    /// Creates a UIColor instance from a hex string.
    ///
    /// - Parameter hexString: The hex string representing the color.
    /// - Returns: The UIColor instance created from the hex string.
    class func hex(_ hexString: String) -> UIColor {
        // Trim whitespace and newlines from the hex string
        var cString: String = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // If the hex string doesn't have enough characters, return black
        if cString.count < 6 {
            return UIColor.black
        }
        
        // Remove any prefix characters like "0x", "#", etc.
        if cString.hasPrefix("0X") || cString.hasPrefix("0x") {
            let index = cString.index(cString.endIndex, offsetBy: -6)
            let subString = cString[index...]
            cString = String(subString)
        }
        if cString.hasPrefix("#") {
            let index = cString.index(cString.endIndex, offsetBy: -6)
            let subString = cString[index...]
            cString = String(subString)
        }
        
        // If the cleaned hex string doesn't have exactly 6 characters, return black
        if cString.count != 6 {
            return UIColor.black
        }
        
        let scanner = Scanner(string: cString)
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        // Create and return a UIColor instance with the extracted components
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
    
    /// Returns a random UIColor instance with random RGB components.
    class var random: UIColor {
        return UIColor.RGB(CGFloat(arc4random_uniform(256)), CGFloat(arc4random_uniform(256)), CGFloat(arc4random_uniform(256)))
    }
    
    /// Gets the red component value of the UIColor.
    var r: Float {
        get {
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            
            self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            
            return Float(red)
        }
    }
    
    /// Gets the green component value of the UIColor.
    var g: Float {
        get {
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            
            self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            
            return Float(green)
        }
    }
    
    /// Gets the blue component value of the UIColor.
    var b: Float {
        get {
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            
            self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            
            return Float(blue)
        }
    }
    
    /// Gets the alpha component value of the UIColor.
    var a: Float {
        get {
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            
            self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            
            return Float(alpha)
        }
    }
    
    /// Returns whether the UIColor is clear (transparent).
    var isClear: Bool {
        get {
            // Check if the UIColor is equal to UIColor.clear
            return self == UIColor.clear
        }
    }
    
    /// Returns whether the UIColor is lighter in brightness.
    var isLighter: Bool {
        get {
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            
            // Get the individual color components of the UIColor
            self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            
            // Calculate the average brightness and compare with threshold
            if (red + green + blue) / 3.0 >= 0.5 {
                return true
            } else {
                return false
            }
        }
    }
    
    /// Returns a lighter version of the UIColor.
    var lighter: UIColor {
        get {
            if self == .white {
                return self
            }
            if self == .black {
                return UIColor(white: 0.01, alpha: 1.0)
            }
            
            var hue: CGFloat = 0
            var saturation: CGFloat = 0
            var brightness: CGFloat = 0
            var alpha: CGFloat = 0
            var white: CGFloat = 0
            
            if self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
                return UIColor(hue: hue,
                               saturation: saturation,
                               brightness: min(brightness * 1.3, 1.0),
                               alpha: alpha)
            }
            if self.getWhite(&white, alpha: &alpha) {
                return UIColor(white: min(white * 1.3, 1.0), alpha: alpha)
            }
            return UIColor.white
        }
    }
    
    /// Returns a darker version of the UIColor.
    var darker: UIColor {
        get {
            if self == .white {
                return UIColor(white: 0.99, alpha: 1.0)
            }
            if self == .black {
                return self
            }
            
            var hue: CGFloat = 0
            var saturation: CGFloat = 0
            var brightness: CGFloat = 0
            var alpha: CGFloat = 0
            var white: CGFloat = 0
            
            if self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
                return UIColor(hue: hue,
                               saturation: saturation,
                               brightness: brightness * 0.75,
                               alpha: alpha)
            }
            if self.getWhite(&white, alpha: &alpha) {
                return UIColor(white: white * 0.75, alpha: alpha)
            }
            return UIColor.black
        }
    }
}
