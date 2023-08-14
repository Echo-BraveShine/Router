//
//  HomeRouter.swift
//  Home
//
//  Created by Ekko on 2023/8/7.
//

import Foundation
import ERouter


public class HomeModule: RouteModule {
    
    let bin = RouterBin()
    
    static var token: String?// = "12345677"
    
    public static let shared: HomeModule = HomeModule()
    
    init() {
        super.init("home")
        register("/name") { data in
            return ResponseData<String>.success("name")
        }.disposed(by: bin)
        register("/name/info") { data in
            let vc = HomeViewController()
            vc.text = "info"
            return ResponseData<HomeViewController>.success(vc)
        }.disposed(by: bin)
        
        registerAsync("/name/detail") { data, res in
            let vc = HomeViewController()
            vc.text = "detail"
            res?(ResponseData<UIViewController>.success(vc))
        }.disposed(by: bin)
        
        register("/name/:id") { data in
            return ResponseData.success(data)
        }.disposed(by: bin)
        registerAsync("/:id/info") { data,res in
            res?(ResponseData.success(data))
        }.disposed(by: bin)
        
        register("/:id") { data in
            return ResponseData.success(data)
        }.disposed(by: bin)
        
        register("/:id/in") { data in
            return ResponseData.success(data)
        }.disposed(by: bin)
        
        
        
        registerAsync("/:id") { data, res in
            res?(ResponseData.success(data))
        }.disposed(by: bin)
        
        register("info/:name") { data in
            return ResponseData.success(data)
        }.disposed(by: bin)
        register("info/:name/in") { data in
            return ResponseData.success(data)
        }.disposed(by: bin)
        
        self.add(HomeInterceptor())
    }
}


struct HomeInterceptor: RequestInterceptor {
    func interceptor(_ request: inout RTRequestData) {
        if let token = HomeModule.token {
            request.parameters["token"] = token
        }
    }
    
}
