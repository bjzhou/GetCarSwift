//
//  NSAttributedString+GK.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/9/4.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation

extension NSAttributedString {
    class func loadHTMLString(_ string: String) -> NSAttributedString? {
        if let data = string.data(using: String.Encoding.unicode) {
            return try? NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
        }
        return nil
    }
}
