//
//  TestViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/11/5.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    let scoreDir = File(path: "score")

    override func viewDidLoad() {
        super.viewDidLoad()

//        _ = try! _100dir.listFiles().filter { file in
//            if file.getName().hasPrefix("v60") {
//                return true
//            }
//            return false
//            }.map { file in
//            print("file: ----------\(file.getName())")
//            let a = NSKeyedUnarchiver.unarchiveObjectWithFile(file.path) as? Score ?? [:]
//            let b = a.sort { a0, a1 in
//                if a0.0 < a1.0 {
//                    return true
//                }
//                return false
//            }
//            print(b)
//        }

//        _ = try! File.docFile.listFiles().map { file in
//            if file.path.containsString("/100/") || !file.path.containsString("test") {
//                return
//            }
//            print("file: ----------\(file.getName())")
//            let a = NSKeyedUnarchiver.unarchiveObjectWithFile(file.path) as? Score ?? [:]
//            let b = a.sort { a0, a1 in
//                if a0.0 < a1.0 {
//                    return true
//                }
//                return false
//            }
//            print(b)
//        }
    }

    @IBAction func didClick(sender: UIButton) {
        showViewController(R.storyboard.carBar.straightMatch!)
    }

}
