//
//  MPVisualStyle.swift
//  Markpad
//
//  Created by Slava Zubrin on 2/17/20.
//

import Foundation

public struct MPContentConfig {
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

public struct MPInterfaceConfig {
    let toolbarIconsColorNormal: UIColor
    let toolbarIconsColorSelected: UIColor
    let borderColor: UIColor

    public init(toolbarIconsColorNormal: UIColor, toolbarIconsColorSelected: UIColor, borderColor: UIColor) {
        self.toolbarIconsColorNormal = toolbarIconsColorNormal
        self.toolbarIconsColorSelected = toolbarIconsColorSelected
        self.borderColor = borderColor
    }
}

public struct MPGeometryConfig {
    let toolbarItemSize: CGFloat
    let toolbarHeight: CGFloat
    let toolbarInteritemSpacing: CGFloat
    let toolbarCornerRadius: CGFloat
    let textViewMargins: CGFloat
    let textViewCornerRadius: CGFloat
    let toolbarToTextViewMargin: CGFloat

    public init(toolbarItemSize: CGFloat,
                toolbarHeight: CGFloat,
                toolbarInteritemSpacing: CGFloat,
                toolbarCornerRadius: CGFloat,
                textViewMargins: CGFloat,
                textViewCornerRadius: CGFloat,
                toolbarToTextViewMargin: CGFloat) {
        self.toolbarItemSize = toolbarItemSize
        self.toolbarHeight = toolbarHeight
        self.toolbarInteritemSpacing = toolbarInteritemSpacing
        self.toolbarCornerRadius = toolbarCornerRadius
        self.textViewMargins = textViewMargins
        self.textViewCornerRadius = textViewCornerRadius
        self.toolbarToTextViewMargin = toolbarToTextViewMargin
    }
}

public struct MPLinkPopupConfig {
    let title: String
    let linkNamePlaceholder: String
    let linkURLPlaceholder: String
    let okButtonTitle: String
    let cancelButtonTitle: String

    public init(title: String,
         linkNamePlaceholder: String,
         linkURLPlaceholder: String,
         okButtonTitle: String,
         cancelButtonTitle: String) {
        self.title = title
        self.linkNamePlaceholder = linkNamePlaceholder
        self.linkURLPlaceholder = linkURLPlaceholder
        self.okButtonTitle = okButtonTitle
        self.cancelButtonTitle = cancelButtonTitle
    }
}

public struct MPConfiguration {
    let content: MPContentConfig
    let interface: MPInterfaceConfig
    let geometry: MPGeometryConfig
    let linkPopup: MPLinkPopupConfig

    public init(content: MPContentConfig,
                interface: MPInterfaceConfig,
                geometry: MPGeometryConfig,
                linkPopup: MPLinkPopupConfig) {
        self.content = content
        self.interface = interface
        self.geometry = geometry
        self.linkPopup = linkPopup
    }
}
