//
//  MPTextStorage.swift
//  Markpad
//
//  Created by Slava Zubrin on 2/15/20.
//

import UIKit

class MPTextStorage: NSTextStorage {

    /// The Theme for the Notepad.
    public var theme: MPTheme? {
        didSet {
            let wholeRange = NSRange(location: 0, length: (self.string as NSString).length)

            self.beginEditing()
            self.applyStyles(wholeRange)
            self.edited(.editedAttributes, range: wholeRange, changeInLength: 0)
            self.endEditing()
        }
    }

    /// The underlying text storage implementation.
    var backingStore = NSTextStorage()

    override public var string: String {
        get {
            return backingStore.string
        }
    }

    override public init() {
        super.init()
    }

    override public init(attributedString attrStr: NSAttributedString) {
        super.init(attributedString:attrStr)
        backingStore.setAttributedString(attrStr)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required public init(itemProviderData data: Data, typeIdentifier: String) throws {
        fatalError("init(itemProviderData:typeIdentifier:) has not been implemented")
    }

    #if os(macOS)
    required public init?(pasteboardPropertyList propertyList: Any, ofType type: String) {
        fatalError("init(pasteboardPropertyList:ofType:) has not been implemented")
    }

    required public init?(pasteboardPropertyList propertyList: Any, ofType type: NSPasteboard.PasteboardType) {
        fatalError("init(pasteboardPropertyList:ofType:) has not been implemented")
    }
    #endif

    /// Finds attributes within a given range on a String.
    ///
    /// - parameter location: How far into the String to look.
    /// - parameter range:    The range to find attributes for.
    ///
    /// - returns: The attributes on a String within a certain range.
    override public func attributes(at location: Int, longestEffectiveRange range: NSRangePointer?, in rangeLimit: NSRange) -> [NSAttributedString.Key : Any] {
        return backingStore.attributes(at: location, longestEffectiveRange: range, in: rangeLimit)
    }

    /// Replaces edited characters within a certain range with a new string.
    ///
    /// - parameter range: The range to replace.
    /// - parameter str:   The new string to replace the range with.
    override public func replaceCharacters(in range: NSRange, with str: String) {
        self.beginEditing()
        backingStore.replaceCharacters(in: range, with: str)
        let len = (str as NSString).length
        let change = len - range.length
        self.edited([.editedCharacters, .editedAttributes], range: range, changeInLength: change)
        self.endEditing()
    }

    /// Sets the attributes on a string for a particular range.
    ///
    /// - parameter attrs: The attributes to add to the string for the range.
    /// - parameter range: The range in which to add attributes.
    public override func setAttributes(_ attrs: [NSAttributedString.Key : Any]?, range: NSRange) {
        self.beginEditing()
        backingStore.setAttributes(attrs, range: range)
        self.edited(.editedAttributes, range: range, changeInLength: 0)
        self.endEditing()
    }

    /// Adds the attribute to a string for a particular range.
    /// - Parameters:
    ///   - name: The name of the attribute to add
    ///   - value: The value of the attribute to add
    ///   - range: The range in which to add attribute
    override func addAttribute(_ name: NSAttributedString.Key, value: Any, range: NSRange) {
        self.beginEditing()
        backingStore.addAttribute(name, value: value, range: range)
        self.edited(.editedAttributes, range: range, changeInLength: 0)
        self.endEditing()
    }

    /// Retrieves the attributes of a string for a particular range.
    ///
    /// - parameter at: The location to begin with.
    /// - parameter range: The range in which to retrieve attributes.
    public override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedString.Key : Any] {
        return backingStore.attributes(at: location, effectiveRange: range)
    }

    /// Processes any edits made to the text in the editor.
    override public func processEditing() {
        let backingString = backingStore.string
        let nsRange = backingString.range(from: NSMakeRange(NSMaxRange(editedRange), 0))!
        let indexRange = backingString.lineRange(for: nsRange)
        let extendedRange: NSRange = NSUnionRange(editedRange, backingString.nsRange(from: indexRange))

        applyStyles(extendedRange)
        super.processEditing()
    }

    /// Applies styles to a range on the backingString.
    ///
    /// - parameter range: The range in which to apply styles.
    func applyStyles(_ range: NSRange) {
        guard let theme = self.theme else { return }

        let backingString = backingStore.string
        backingStore.setAttributes(theme.body.attributes, range: range)

        for (style) in theme.styles {
            style.regex.enumerateMatches(in: backingString, options: .withoutAnchoringBounds, range: range, using: { (match, flags, stop) in
                guard let match = match else { return }
                backingStore.addAttributes(style.attributes, range: match.range(at: 0))
            })
        }
    }

    // MARK: - Custom styles

    func applyBold(to range: NSRange) {
        applyFontSymbolicTraitToSelection(.traitBold, to: range)
    }

    func applyItalic(to range: NSRange) {
        applyFontSymbolicTraitToSelection(.traitItalic, to: range)
    }

    private func applyFontSymbolicTraitToSelection(_ trait: UIFontDescriptor.SymbolicTraits, to range: NSRange) {
        guard range.length > 0 else { return }

        enum Operation {
            case add, remove
        }
        var operation: Operation = .remove
        backingStore.enumerateAttribute(.font, in: range, options: []) { (value, range, stop) in
            guard let font = value as? UIFont else { return }

            if !font.fontDescriptor.symbolicTraits.contains(trait) {
                operation = .add
                stop.pointee = true
            }
        }

        self.beginEditing()

        backingStore.enumerateAttribute(.font, in: range, options: []) { (value, range, stop) in
            guard let font = value as? UIFont else { return }

            let fontDesc = font.fontDescriptor
            var newTraits = fontDesc.symbolicTraits
            switch operation {
            case .add: newTraits.update(with: trait)
            case .remove: newTraits.subtract(trait)
            }
            if let fontDesc = fontDesc.withSymbolicTraits(newTraits) {
                let italizedFont = UIFont(descriptor: fontDesc, size: font.pointSize)
                backingStore.addAttribute(.font, value: italizedFont, range: range)
            }
        }

        self.edited(.editedAttributes, range: range, changeInLength: 0)
        self.endEditing()
    }

    func applyUnderline(to range: NSRange) {
        guard range.length > 0 else { return }

        enum Operation {
            case none, add, remove
        }
        var operation: Operation = .none
        backingStore.enumerateAttribute(.underlineStyle, in: range, options: []) { (value, frange, stop) in
            guard let value = value else {
                // no attribute found
                operation = .add
                stop.pointee = true
                return
            }

            guard let iValue = value as? Int else { return }

            let uStyle = NSUnderlineStyle(rawValue: iValue)
            if uStyle.isEmpty {
                operation = .add
                stop.pointee = true
            } else {
                operation = .remove
            }
        }

        self.beginEditing()

        backingStore.enumerateAttribute(.font, in: range, options: []) { (value, frange, stop) in
            switch operation {
            case .add:
                backingStore.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: frange)
            case .remove:
                backingStore.removeAttribute(.underlineStyle, range: frange)
            case .none:
                break
            }
        }

        self.edited(.editedAttributes, range: range, changeInLength: 0)
        self.endEditing()
    }

    func applyLink(_ style: Style, to range: NSRange, font: UIFont) {
        guard case let .link(title, url) = style else { return }

        enum Operation {
            case insert, update
        }
        let operation: Operation = range.length == 0 ? .insert : .update

        if operation == .insert {
            self.beginEditing()

            let linkString = NSMutableAttributedString(string: title)
            let linkRange = NSRange(location: 0, length: linkString.length)
            linkString.addAttributes([.link: url, .font: font], range: linkRange)
            backingStore.insert(linkString, at: range.location)

            let change = linkRange.length
            let changeRange = NSRange(location: range.location, length: changeInLength)
            self.edited([.editedCharacters, .editedAttributes], range: changeRange, changeInLength: change)
            self.endEditing()
        } else {
            let linkString = NSMutableAttributedString(string: title)
            let linkRange = NSRange(location: 0, length: linkString.length)
            linkString.addAttributes([.link: url, .font: font], range: linkRange)
            replaceCharacters(in: range, with: linkString)
        }
    }
}
