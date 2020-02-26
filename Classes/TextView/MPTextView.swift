//
//  MPTextView.swift
//  Markpad
//
//  Created by Slava Zubrin on 2/15/20.
//

import UIKit

public enum Style {
    case bold
    case italic
    case underline
    case link(title: String, url: URL)
    case bulletList
    case numberList
}

protocol Stylable {
    func markSelection(withStyle style: Style, updateToolbar: (()->())?)
}

class MPTextView: UITextView {

    var storage: MPTextStorage = MPTextStorage()

    private var defaultAttributeValues: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
    ]

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

    func markSelection(withStyle style: Style, updateToolbar: (()->())? = nil) {
        switch style {
        case .bold:
            if selectedRange.length > 0 {
                storage.applyBold(to: selectedRange)
            } else {
                switchTypingTrait(.traitBold)
            }
            updateToolbar?()

        case .italic:
            if selectedRange.length > 0 {
                storage.applyItalic(to: selectedRange)
            } else {
                switchTypingTrait(.traitItalic)
            }
            updateToolbar?()

        case .underline:
            if selectedRange.length > 0 {
                storage.applyUnderline(to: selectedRange)
            } else {
                switchTypingAttribute(.underlineStyle)
            }
            updateToolbar?()

        case .link:
            let linkFont = font ?? UIFont.systemFont(ofSize: UIFont.systemFontSize)
            storage.applyLink(style, to: selectedRange, font: linkFont)

//        case .bulletList:
//        case .numberedList:

        default:
            break
        }
    }
}

// MARK: - Helpers

private extension MPTextView {

    // Traits handling

    func switchTypingTrait(_ trait: UIFontDescriptor.SymbolicTraits) {
        guard typingAttributes.keys.contains(.font), let font = typingAttributes[.font] as? UIFont else { return }

        if font.fontDescriptor.symbolicTraits.contains(trait) {
            removeTypingTrait(trait)
        } else {
            appendTypingTrait(trait)
        }
    }

    func removeTypingTrait(_ trait: UIFontDescriptor.SymbolicTraits) {
        guard typingAttributes.keys.contains(.font), let font = typingAttributes[.font] as? UIFont else { return }

        if font.fontDescriptor.symbolicTraits.contains(trait) {
            var traits = font.fontDescriptor.symbolicTraits
            traits.remove(trait)
            let descriptor = font.fontDescriptor.withSymbolicTraits(traits)
            if let descriptor = descriptor {
                let newFont = UIFont(descriptor: descriptor, size: font.pointSize)
                typingAttributes[.font] = newFont
            }
        }
    }

    func appendTypingTrait(_ trait: UIFontDescriptor.SymbolicTraits) {
        guard typingAttributes.keys.contains(.font), let font = typingAttributes[.font] as? UIFont else { return }

        if !font.fontDescriptor.symbolicTraits.contains(trait) {
            var traits = font.fontDescriptor.symbolicTraits
            traits.update(with: trait)
            let descriptor = font.fontDescriptor.withSymbolicTraits(traits)
            if let descriptor = descriptor {
                let newFont = UIFont(descriptor: descriptor, size: font.pointSize)
                typingAttributes[.font] = newFont
            }
        }
    }

    // Attributes handling

    func switchTypingAttribute(_ attribute: NSAttributedString.Key) {
        if typingAttributes.keys.contains(attribute) {
            typingAttributes.removeValue(forKey: attribute)
        } else {
            guard defaultAttributeValues.keys.contains(attribute) else { return }
            typingAttributes[attribute] = defaultAttributeValues[attribute]
        }
    }
}
