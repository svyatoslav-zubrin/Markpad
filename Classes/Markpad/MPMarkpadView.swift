//
//  MPMarkpadView.swift
//  Markpad
//
//  Created by Slava Zubrin on 2/15/20.
//

import UIKit

public class MPMarkpadView: UIView {

    @IBOutlet private weak var view: UIView!
    @IBOutlet private weak var toolbarContainer: UIView!
    @IBOutlet private weak var textViewContainer: UIView!
    @IBOutlet private weak var textView: MPTextView!

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromNib()
    }

    override public func awakeFromNib() {
        super.awakeFromNib()

    }

    // MARK: - Nib loadings

    private func loadFromNib() {
        Bundle(for: MPMarkpadView.self).loadNibNamed("MPMarkpadView", owner: self, options: nil)
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        setupLayout()
    }

    private func setupLayout() {
        let bindings: [String: UIView] = ["view": view]
        var constraints = [NSLayoutConstraint]()
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
                                                      options: [],
                                                      metrics: nil,
                                                      views: bindings)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|",
                                                      options: [],
                                                      metrics: nil,
                                                      views: bindings)
        NSLayoutConstraint.activate(constraints)
    }
}
