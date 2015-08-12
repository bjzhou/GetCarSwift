//
//  CarTableViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/11.
//  Copyright © 2015年 &#21608;&#25996;&#20339;. All rights reserved.
//

import UIKit
import MMDrawerController

class CarTableViewController: UITableViewController {

    var json: JSON = JSON([])
    var keys: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.sectionIndexColor = UIColor.blackColor()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let jsonpath = NSBundle.mainBundle().pathForResource("cars", ofType: "json")
            let jsonstr = try! NSData(contentsOfFile: jsonpath!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
            self.json = JSON(data: jsonstr)
            self.keys = Array(self.json.dictionary!.keys).sort()
            
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        })
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return keys.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return json[keys[section]].count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("car_no", forIndexPath: indexPath)

        let icon = cell.viewWithTag(501) as! UIImageView
        let title = cell.viewWithTag(502) as! UILabel
        
        let titleText = Array(json[keys[indexPath.section]].dictionary!.keys).sort()[indexPath.row]
        icon.image = UIImage(named: titleText+"logo")
        title.text = titleText

        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return keys[section]
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return keys
    }
    
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return keys.indexOf(title)!
    }
    
//    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let label = UILabel(frame: CGRectMake(20, 8, 20, 20))
//        label.text = alphabet[section]
//        label.font = UIFont.systemFontOfSize(14)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }

}
