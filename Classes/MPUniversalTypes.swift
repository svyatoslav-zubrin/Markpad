//
//  UniversalTypes.swift
//  Markpad
//
//  Created by Slava Zubrin on 2/15/20.
//

//#if os(iOS)
    import UIKit
    public typealias UniversalColor = UIColor
    public typealias UniversalFont = UIFont
    public typealias UniversalFontDescriptor = UIFontDescriptor
    public typealias UniversalTraits = UIFontDescriptor.SymbolicTraits
//#elseif os(macOS)
//    import AppKit
//    public typealias UniversalColor = NSColor
//    public typealias UniversalFont = NSFont
//    public typealias UniversalFontDescriptor = NSFontDescriptor
//    public typealias UniversalTraits = NSFontDescriptor.SymbolicTraits
//#endif
