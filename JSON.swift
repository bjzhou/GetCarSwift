//
//  JSON.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/13.
//  Copyright © 2015年 &#21608;&#25996;&#20339;. All rights reserved.
//

import Foundation


extension JSON {
    func sortedDictionaryKeys() -> [String]? {
        if self.type == .Dictionary {
            return Array(self.dictionary!.keys).sort()
        }
        return nil
    }
    func sortedDictionaryValue(withIndex: Int) -> JSON? {
        if self.type == .Dictionary {
            if let keys = sortedDictionaryKeys() {
                return self[keys[withIndex]]
            }
        }
        return nil
    }
}