//
//  ViewController.swift
//  Markpad
//
//  Created by svyatoslav-zubrin on 02/15/2020.
//  Copyright (c) 2020 svyatoslav-zubrin. All rights reserved.
//

import UIKit
import Markpad
import SnapKit

class ViewController: UIViewController {

    @IBOutlet private weak var richTextEditorContainer: UIView!
    private weak var richTextEditor: MPRichTextEditorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let textColor = UIColor(red: 74/256, green: 74/256, blue: 74/256, alpha: 1)
        let content = MPContentConfig(fontName: "Avenir-Medium",
                                      fontSize: 20,
                                      color: textColor,
                                      traits: [])
        let interface = MPInterfaceConfig(toolbarIconsColorNormal: .gray,
                                          toolbarIconsColorSelected: .red,
                                          borderColor: .black)
        let geometry = MPGeometryConfig(toolbarItemSize: 24,
                                        toolbarHeight: 40,
                                        toolbarInteritemSpacing: 4,
                                        toolbarCornerRadius: 10,
                                        textViewMargins: 8,
                                        textViewCornerRadius: 10,
                                        toolbarToTextViewMargin: 4)
        let linkPopup = MPLinkPopupConfig(title: "Popup title",
                                          linkNamePlaceholder: "Name placeholder...",
                                          linkURLPlaceholder: "URL placeholder...",
                                          okButtonTitle: "OK",
                                          cancelButtonTitle: "Cancel")
        let config = MPConfiguration(content: content,
                                     interface: interface,
                                     geometry: geometry,
                                     linkPopup: linkPopup)

        let rte = MPRichTextEditorView(frame: .zero, config: config)
        self.richTextEditor = rte

        // layout
        richTextEditorContainer.addSubview(rte)
        rte.translatesAutoresizingMaskIntoConstraints = false
        rte.snp.makeConstraints { (make) in
            make.top.leading.trailing.bottom.equalTo(0)
        }

        let items: [MPRichTextEditorView.ToolbarItem] = [
            .button(type: .bold),
            .button(type: .italic),
            .button(type: .underline),
            .separator,
            .button(type: .link),
            .separator,
        //            .button(type: .numberList),
        //            .button(type: .bulletList)
        ]
        rte.toolbarItems = items
    }

    // MARK: - Attributed String -> Markdown

    @IBAction func convertToMardown() {
        let attrString = richTextEditor.attributedText
        print(attrString.markdowned(for: .bold).markdowned(for: .italic).string)
    }
}

private extension NSAttributedString {

    enum TextStyle {
        case bold, italic

        var trait: UIFontDescriptor.SymbolicTraits {
            switch self {
            case .bold: return .traitBold
            case .italic: return .traitItalic
            }
        }

        var mark: String {
            switch self {
            case .bold: return "**"
            case .italic: return "_"
            }
        }
    }

    func markdowned(for style: TextStyle) -> NSAttributedString {
        let retval = NSMutableAttributedString(attributedString: self)

        // find ranges
        var ranges: [NSRange] = []
        let range = NSRange(location: 0, length: length)
        retval.enumerateAttribute(.font, in: range, options: []) { (value, range, stop) in
            guard range.location != NSNotFound,
                let font = value as? UIFont,
                font.fontDescriptor.symbolicTraits.contains(style.trait) else { return }

            // trim whitespaces (leading & trailing)
            let _attrString = NSMutableAttributedString(attributedString: retval.attributedSubstring(from: range))
            let _trimmedAttrString = _attrString.stringByTrimmingCharacters(from: .whitespacesAndNewlines)

            guard _trimmedAttrString.length > 0 else { return }
            guard let _trimmedAttrStringRange = _attrString.string.range(of: _trimmedAttrString.string) else { return }

            let _trimmedAttrStringNSRange = NSRange(_trimmedAttrStringRange, in: _attrString.string)
            let trimmedRange = NSRange(location: range.location + _trimmedAttrStringNSRange.location,
                                       length: _trimmedAttrStringNSRange.length)
            ranges.append(trimmedRange)
        }

        // catenate ranges
        /*
        ranges.sort(by: { $0.location < $1.location })
        ranges = ranges.reduce([]) { (res, range) -> [NSRange] in
            guard !res.isEmpty else { return [range] }

            var retval = res
            if let lastRange = res.last, let catenatedRange = lastRange.catenated(with: range) {
                retval.removeLast()
                retval.append(catenatedRange)
            } else {
                retval.append(range)
            }
            return retval
        }
        */

        // insert marks
        var shift = 0
        for range in ranges {
            var shiftedRange = range.shifted(by: shift)
            // lower bound
            var attrs = retval.attributes(at: shiftedRange.lowerBound, effectiveRange: nil)
            var adjustedBoldMark = NSAttributedString(string: style.mark, attributes: attrs)
            retval.insert(adjustedBoldMark, at: shiftedRange.lowerBound)
            // upper bound
            shiftedRange = shiftedRange.shifted(by: style.mark.count)
            let upperAttrsLocation = shiftedRange.upperBound > 0 ? shiftedRange.upperBound - 1 : 0
            attrs = retval.attributes(at: upperAttrsLocation, effectiveRange: nil)
            adjustedBoldMark = NSAttributedString(string: style.mark, attributes: attrs)

            retval.insert(adjustedBoldMark, at: shiftedRange.upperBound)
            shift += 2 * style.mark.count
        }

        return retval
    }

    /*
    func markupedUnderlined() -> NSAttributedString {
        let retval = NSMutableAttributedString(attributedString: self)

        // find ranges
        var ranges: [NSRange] = []
        let range = NSRange(location: 0, length: length)
        retval.enumerateAttribute(.underlineStyle, in: range, options: []) { (value, range, stop) in
            guard range.location != NSNotFound,
                let _ = value as? NSUnderlineStyle else { return }

            ranges.append(range)
        }

        // catenate ranges
        ranges.sort(by: { $0.location < $1.location })
        ranges = ranges.reduce([]) { (res, range) -> [NSRange] in
            guard !res.isEmpty else { return [range] }

            var retval = res
            if let lastRange = res.last, let catenatedRange = lastRange.catenated(with: range) {
                retval.removeLast()
                retval.append(catenatedRange)
            } else {
                retval.append(range)
            }
            return retval
        }

        // insert marks
        var shift = 0
        let italicMark = "_"
        for range in ranges {
            var shiftedRange = range.shifted(by: shift)
            // lower bound
            var attrs = retval.attributes(at: shiftedRange.lowerBound, effectiveRange: nil)
            var adjustedItalicMark = NSAttributedString(string: italicMark, attributes: attrs)
            retval.insert(adjustedItalicMark, at: shiftedRange.lowerBound)
            // upper bound
            shiftedRange = shiftedRange.shifted(by: 1)
            let upperAttrsLocation = shiftedRange.upperBound > 0 ? shiftedRange.upperBound - 1 : 0
            attrs = retval.attributes(at: upperAttrsLocation, effectiveRange: nil)
            adjustedItalicMark = NSAttributedString(string: italicMark, attributes: attrs)

            retval.insert(adjustedItalicMark, at: shiftedRange.upperBound)
            shift += 2
        }

        return retval
    }
    */
}

extension NSRange {

    func shifted(by shift: Int) -> NSRange {
        return NSRange(location: location + shift, length: length)
    }

    func catenated(with range: NSRange) -> NSRange? {
        let ranges = [self, range].sorted { $0.location < $1.location }
        guard ranges.first!.upperBound == ranges.last!.lowerBound  else { return nil }
        return NSRange(location: ranges.first!.location, length: ranges.first!.length + ranges.last!.length)
    }
}

extension NSAttributedString {
     public func stringByTrimmingCharacters(from charSet: CharacterSet) -> NSAttributedString {
         let modifiedString = NSMutableAttributedString(attributedString: self)
        modifiedString.trimCharacters(from: charSet)
         return NSAttributedString(attributedString: modifiedString)
     }
}

extension NSMutableAttributedString {
     public func trimCharacters(from charSet: CharacterSet) {
        var range = (string as NSString).rangeOfCharacter(from: charSet as CharacterSet)

         // Trim leading characters from character set.
         while range.length != 0 && range.location == 0 {
            replaceCharacters(in: range, with: "")
            range = (string as NSString).rangeOfCharacter(from: charSet)
         }

         // Trim trailing characters from character set.
        range = (string as NSString).rangeOfCharacter(from: charSet, options: .backwards)
         while range.length != 0 && NSMaxRange(range) == length {
            replaceCharacters(in: range, with: "")
            range = (string as NSString).rangeOfCharacter(from: charSet, options: .backwards)
         }
     }
}
