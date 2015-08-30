//
//  UploadApi.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/30.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation

class UploadApi {
    static let PREFIX = "upload/"

    class func uploadHeader(image: UIImage, completion: GKResult -> Void) {
        upload(PREFIX + "uploadHeader", datas: ["pictures":UIImagePNGRepresentation(image)!], completion: completion)
    }
}