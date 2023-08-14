//
//  MessageRouter.swift
//  Message
//
//  Created by Ekko on 2023/8/7.
//

import Foundation
import ERouter

public class MessageRouter: RouteModule {
    public static let shared = MessageRouter()
    let bin = RouterBin()
    init() {
        super.init("message")
        register("view") { data in
            return ResponseData.success(MessageView())
        }.disposed(by: bin)
    }
}
