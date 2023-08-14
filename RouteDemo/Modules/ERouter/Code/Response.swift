//
//  Response.swift
//  Router
//
//  Created by Ekko on 2023/8/9.
//

import Foundation

enum ResponseCode: Int {
    /// 请求成功
    case success = 200
    /// 请求失败
    case failure = 500
    /// 请求未找到 路径错误
    case notfound = 404
    /// 请求与响应数据类型错误
    case type = 1000
}

/// 请求的响应
public class Response {
    /// 响应码
    public var code: Int
    /// 响应信息
    public var message: String
    public required init(code: Int, message: String) {
        self.code = code
        self.message = message
    }
    public static func success(message: String? = nil) -> Self {
        return self.init(code: ResponseCode.success.rawValue, message: message ?? "success")
    }
    public static func failure(message: String? = nil) -> Self {
        return self.init(code: ResponseCode.failure.rawValue, message: message ?? "failure")
    }
    public static func notfound(message: String? = nil) -> Self {
        return self.init(code: ResponseCode.notfound.rawValue, message: message ?? "notfound")
    }
    public var isSuccess: Bool {
        return self.code == ResponseCode.success.rawValue
    }
    public var isFailure: Bool {
        return self.code == ResponseCode.failure.rawValue
    }
    public var isNotFound: Bool {
        return self.code == ResponseCode.notfound.rawValue
    }
    public func toJSON() -> [String: Any] {
        return ["code": code,
                "message": message]
    }
    public func log() {
        debugLog(toJSON())
    }
    public func toData<T>() -> ResponseData<T>? {
        return ResponseData<T>.init(code: self.code, message: self.message)
    }
}

/// 附带数据的响应
public class ResponseData<T>: Response {
    public var data: T?
    public init(code: Int, message: String, data: T?) {
        super.init(code: code, message: message)
        self.data = data
    }
    public required init(code: Int, message: String) {
        super.init(code: code, message: message)
    }
    public static func success(_ data: T) -> Self {
        let res = Self.success()
        res.data = data
        return res
    }
    public static func success(_ message: String, _ data: T) -> Self {
        let res = Self.success(message: message)
        res.data = data
        return res
    }
    public static func failure(_ data: T) -> Self {
        let res = Self.failure()
        res.data = data
        return res
    }
    public static func failure(_ message: String, _ data: T) -> Self {
        let res = Self.failure(message: message)
        res.data = data
        return res
    }
    public override func toJSON() -> [String: Any] {
        var json = super.toJSON()
        json["data"] = data
        return json
    }
    public override func toData<F>() -> ResponseData<F>? {
        if let dts = self.data as? F {
            return ResponseData<F>.init(code: self.code, message: self.message, data: dts)
        }
        return ResponseData<F>.init(code: ResponseCode.type.rawValue, message: "类型错误 回执类型为\(T.self) 接收类型为\(F.self)")
    }
}
