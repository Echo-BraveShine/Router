//
//  ViewController.swift
//  RouteDemo
//
//  Created by Ekko on 2023/8/7.
//

import UIKit
import ERouter
import User
import Home
import Message

class APPModule: RouteModule {
    static let shared = APPModule("app")
}

class FViewController: UIViewController {
    let bin = RouterBin()
    override func viewDidLoad() {
        super.viewDidLoad()
        APPModule.shared.install()
        UserModule.shared.install()
        HomeModule.shared.install()
        MessageRouter.shared.install()

//        let text = HomeModule.shared.request("user/name?name=abc&age=10", type: [String: Any?].self)
//        text.log()
//        
//        let user = HomeModule.shared.request("user/info?name=abc&age=10", type: [String: Any].self)
//        user.log()
    }
    
    @IBAction func btn1Click(_ sender: UIButton) {
        let id1 = HomeModule.shared.request("home/name/123456?name=abc&age=10", type: [String: Any?].self)
        id1.log()

        let id2 = HomeModule.shared.request("home/name/123456/info?name=abc&age=10", type: [String: Any?].self)
        id2.log()
//
        let id3 = HomeModule.shared.request("home/123456/in?name=abc&age=10", type: [String: Any?].self)
        id3.log()
//
        let id4 = HomeModule.shared.request("home/info/swk/in?age=10", type: [String: Any?].self)
        id4.log()
        
        HomeModule.shared.requestAsync("home/123456?name=abc&age=10", type: [String: Any?].self) { res in
            res?.log()
        }
        HomeModule.shared.requestAsync("home/123456/info?name=abc&age=10", type: [String: Any?].self) { res in
            res?.log()
        }

        let text = HomeModule.shared.request("user/name?name=abc&age=10", type: [String: Any?].self)
        text.log()
    }
    
    @IBAction func btn2Click(_ sender: UIButton) {
        let res = APPModule.shared.request("home/name/info", type: UIViewController.self)
        res.log()
        if let vc = res.data {
            self.present(vc, animated: true)
        }
    }
    
    @IBAction func btn3Click(_ sender: UIButton) {
        APPModule.shared.requestAsync("/home/name/detail", type: UIViewController.self) {[weak self] res in
            res?.log()
            if let vc = res?.data {
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    @IBAction func btn4Click(_ sender: UIButton) {
        let res = APPModule.shared.request("/user/page/info?token=erqwrwe", type: UIViewController.self)
        res.log()
        if let vc = res.data {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func btn5Click(_ sender: UIButton) {
        let res = APPModule.shared.request("message/view", type: UIView.self)
        res.log()
        if let vie = res.data {
            vie.frame = CGRect(x: 0, y: 200, width: 100, height: 100)
            self.view.addSubview(vie)
        }
    }
}

class SViewController: UIViewController {
    let bin = RouterBin()
    override func viewDidLoad() {
        super.viewDidLoad()
        APPModule.shared.register("/name") { data in
            return ResponseData.success("xxxx")
        }.disposed(by: bin)
    }
}
