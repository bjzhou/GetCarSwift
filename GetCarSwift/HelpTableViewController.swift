//
//  HelpTableViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/12/1.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit

class HelpTableViewController: UITableViewController {

    let telUrl = "tel://15921874027"

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if (indexPath as NSIndexPath).row == 0 {
            let now = Calendar.current.dateComponents([.hour], from: Date())
            if now.hour! >= 8 && now.hour! < 22 {
                let alertController = UIAlertController(title: "联系改客专员", message: nil, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                alertController.addAction(UIAlertAction(title: "呼叫", style: .default, handler: { _ in
                    UIApplication.shared.openURL(URL(string: self.telUrl)!)
                }))
                present(alertController, animated: true, completion: nil)
            }
        }
    }

}
