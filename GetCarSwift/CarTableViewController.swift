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

    var indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)

    var categeries: [String] = []
    var brands: [String: [String]] = [:]
    var models: [String: [CarInfo]] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.sectionIndexColor = UIColor.black

        self.sideMenuController()?.sideMenu?.delegate = self
        indicator.center = CGPoint(x: self.view.center.x, y: self.view.center.y - 64)
        indicator.hidesWhenStopped = true
        self.view.addSubview(indicator)

        indicator.startAnimating()

        _ = CarInfo.infoLogo().subscribe(onNext: { (c, b, m) in
            self.categeries = c
            self.brands = b
            self.models = m
            self.tableView.reloadData()
            self.indicator.stopAnimating()
        })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return categeries.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return brands[categeries[section]]?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.car_no, for: indexPath)

        let titleText = brands[categeries[(indexPath as NSIndexPath).section]]?[(indexPath as NSIndexPath).row] ?? ""
        let imageUrl = models[titleText]?[0].imageUrl ?? ""
        cell?.logoView?.kf.setImage(with: URL(string: imageUrl)!, placeholder: defaultImage)
        cell?.titleLabel?.text = titleText

        return cell!
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return categeries[section]
    }

    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return categeries
    }

    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return categeries.index(of: title)!
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let navController = self.navigationController as? CarTableNavigationController
        navController?.menuController!.data = models[(brands[categeries[(indexPath as NSIndexPath).section]]?[(indexPath as NSIndexPath).row]) ?? ""] ?? []
        showSideMenuView()
    }

    @IBAction func didNavigationItemCancel(_ sender: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

}

extension CarTableViewController: ENSideMenuDelegate {
    func sideMenuWillClose() {
        if let index = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: index, animated: true)
        }
    }
}
