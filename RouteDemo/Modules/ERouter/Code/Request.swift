//
//  Request.swift
//  Router
//
//  Created by Ekko on 2023/8/9.
//

import Foundation

public struct RTRequestData {
    /// 指向模块
    public var module: RouteModule
    /// 路径
    public var subPath: String?
    /// 参数
    public var parameters: [String: Any?]
}

struct RTRequest {
    let url: String
    var parameters: [String: Any?] = [:]
    private(set) var path: String = ""
    init(_ url: String, parameters: [String: Any?]? = nil) {
        self.url = url
        parameters?.forEach { key, value in
            self.parameters[key] = value
        }
        /// 解析url中的参数
        if let url = URL.init(string: url) {
            if let queryItems = URLComponents(string: url.absoluteString)?.queryItems {
                queryItems.forEach({ item in
                    self.parameters[item.name] = item.value
                })
            }
            if #available(iOS 16.0, *) {
                self.path = url.path()
            } else {
                self.path = url.path
            }
        }
        debugLog(url)
        debugLog(parameters ?? [:])
    }
    /// 拆分路径
    /// - Returns: 路径
    func pathComponents() -> [String] {
        return self.path.components(separatedBy: "/").filter {!$0.isEmpty}
    }
    /// 组装请求参数
    /// - Returns: 请求参数
    func parser() -> RTRequestData? {
        let paths = self.pathComponents()
        if let moduleName = paths.first, let module = Router.module(for: moduleName) {
            let subPath = paths[1..<paths.count].joined(separator: "/")
            let data = RTRequestData.init(module: module, subPath: subPath, parameters: self.parameters)
            return data
        }
        return nil
    }
}
