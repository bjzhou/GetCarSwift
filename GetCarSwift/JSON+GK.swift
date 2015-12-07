//
//  JSON+GK.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/13.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation
import SwiftyJSON

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
