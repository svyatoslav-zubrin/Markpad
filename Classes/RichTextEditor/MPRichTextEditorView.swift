//
//  MPRichTextEditorView.swift
//  Markpad
//
//  Created by Slava Zubrin on 2/17/20.
//

import UIKit
import SnapKit

public class MPRichTextEditorView: UIView {

    // MARK: - Private props

    private var toolbarItems = [ToolbarItem]()
    private var styles: MPVisualStylesConfiguration?

    // MARK: - View structure

    private lazy var toolbarContainer: UIView = {
        let v = UIView()
        v.layer.borderWidth = Constants.Layout.borderWidth
        v.layer.cornerRadius = Constants.Layout.cornerRadius
        v.layer.borderColor = UIColor.gray.cgColor
        return v
    }()

    private lazy var toolbarStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.alignment = .leading
        sv.distribution = .fill
        return sv
    }()

    private lazy var textViewContainer: UIView = {
        let v = UIView()
        v.layer.borderWidth = Constants.Layout.borderWidth
        v.layer.cornerRadius = Constants.Layout.cornerRadius
        v.layer.borderColor = UIColor.gray.cgColor
        return v
    }()

    private let textView = MPTextView()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        construct()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        construct()
    }


    // MARK: - Public

    public enum ToolbarItem: Equatable {

        case button(type: Style)
        case separator

        public static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (.button(let lType), .button(let rType)): return lType == rType
            case (.separator, .separator): return true
            default: return false
            }
        }
    }

    public func configure(toolbarItems items: [ToolbarItem], styleConfig: MPVisualStylesConfiguration) {
        // text view
        styles = styleConfig
        textView.font = styleConfig.baseStyle.font
        textView.textColor = styleConfig.baseStyle.color
        textView.delegate = self

        // toolbar
        guard toolbarItems != items else { return }

        toolbarItems.removeAll()
        toolbarStackView.arrangedSubviews.forEach { toolbarStackView.removeArrangedSubview($0) }

        toolbarItems.append(contentsOf: items)
        var toolbarViews = [UIView]()
        for item in toolbarItems {
            switch item {
            case .button(let style):
                toolbarViews.append(constructButton(style: style))
            case .separator:
                toolbarViews.append(constructSeparator())
            }
        }

        toolbarViews.forEach { toolbarStackView.addArrangedSubview($0) }
    }

    // MARK: - User actions

    @IBAction func handleToolbarItemTap(_ sender: UIView) {
        guard let index = toolbarStackView.arrangedSubviews.index(of: sender) else { return }
        guard toolbarItems.indices.contains(index) else { return }

        let itemTapped = toolbarItems[index]
        guard case .button(let style) = itemTapped else { return }

        textView.markSelection(withSyle: style)
    }

    // MARK: - Helpers

    private struct Constants {
        struct Layout {
            static let borderWidth: CGFloat = 1
            static let cornerRadius: CGFloat = 8
            static let buttonHeight: CGFloat = 24
            static let separatorWidth: CGFloat = 1
            static let toolbarSpacingX: CGFloat = 4
            static let toolbarMargins: CGFloat = 8
            static let textviewMargins: CGFloat = 8
        }
    }

    private func constructButton(style: Style) -> UIButton {
        let button = UIButton(frame: .zero)
        button.setImage(style.icon, for: .normal)
        button.addTarget(self, action: #selector(handleToolbarItemTap(_:)), for: .touchUpInside)
        button.snp.makeConstraints { (make) in
            make.width.height.equalTo(Constants.Layout.buttonHeight)
        }
        return button
    }

    private func constructSeparator() -> UIView {
        let v = UIView()
        v.backgroundColor = .gray
        v.snp.makeConstraints { (make) in
            make.height.equalTo(Constants.Layout.buttonHeight)
            make.width.equalTo(Constants.Layout.separatorWidth)
        }
        return v
    }

    private func construct() {
        // toolbar
        toolbarContainer.addSubview(toolbarStackView)
        toolbarStackView.translatesAutoresizingMaskIntoConstraints = false
        toolbarStackView.snp.makeConstraints { (make) in
            make.top.leading.equalToSuperview().offset(Constants.Layout.toolbarMargins)
            make.bottom.trailing.equalToSuperview().offset(-Constants.Layout.toolbarMargins)
        }

        toolbarStackView.spacing = Constants.Layout.toolbarSpacingX

        // text view
        textViewContainer.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.snp.makeConstraints { (make) in
            make.top.leading.equalToSuperview().offset(Constants.Layout.textviewMargins)
            make.bottom.trailing.equalToSuperview().offset(-Constants.Layout.textviewMargins)
        }

        // top
        addSubview(toolbarContainer)
        addSubview(textViewContainer)

        toolbarContainer.translatesAutoresizingMaskIntoConstraints = false
        textViewContainer.translatesAutoresizingMaskIntoConstraints = false

        toolbarContainer.snp.makeConstraints { (make) in
            make.top.leading.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
            make.bottom.equalTo(textViewContainer.snp.top).offset(-Constants.Layout.toolbarSpacingX)
        }

        textViewContainer.snp.makeConstraints { (make) in
            make.bottom.leading.trailing.equalToSuperview()
        }
    }
}

// MARK: - UITextViewDelegate

extension MPRichTextEditorView: UITextViewDelegate {

    public func textViewDidChangeSelection(_ textView: UITextView) {
        toolbarButton(for: .bold)?.isHighlighted = false
        toolbarButton(for: .italic)?.isHighlighted = false
        toolbarButton(for: .underline)?.isHighlighted = false
//        toolbarButton(for: .bold)?.tintColor = .gray
//        toolbarButton(for: .italic)?.tintColor = .gray

        if textView.selectedRange.length == 0 {
            // bold & italic
            var traits: UIFontDescriptorSymbolicTraits = []
            if textView.typingAttributes.keys.contains(NSAttributedString.Key.font.rawValue),
                let font = textView.typingAttributes[NSAttributedString.Key.font.rawValue] as? UIFont {
                traits = font.fontDescriptor.symbolicTraits

                toolbarButton(for: .bold)?.isHighlighted = traits.contains(.traitBold)
                toolbarButton(for: .italic)?.isHighlighted = traits.contains(.traitItalic)
//                toolbarButton(for: .bold)?.tintColor = .systemBlue
//                toolbarButton(for: .italic)?.tintColor = .systemBlue
            }
            // underline
            if textView.typingAttributes.keys.contains(NSAttributedString.Key.underlineStyle.rawValue),
                let styleValue = textView.typingAttributes[NSAttributedString.Key.underlineStyle.rawValue] as? Int,
                let style = NSUnderlineStyle(rawValue: styleValue) {
                toolbarButton(for: .underline)?.isHighlighted = style != .styleNone
            }

            print("traits: \(traits)")
        } else {
            print("will handle selected logic later")
        }
    }

    private func toolbarButton(for style: Style) -> UIButton? {
        let toolbarButtons = toolbarItems.filter { $0 != .separator }

        guard !toolbarButtons.isEmpty else { return nil }
        guard let index = toolbarItems.index(of: .button(type: style)) else { return nil }
        guard toolbarStackView.arrangedSubviews.indices.contains(index) else { return nil }

        return toolbarStackView.arrangedSubviews[index] as? UIButton
    }
}
