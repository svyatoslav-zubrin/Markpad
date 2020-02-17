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
        v.layer.borderWidth = 1
        v.layer.cornerRadius = 4
        v.layer.borderColor = UIColor.gray.cgColor

        let sv = self.toolbarStackView
        v.addSubview(sv)
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.snp.makeConstraints { (make) in
            make.top.leading.equalToSuperview().offset(8)
            make.bottom.trailing.equalToSuperview().offset(-8)
        }
        return v
    }()

    private lazy var toolbarStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [self.boldButton, self.italicButton])
        sv.axis = .horizontal
        sv.alignment = .leading
        sv.distribution = .fill
        sv.spacing = 4
        return sv
    }()

    private lazy var boldButton: UIButton = {
        let bundle = Bundle(for: MPRichTextEditorView.self)
        let image = UIImage(named: "icon_bold", in: bundle, compatibleWith: nil)!

        let button = UIButton(frame: .zero)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(boldTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.snp.makeConstraints { (make) in
            make.width.height.equalTo(image.size.height)
        }
        return button
    }()

    private lazy var italicButton: UIButton = {
        let bundle = Bundle(for: MPRichTextEditorView.self)
        let image = UIImage(named: "icon_italic", in: bundle, compatibleWith: nil)!

        let button = UIButton(frame: .zero)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(italicTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.snp.makeConstraints { (make) in
            make.width.height.equalTo(image.size.height)
        }
        return button
    }()

    private lazy var textViewContainer: UIView = {
        let v = UIView()
        v.layer.borderWidth = 1
        v.layer.cornerRadius = 4
        v.layer.borderColor = UIColor.gray.cgColor

        v.addSubview(self.textView)
        self.textView.translatesAutoresizingMaskIntoConstraints = false
        self.textView.snp.makeConstraints { (make) in
            make.top.leading.equalToSuperview().offset(8)
            make.bottom.trailing.equalToSuperview().offset(-8)
        }
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

    private func construct() {
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
