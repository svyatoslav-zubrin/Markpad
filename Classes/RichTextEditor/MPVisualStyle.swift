//
//  MPVisualStyle.swift
//  Markpad
//
//  Created by Slava Zubrin on 2/17/20.
//

import Foundation

public struct MPVisualStyle {
    let fontName: String
    let fontSize: CGFloat
    let color: UniversalColor
    let traits: UniversalTraits

    public init(fontName: String, fontSize: CGFloat, color: UniversalColor, traits: UniversalTraits) {
        self.fontName = fontName
        self.fontSize = fontSize
        self.color = color
        self.traits = traits
    }

    public var font: UIFont {
        var fd = UIFontDescriptor(name: fontName, size: fontSize)
        fd = fd.withSymbolicTraits([fd.symbolicTraits, traits])!
        return UIFont(descriptor: fd, size: fontSize)
    }
}

public struct MPVisualStylesConfiguration {
    let baseStyle: MPVisualStyle

    public init(baseStyle: MPVisualStyle) {
        self.baseStyle = baseStyle
    }
}
