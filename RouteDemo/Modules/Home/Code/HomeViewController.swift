//
//  HomeViewController.swift
//  Home
//
//  Created by Ekko on 2023/8/7.
//

import UIKit
import ERouter

class HomeViewController: UIViewController {
    var text: String?
    
    let bin = RouterBin()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let label = UILabel()
        label.text = text ?? "home"
        label.backgroundColor = .gray
        label.sizeToFit()
        self.view.addSubview(label)
        label.center = self.view.center
        self.view.backgroundColor = .white
    }
    func name(_ data: [String: Any?]) -> Response {
        print(data)
        return Response.success()
    }
    func infoData(_ data: [String: Any?]) -> Response {
        return Response.success()
    }
    
    deinit{
        print(self)
        print("home deinit")
    }
    override var description: String {
        return "HomeViewController: \(text ?? "home")"
    }
}
