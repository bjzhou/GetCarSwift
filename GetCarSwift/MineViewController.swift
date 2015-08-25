//
//  MineViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/4/11.
//  Copyright (c) 2015年 周斌佳. All rights reserved.
//

import UIKit

class MineViewController: UITableViewController {
    
    var searchApi: AMapSearchAPI!
    
    var district: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let location = ApiHeader.sharedInstance.location {
            searchApi = AMapSearchAPI(searchKey: AMAP_KEY, delegate: self)
            let regeoRequest = AMapReGeocodeSearchRequest()
            regeoRequest.searchType = .ReGeocode
            regeoRequest.location = AMapGeoPoint.locationWithLatitude(CGFloat(location.coordinate.latitude), longitude: CGFloat(location.coordinate.longitude))
            regeoRequest.requireExtension = true
            
            searchApi.AMapReGoecodeSearch(regeoRequest)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tableView.reloadData()
    }

    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView.sectionHeaderHeight
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath) as UITableViewCell
        if indexPath.section == 0 {
            let accountCell = cell as! AccountCell
            accountCell.avatar.layer.masksToBounds = true
            accountCell.avatar.layer.cornerRadius = 8
            accountCell.sexIcon.image = UIImage(named: NSUserDefaults.standardUserDefaults().integerForKey("sex") == 0 ? "mine_female" : "mine_male")
            accountCell.avatar.image = avatarImage()
            accountCell.accountName.text = NSUserDefaults.standardUserDefaults().stringForKey("nickname") ?? "用户名"
            accountCell.accountDescription.text = district ?? "正在获得当前位置"
            return accountCell
        }
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "personInfo" {
            let dest = segue.destinationViewController as! PersonInfoViewController
            dest.district = district
        }
    }

}

extension MineViewController: AMapSearchDelegate {
    func onReGeocodeSearchDone(request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!) {
        let city = response.regeocode.addressComponent.city == "" ? response.regeocode.addressComponent.district : response.regeocode.addressComponent.city
        district = "\(response.regeocode.addressComponent.province)\(city)"
        self.tableView.reloadData()
        print(district)
    }
}
