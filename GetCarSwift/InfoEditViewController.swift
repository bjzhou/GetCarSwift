//
//  InfoEditViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/4/16.
//  Copyright (c) 2015年 &#21608;&#25996;&#20339;. All rights reserved.
//

import UIKit

class InfoEditViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let MODE_SEX = 0;
    
    var currentSex = 0


    override func viewDidLoad() {
        super.viewDidLoad()

        initSexView()
    }
    
    func initSexView() {
        currentSex = NSUserDefaults.standardUserDefaults().integerForKey("sex")
        var tableView = UITableView(frame: CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height), style: UITableViewStyle.Grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "sex")
        self.view.addSubview(tableView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("sex", forIndexPath: indexPath) as! UITableViewCell

        if indexPath.row == 0 {
            cell.textLabel?.text = "男"
        } else {
            cell.textLabel?.text = "女"
        }
        
        if indexPath.row == currentSex {
            cell.accessoryView = UIImageView(image: UIImage(named: IAMGE_SELECTED_ACCESSORY))
        } else {
            cell.accessoryView = nil
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        currentSex = indexPath.row
        NSUserDefaults.standardUserDefaults().setInteger(currentSex, forKey: "sex")
        tableView.reloadData()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
