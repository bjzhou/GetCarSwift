//
//  CarTableViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/11.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit

class CarTableViewController: UITableViewController {

    var json: JSON = JSON([])
    var keys: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.sectionIndexColor = UIColor.blackColor()
        
        CarApi.info().responseGKJSON { (req, res, result) in
            guard let json = result.json else {
                return
            }
            self.json = json
            self.keys = self.json.sortedDictionaryKeys() ?? []
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return keys.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return json.sortedDictionaryValue(section)!.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("car_no", forIndexPath: indexPath)

        let icon = cell.viewWithTag(501) as! UIImageView
        let title = cell.viewWithTag(502) as! UILabel
        
        let titleText = json.sortedDictionaryValue(indexPath.section)!.sortedDictionaryKeys()![indexPath.row]//Array(json[keys[indexPath.section]].dictionary!.keys).sort()[indexPath.row]
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let navController = self.navigationController as! CarTableNavigationController
        navController.menuController!.data = json.sortedDictionaryValue(indexPath.section)!.sortedDictionaryValue(indexPath.row)!.arrayObject as! [String]
        showSideMenuView()
    }

    @IBAction func didNavigationItemCancel(sender: UIBarButtonItem) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
