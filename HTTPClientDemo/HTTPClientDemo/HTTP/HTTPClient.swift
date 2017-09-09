//
//  HTTPClient.swift
//  HTTPClientDemo
//
//  Created by HJQ on 2017/9/9.
//  Copyright © 2017年 HJQ. All rights reserved.
//

import Foundation
import Alamofire


// MARK: - 自定义Log打印
func JQLog<T>(_ messsage : T, file : String = #file, funcName : String = #function, lineNum : Int = #line) {
    #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        print("\(fileName):(\(lineNum))-\(messsage)")
    #endif
}

typealias success = (_ result: [String: AnyObject])->()
typealias failure = (_ error: Error)->()

// MARK: - 面向协议编程
public protocol Request {
    // 接口
    var path: String { get }
    // 请求方式
    var method: HTTPMethod { get }
    // 请求参数
    var parameters: [String: Any]? { get }
    // 是否显示指示器
    var hud: Bool { get }
    // 自定义头部
    //var headers: [String: String] {get}
    // 服务器的基本地址
    var host: String { get }
}

extension Request {
    var hud: Bool {
        return false
    }
    
    var method: HTTPMethod {
        return HTTPMethod.post
    }
    
    var parameters: [String: Any]? {
        return [:]
    }
}

protocol RequestClient {
    // var host: String { get }
    mutating func send<T: Request>(_ r: T, success:@escaping success, failure:@escaping failure)
    mutating func upload<T: Request>(_ r: T, success:@escaping success, failure:@escaping failure)
}


// MARK: - 网络请求相关
public struct HTTPClient: RequestClient {

    // 创建单例
    static var sharedInstance: HTTPClient =  HTTPClient()

    mutating func send<T>(_ r: T, success: @escaping success, failure: @escaping failure) where T : Request {
        if r.hud {}
        
        // 2.自定义头部
        let headers: HTTPHeaders = [
            "Accept": "application/json"
        ]
        
        JQLog("请求链接:\(r.host + r.path)")
        JQLog("请求参数:\( r.parameters ?? [:] )")
        
        sessionManager.request(r.host + r.path, method: r.method, parameters: r.parameters, headers: headers).downloadProgress(queue: DispatchQueue.global(qos: .utility)) { progress in
            print("Progress: \(progress.fractionCompleted)")
            
            }
            .validate { request, response, data in
                return .success
            }
            .responseJSON { response in
                switch response.result{
                case .success(_):
                    if let value = response.result.value as? [String: AnyObject] {
                        success(value)
                    }
                case .failure(let error):
                    failure(error)
                }
        }
    }


    // 图片上传
    mutating func upload<T>(_ r: T, success: @escaping success, failure: @escaping failure) where T : Request {
        if r.hud {
            
        }
        // 2.自定义头部
        let headers: HTTPHeaders = [
            "Accept": "application/json",
            "content-type":"multipart/form-data"
        ]
        
        JQLog("请求链接:\(r.host + r.path)")
        JQLog("请求参数:\( r.parameters ?? [:] )")
        
        // 3.发送网络请求
        sessionManager.upload( multipartFormData: { multipartFormData in
            // 图片数据绑定
            for (key, value) in r.parameters! {
                if (value as AnyObject).isKind(of: UIImage.self) {
                    let fileName = key + ".jpg"
                    multipartFormData.append(UIImageJPEGRepresentation(value as! UIImage, 0.5)!, withName: key , fileName: fileName, mimeType: "image/jpeg")
                }else {
                    assert(value is String)
                    let utf8Value = (value as AnyObject).data(using: String.Encoding.utf8.rawValue)!
                    multipartFormData.append(utf8Value, withName: key )
                }
            }
        },to: r.host + r.path, headers: headers, encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    if let value = response.result.value as? [String: AnyObject]{
                        success(value)
                    }
                }
            case .failure(let error):
                failure(error)
                break
            }
        })
    }
    
    // MARK: - lazy load
    private lazy var sessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        // 设置请求超时时间
        configuration.timeoutIntervalForRequest = 15
        let manager = Alamofire.SessionManager(configuration: configuration)
        return manager
    }()
    
}
