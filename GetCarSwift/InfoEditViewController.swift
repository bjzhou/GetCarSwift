//
//  InfoEditViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/4/16.
//  Copyright (c) 2015年 周斌佳. All rights reserved.
//

import UIKit

enum InfoEditMode: Int {
    case Sex
    case Nickname
    case Address
    case District
    case Sign
}

class InfoEditViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var mode: InfoEditMode = .Sex
    
    init(mode: InfoEditMode) {
        super.init(nibName: nil, bundle: nil)
        self.mode = mode
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        switch mode {
        case .Sex:
            initSexView()
        case .Nickname:
            break
        case .Address:
            break
        case .District:
            break
        case .Sign:
            break
        }
    }
    
    func initSexView() {
        let tableView = UITableView(frame: CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height), style: UITableViewStyle.Grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "sex")
        self.view.addSubview(tableView)
    }
    
    func initNicknameView() {
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
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("sex", forIndexPath: indexPath) as! UITableViewCell

        if indexPath.row == 0 {
            cell.textLabel?.text = "男"
        } else {
            cell.textLabel?.text = "女"
        }
        
        cell.accessoryView = UIImageView(image: indexPath.row != DataKeeper.sharedInstance.sex ? UIImage(named: IAMGE_ACCESSORY_SELECTED) : UIImage(named: IAMGE_ACCESSORY))
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        DataKeeper.sharedInstance.sex = indexPath.row == 1 ? 0 : 1
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
