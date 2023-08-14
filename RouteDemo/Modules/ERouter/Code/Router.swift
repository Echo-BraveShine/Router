//
//  Router.swift
//  Router
//
//  Created by Ekko on 2023/8/7.
//

import Foundation

/// 根路由
public class Router {
    private(set) static var domain: String = "app://myapp.com/"
    /// 是否支持log
    public static var isDebugLog: Bool = true
    private static var moduleMap: [String: RouteModule] = [:]
    /// 设置域名
    /// - Parameter domain: 域名
    public static func setup(_ domain: String) {
        self.domain = domain
    }
    /// 子模块添加
    /// - Parameters:
    ///   - name: 子模块名
    ///   - module: 子模块
    static func register(_ name: String, module: RouteModule) {
        if self.module(for: name) != nil {
            debugLog("相同名称(\(name))的module已经注册，请勿重复添加")
        } else {
            self.moduleMap[name] = module
        }
    }
    /// 卸载子模块
    /// - Parameter name: 模块名
    static func unregister(_ name: String) {
        self.moduleMap[name] = nil
    }
    /// 根据模块名获取模块
    /// - Parameter name: 模块名
    /// - Returns: 模块
    static func module(for name: String) -> RouteModule? {
        return self.moduleMap[name]
    }
}
