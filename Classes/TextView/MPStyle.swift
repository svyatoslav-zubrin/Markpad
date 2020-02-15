//
//  MPStyle.swift
//  Markpad
//
//  Created by Slava Zubrin on 2/15/20.
//

import Foundation

public struct MPStyle {
    
    var regex: NSRegularExpression!
    var attributes: [NSAttributedString.Key: Any] = [:]

    init(element: MPElement, attributes: [NSAttributedString.Key: Any]) {
        self.regex = element.toRegex()
        self.attributes = attributes
    }

    init(regex: NSRegularExpression, attributes: [NSAttributedString.Key: Any]) {
        self.regex = regex
        self.attributes = attributes
    }

    init() {
        self.regex = MPElement.unknown.toRegex()
    }
}
