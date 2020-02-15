//
//  MPTheme.swift
//  Markpad
//
//  Created by Slava Zubrin on 2/15/20.
//

import UIKit

public struct MPTheme {
    /// The body style for the Notepad editor.
    public fileprivate(set) var body: MPStyle = MPStyle()
    /// The background color of the Notepad.
    public fileprivate(set) var backgroundColor: UniversalColor = UniversalColor.clear
    /// The tint color (AKA cursor color) of the Notepad.
    public fileprivate(set) var tintColor: UniversalColor = UniversalColor.blue

    /// All of the other styles for the Notepad editor.
    var styles: [MPStyle] = []


    /// Build a theme from a JSON theme file.
    ///
    /// - parameter name: The name of the JSON theme file.
    ///
    /// - returns: The Theme.
    public init(_ name: String) {
        let bundle = Bundle(for: MPTextView.self)

        let path: String

        if let path1 = bundle.path(forResource: "Notepad.framework/themes/\(name)", ofType: "json") {

            path = path1
        }
        else if let path2 = bundle.path(forResource: "Notepad.framework/\(name)", ofType: "json") {

            path = path2
        }
        else if let path3 = bundle.path(forResource: "themes/\(name)", ofType: "json") {

            path = path3
        }
        else {

            print("[Notepad] Unable to load your theme file.")

            return
        }

        if let data = convertFile(path) {
            configure(data)
        }
    }

    public init(themePath: String) {
        if let data = convertFile(themePath) {
            configure(data)
        }
    }

    /// Configures all of the styles for the Theme.
    ///
    /// - parameter data: The dictionary data form the parsed JSON file.
    mutating func configure(_ data: [String: AnyObject]) {
        if let editorStyles = data["editor"] as? [String: AnyObject] {
            configureEditor(editorStyles)
        }

        if var allStyles = data["styles"] as? [String: AnyObject] {
            if let bodyStyles = allStyles["body"] as? [String: AnyObject] {
                if var parsedBodyStyles = parse(bodyStyles) {
                    if #available(iOS 13.0, *) {
                        if parsedBodyStyles[NSAttributedString.Key.foregroundColor] == nil {
                            parsedBodyStyles[NSAttributedString.Key.foregroundColor] = UniversalColor.label
                        }
                    }
                    body = MPStyle(element: .body, attributes: parsedBodyStyles)
                }
            }
            else { // Create a default body font so other styles can inherit from it.
                var textColor = UniversalColor.black
                if #available(iOS 13.0, *) {
                    textColor = UniversalColor.label
                }
                let attributes = [NSAttributedString.Key.foregroundColor: textColor]
                body = MPStyle(element: .body, attributes: attributes)
            }

            allStyles.removeValue(forKey: "body")
            for (element, attributes) in allStyles {
                if let parsedStyles = parse(attributes as! [String : AnyObject]) {
                    if let regexString = attributes["regex"] as? String {
                        let regex = regexString.toRegex()
                        styles.append(MPStyle(regex: regex, attributes: parsedStyles))
                    }
                    else {
                        styles.append(MPStyle(element: MPElement.unknown.from(string: element), attributes: parsedStyles))
                    }
                }
            }
        }
    }

    /// Sets the background color, tint color, etc. of the Notepad editor.
    ///
    /// - parameter attributes: The attributes to parse for the editor.
    mutating func configureEditor(_ attributes: [String: AnyObject]) {
        if let bgColor = attributes["backgroundColor"] {
            let value = bgColor as! String
            backgroundColor = UniversalColor(hexString: value)
        }

        if let tint = attributes["tintColor"] {
            let value = tint as! String
            tintColor = UniversalColor(hexString: value)
        }
    }

    /// Parses attributes from shorthand JSON to real attributed string key constants.
    ///
    /// - parameter attributes: The attributes to parse.
    ///
    /// - returns: The converted attribute/key constant pairings.
    func parse(_ attributes: [String: AnyObject]) -> [NSAttributedString.Key: Any]? {
        var stringAttributes: [NSAttributedString.Key: Any] = [:]

        if let color = attributes["color"] as? String {
            stringAttributes[NSAttributedString.Key.foregroundColor] = UniversalColor(hexString: color)
        }

        let bodyFont = body.attributes[NSAttributedString.Key.font] as? UniversalFont
        // if size is set use custom size, otherwise use body font size, otherwise fallback to 15 points
        let fontSize: CGFloat = attributes["size"] as? CGFloat ?? (bodyFont?.pointSize ?? 15)
        let fontTraits = attributes["traits"] as? String ?? ""
        var font: UniversalFont?

        if let fontName = attributes["font"] as? String, fontName != "System" {
            // use custom font if set
            font = UniversalFont(name: fontName, size: fontSize)?.with(traits: fontTraits, size: fontSize)
        } else if let bodyFont = bodyFont, bodyFont.fontName != "System" {
            // use body font if set
            font = UniversalFont(name: bodyFont.fontName, size: fontSize)?.with(traits: fontTraits, size: fontSize)
        } else {
            // use system font in all other cases
            font = UniversalFont.systemFont(ofSize: fontSize).with(traits: fontTraits, size: fontSize)
        }

        stringAttributes[NSAttributedString.Key.font] = font
        return stringAttributes
    }

    /// Converts a file from JSON to a [String: AnyObject] dictionary.
    ///
    /// - parameter path: The path to the JSON file.
    ///
    /// - returns: The new dictionary.
    func convertFile(_ path: String) -> [String: AnyObject]? {
        do {
            let json = try String(contentsOf: URL(fileURLWithPath: path), encoding: .utf8)
            if let data = json.data(using: .utf8) {
                do {
                    return try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
                } catch let error as NSError {
                    print(error)
                }
            }
        } catch let error as NSError {
            print(error)
        }

        return nil
    }
}

