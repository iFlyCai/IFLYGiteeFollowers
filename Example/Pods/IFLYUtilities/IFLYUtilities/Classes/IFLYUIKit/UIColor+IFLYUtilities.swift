//
//  UIColor+IFLYUtilities.swift
//  FBSnapshotTestCase
//
//  Created by iFlyCai on 2025/8/29.
//

import Foundation
import UIKit

extension UIColor {
    public func hexString(includeAlpha: Bool = false) -> String? {
        guard let components = self.cgColor.components else {
            return nil
        }
        let r, g, b, a: CGFloat
        
        if components.count >= 4 {
            r = components[0]
            g = components[1]
            b = components[2]
            a = components[3]
        } else if components.count == 2 {
            r = components[0]
            g = components[0]
            b = components[0]
            a = components[1]
        } else {
            return nil
        }
        
        if includeAlpha {
            return String(format: "#%02X%02X%02X%02X",
                          Int(r * 255),
                          Int(g * 255),
                          Int(b * 255),
                          Int(a * 255))
        } else {
            return String(format: "#%02X%02X%02X",
                          Int(r * 255),
                          Int(g * 255),
                          Int(b * 255))
        }
    }
}
