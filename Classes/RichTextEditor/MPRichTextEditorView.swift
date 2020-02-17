//
//  MPRichTextEditorView.swift
//  Markpad
//
//  Created by Slava Zubrin on 2/17/20.
//

import UIKit
import SnapKit

class MPRichTextEditorView: UIView {

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

    private lazy var boldButton: UIButton = {
        let bundle = Bundle(for: MPRichTextEditorView.self)
        let image = UIImage(named: "icon_bold", in: bundle, compatibleWith: nil)!

        let button = UIButton(frame: .zero)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(boldTapped), for: .touchUpInside)
        return button
    }()

    private lazy var italicButton: UIButton = {
        let bundle = Bundle(for: MPRichTextEditorView.self)
        let image = UIImage(named: "icon_italic", in: bundle, compatibleWith: nil)!

        let button = UIButton(frame: .zero)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(italicTapped), for: .touchUpInside)
        return button
    }()

    private lazy var textViewContainer: UIView = {
        let v = UIView()
        v.layer.borderWidth = Constants.Layout.borderWidth
        v.layer.cornerRadius = Constants.Layout.cornerRadius
        v.layer.borderColor = UIColor.gray.cgColor
        return v
    }()

    private let textView = UITextView()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        construct()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        construct()
    }

    private struct Constants {
        struct Layout {
            static let borderWidth: CGFloat = 1
            static let cornerRadius: CGFloat = 8
            static let buttonHeight: CGFloat = 24
            static let toolbarSpacingX: CGFloat = 4
            static let toolbarMargins: CGFloat = 8
            static let textviewMargins: CGFloat = 8
        }
    }

    private func construct() {
        // buttons
        let buttons = [boldButton, italicButton]
        for button in buttons {
            button.translatesAutoresizingMaskIntoConstraints = false
            button.snp.makeConstraints { (make) in
                make.width.height.equalTo(Constants.Layout.buttonHeight)
            }
            toolbarStackView.addArrangedSubview(button)
        }

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
            make.bottom.equalTo(textViewContainer.snp.top)
        }

        textViewContainer.snp.makeConstraints { (make) in
            make.bottom.leading.trailing.equalToSuperview()
        }
    }

    // MARK: - User actions

    @IBAction func boldTapped() {
        print("Bold")
    }

    @IBAction func italicTapped() {
        print("Italic")
    }
}
