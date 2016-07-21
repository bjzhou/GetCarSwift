//
//  RealmHelper.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/12/14.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation
import RealmSwift

let gRealm: Realm? = {
    do {
        return try Realm()
    } catch(let err) {
        RmLog.e("Realm init Error: \(err)")
        return nil
    }
}()

extension Realm {
    func writeOptional(_ closure: () -> Void) {
        do {
            try self.write(block: closure)
        } catch(let err) {
            RmLog.e("Realm write Error: \(err)")
        }
    }
}
