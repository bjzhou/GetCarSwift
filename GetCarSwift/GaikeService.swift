//
//  ApiBase.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/2.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation
import Alamofire
import Haneke
import RxSwift
import SwiftyJSON

let apiManager = Manager.sharedInstance

let API_DEBUG = true

class GaikeService {
    static let sharedInstance = GaikeService()
    static let domain = "http://api.gaikit.com:8901/"

    func getHeader(upload: Bool = false) -> [String:String] {
        var headers: [String:String] = [:]

        headers["Ass-apiver"] = "1.0"
        headers["Ass-appver"] = VERSION_SHORT
        headers["Ass-accesskey"] = ""
        headers["Ass-contentmd5"] = ""
        headers["Ass-signature"] = ""
        headers["Ass-time"] = String(NSDate().timeIntervalSince1970)
        headers["Ass-token"] = DataKeeper.sharedInstance.token ?? ""
        headers["Ass-packagename"] = NSBundle.mainBundle().bundleIdentifier
        headers["Ass-lati"] = String(DataKeeper.sharedInstance.location?.coordinate.latitude ?? 0)
        headers["Ass-longti"] = String(DataKeeper.sharedInstance.location?.coordinate.longitude ?? 0)

        if API_DEBUG {
            print("HEADER=========================================> \(headers)")
        }

        return headers
    }

    func generateURLRequest(urlString: String, body: [String:AnyObject]) -> NSMutableURLRequest {
        let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: GaikeService.domain + urlString)!)
        mutableURLRequest.HTTPMethod = "POST"
        for (headerField, headerValue) in self.getHeader() {
            mutableURLRequest.setValue(headerValue, forHTTPHeaderField: headerField)
        }
        mutableURLRequest.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(body, options: [])

        if API_DEBUG {
            print("REQUEST=========================================> \(mutableURLRequest.URLString)")
        }

        return mutableURLRequest
    }

    func api<T>(urlString: String, body: [String:AnyObject] = [:]) -> Observable<GKResult<T>> {
        return create { observer in
            let request = apiManager.request(self.generateURLRequest(urlString, body: body)).responseData { res in
                if let err = res.result.error {
                    observer.on(.Error(err))
                    print("ERROR=========================================> \(err)")
                } else {
                    if let data = res.result.value {
                        let gkResult = GKResult<T>(json: SwiftyJSON.JSON(data: data))
                        if gkResult.msg == "user need login" || gkResult.msg == "token empty" {
                            logout()
                        } else {
                            observer.on(.Next(gkResult))
                        }
                        if API_DEBUG {
                            let responseString = String(data: data, encoding: NSUTF8StringEncoding) ?? ""
                            print("RESPONSE=========================================> \(responseString)")
                        }
                    }
                    observer.on(.Completed)
                }
            }
            return AnonymousDisposable {
                request.cancel()
            }
        }
    }

    func upload<T>(urlString: String, datas: [String:NSData]) -> Observable<GKResult<T>> {
        return create { observer in
            let urlRequest = self.urlRequestWithComponents(GaikeService.domain + urlString, headers: self.getHeader(), imageData: datas)

            let upload = Alamofire.upload(urlRequest.0, data: urlRequest.1).responseData { res in
                if let err = res.result.error {
                    observer.on(.Error(err))
                } else {
                    if let data = res.result.value {
                        let gkResult = GKResult<T>(json: SwiftyJSON.JSON(data: data))
                        if gkResult.msg == "user need login" || gkResult.msg == "token empty" {
                            logout()
                        } else {
                            observer.on(.Next(gkResult))
                        }
                    }
                    observer.on(.Completed)
                }
            }
            return AnonymousDisposable {
                upload.cancel()
            }
        }
    }

    func cache<T>(urlString: String, body: [String:AnyObject] = [:]) -> Observable<GKResult<T>> {
        return create { observer in
            Shared.dataCache.fetch(fetcher: GKFetcher(method: urlString, body: body)).onFailure { err in
                if let err = err {
                    observer.on(.Error(err))
                }
                }.onSuccess { data in
                    let gkResult = GKResult<T>(json: SwiftyJSON.JSON(data: data))
                    if gkResult.msg == "user need login" || gkResult.msg == "token empty" {
                        logout()
                    } else {
                        observer.on(.Next(gkResult))
                    }
                    observer.on(.Completed)
            }
            return AnonymousDisposable {
            }
        }
    }

    func urlRequestWithComponents(urlString:String, headers: [String:String]? = nil, imageData: [String:NSData]) -> (URLRequestConvertible, NSData) {

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
        let uploadData = NSMutableData()

        // add image
        uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        for (key, data) in imageData {
            uploadData.appendData("Content-Disposition: form-data; name=\(key); filename=\(key).png\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            uploadData.appendData("Content-Type: image/png\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            uploadData.appendData(data)
        }
        uploadData.appendData("\r\n--\(boundaryConstant)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)

        // return URLRequestConvertible and NSData
        return (Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0, uploadData)
    }
}

class GKFetcher : Fetcher<NSData> {
    let method: String
    let body: [String:AnyObject]

    init(method: String, body: [String:AnyObject] = [:]) {
        let urlString = GaikeService.domain + method
        let key = ParameterEncoding.URL.encode(NSMutableURLRequest(URL: NSURL(string: urlString)!), parameters: body).0.URLString
        self.method = method
        self.body = body
        super.init(key: key)
    }

    override func fetch(failure fail : ((NSError?) -> ()), success succeed : (NSData.Result) -> ()) {
        apiManager.request(GaikeService.sharedInstance.generateURLRequest(method, body: body)).responseData { res in
            if let err = res.result.error {
                fail(err)
            } else {
                if let data = res.result.value {
                    succeed(data)
                    if API_DEBUG {
                        let responseString = String(data: data, encoding: NSUTF8StringEncoding) ?? ""
                        print("RESPONSE=========================================> \(responseString)")
                    }
                }
            }
        }
    }

    override func cancelFetch() {}
}

struct GKResult<U: JSONable> {
    var data: U?
    var dataArray : [U]?
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