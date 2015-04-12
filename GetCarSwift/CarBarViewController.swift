//
//  CarBarViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/4/11.
//  Copyright (c) 2015年 周斌佳. All rights reserved.
//

import UIKit

class CarBarViewController: UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var infos = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        loadNewData()
    }
    
    func loadNewData() {
        var info0 = ["carbar_test0", "汽车养护技巧四种爱车车身清洗方法", "目前汽车车身清洗大致可分为洗衣粉洗车、洗洁精洗车、洗车液洗车、水蜡洗车、免划痕洗车几种，这里对这几种方法做个简单的比较。", "今天 21:07", "3"]
        var info1 = ["carbar_test1", "大家看一下这种情况修一下要多少钱", "", "今天 13:21", "9"]
        var info2 = ["", "左后轮低速有叽叽的刺耳声是不是刹车盘的问题？", "每次降底车速就有这种声音，是不是需要更换刹车片还是刹车盘，目前小科86000公里了，需要注意些什么？", "3月20日 16:11", "1"]
        
        infos = [info0, info1, info2]
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infos.count
    }

 
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView != self.tableView {
            // TODO: search mode
        }
        var cell: PostCell
        let info = infos.objectAtIndex(indexPath.row) as! [String]
        let iconName = info[0]
        if count(iconName) <= 0 {
            cell = self.tableView.dequeueReusableCellWithIdentifier("carbar_noicon") as! PostCell
        } else {
            cell = self.tableView.dequeueReusableCellWithIdentifier("carbar") as! PostCell
            cell.icon.image = UIImage(named: iconName)
        }
        
        cell.title.text = info[1]
        cell.message.text = info[2]
        cell.time.text = info[3]
        cell.reply.text = info[4]

        return cell
    }
    
    // TODO: maybe can remove later
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
