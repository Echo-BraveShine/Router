# Router Swift 路由器

### 安装
```ruby
pod 'ERouter'
```
### 自定义一个module
``` swift
class HomeModule: RouteModule {
    static let shared = HomeModule("home")
}
```
### 基础设置(可跳过)
```swift
/// 设置域名 用于拼接请求 默认为app://myapp.com/
Router.setup("myapp://app.com")
/// 开启log (默认开启)
Router.isDebugLog = true
```
### 模块安装
```swift
HomeModule.shared.install()
```
### 模块内注册响应
```swift
public class HomeModule: RouteModule {
    
    let bin = RouterBin()
    
    static var token: String? = "12345677"
    
    public static let shared: HomeModule = HomeModule()

    init() {
        super.init("home")
        /// 注册同步响应
        register("/name") { data in
            return ResponseData<String>.success("name")
        }.disposed(by: bin)
        register("/name/info") { data in
            let vc = HomeViewController()
            vc.text = "info"
            return ResponseData<HomeViewController>.success(vc)
        }.disposed(by: bin)
        /// 注册异步响应
        registerAsync("/name/detail") { data, res in
            let vc = HomeViewController()
            vc.text = "detail"
            res?(ResponseData<UIViewController>.success(vc))
        }.disposed(by: bin)
    }
}
```
### 模块调用
```swift
/// 同步调用
let text = HomeModule.shared.request("user/name?name=abc&age=10", type: [String: Any?].self)
let res = HomeModule.shared.request("home/name/info", type: UIViewController.self)
/// 异步调用
HomeModule.shared.requestAsync("home/name/detail", type: UIViewController.self) {[weak self] res in
    res?.log()
    if let vc = res?.data {
        self?.present(vc, animated: true)
    }
}
```
### 使用路径参数
```swift
/// 注册
register("/name/:id") { data in
    return ResponseData<String>.success("name")
}.disposed(by: bin)

registerAsync("/:id") { data, res in
    res?(ResponseData.success(data))
}.disposed(by: bin)
/// 调用
HomeModule.shared.request("home/name/123456?name=abc&age=10", type: String.self)

HomeModule.shared.requestAsync("home/123456?name=abc&age=10", type: [String: Any?].self) { res in
    res?.log()
}
```
### 拦截器 Interceptor(RequestInterceptor,ResponseInterceptor)
```swift
/// 添加请求拦截器
self.add(HomeInterceptor())
/// 请求拦截器实现
struct HomeInterceptor: RequestInterceptor {
    func interceptor(_ request: inout RTRequestData) {
        if let token = HomeModule.token {
            request.parameters["token"] = token
        }
    }

}
```
```swift
/// 添加响应拦截器
self.add(UserInterceptor())
/// 响应拦截器实现
struct UserInterceptor: ResponseInterceptor {
    func interceptor(path: String, parameters: inout [String : Any?]) -> Response? {
        if parameters["token"] == nil  {
            return Response.failure(message: "请求错误 缺失token")
        }
        return nil
    }
}
```
