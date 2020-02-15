//
//  SettingsViewController.swift
//  Swifty Proteins
//
//  Created by Nikolay Zhurba on 14.02.2020.
//  Copyright © 2020 mzhurba. All rights reserved.
//

import UIKit

protocol SettingsViewControllerDelegate: AnyObject {
    func showHydrogens()
    func hideHydrogens()
    func makeDarkBackground()
    func makeLightBackground()
}

class SettingsViewController: UIViewController {

    // MARK: IBOutlets

    @IBOutlet weak var showHydrogensSwitcher: UISwitch!
    @IBOutlet weak var darkBackgroundSwitcher: UISwitch!
    
    // MARK: Public properties

    weak var delegate: SettingsViewControllerDelegate?

    // MARK: Private properties

    private var shouldShowHydrogens = false
    private var shouldHaveDarkBackground = false

    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        showHydrogensSwitcher.isOn = shouldShowHydrogens
        darkBackgroundSwitcher.isOn = shouldHaveDarkBackground
    }

    // MARK: Public functions

    func configure(shouldShowHydrogens: Bool, shouldHaveDarkBackground: Bool) {
        self.shouldShowHydrogens = shouldShowHydrogens
        self.shouldHaveDarkBackground = shouldHaveDarkBackground
    }

    // MARK: IBActions
    
    @IBAction private func closeButtomTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func hydrogensSwitcherChangedValue(_ sender: UISwitch) {
        switch sender.isOn {
        case true:
            delegate?.showHydrogens()
        case false:
            delegate?.hideHydrogens()
        }
    }

    @IBAction private func darkBackgroundSwitcherChangedValue(_ sender: UISwitch) {
        switch sender.isOn {
        case true:
            delegate?.makeDarkBackground()
        case false:
            delegate?.makeLightBackground()
        }
    }
}
