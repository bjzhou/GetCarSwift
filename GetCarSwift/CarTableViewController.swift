//
//  CarTableViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/11.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit
import SwiftyJSON

class CarTableViewController: UITableViewController {

    var categeries: [String] = []
    var brands: [String: [String]] = [:]
    var models: [String: [String]] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.sectionIndexColor = UIColor.blackColor()

        CarApi.sharedInstance.info() { result in
            guard let json = result.data else {
                return
            }
            {
//                self.categeries = json.sortedDictionaryKeys() ?? []
//                for categery in self.categeries {
//                    self.brands[categery] = json[categery].sortedDictionaryKeys() ?? []
//                    for brand in self.brands[categery]! {
//                        self.models[brand] = json[categery, brand].arrayObject as? [String]
//                    }
//                }

                for i in 0..<json.count {
                    let categery = json[i, "categery"].stringValue
                    let brand = json[i, "brand"].stringValue
                    let model = json[i, "model"].stringValue
                    //let modelId = json[i, "id"].stringValue

                    if self.brands[categery] == nil {
                        self.brands[categery] = []
                    }
                    if self.models[brand] == nil {
                        self.models[brand] = []
                    }

                    if !self.categeries.contains(categery) {
                        self.categeries.append(categery)
                    }
                    if !self.brands[categery]!.contains(brand) {
                        self.brands[categery]!.append(brand)
                    }
                    self.models[brand]!.append(model)
                }
                } ~> {
                    self.tableView.reloadData()
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return categeries.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return brands[categeries[section]]?.count ?? 0
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("car_no", forIndexPath: indexPath) 

        let icon = cell.viewWithTag(501) as! UIImageView
        let title = cell.viewWithTag(502) as! UILabel

        let titleText = brands[categeries[indexPath.section]]?[indexPath.row] ?? ""
        icon.image = UIImage(named: titleText+"logo")
        title.text = titleText

        return cell
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return categeries[section]
    }

    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return categeries
    }

    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return categeries.indexOf(title)!
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let navController = self.navigationController as! CarTableNavigationController
        navController.menuController!.data = models[(brands[categeries[indexPath.section]]?[indexPath.row]) ?? ""] ?? []
        showSideMenuView()
    }

    @IBAction func didNavigationItemCancel(sender: UIBarButtonItem) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
