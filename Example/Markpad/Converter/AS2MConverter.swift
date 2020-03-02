//
//  AS2MConverter.swift
//  Markpad_Example
//
//  Created by Slava Zubrin on 3/2/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit


enum AS2MConverterError: Error {
    case general
}

/// Simple attributted string to markdown converter
struct AS2MConverter {
    func convert(_ string: NSAttributedString) -> Result<String, AS2MConverterError> {
        return .success(string.markdowned(for: .bold).markdowned(for: .italic).string)
    }
}

// MARK: - Extensions

extension NSAttributedString {

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

    // Helpers

    func stringByTrimmingCharacters(from charSet: CharacterSet) -> NSAttributedString {
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
