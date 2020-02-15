//
//  AtomViewController.swift
//  Swifty Proteins
//
//  Created by Nikolay Zhurba on 16.02.2020.
//  Copyright © 2020 mzhurba. All rights reserved.
//

import UIKit

class AtomViewController: UIViewController {

    // MARK: IBOulets

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var discoveredByLabel: UILabel!
    @IBOutlet weak var atomicMassLabel: UILabel!
    @IBOutlet weak var electronConfigurationLabel: UILabel!

    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognizer:)))
        view.addGestureRecognizer(tapRecognizer)
        print("viewDidLoad")
    }

    // MARK: Private functions

    @objc private func handleTap(gestureRecognizer: UITapGestureRecognizer) {
      dismiss(animated: true)
    }
}
