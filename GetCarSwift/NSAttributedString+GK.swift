//
//  NSAttributedString+GK.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/9/4.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation

extension AttributedString {
    class func loadHTMLString(_ string: String) -> AttributedString? {
        if let data = string.data(using: String.Encoding.unicode) {
            return try? AttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
        }
        return nil
    }
}
