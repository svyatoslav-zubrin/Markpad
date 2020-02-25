//
//  MPRichTextEditorView.swift
//  Markpad
//
//  Created by Slava Zubrin on 2/17/20.
//

import UIKit
import SnapKit

public enum MPToolbarItemType {
    case bold, italic, underline, bulletList, numberList, link

    internal var icon: UIImage {
        let iconName: String
        switch self {
        case .bold: iconName = "icon_bold"
        case .italic: iconName = "icon_italic"
        case .underline: iconName = "icon_underline"
        case .link: iconName = "icon_link"
        case .bulletList: iconName = "icon_bullet_list"
        case .numberList: iconName = "icon_numbered_list"
        }
        let bundle = Bundle(for: MPRichTextEditorView.self)
        return UIImage(named: iconName, in: bundle, compatibleWith: nil)!
    }
}

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

        case button(type: MPToolbarItemType)
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
            case .button(let type):
                toolbarViews.append(constructButton(of: type))
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
        guard case .button(let type) = itemTapped else { return }

        switch type {
        case .bold:
            textView.markSelection(withStyle: .bold, updateToolbar: { [weak self] in
                self?.updateToolbarButtonsState()
            })

        case .italic:
            textView.markSelection(withStyle: .italic, updateToolbar: { [weak self] in
                self?.updateToolbarButtonsState()
            })

        case .underline:
            textView.markSelection(withStyle: .underline, updateToolbar: { [weak self] in
                self?.updateToolbarButtonsState()
            })

        case .bulletList:
            () // todo:

        case .numberList:
            () // todo

        case .link:
            guard let range = textView.selectedTextRange else { return }
            if range.isEmpty {
                presentLinkPopup()
            } else {
                let text = textView.text(in: range)
                presentLinkPopup(title: text)
            }
        }
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

    private func constructButton(of type: MPToolbarItemType) -> UIButton {
        let button = UIButton(frame: .zero)
        let image = type.icon
        button.setImage(image, for: .normal)
        button.setImage(image.maskWithColor(color: .red), for: .selected)
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

    private func presentLinkPopup(title: String? = nil) {
        let alert = MPIndependentAlert(title: "Link", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Title..."
            textField.text = title
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Link url..."
        }

        let ok = UIAlertAction(title: "OK", style: .default) { [weak self, weak alert] action in
            guard let alert = alert else { return }
            guard let uTitle = alert.textFields?.first?.text, !uTitle.isEmpty else { return }
            guard let urlString = alert.textFields?.last?.text, !urlString.isEmpty else { return }
            guard let url = URL(string: urlString) else { return } // todo: validate URL somehow?

            self?.textView.markSelection(withStyle: .link(title: uTitle, url: url))
        }
        alert.addAction(ok)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
        alert.show()
    }

    private func updateToolbarButtonsState() {
        var itemsToSelect: [MPToolbarItemType] = [.bold, .italic, .underline, .link]
        itemsToSelect.forEach({ toolbarButton(for: $0)?.isSelected = false })

        let selectedRange = textView.selectedRange
        if selectedRange.length == 0 {
            // bold & italic
            if textView.typingAttributes.keys.contains(NSAttributedString.Key.font.rawValue),
                let font = textView.typingAttributes[NSAttributedString.Key.font.rawValue] as? UIFont {
                let traits = font.fontDescriptor.symbolicTraits
                if !traits.contains(.traitBold) { itemsToSelect.removeAll(where: { $0 == .bold }) }
                if !traits.contains(.traitItalic) { itemsToSelect.removeAll(where: { $0 == .italic }) }
            }
            // underline
            if textView.typingAttributes.keys.contains(NSAttributedString.Key.underlineStyle.rawValue),
                let styleValue = textView.typingAttributes[NSAttributedString.Key.underlineStyle.rawValue] as? Int,
                let style = NSUnderlineStyle(rawValue: styleValue) {
                if style == .styleNone { itemsToSelect.removeAll(where: { $0 == .underline }) }
            } else {
                itemsToSelect.removeAll(where: { $0 == .underline })
            }
            // link
            if textView.typingAttributes.keys.contains(NSAttributedString.Key.link.rawValue),
                let _ = textView.typingAttributes[NSAttributedString.Key.link.rawValue] as? URL {
                ()
            } else {
                itemsToSelect.removeAll(where: { $0 == .link })
            }
        } else {
            textView.storage.enumerateAttributes(in: selectedRange, options: []) { (attrs, range, stop) in
                // bold & italic
                if attrs.keys.contains(NSAttributedString.Key.font),
                    let font = attrs[NSAttributedString.Key.font] as? UIFont {
                    let traits = font.fontDescriptor.symbolicTraits
                    if !traits.contains(.traitBold) { itemsToSelect.removeAll(where: { $0 == .bold }) }
                    if !traits.contains(.traitItalic) { itemsToSelect.removeAll(where: { $0 == .italic }) }
                }
                // underline
                if attrs.keys.contains(NSAttributedString.Key.underlineStyle),
                    let styleValue = attrs[NSAttributedString.Key.underlineStyle] as? Int,
                    let style = NSUnderlineStyle(rawValue: styleValue) {
                    if style == .styleNone { itemsToSelect.removeAll(where: { $0 == .underline }) }
                } else {
                    itemsToSelect.removeAll(where: { $0 == .underline })
                }
                // link
                if attrs.keys.contains(NSAttributedString.Key.link) ,
                    let _ = attrs[NSAttributedString.Key.link] as? URL {
                    ()
                } else {
                    itemsToSelect.removeAll(where: { $0 == .link })
                }

                if itemsToSelect.isEmpty { stop.pointee = true }
            }
        }

        itemsToSelect.forEach({ toolbarButton(for: $0)?.isSelected = true })
    }
}

// MARK: - UITextViewDelegate

extension MPRichTextEditorView: UITextViewDelegate {

    public func textViewDidChangeSelection(_ textView: UITextView) {
        updateToolbarButtonsState()
    }

    // Helpers

    private func toolbarButton(for type: MPToolbarItemType) -> UIButton? {
        let toolbarButtons = toolbarItems.filter { $0 != .separator }

        guard !toolbarButtons.isEmpty else { return nil }
        guard let index = toolbarItems.index(of: .button(type: type)) else { return nil }
        guard toolbarStackView.arrangedSubviews.indices.contains(index) else { return nil }

        return toolbarStackView.arrangedSubviews[index] as? UIButton
    }
}
