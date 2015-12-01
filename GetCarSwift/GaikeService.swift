//
//  ApiBase.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/2.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import SwiftyJSON

let apiManager = Manager.sharedInstance
let operationQueue = NSOperationQueue()
let operationScheduler = OperationQueueScheduler(operationQueue: operationQueue)

class GaikeService {
    static let sharedInstance = GaikeService()
    static let domain = "http://api.gaikit.com/"

    func getHeader(upload: Bool = false) -> [String:String] {
        var headers: [String:String] = [:]

        headers["Ass-apiver"] = "1.0"
        headers["Ass-appver"] = versionShort
        headers["Ass-accesskey"] = ""
        headers["Ass-contentmd5"] = ""
        headers["Ass-signature"] = ""
        headers["Ass-time"] = String(NSDate().timeIntervalSince1970)
        headers["Ass-token"] = Mine.sharedInstance.token ?? ""
        headers["Ass-packagename"] = NSBundle.mainBundle().bundleIdentifier
        headers["Ass-lati"] = String(DeviceDataService.sharedInstance.rxLocation.value?.coordinate.latitude ?? 0)
        headers["Ass-longti"] = String(DeviceDataService.sharedInstance.rxLocation.value?.coordinate.longitude ?? 0)

        #if DEBUG
            print("HEADER=========================================>")
            print(headers)
        #endif

        return headers
    }

    func generateURLRequest(urlString: String, body: [String:AnyObject]) -> NSMutableURLRequest {
        let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: GaikeService.domain + urlString)!)
        mutableURLRequest.HTTPMethod = "POST"
        for (headerField, headerValue) in self.getHeader() {
            mutableURLRequest.setValue(headerValue, forHTTPHeaderField: headerField)
        }
        mutableURLRequest.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(body, options: [])

        #if DEBUG
            print("REQUEST=========================================>")
            print(mutableURLRequest.URLString)
        #endif

        return mutableURLRequest
    }

    func request(urlString: URLStringConvertible) -> Observable<NSData> {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        return create { observer in
            let request = apiManager.request(.GET, urlString).responseData { res in
                #if DEBUG
                    let responseString = String(data: res.data!, encoding: NSUTF8StringEncoding) ?? ""
                    print("RESPONSE=========================================>")
                    print(responseString)
                #endif
                if let err = res.result.error {
                    observer.on(.Error(err))
                } else {
                    if let data = res.result.value {
                        observer.on(.Next(data))
                    }
                    observer.on(.Completed)
                }
            }
            return AnonymousDisposable {
                request.cancel()
            }
            }.observeOn(MainScheduler.sharedInstance).doOn {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
    }

    func api<T>(urlString: String, body: [String:AnyObject] = [:]) -> Observable<GKResult<T>> {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        return create { observer in
            let request = apiManager.request(self.generateURLRequest(urlString, body: body)).responseData { res in
                #if DEBUG
                    let responseString = String(data: res.data!, encoding: NSUTF8StringEncoding) ?? ""
                    print("RESPONSE=========================================>")
                    print(responseString)
                #endif
                if let err = res.result.error {
                    observer.on(.Error(err))
                } else {
                    if let data = res.result.value {
                        observer.on(.Next(data))
                    }
                    observer.on(.Completed)
                }
            }
            return AnonymousDisposable {
                request.cancel()
            }
            }.observeOn(operationScheduler).map { (data: NSData) in
                return self.parseJSON(data)
            }.observeOn(MainScheduler.sharedInstance).doOn {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
    }

    func upload<T>(urlString: String, parameters: [String: AnyObject]? = nil, datas: [String: NSData]) -> Observable<GKResult<T>> {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        return create { observer in
            let urlRequest = self.urlRequestWithComponents(GaikeService.domain + urlString, headers: self.getHeader(), parameters: parameters, imageData: datas)
            #if DEBUG
                print("REQUEST=========================================>")
                print(urlRequest.0)
            #endif
            let upload = Alamofire.upload(urlRequest.0, data: urlRequest.1).responseData { res in
                #if DEBUG
                    let responseString = String(data: res.data!, encoding: NSUTF8StringEncoding) ?? ""
                    print("RESPONSE=========================================>")
                    print(responseString)
                #endif
                if let err = res.result.error {
                    observer.on(.Error(err))
                } else {
                    if let data = res.result.value {
                        observer.on(.Next(data))
                    }
                    observer.on(.Completed)
                }
            }
            return AnonymousDisposable {
                upload.cancel()
            }
            }.observeOn(operationScheduler).map { (data: NSData) in
                return self.parseJSON(data)
            }.observeOn(MainScheduler.sharedInstance).doOn {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
    }

    private func parseJSON<T>(data: NSData) -> GKResult<T> {
        let gkResult = GKResult<T>(json: SwiftyJSON.JSON(data: data))
        if gkResult.msg == "user need login" || gkResult.msg == "token empty" {
            Mine.sharedInstance.logout()
        }
        return gkResult
    }

    func urlRequestWithComponents(urlString:String, headers: [String:String]? = nil, parameters: [String: AnyObject]? = nil, imageData: [String:NSData]) -> (URLRequestConvertible, NSData) {

        // create url request to send
        let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        mutableURLRequest.HTTPMethod = Alamofire.Method.POST.rawValue
        let boundaryConstant = "myRandomBoundary12345";
        let contentType = "multipart/form-data;boundary="+boundaryConstant
        mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        if let headers = headers {
            for (key, value) in headers {
                mutableURLRequest.setValue(value, forHTTPHeaderField: key)
            }
        }

        // create upload data to send
        var uploadData = ""

        // add image
        for (key, data) in imageData {
            uploadData += "\r\n----\(boundaryConstant)\r\n"
            uploadData += "Content-Disposition: form-data; name=\(key); filename=\(key)\r\n"
            uploadData += "Content-Type: \r\n\r\n"
            uploadData += (String(data: data, encoding: NSUTF8StringEncoding) ?? "") + "\r\n"
        }
        if let parameters = parameters {
            uploadData += "\r\n----\(boundaryConstant)\r\n"
            uploadData += "Content-Disposition: form-data; name=content\r\n\r\n"
            uploadData += String(data: try! NSJSONSerialization.dataWithJSONObject(parameters, options: []), encoding: NSUTF8StringEncoding)!
        }
        uploadData += "\r\n----\(boundaryConstant)\r\n"

        print(uploadData)

        // return URLRequestConvertible and NSData
        return (Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0, uploadData.dataUsingEncoding(NSUTF8StringEncoding)!)
    }
}

//class GKFetcher : Fetcher<NSData> {
//    let method: String
//    let body: [String:AnyObject]
//
//    init(method: String, body: [String:AnyObject] = [:]) {
//        let urlString = GaikeService.domain + method
//        let key = ParameterEncoding.URL.encode(NSMutableURLRequest(URL: NSURL(string: urlString)!), parameters: body).0.URLString
//        self.method = method
//        self.body = body
//        super.init(key: key)
//    }
//
//    override func fetch(failure fail : ((NSError?) -> ()), success succeed : (NSData.Result) -> ()) {
//        apiManager.request(GaikeService.sharedInstance.generateURLRequest(method, body: body)).responseData { res in
//            if let err = res.result.error {
//                fail(err)
//            } else {
//                if let data = res.result.value {
//                    succeed(data)
//                    if API_DEBUG {
//                        let responseString = String(data: data, encoding: NSUTF8StringEncoding) ?? ""
//                        print("RESPONSE=========================================> \(responseString)")
//                    }
//                }
//            }
//        }
//    }
//
//    override func cancelFetch() {}
//}

struct GKResult<U: JSONable> {
    var data: U?
    var dataArray: [U]?
    var code: Int = 0
    var msg: String = ""

    init(json: SwiftyJSON.JSON) {
        code = json["code"].intValue
        msg = json["msg"].stringValue
        if json["data"].type == SwiftyJSON.Type.Array {
            dataArray = []
            for (_, subJson) in json["data"] {
                dataArray?.append(U(json: subJson))
            }
        } else {
            data = U(json: json["data"])
        }
    }
}

protocol JSONable {
    init(json: SwiftyJSON.JSON)
}
