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
            //            .separator,
            //            .button(type: .numberList),
            //            .button(type: .bulletList),
            .separator,
            .button(type: .link)
        ]
        rte.toolbarItems = items
    }
}

