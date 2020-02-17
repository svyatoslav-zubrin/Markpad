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

        richTextEditor.configure(toolbarItems: [
            .button(type: .bold),
            .button(type: .italic),
            .button(type: .underline),
            .separator,
            .button(type: .numberedList),
            .button(type: .bulletList),
            .separator,
            .button(type: .link)
        ])
    }

}

