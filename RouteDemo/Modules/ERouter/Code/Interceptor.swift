//
//  Interceptor.swift
//  Router
//
//  Created by Ekko on 2023/8/9.
//

import Foundation

public protocol RequestInterceptor {
    /// 请求拦截器
    /// - Parameter request: 请求数据 （可在拦截过程中修改）
    func interceptor(_ request: inout RTRequestData)
}

public protocol ResponseInterceptor {
    /// 响应拦截器
    /// - Parameters:
    ///   - path: 路径
    ///   - parameters: 参数 （可在拦截过程中修改）
    /// - Returns: 返回值有值，则流程中断 直接返回
    func interceptor(path: String, parameters: inout [String: Any?]) -> Response?
}
