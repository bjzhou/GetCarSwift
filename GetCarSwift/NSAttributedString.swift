//
//  NSAttributedString.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/9/4.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation

extension NSAttributedString {
    class func loadHTMLString(string: String) -> NSAttributedString? {
        if let data = string.dataUsingEncoding(NSUnicodeStringEncoding) {
            return NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil, error: nil)
        }
        return nil
    }
}