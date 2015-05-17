//
//  CarInfoViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/5/16.
//  Copyright (c) 2015年 &#21608;&#25996;&#20339;. All rights reserved.
//

import UIKit

class CarInfoViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, AddCarDelegate {
    
    let TAG_LOGO = 430
    let TAG_LICENSE = 431
    let TAG_NAME = 432
    let TAG_BG = 433
    
    let logos = ["bmw_logo", "benz_logo", "honda_logo_small"]

    @IBOutlet weak var addCarView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var infos: [[String: String]] = []
    var preSelectedIndexPath: NSIndexPath?
    
    var userDefaults = NSUserDefaults.standardUserDefaults()
    
    func onCarAdded(license: String, name: String, brandIndex: Int) {
        infos.append([
            "license": license,
            "name": name,
            "logo": logos[brandIndex]
        ])
        userDefaults.setObject(infos, forKey: "car_info")
        tableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {

        if let infos = userDefaults.arrayForKey("car_info") as? [[String: String]] {
            self.infos = infos;
            tableView.reloadData()
        }
        if infos.count == 0 {
            addCarView.hidden = false
            tableView.hidden = true
        } else {
            addCarView.hidden = true
            tableView.hidden = false
        }
        
        var defaultIndexPath = NSIndexPath(forRow: userDefaults.integerForKey("using_car_info"), inSection: 0);
        tableView.selectRowAtIndexPath(defaultIndexPath, animated: true, scrollPosition: .None)
        tableView(tableView, didSelectRowAtIndexPath: defaultIndexPath)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // - MARK: tableView delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cell = tableView.cellForRowAtIndexPath(indexPath)
        var cellBg = cell?.viewWithTag(TAG_BG) as? UIImageView
        cellBg?.image = UIImage(named: IMAGE_CAR_INFO_AREA_PRESSED)
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        var cell = tableView.cellForRowAtIndexPath(indexPath)
        var cellBg = cell?.viewWithTag(TAG_BG) as? UIImageView
        cellBg?.image = UIImage(named: IMAGE_CAR_INFO_AREA)
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        preSelectedIndexPath = tableView.indexPathForSelectedRow()
        if preSelectedIndexPath != indexPath {
            var alertView = UIAlertController(title: "选取您想改装的车辆", message: nil, preferredStyle: .Alert)
            alertView.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: {(action: UIAlertAction!) in
                if let selectedIndexPath = self.tableView.indexPathForSelectedRow() {
                    self.tableView.deselectRowAtIndexPath(selectedIndexPath, animated: true)
                    self.tableView(tableView, didDeselectRowAtIndexPath: selectedIndexPath)
                }
                if (self.preSelectedIndexPath != nil) {
                    self.tableView.selectRowAtIndexPath(self.preSelectedIndexPath, animated: true, scrollPosition: .None)
                    self.tableView(tableView, didSelectRowAtIndexPath: self.preSelectedIndexPath!)
                }
            }))
            alertView.addAction(UIAlertAction(title: "确认", style: .Default, handler: {(action: UIAlertAction!) in
                if let selectedIndexPath = self.tableView.indexPathForSelectedRow() {
                    NSUserDefaults.standardUserDefaults().setInteger(selectedIndexPath.row, forKey: "using_car_info")
                }
            }))
            presentViewController(alertView, animated: true, completion: nil)
        }
        return indexPath
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infos.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("car_info") as! UITableViewCell
        var clearView = UIView(frame: cell.frame)
        clearView.backgroundColor = UIColor.clearColor()
        cell.selectedBackgroundView = clearView
        
        let info = infos[indexPath.row] as [String: String]
        var carLogo = cell.viewWithTag(TAG_LOGO) as? UIImageView
        var carLicense = cell.viewWithTag(TAG_LICENSE) as? UILabel
        var carName = cell.viewWithTag(TAG_NAME) as? UILabel
        
        carLogo?.image = UIImage(named: info["logo"] ?? "")
        carLicense?.text = info["license"]
        carName?.text = info["name"]
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var addCarViewController = segue.destinationViewController as! AddCarViewController
        addCarViewController.delegate = self
    }

}
