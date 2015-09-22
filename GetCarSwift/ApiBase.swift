//
//  ApiBase.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/2.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import Haneke

let apiManager = Manager.sharedInstance
let apiCache = Shared.GKResultCache

let API_DEBUG = true

protocol GaikeApi {
    var domain: String { get }
    var path: String { get set }
    func getHeader(upload: Bool) -> [String:String]
    func api(urlString: String, body: [String:AnyObject], completion: GKResult -> Void)
    func upload(urlString: String, datas: [String:NSData], completion: GKResult -> Void)
}

extension GaikeApi {
    var domain: String {
        return "http://api.gaikit.com:8901/"
    }

    var path: String {
        return ""
    }

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
        
        return headers
    }

    func api(urlString: String, body: [String:AnyObject], completion: GKResult -> Void) {
        let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: domain + path + urlString)!)
        mutableURLRequest.HTTPMethod = "POST"
        for (headerField, headerValue) in getHeader() {
            mutableURLRequest.setValue(headerValue, forHTTPHeaderField: headerField)
        }
        do {
            try mutableURLRequest.HTTPBody = JSON(body).rawData()
        } catch {
            if API_DEBUG {print("url request error: \(mutableURLRequest.description)")}
        }

        apiManager.request(mutableURLRequest).responseGK {(req, res, gkResult) in
            if gkResult.msg == "user need login" || gkResult.msg == "token empty" {
                logout()
                return
            }
            completion(gkResult)
        }
    }

    func upload(urlString: String, datas: [String:NSData], completion: GKResult -> Void) {
        let urlRequest = urlRequestWithComponents(domain + path + urlString, headers: getHeader(), imageData: datas)

        Alamofire.upload(urlRequest.0, data: urlRequest.1).responseGK {(req, res, gkResult) in
            completion(gkResult)
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

extension Request {
    func responseGK(completionHandler: (NSURLRequest?, NSHTTPURLResponse?, GKResult) -> Void) -> Self {
        return response(responseSerializer: Request.dataResponseSerializer()) { res in
            {
                var gkResult = GKResult()
                if let data = res.result.value {
                    if let err = res.result.error {
                        gkResult.error = Error.errorWithCode(-10003, failureReason: "error reason : \(err)")
                    } else {
                        gkResult = GKResult(json: JSON(data: data))
                    }
                    if API_DEBUG {print(NSString(data: data, encoding: NSUTF8StringEncoding))}
                }
                return gkResult
            } ~> { gkResult in
                completionHandler(res.request, res.response, gkResult)
            }
        }
    }
}

extension GKResult: DataConvertible, DataRepresentable {
    public typealias Result = GKResult

    public static func convertFromData(data:NSData) -> Result? {
        let json = SwiftyJSON.JSON(data: data)
        return GKResult(json: json)
    }

    public func asData() -> NSData! {
        return try! self.rawJSON?.rawData()
    }
}

extension Shared {
    public static var GKResultCache : Cache<GKResult> {
        struct Static {
            static let name = "shared-gkresult"
            static let cache = Cache<GKResult>(name: name)
        }
        return Static.cache
    }
}

class GKFetcher : Fetcher<GKResult> {
    let api: GaikeApi
    let method: String
    let body: [String:AnyObject]

    init(api: GaikeApi, method: String, body: [String:AnyObject] = [:]) {
        let urlString = api.domain + api.path + method
        let key = ParameterEncoding.URL.encode(NSMutableURLRequest(URL: NSURL(string: urlString)!), parameters: body).0.URLString
        self.api = api
        self.method = method
        self.body = body
        super.init(key: key)
    }

    override func fetch(failure fail : ((NSError?) -> ()), success succeed : (GKResult.Result) -> ()) {
        api.api(method, body: body) { result in
            if let err = result.error {
                fail(err)
            } else {
                succeed(result)
            }
        }
    }

    override func cancelFetch() {}
}

public struct GKResult {
    var data: SwiftyJSON.JSON?
    var code: Int?
    var msg: String?
    var error: NSError?

    var rawJSON: SwiftyJSON.JSON?

    init(json: SwiftyJSON.JSON) {
        code = json["code"].intValue
        msg = json["msg"].stringValue
        data = json["data"]

        rawJSON = json
    }

    init() {
    }
}