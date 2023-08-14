//
//  RouteModule.swift
//  Router
//
//  Created by Ekko on 2023/8/9.
//

import Foundation

func debugLog(_ data: Any) {
    if Router.isDebugLog != true {
        return
    }
    print("route print: \(data)")
}

public typealias RouteSyncCall = (([String: Any?]) -> (Response?))

public typealias RouteAsyncCallResponse = ((Response?) -> Void)

public typealias RouteAsyncCall = (([String: Any?], RouteAsyncCallResponse?) -> Void)

open class RouteModule {
    public var moduleName: String
    /// 模块名
    private var map: [String: RouteSyncCall]  = [:]
    /// 异步模块
    private var asyncMap: [String: RouteAsyncCall]  = [:]
    /// 请求拦截器
    private var requestInterceptor: [RequestInterceptor] = []
    /// 响应拦截器
    private var responseInterceptor: [ResponseInterceptor] = []
    public init(_ moduleName: String) {
        self.moduleName = moduleName
    }
    /// 安装模块
    public func install() {
        Router.register(moduleName, module: self)
    }
    /// 卸载模块
    public func uninstall() {
        Router.unregister(moduleName)
    }
}

// MARK: - 模块注册
extension RouteModule {
    /// 添加请求拦截器
    /// - Parameter interceptor: 请求拦截器
    public func add(_ interceptor: RequestInterceptor) {
        self.requestInterceptor.append(interceptor)
    }
    /// 添加响应拦截器
    /// - Parameter interceptor: 响应拦截器
    public func add(_ interceptor: ResponseInterceptor) {
        self.responseInterceptor.append(interceptor)
    }
    /// 获取路径实际的模块key
    /// - Parameter text: 路径
    /// - Returns: 模块key
    private func analysis(_ text: String) -> String {
        return text.components(separatedBy: "/").filter {!$0.isEmpty}.joined(separator: "_")
    }
    private func unanalysis(_ text: String) -> String {
        return text.components(separatedBy: "_").filter {!$0.isEmpty}.joined(separator: "/")
    }
    @discardableResult
    /// 注册路径
    /// - Parameters:
    ///   - name: 路径名
    ///   - call: 执行函数
    /// - Returns: 回收器
    public func register(_ name: String, call: @escaping RouteSyncCall) -> RouteObject {
        let key = analysis(name)
        if self.map[key] == nil {
            self.map[key] = call
        } else {
            debugLog("相同名称(\(name))的path已经注册，请勿重复添加")
        }
        let obj = RouteObject.init(key: key, module: self)
        return obj
    }
    @discardableResult
    /// 注册异步路径
    /// - Parameters:
    ///   - name: 路径名
    ///   - call: 执行函数
    /// - Returns: 回收器
    public func registerAsync(_ name: String, call: @escaping RouteAsyncCall) -> RouteObject {
        let key = analysis(name)
        if self.asyncMap[key] == nil {
            self.asyncMap[key] = call
        } else {
            debugLog("相同名称(\(name))的async path已经注册，请勿重复添加")
        }
        let obj = RouteObject.init(key: key, module: self)
        return obj
    }
    /// 卸载注册的路径
    /// - Parameter name: 路径名
    public func unregister(_ name: String) {
        let key = analysis(name)
        self.map[key] = nil
        self.asyncMap[key] = nil
    }
}

// MARK: - 模块响应
extension RouteModule {
    /// 响应器生效
    /// - Parameters:
    ///   - path: 路径
    ///   - parameters: 参数
    /// - Returns: 拦截器的回执
    private func responseInterceptor(path: String, parameters: inout [String: Any?]) -> Response? {
        for interceptor in self.responseInterceptor {
            if let res = interceptor.interceptor(path: path, parameters: &parameters) {
                return res
            }
            break
        }
        return nil
    }
    /// 响应
    /// - Parameters:
    ///   - path: 请求路径
    ///   - parameters: 请求参数
    /// - Returns: 结果
    private func callSub(path: String, parameters: [String: Any?]) -> Response? {
        var resParameters = parameters
        if let res = responseInterceptor(path: path, parameters: &resParameters) {
            return res
        }
        let key = analysis(path)
        var call = map[key]
        if call == nil {
            call = self.regular(with: key, parameters: &resParameters)
        }
        return call?(resParameters)
    }
    /// 异步响应
    /// - Parameters:
    ///   - path: 请求路径
    ///   - parameters: 请求参数
    ///   - response: 结果
    private func callSubAsync(path: String, parameters: [String: Any?], response: RouteAsyncCallResponse? = nil) {
        var resParameters = parameters
        if let res = responseInterceptor(path: path, parameters: &resParameters) {
            response?(res)
            return
        }
        let key = analysis(path)
        if let call = asyncMap[key] {
            call(resParameters, response)
        } else if let call = self.regularAsync(with: key, parameters: &resParameters) {
            call(resParameters, response)
        } else {
            response?(nil)
        }
    }
    private func regular(with key: String, parameters: inout [String: Any?]) -> RouteSyncCall? {
        if let value = regularKey(key: key, keys: Array(self.map.keys)) {
            value.1.forEach { vkey, val in
                parameters[vkey] = val
            }
            return self.map[value.0]
        }
        return nil
    }
    private func regularAsync(with key: String, parameters: inout [String: Any?]) -> RouteAsyncCall? {
        if let value = regularKey(key: key, keys: Array(self.asyncMap.keys)) {
            value.1.forEach { vkey, val in
                parameters[vkey] = val
            }
            return self.asyncMap[value.0]
        }
        return nil
    }
    private func regularKey(key: String, keys: [String]) -> (String, [String: String])? {
        for mapKey in keys.filter({$0.contains(":")}) {
            if let path = mapKey.components(separatedBy: "_").first(where: {$0.first == ":"}) {
                // 将占位符替换为正则表达式捕获组
                let regexPattern = mapKey.replacingOccurrences(of: path, with: "([^_]+)(?:_)?")
                if let regex = try? NSRegularExpression(pattern: regexPattern),
                   let match = regex.firstMatch(in: key, options: [], range: NSRange(location: 0, length: key.count)),
                   let range = Range(match.range(at: 1), in: key) {
                    let value = String(key[range])
                    let pkey = path.replacingOccurrences(of: ":", with: "")
                    let newkey = mapKey.replacingOccurrences(of: path, with: value)
                    if newkey == key {
                        return (mapKey, [pkey: value])
                    }
                }
            }
        }
        return nil
    }
}

// MARK: - 模块请求
extension RouteModule {
    /// 拦截器生效
    /// - Parameter data: 原始需要拦截数据
    /// - Returns: 拦截操作后的数据
    private func requestInterceptor(data: RTRequestData) -> RTRequestData {
        var reqData: RTRequestData = data
        requestInterceptor.forEach { interceptor in
            interceptor.interceptor(&reqData)
        }
        return reqData
    }
    /// 请求
    /// - Parameter data: 请求数据
    /// - Returns: 回执
    private func call(data: RTRequestData) -> Response? {
        let reqData = self.requestInterceptor(data: data)
        if let subPath = reqData.subPath,
           let res = reqData.module.callSub(path: subPath, parameters: reqData.parameters) {
            return res
        }
        return nil
    }
    /// 异步请求
    /// - Parameters:
    ///   - data: 请求数据
    ///   - response: 结果
    private func callAsync(data: RTRequestData, response: RouteAsyncCallResponse? = nil) {
        let reqData = self.requestInterceptor(data: data)
        if let subPath = reqData.subPath {
            reqData.module.callSubAsync(path: subPath, parameters: reqData.parameters) { dts in
                response?(dts)
            }
        } else {
            response?(nil)
        }
    }
    @discardableResult
    /// 请求
    /// - Parameters:
    ///   - path: 路径
    ///   - parameter: 参数
    /// - Returns: 结果
    public func request(_ path: String, parameter: [String: Any]? = nil) -> Response {
        if let data = self.parser(path, parameter: parameter),
           let res = self.call(data: data) {
            return res
        }
        return Response.notfound()
    }
    /// 指定返回类型的请求
    /// - Parameters:
    ///   - path: 路径
    ///   - parameter: 参数
    ///   - type: 类型
    /// - Returns: 结果
    public func request<T>(_ path: String, parameter: [String: Any]? = nil, type: T.Type) -> ResponseData<T> {
        if let data = self.parser(path, parameter: parameter),
           let res = self.call(data: data)?.toData() as? ResponseData<T> {
            return res
        }
        return ResponseData.notfound()
    }
    /// 异步请求
    /// - Parameters:
    ///   - path: 路径
    ///   - parameter: 参数
    ///   - response: 结果
    public func requestAsync(_ path: String, parameter: [String: Any]? = nil, response: RouteAsyncCallResponse? = nil) {
        if let data = self.parser(path, parameter: parameter) {
            self.callAsync(data: data) { res in
                response?(res ?? .notfound())
            }
        } else {
            response?(Response.notfound())
        }
    }
    /// 指定返回类型的异步请求
    /// - Parameters:
    ///   - path: 路径
    ///   - parameter: 参数
    ///   - type: 类型
    ///   - response: 结果
    public func requestAsync<T>(_ path: String,
                                parameter: [String: Any]? = nil,
                                type: T.Type,
                                response: ((ResponseData<T>?) -> Void)? = nil) {
        if let data = self.parser(path, parameter: parameter) {
            self.callAsync(data: data) { res in
                response?(res?.toData() as? ResponseData<T> ?? .notfound())
            }
        } else {
            response?(ResponseData.notfound())
        }
    }
    /// 组装request
    /// - Parameters:
    ///   - path: 路径
    ///   - parameter: 参数
    /// - Returns: request
    private func getRequest(_ path: String, parameter: [String: Any]? = nil) -> RTRequest {
        let url = Router.domain + path
        let request = RTRequest(url, parameters: parameter)
        return request
    }
    /// 根据请求组装数据
    /// - Parameters:
    ///   - path: 路径
    ///   - parameter: 参数
    /// - Returns: 请求数据
    private func parser(_ path: String, parameter: [String: Any]? = nil) -> RTRequestData? {
        let request = self.getRequest(path, parameter: parameter)
        return request.parser()
    }
}
