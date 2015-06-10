//
//  CarBarViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/4/11.
//  Copyright (c) 2015年 周斌佳. All rights reserved.
//

import UIKit

class CarBarViewController: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate {
    
    let searchController = UISearchController(searchResultsController: nil)
    
    //@IBOutlet var searchController: UISearchDisplayController!
    var infos = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        loadNewData()

        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        searchController.delegate = self
        searchController.searchBar.tintColor = UIColor.blackColor()
        searchController.searchBar.setBackgroundImage(UIImageWithColor(UIColorFromRGB(0xe2e2e2)), forBarPosition: .Top, barMetrics: .Default)
        tableView.tableHeaderView = searchController.searchBar
    }
    
    func loadNewData() {
        let info0 = ["carbar_test0", "汽车养护技巧四种爱车车身清洗方法", "目前汽车车身清洗大致可分为洗衣粉洗车、洗洁精洗车、洗车液洗车、水蜡洗车、免划痕洗车几种，这里对这几种方法做个简单的比较。", "今天 21:07", "3"]
        let info1 = ["carbar_test1", "大家看一下这种情况修一下要多少钱", "", "今天 13:21", "9"]
        let info2 = ["", "左后轮低速有叽叽的刺耳声是不是刹车盘的问题？", "每次降底车速就有这种声音，是不是需要更换刹车片还是刹车盘，目前小科86000公里了，需要注意些什么？", "3月20日 16:11", "1"]
        
        infos = [info0, info1, info2]
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infos.count + 1
    }

 
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView != self.tableView {
            // TODO: search mode
        }
        
        if indexPath.row == 0 {
            let cell = self.tableView.dequeueReusableCellWithIdentifier("tag")!
            return cell
        }
        var postCell = self.tableView.dequeueReusableCellWithIdentifier("carbar") as! PostCell
        let info = infos.objectAtIndex(indexPath.row - 1) as! [String]
        let iconName = info[0]
        if iconName.characters.count > 0 {
            postCell.icon.image = UIImage(named: iconName)
        } else {
            postCell = self.tableView.dequeueReusableCellWithIdentifier("carbar_noicon") as! PostCell
        }
        postCell.title.text = info[1]
        postCell.message.text = info[2]
        postCell.time.text = info[3]
        postCell.reply.text = info[4]

        return postCell
    }
    
    // TODO: maybe can remove later
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 44
        } else {
            return 120
        }
    }
    
    @IBAction func onMoreAction(sender: UIButton) {
        let tagCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
        UIView.transitionWithView(tagCell!, duration: 0.3, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            let frame = CGRectMake(tagCell!.frame.origin.x, tagCell!.frame.origin.y, tagCell!.frame.width, sender.selected ? 44 : 120)
            tagCell!.frame = frame
            }, completion: {(arg) in
                sender.selected = !sender.selected
        })
    }

    @IBAction func onTagAction(sender: UIButton) {
        for tag in 301...307 {
            let button = self.view.viewWithTag(tag) as? UIButton
            if sender.tag == tag {
                sender.selected = true
            } else {
                button?.selected = false
            }
        }
    }
    
    // MARK: UISearchController Delegate
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
    }
    
    func willPresentSearchController(searchController: UISearchController) {
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
    }

    func willDismissSearchController(searchController: UISearchController) {
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
    }

}
