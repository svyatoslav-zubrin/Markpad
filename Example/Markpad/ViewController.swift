//
//  ViewController.swift
//  Markpad
//
//  Created by svyatoslav-zubrin on 02/15/2020.
//  Copyright (c) 2020 svyatoslav-zubrin. All rights reserved.
//

import UIKit
import Markpad

class ViewController: UIViewController {

    @IBOutlet private weak var richTextEditor: MPRichTextEditorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let items: [MPRichTextEditorView.ToolbarItem] = [
            .button(type: .bold),
            .button(type: .italic),
            .button(type: .underline),
            .separator,
            .button(type: .numberedList),
            .button(type: .bulletList),
            .separator,
            .button(type: .link)
        ]

        let textColor = UIColor(red: 74/256, green: 74/256, blue: 74/256, alpha: 1)
        let baseStyle = MPVisualStyle(fontName: "Avenir-Medium",
                                      fontSize: 20,
                                      color: textColor,
                                      traits: [])
        let config = MPVisualStylesConfiguration(baseStyle: baseStyle)

        richTextEditor.configure(toolbarItems: items, styleConfig: config)
    }
}

