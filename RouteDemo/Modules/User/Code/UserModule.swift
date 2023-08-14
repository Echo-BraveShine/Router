//
//  UserRouter.swift
//  User
//
//  Created by Ekko on 2023/8/7.
//

import Foundation
import ERouter


public class UserModule: RouteModule {
            
    public static let shared: UserModule = UserModule()
    let bin = RouterBin()
    init(){
        super.init("user")

        register("name") { data in
            return ResponseData<[String: Any?]>.success(data)
        }.disposed(by: bin)
        register("info") { data in
            return ResponseData<[String: Any]>.success(User().toJSON())
        }.disposed(by: bin)
        register("page/info") { data in
            return ResponseData.success(UserViewController())
        }.disposed(by: bin)
        self.add(HomeInterceptor())
    }
}

struct HomeInterceptor: ResponseInterceptor {
    func interceptor(path: String, parameters: inout [String : Any?]) -> Response? {
        if parameters["token"] == nil  {
            return Response.failure(message: "请求错误 缺失token")
        }
        return nil
    }
}
