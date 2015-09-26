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

    var carTableViewModel: CarTableViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.sectionIndexColor = UIColor.blackColor()

        carTableViewModel = CarTableViewModel()
        carTableViewModel.fetchCarInfos().subscribeNext {
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return carTableViewModel.categeries.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return carTableViewModel.brands[carTableViewModel.categeries[section]]?.count ?? 0
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("car_no", forIndexPath: indexPath) 

        let icon = cell.viewWithTag(501) as! UIImageView
        let title = cell.viewWithTag(502) as! UILabel

        let titleText = carTableViewModel.brands[carTableViewModel.categeries[indexPath.section]]?[indexPath.row] ?? ""
        icon.image = UIImage(named: titleText+"logo")
        title.text = titleText

        return cell
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return carTableViewModel.categeries[section]
    }

    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return carTableViewModel.categeries
    }

    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return carTableViewModel.categeries.indexOf(title)!
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let navController = self.navigationController as! CarTableNavigationController
        navController.menuController!.data = carTableViewModel.models[(carTableViewModel.brands[carTableViewModel.categeries[indexPath.section]]?[indexPath.row]) ?? ""] ?? []
        showSideMenuView()
    }

    @IBAction func didNavigationItemCancel(sender: UIBarButtonItem) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
