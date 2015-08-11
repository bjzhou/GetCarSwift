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
    
    let alphabet = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.sectionIndexColor = UIColor.blackColor()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return alphabet.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("car_no", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    
//    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return tableView.sectionHeaderHeight
//    }
//    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return alphabet[section]
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return alphabet
    }
    
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return alphabet.indexOf(title)!
    }
    
//    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let label = UILabel(frame: CGRectMake(20, 8, 20, 20))
//        label.text = alphabet[section]
//        label.font = UIFont.systemFontOfSize(14)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }

}
