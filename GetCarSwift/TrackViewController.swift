//
//  TrackViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/9/3.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit

class TrackViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier {
        case .Some("tianhuangping"):
            break
        case .Some("niaoshan"):
            break
        case .Some("sanjiacun"):
            break
        case .Some("tongtiandadao"):
            break
        default:
            break
        }
    }

}
