//
//  MPTextView.swift
//  Markpad
//
//  Created by Slava Zubrin on 2/15/20.
//

import UIKit

public enum Style {
    case bold, italic, underline, link, bulletList, numberedList

    internal var icon: UIImage {
        let iconName: String
        switch self {
        case .bold: iconName = "icon_bold"
        case .italic: iconName = "icon_italic"
        case .underline: iconName = "icon_underline"
        case .link: iconName = "icon_link"
        case .bulletList: iconName = "icon_bullet_list"
        case .numberedList: iconName = "icon_numbered_list"
        }
        let bundle = Bundle(for: MPRichTextEditorView.self)
        return UIImage(named: iconName, in: bundle, compatibleWith: nil)!
    }
}

protocol Stylable {
    func markSelection(withSyle style: Style)
}

class MPTextView: UITextView {

    var storage: MPTextStorage = MPTextStorage()

    /// Creates a new Notepad.
    ///
    /// - parameter frame:     The frame of the text editor.
    /// - parameter themeFile: The name of the theme file to use.
    ///
    /// - returns: A new Notepad.
    convenience public init(frame: CGRect, themeFile: String) {
        self.init(frame: frame, textContainer: nil)
        let theme = MPTheme(themeFile)
        self.storage.theme = theme
        self.backgroundColor = theme.backgroundColor
        self.tintColor = theme.tintColor
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    convenience public init(frame: CGRect, theme: MPTheme) {
        self.init(frame: frame, textContainer: nil)
        self.storage.theme = theme
        self.backgroundColor = theme.backgroundColor
        self.tintColor = theme.tintColor
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        let layoutManager = NSLayoutManager()
        let containerSize = CGSize(width: frame.size.width, height: CGFloat.greatestFiniteMagnitude)
        let container = NSTextContainer(size: containerSize)
        container.widthTracksTextView = true

        layoutManager.addTextContainer(container)
        storage.addLayoutManager(layoutManager)
        super.init(frame: frame, textContainer: container)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let layoutManager = NSLayoutManager()
        let containerSize = CGSize(width: frame.size.width, height: CGFloat.greatestFiniteMagnitude)
        let container = NSTextContainer(size: containerSize)
        container.widthTracksTextView = true

        layoutManager.addTextContainer(container)
        storage.addLayoutManager(layoutManager)
    }
}

// MARK: - Stylable

extension MPTextView: Stylable {

    func markSelection(withSyle style: Style) {
        guard selectedRange.length > 0 else { return }

        switch style {
        case .bold:
            storage.applyBold(to: selectedRange)
        case .italic:
            storage.applyItalic(to: selectedRange)
        case .underline:
            storage.applyUnderline(to: selectedRange)
//        case .link:
//        case .bulletList:
//        case .numberedList:
        default:
            break
        }
    }
}
