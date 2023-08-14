//
//  UserViewController.swift
//  User
//
//  Created by Ekko on 2023/8/7.
//

import UIKit

class UserViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let label = UILabel()
        label.text = "mine"
        label.backgroundColor = .gray
        label.sizeToFit()
        self.view.addSubview(label)
        label.center = self.view.center
        self.view.backgroundColor = .white
    }
}
