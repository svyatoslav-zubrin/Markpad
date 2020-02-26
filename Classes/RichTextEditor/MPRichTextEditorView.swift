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
        return UIImage(named: iconName, in: Bundle.resourceBundle, compatibleWith: nil)!
    }
}

public class MPRichTextEditorView: UIView {

    // MARK: - Private props

    private let config: MPConfiguration

    // MARK: - View structure

    private lazy var toolbarStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.alignment = .leading
        sv.distribution = .fill
        return sv
    }()
    private let toolbarContainer = UIView()
    private let textViewContainer = UIView()
    private let textView = MPTextView()

    // MARK: - Lifecycle

    private override init(frame: CGRect) {
        fatalError("Component doesn't support initialization without config atm.")
    }

    public init(frame: CGRect, config: MPConfiguration) {
        self.config = config

        super.init(frame: frame)

        constructBaseUI()
        configureBaseUI()
    }

    required init?(coder: NSCoder) {
        fatalError("Component doesn't support initialization from Nib atm.")
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

    private var _toolbarItems = [ToolbarItem]()
    public var toolbarItems: [ToolbarItem] {
        get {
            return _toolbarItems
        }
        set {
            guard newValue != toolbarItems else { return }

            _toolbarItems = newValue
            fillToolbar()
        }
    }

    // MARK: - User actions

    @IBAction func handleToolbarItemTap(_ sender: UIView) {
        guard let index = toolbarStackView.arrangedSubviews.firstIndex(of: sender) else { return }
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

    // Base UI

    private func constructBaseUI() {
        // toolbar
        toolbarContainer.addSubview(toolbarStackView)
        toolbarStackView.translatesAutoresizingMaskIntoConstraints = false
        toolbarStackView.snp.makeConstraints { (make) in
            let margin: CGFloat = (config.geometry.toolbarHeight - config.geometry.toolbarItemSize) / 2
            make.top.leading.equalToSuperview().offset(margin)
            make.bottom.trailing.equalToSuperview().offset(-margin)
        }

        toolbarStackView.spacing = config.geometry.toolbarInteritemSpacing

        // text view
        textViewContainer.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.snp.makeConstraints { (make) in
            make.top.leading.equalToSuperview().offset(config.geometry.textViewMargins) // todo: move to config
            make.bottom.trailing.equalToSuperview().offset(-config.geometry.textViewMargins) // todo: move to config
        }

        // top
        addSubview(toolbarContainer)
        addSubview(textViewContainer)

        toolbarContainer.translatesAutoresizingMaskIntoConstraints = false
        textViewContainer.translatesAutoresizingMaskIntoConstraints = false

        toolbarContainer.snp.makeConstraints { (make) in
            make.height.equalTo(config.geometry.toolbarHeight)
            make.top.leading.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
            make.bottom.equalTo(textViewContainer.snp.top).offset(-config.geometry.toolbarToTextViewMargin)
        }

        textViewContainer.snp.makeConstraints { (make) in
            make.bottom.leading.trailing.equalToSuperview()
        }
    }

    private func configureBaseUI() {
        // containers
        toolbarContainer.layer.borderWidth = 1
        toolbarContainer.layer.borderColor = config.interface.borderColor.cgColor
        toolbarContainer.layer.cornerRadius = config.geometry.textViewCornerRadius

        textViewContainer.layer.borderWidth = 1
        textViewContainer.layer.borderColor = config.interface.borderColor.cgColor
        textViewContainer.layer.cornerRadius = config.geometry.textViewCornerRadius

        // text view
        textView.font = config.content.font
        textView.textColor = config.content.color
        textView.delegate = self
    }

    // Toolbar items

    private struct Constants {
        struct Layout {
            static let borderWidth: CGFloat = 1
            static let separatorWidth: CGFloat = 1
        }
    }

    private func constructButton(of type: MPToolbarItemType, config: MPConfiguration) -> UIButton {
        let button = UIButton(frame: .zero)
        let image = type.icon
        button.setImage(image.maskWithColor(color: config.interface.toolbarIconsColorNormal), for: .normal)
        button.setImage(image.maskWithColor(color: config.interface.toolbarIconsColorSelected), for: .selected)
        button.addTarget(self, action: #selector(handleToolbarItemTap(_:)), for: .touchUpInside)
        button.snp.makeConstraints { (make) in
            make.width.height.equalTo(config.geometry.toolbarItemSize)
        }
        return button
    }

    private func constructSeparator(config: MPConfiguration) -> UIView {
        let v = UIView()
        v.backgroundColor = config.interface.toolbarIconsColorNormal
        v.snp.makeConstraints { (make) in
            make.height.equalTo(config.geometry.toolbarItemSize)
            make.width.equalTo(Constants.Layout.separatorWidth)
        }
        return v
    }

    private func fillToolbar() {
        toolbarStackView.arrangedSubviews.forEach { toolbarStackView.removeArrangedSubview($0) }

        guard !_toolbarItems.isEmpty else { return }

        var toolbarViews = [UIView]()
        for item in _toolbarItems {
            switch item {
            case .button(let type):
                toolbarViews.append(constructButton(of: type, config: config))
            case .separator:
                toolbarViews.append(constructSeparator(config: config))
            }
        }

        toolbarViews.forEach { toolbarStackView.addArrangedSubview($0) }
    }

    private func toolbarButton(for type: MPToolbarItemType) -> UIButton? {
        let toolbarButtons = toolbarItems.filter { $0 != .separator }

        guard !toolbarButtons.isEmpty else { return nil }
        guard let index = toolbarItems.firstIndex(of: .button(type: type)) else { return nil }
        guard toolbarStackView.arrangedSubviews.indices.contains(index) else { return nil }

        return toolbarStackView.arrangedSubviews[index] as? UIButton
    }

    private func updateToolbarButtonsState() {
        var itemsToSelect: [MPToolbarItemType] = [.bold, .italic, .underline, .link]
        itemsToSelect.forEach({ toolbarButton(for: $0)?.isSelected = false })

        let selectedRange = textView.selectedRange
        if selectedRange.length == 0 {
            // bold & italic
            if textView.typingAttributes.keys.contains(.font), let font = textView.typingAttributes[.font] as? UIFont {
                let traits = font.fontDescriptor.symbolicTraits
                if !traits.contains(.traitBold) { itemsToSelect.removeAll(where: { $0 == .bold }) }
                if !traits.contains(.traitItalic) { itemsToSelect.removeAll(where: { $0 == .italic }) }
            }
            // underline
            if textView.typingAttributes.keys.contains(.underlineStyle),
                let styleValue = textView.typingAttributes[.underlineStyle] as? Int {
                let style = NSUnderlineStyle(rawValue: styleValue)
                if style.isEmpty { itemsToSelect.removeAll(where: { $0 == .underline }) }
            } else {
                itemsToSelect.removeAll(where: { $0 == .underline })
            }
            // link
            if textView.typingAttributes.keys.contains(.link), let _ = textView.typingAttributes[.link] as? URL {
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
                    let styleValue = attrs[NSAttributedString.Key.underlineStyle] as? Int {
                    let style = NSUnderlineStyle(rawValue: styleValue)
                    if style.isEmpty { itemsToSelect.removeAll(where: { $0 == .underline }) }
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

    // Link popup

    private func presentLinkPopup(title: String? = nil) {
        let alert = MPIndependentAlert(title: config.linkPopup.title, message: nil, preferredStyle: .alert)
        alert.addTextField { [weak self] (textField) in
            textField.placeholder = self?.config.linkPopup.linkNamePlaceholder ?? "Enter name here..."
            textField.text = title
        }
        alert.addTextField { [weak self] (textField) in
            textField.placeholder = self?.config.linkPopup.linkURLPlaceholder ?? "Enter URL here..."
        }

        let ok = UIAlertAction(title:  config.linkPopup.okButtonTitle, style: .default) { [weak self, weak alert] action in
            guard let alert = alert else { return }
            guard let uTitle = alert.textFields?.first?.text, !uTitle.isEmpty else { return }
            guard let urlString = alert.textFields?.last?.text, !urlString.isEmpty else { return }
            guard let url = URL(string: urlString) else { return } // todo: validate URL somehow?

            self?.textView.markSelection(withStyle: .link(title: uTitle, url: url))
        }
        alert.addAction(ok)
        let cancel = UIAlertAction(title: config.linkPopup.cancelButtonTitle, style: .cancel, handler: nil)
        alert.addAction(cancel)
        alert.show()
    }
}

// MARK: - UITextViewDelegate

extension MPRichTextEditorView: UITextViewDelegate {

    public func textViewDidChangeSelection(_ textView: UITextView) {
        updateToolbarButtonsState()
    }
}
