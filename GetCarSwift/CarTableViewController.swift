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

    let defaultImage = UIImage().scaleImage(size: CGSize(width: 41, height: 41))

    var indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)

    var categeries: [String] = []
    var brands: [String: [String]] = [:]
    var models: [String: [CarInfo]] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.sectionIndexColor = UIColor.blackColor()

        self.sideMenuController()?.sideMenu?.delegate = self
        indicator.center = CGPoint(x: self.view.center.x, y: self.view.center.y - 64)
        indicator.hidesWhenStopped = true
        self.view.addSubview(indicator)

        indicator.startAnimating()

        _ = CarInfo.infoLogo().subscribeNext { (c, b, m) in
            self.categeries = c
            self.brands = b
            self.models = m
            self.tableView.reloadData()
            self.indicator.stopAnimating()
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
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.car_no, forIndexPath: indexPath)

        let titleText = brands[categeries[indexPath.section]]?[indexPath.row] ?? ""
        let imageUrl = models[titleText]?[0].imageUrl ?? ""
        cell?.logoView?.kf_setImageWithURL(NSURL(string: imageUrl)!, placeholderImage: defaultImage)
        cell?.titleLabel?.text = titleText

        return cell!
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
        let navController = self.navigationController as? CarTableNavigationController
        navController?.menuController!.data = models[(brands[categeries[indexPath.section]]?[indexPath.row]) ?? ""] ?? []
        showSideMenuView()
    }

    @IBAction func didNavigationItemCancel(sender: UIBarButtonItem) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }

}

extension CarTableViewController: ENSideMenuDelegate {
    func sideMenuWillClose() {
        if let index = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRowAtIndexPath(index, animated: true)
        }
    }
}
