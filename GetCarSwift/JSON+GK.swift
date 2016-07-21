//
//  JSON+GK.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/13.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation
import SwiftyJSON

extension JSON: JSONable {
    func sortedDictionaryKeys() -> [String]? {
        if self.type == .dictionary {
            var arr = Array(self.dictionary!.keys)
            arr.sort()
            return arr
        }
        return nil
    }
    func sortedDictionaryValue(_ withIndex: Int) -> JSON? {
        if self.type == .dictionary {
            if let keys = sortedDictionaryKeys() {
                return self[keys[withIndex]]
            }
        }
        return nil
    }

    init(json: JSON) {
        self = json
    }
}
