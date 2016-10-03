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

let apiManager = Alamofire.SessionManager.default
let operationQueue = OperationQueue()
let operationScheduler = OperationQueueScheduler(operationQueue: operationQueue)

class GaikeService {
    static let sharedInstance = GaikeService()

#if DEBUG
    static let domain = "http://api.gaikit.com:8911/"
#else
    static let domain = "http://api.gaikit.com/"
#endif

    func getHeader(_ upload: Bool = false) -> [String:String] {
        var headers: [String:String] = [:]

//        headers["Ass-apiver"] = "1.0"
//        headers["Ass-appver"] = versionShort
//        headers["Ass-accesskey"] = ""
//        headers["Ass-contentmd5"] = ""
//        headers["Ass-signature"] = ""
//        headers["Ass-time"] = String(NSDate().timeIntervalSince1970)
//        headers["Ass-packagename"] = NSBundle.mainBundle().bundleIdentifier
        headers["Ass-token"] = Mine.sharedInstance.token ?? ""
        headers["Ass-lati"] = String(DeviceDataService.sharedInstance.rxLocation.value?.coordinate.latitude ?? 0)
        headers["Ass-longti"] = String(DeviceDataService.sharedInstance.rxLocation.value?.coordinate.longitude ?? 0)

        RmLog.i("http header: \(headers)")

        return headers
    }

    func request(_ urlString: URLConvertible) -> Observable<Data> {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        return Observable.create { observer in
            RmLog.i("http request data: \(urlString)")
            let request = apiManager.request(urlString).responseData { res in
                let responseString = String(data: res.data!, encoding: String.Encoding.utf8) ?? ""
                RmLog.i("http response data: \(responseString), error: \(res.result.error)")
                if let err = res.result.error {
                    observer.on(.error(err))
                } else {
                    if let data = res.result.value {
                        observer.onNext(data)
                    }
                    observer.on(.completed)
                }

            }
            return Disposables.create {
                request.cancel()
            }
            }.observeOn(MainScheduler.instance).do { _ in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }

    func api<T>(_ urlString: String, body: [String:String] = [:]) -> Observable<GKResult<T>> {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        return Observable.create { observer in
            let request = apiManager.request(GaikeService.domain + urlString, method: .post, parameters: body, encoding: JSONEncoding.default, headers: self.getHeader()).responseData { res in
                let responseString = String(data: res.data!, encoding: String.Encoding.utf8) ?? ""
                RmLog.i("http response: \(responseString)")
                if let err = res.result.error {
                    observer.on(.error(err))
                } else {
                    if let data = res.result.value {
                        observer.onNext(data)
                    }
                    observer.on(.completed)
                }
            }
            RmLog.i("http request: \(request.request?.url?.absoluteString) \(body)")
            return Disposables.create {
                request.cancel()
            }
            }.observeOn(operationScheduler).map { (data: Data) in
                return self.parseJSON(data)
            }.observeOn(MainScheduler.instance).do { _ in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }

    func upload<T>(_ urlString: String, parameters: [String: String]? = nil, datas: [String: Data], mimeType: String = "image/png") -> Observable<GKResult<T>> {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        return Observable.create { observer in
            var upload: Request?
            Alamofire.upload(multipartFormData: { data in
                if let parameters = parameters, let jsonParams = try? JSONSerialization.data(withJSONObject: parameters, options: []) {
                    data.append(jsonParams, withName: "content")
                }
                for (key, value) in datas {
                    data.append(value, withName: key, fileName: key+".png", mimeType: mimeType)
                }
                }, to: GaikeService.domain + urlString, method: .post, headers: self.getHeader()) { res in
                    switch res {
                    case .success(request: let req, streamingFromDisk: _, streamFileURL: _):
                        RmLog.i("http request upload: \(req.request?.url?.absoluteString), \(parameters), data keys: \(datas.keys.joined(separator: ","))")
                        upload = req.responseData { res in
                            let responseString = String(data: res.data!, encoding: String.Encoding.utf8) ?? ""
                            RmLog.i("http response upload: \(responseString)")
                            if let err = res.result.error {
                                observer.on(.error(err))
                            } else {
                                if let data = res.result.value {
                                    observer.on(.next(data))
                                }
                                observer.on(.completed)
                            }
                        }
                    case .failure(let err):
                        observer.on(.error(err))
                    }

            }
            return Disposables.create {
                upload?.cancel()
            }
            }.observeOn(operationScheduler).map { (data: Data) in
                return self.parseJSON(data as Data)
            }.observeOn(MainScheduler.instance).do { _ in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }

    private func parseJSON<T>(_ data: Data) -> GKResult<T> {
        let gkResult = GKResult<T>(json: JSON(data: data))
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

    init(json: JSON) {
        code =? json["code"].int
        msg =? json["msg"].string
        if let raw = json["data"].rawString(), raw != "null" {
            if json["data"].type == SwiftyJSON.Type.array {
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
    init(json: JSON)
}
