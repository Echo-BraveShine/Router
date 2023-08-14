//
//  RouteBin.swift
//  Router
//
//  Created by Ekko on 2023/8/9.
//

import Foundation

/// 回收
public class RouteObject {
    let key: String
    weak var module: RouteModule?
    init(key: String, module: RouteModule? = nil) {
        self.key = key
        self.module = module
    }
    /// 保存到垃圾桶
    /// - Parameter bin: 垃圾桶
    public func disposed(by bin: RouterBin) {
        bin.insert(self)
    }
    deinit {
        debugLog("RouteObject:\(self.key) deinit")
    }
}

/// 垃圾桶 垃圾桶销毁，所有保存的响应销毁
public class RouterBin {
    public init() {}
    private var objects: [RouteObject] = []
    /// 插入回收器
    /// - Parameter object: 回收器
    func insert(_ object: RouteObject) {
        objects.append(object)
    }
    /// 清理
    func dispose() {
        objects.forEach { object in
            object.module?.unregister(object.key)
        }
        debugLog("RouterBin deinit")
    }
    deinit {
        dispose()
    }
}
