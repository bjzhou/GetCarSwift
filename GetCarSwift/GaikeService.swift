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

    func upload<T>(urlString: String, parameters: [String: AnyObject]? = nil, datas: [String: NSData], mimeType: String = "image/png") -> Observable<GKResult<T>> {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        return create { observer in
            var upload: Request?
            Alamofire.upload(.POST, GaikeService.domain + urlString, headers: self.getHeader(), multipartFormData: { data in
                if let parameters = parameters {
                    let jsonParams = try! NSJSONSerialization.dataWithJSONObject(parameters, options: [])
                    data.appendBodyPart(data: jsonParams, name: "content")
                }
                for (key, value) in datas {
                    data.appendBodyPart(data: value, name: key, fileName: key+".png", mimeType: mimeType)
                }
                }) { res in
                    switch res {
                    case .Success(request: let req, streamingFromDisk: _, streamFileURL: _):
                        #if DEBUG
                            print("REQUEST=========================================>")
                            print(req.request?.URLString)
                        #endif
                        upload = req.responseData { res in
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
                    case .Failure(let err):
                        observer.on(.Error(err))
                    }

            }
            return AnonymousDisposable {
                upload?.cancel()
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
}

struct GKResult<U: JSONable> {
    var data: U?
    var dataArray: [U]?
    var code: Int = -1
    var msg: String = "json parse error"

    init(json: SwiftyJSON.JSON) {
        code =? json["code"].int
        msg =? json["msg"].string
        if let raw = json["data"].rawString() where raw != "null" {
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
}

protocol JSONable {
    init(json: SwiftyJSON.JSON)
}
