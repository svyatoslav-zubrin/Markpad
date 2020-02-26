//
//  MPIndependentAlert.swift
//  Markpad
//
//  Created by Slava Zubrin on 2/19/20.
//

import UIKit

class MPIndependentAlert: UIAlertController {

    private lazy var window: UIWindow = {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.windowLevel = UIWindow.Level.alert + 1
        window.backgroundColor = .clear
        window.rootViewController = MPClearViewController()
        return window
    }()

    // MARK: - Public

    func show() {
        guard let rvc = window.rootViewController else { return }

        window.makeKeyAndVisible()
        rvc.present(self, animated: true, completion: nil)
    }
}

private class MPClearViewController: UIViewController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIApplication.shared.statusBarStyle
    }

    override var prefersStatusBarHidden: Bool {
        return UIApplication.shared.isStatusBarHidden
    }
}
