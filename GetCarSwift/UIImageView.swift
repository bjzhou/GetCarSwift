//
//  UIImageView.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/30.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation
import Haneke

extension UIImageView {
    func hnk_setImageFromKey(key: String, placeholder : UIImage? = nil, format : Format<UIImage>? = nil, failure fail : ((NSError?) -> ())? = nil, success succeed : ((UIImage) -> ())? = nil) {
        if let placeholder = placeholder {
            self.image = placeholder
        }


        if let format = format {
            imageCache.addFormat(format)
        }

        var animated = false
        imageCache.fetch(key: key, formatName: format?.name ?? HanekeGlobals.Cache.OriginalFormatName, failure: {[weak self] error in
            if let _ = self {
                fail?(error)
            }
            }) { [weak self] image in
                if let strongSelf = self {
                    strongSelf.hnk_setImage(image, animated:animated, success:succeed)
                }
        }
        animated = true
    }

    func setAvatarImage() {
        if let avatarUrl = DataKeeper.sharedInstance.avatarUrl {
            self.hnk_setImageFromURL(NSURL(string: avatarUrl)!, failure: {_ in
                self.image = UIImage(named: "avatar")
            })
        } else {
            self.image = UIImage(named: NSUserDefaults.standardUserDefaults().integerForKey("sex") == 1 ? "avatar" : "avatar_female")
        }
    }
}